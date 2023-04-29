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
    log_level = ENV['LOG_LEVEL'] || 'info'
    set :logger, Logger.new($stdout, log_level)
    # Set the port and bind address for the web server
    set :port, 8999
    set :bind, '0.0.0.0'
    # Set the views directory to 'views/' relative to the current directory
    set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')
    set :views, File.join(File.dirname(__FILE__), '..', 'views')

    # Instantiate the PocketAPI class
    set :pocket_api, PocketAPI.new
    # Enable sessions so that we can store data between requests
    enable :sessions
  end

  before do
    logger.debug "#{request.request_method} #{request.url}"
    logger.debug "Params: #{params}"
    logger.debug "Session keys: #{session.keys}"
  end

  get '/' do
    erb :index, locals: {
      access_token: session[:access_token],
      article_list: settings.pocket_api.article_list
    }
  end

  post '/clear_session' do
    logger.debug 'Clearing session'
    session.clear
    settings.pocket_api.reset
    redirect '/'
  end

  post '/authorize' do
    # Create a request token
    unless settings.pocket_api.create_request_token
      return erb :error, locals: { error_message: 'Failed to create request token. See logs for details.' }
    end

    session[:request_token] = settings.pocket_api.request_token

    # Redirect the user to the Pocket authorization page
    redirect_url = settings.pocket_api.api_auth_url(settings.pocket_api.request_token)
    logger.debug "Redirecting to: #{redirect_url}"
    redirect redirect_url
  end

  get '/callback' do
    if session[:request_token].nil?
      return erb :error,
                 locals: { error_message: 'Cannot create access token without request token. Please authorize first.' }
    end

    # Exchange the request token for an access token
    unless settings.pocket_api.create_access_token(session[:request_token])
      return erb :error, locals: { error_message: 'Failed to create access token. See logs for details.' }
    end

    session[:access_token] = settings.pocket_api.access_token

    # Redirect the user to the success page
    redirect '/auth_success'
  end

  get '/auth_success' do
    if session[:access_token].nil?
      return erb :error, locals: { error_message: 'No access token found in session. User must authorize first.' }
    end

    redirect '/'
  end

  post '/manual_auth' do
    # set the access token from the form
    session[:access_token] = params[:access_token]
    redirect '/'
  end

  get '/article_list' do
    # Serve the article list from the session if it exists
    unless settings.pocket_api.article_list.nil?
      logger.debug 'Serving article list from session'
      return erb :articles, locals: { article_list: settings.pocket_api.article_list }
    end

    # Retrieve the article list from the Pocket API
    if session[:access_token].nil?
      return erb :error, locals: { error_message: 'No access token found in session. User must authorize first.' }
    end

    unless settings.pocket_api.update_article_list(session[:access_token])
      return erb :error, locals: { error_message: 'Failed to retrieve article list. See logs for details.' }
    end

    redirect '/'
  end

  get '/download_article_list' do
    if settings.pocket_api.article_list.nil?
      return erb :error,
                 locals: { error_message: 'No article list found in session. Please retrieve your article list first.' }
    end

    # Serve the article list
    FileUtils.mkdir_p('downloads')
    file_format = params[:format]
    unless %w[json yaml csv].include?(file_format)
      return erb :error, locals: { error_message: "Invalid value for 'format' parameter: #{params[:format]}" }
    end

    content = article_list_content(file_format)
    filename = "#{filename_prefix}.#{file_format}"
    File.write("#{filename_prefix}.#{file_format}", content)
    send_file(filename, filename: filename, type: 'Application/octet-stream')
    redirect '/'
  end

  def filename_prefix
    "pocket_article_list_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  end

  def article_list_content(file_format)
    case file_format
    when 'json'
      settings.pocket_api.articles_as_json
    when 'yaml'
      settings.pocket_api.articles_as_yaml
    when 'csv'
      settings.pocket_api.articles_as_csv
    end
  end
end
