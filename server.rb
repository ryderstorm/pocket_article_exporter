require 'sinatra/base'
require 'net/http'

class PocketServer < Sinatra::Base
  # Replace YOUR_CONSUMER_KEY with your Pocket API consumer key
  CONSUMER_KEY = ''

  # Replace YOUR_REDIRECT_URI with your registered redirect URI
  REDIRECT_URI = ''
  get '/auth' do
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
    access_token = access_token_response.body.split('=')[1]

    # Return the access token to the user
    "Access Token: #{access_token}"
  end

  # Run the server on port 8999
  set :port, 8999
  set :bind, '0.0.0.0'
  run! if app_file == $0
end
