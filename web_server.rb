require 'sinatra/base'
require 'logger'

# Server class for handling the Pocket authorization flow
# depends on the PocketAPI class from pocket_api.rb
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
    # Enable sessions so that we can store data between requests
    enable :sessions
  end

  before do
    logger.info "#{request.request_method} #{request.url}"
    logger.info "Params: #{params}"
    @pocket_api = PocketAPI.new
  end

  get '/' do
    # Serve a simple web form for the user to authorize with the Pocket API
    erb :index
  end

  post '/authorize' do
    # Create a request token
    @pocket_api.create_request_token
    session[:request_token] = @pocket_api.request_token

    # Redirect the user to the Pocket authorization page
    redirect_url = @pocket_api.api_auth_url(@pocket_api.request_token)
    logger.info "Redirecting to: #{redirect_url}"
    redirect(redirect_url)
  end

  get '/callback' do
    if session[:request_token].nil?
      logger.info 'No request token found in session'
      return "Cannot create access token without a request token. Please <a href='/'>authorize</a> first."
    end

    # Exchange the request token for an access token
    @pocket_api.create_access_token(session[:request_token])
    session[:access_token] = @pocket_api.access_token

    # Display the access token to the user
    erb :success, locals: { access_token: @pocket_api.access_token }
  end

  get '/article_list' do
    if session[:access_token].nil?
      logger.info 'No access token found in session'
      return "Cannot retrieve articles without an access token. Please <a href='/'>authorize</a> first."
    end

    article_list = @pocket_api.update_article_list(session[:access_token])

    # Render the article list as HTML
    erb :articles, locals: { article_list: article_list }
  end
end
