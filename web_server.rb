# frozen_string_literal: true

require 'sinatra/base'
require 'logger'

# Server class for handling the Pocket authorization flow
# depends on the PocketAPI class from settings.pocket_api.rb
class PocketServer < Sinatra::Base
  CONSUMER_KEY = ENV['POCKET_CONSUMER_KEY']
  REDIRECT_URI = ENV['POCKET_REDIRECT_URI']

  configure do
    # Configure the logger to log to STDOUT
    enable :logging
    set :logger, Logger.new($stdout)
    # Set the port and bind address for the web server
    set :port, 8999
    set :bind, '0.0.0.0'
    # Set the views directory to 'views/' relative to the current directory
    set :public_folder, File.dirname(__FILE__)
    set :views, File.dirname(__FILE__)

    # Instantiate the PocketAPI class
    set :pocket_api, PocketAPI.new
    # Enable sessions so that we can store data between requests
    enable :sessions
  end

  before do
    logger.info "#{request.request_method} #{request.url}"
    logger.info "Params: #{params}"
    logger.info "Session keys: #{session.keys}"
  end

  get '/' do
    haml :index, locals: { access_token: session[:access_token] }
  end

  post '/clear_session' do
    logger.info 'Clearing session'
    session.clear
    settings.pocket_api.reset
    redirect '/'
  end

  post '/authorize' do
    # Create a request token
    unless settings.pocket_api.create_request_token
      error_message = 'Failed to create request token. See logs for details.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    session[:request_token] = settings.pocket_api.request_token

    # Redirect the user to the Pocket authorization page
    redirect_url = settings.pocket_api.api_auth_url(settings.pocket_api.request_token)
    logger.info "Redirecting to: #{redirect_url}"
    redirect redirect_url
  end

  get '/callback' do
    if session[:request_token].nil?
      error_message = 'Cannot create access token without a request token. Please authorize first.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    # Exchange the request token for an access token
    unless settings.pocket_api.create_access_token(session[:request_token])
      error_message = 'Failed to create access token. See logs for details.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    session[:access_token] = settings.pocket_api.access_token

    # Redirect the user to the success page
    redirect '/auth_success'
  end

  get '/auth_success' do
    if session[:access_token].nil?
      error_message = 'No access token found in session. User must authorize first.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    # Display the access token to the user
    erb :success, locals: { access_token: session[:access_token] }
  end

  get '/article_list' do
    # Serve the article list from the session if it exists
    unless settings.pocket_api.article_list.nil?
      logger.info 'Serving article list from session'
      return erb :articles, locals: { article_list: settings.pocket_api.article_list }
    end

    # Retrieve the article list from the Pocket API
    if session[:access_token].nil?
      error_message = 'No access token found in session. User must authorize first.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    unless settings.pocket_api.update_article_list(session[:access_token])
      error_message = 'Failed to retrieve article list. See logs for details.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    # Render the article list as HTML
    erb :articles, locals: { article_list: settings.pocket_api.article_list }
  end

  get '/download_article_list' do
    if settings.pocket_api.article_list.nil?
      error_message = 'No article list found in session. Please retrieve your article list first.'
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end

    # Serve the article list
    FileUtils.mkdir_p('downloads')
    case params[:format]
    when 'json'
      filename = "downloads/pocket_article_list_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json"
      content = settings.pocket_api.articles_as_json
      File.write(filename, content)
    when 'yaml'
      filename = "downloads/pocket_article_list_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yaml"
      content = settings.pocket_api.articles_as_yaml
      File.write(filename, content)
    when 'csv'
      filename = "downloads/pocket_article_list_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
      content = settings.pocket_api.articles_as_csv
      File.write(filename, content)
    else
      error_message = "Invalid value for 'format' parameter: #{params[:format]}"
      logger.error error_message
      return erb :error, locals: { error_message: error_message }
    end
    send_file(filename, filename: filename, type: 'Application/octet-stream')
  end
end
