require 'sinatra/base'
require 'net/http'
require 'logger'

class PocketServer < Sinatra::Base
  CONSUMER_KEY = ENV['POCKET_CONSUMER_KEY']
  REDIRECT_URI = ENV['POCKET_REDIRECT_URI']

  configure do
    # Configure the logger to log to STDOUT
    enable :logging
    set :logger, Logger.new(STDOUT)
  end

  before do
    logger.info "#{request.request_method} #{request.url}"
    logger.info "Params: #{params}"
  end

  # Set the views directory to 'views/' relative to the current directory
  set :public_folder, File.dirname(__FILE__)
  set :views, File.dirname(__FILE__)

  get '/' do
    # Serve a simple web form for the user to authorize with the Pocket API
    erb :index
  end

  post '/authorize' do
    # Retrieve the request token from the Pocket API
    request_token_response = Net::HTTP.post_form(URI('https://getpocket.com/v3/oauth/request'), {
                                                   'consumer_key' => CONSUMER_KEY,
                                                   'redirect_uri' => REDIRECT_URI
                                                 })
    request_token = request_token_response.body.split('=')[1]

    # Redirect the user to the Pocket authorization page
    redirect("https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{REDIRECT_URI}")
  end

  get '/callback' do
    # Retrieve the authorized code from the query parameters
    authorized_code = params[:code]

    # Exchange the authorized code for an access token
    access_token_response = Net::HTTP.post_form(URI('https://getpocket.com/v3/oauth/authorize'), {
                                                  'consumer_key' => CONSUMER_KEY,
                                                  'code' => authorized_code
                                                })
    logger.info "Access token response: #{access_token_response.body}"
    access_token = access_token_response.body.split('=')[1]

    # Display the access token to the user
    erb :success, locals: { access_token: access_token }
  end

  # Run the server on port 8999 and bind to all interfaces
  set :port, 8999
  set :bind, '0.0.0.0'
  run! if app_file == $0
end
