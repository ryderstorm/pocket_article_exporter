require 'httparty'
require 'logger'

# Class for interacting with the Pocket API
class PocketAPI
  BASE_API_URI = 'https://getpocket.com/v3'.freeze

  attr_reader :request_token, :access_token, :consumer_key, :callback_uri, :article_list

  def initialize
    @logger = Logger.new($stdout)
    @consumer_key = ENV['POCKET_CONSUMER_KEY']
    @callback_uri = ENV['POCKET_REDIRECT_URI']
    verify_envs
  end

  def run_auth_flow
    # This method will run the entire Pocket authorization flow in the console
    # and print the access token to the console when complete
    # This method is intended to be used for testing and debugging purposes
    create_request_token
    url = api_auth_url(@request_token)
    puts "\n\nPlease visit the following URL to authorize this app with your Pocket account:\n#{url}"
    puts "Once you have authorized the app, please press enter to continue.\n"
    gets
    create_access_token(@request_token)
    puts "\n\nAuthorization complete! Your access token is: #{@access_token}\n"
  end

  def create_request_token
    @logger.info('Creating request token')
    options = {
      headers: default_headers,
      body: { consumer_key: @consumer_key, redirect_uri: @callback_uri }.to_json
    }
    response = HTTParty.post("#{BASE_API_URI}/oauth/request", options)
    @logger.info(
      "Request token response:\n\tcode: #{response.code}\n\tmessage: #{response.message}\n\tbody: #{response.body}"
    )
    @request_token = response.parsed_response['code']
  end

  def create_access_token(request_token)
    @logger.info('Creating access token')
    options = {
      headers: default_headers,
      body: { consumer_key: @consumer_key, code: request_token }.to_json
    }
    response = HTTParty.post("#{BASE_API_URI}/oauth/authorize", options)
    @logger.info(
      "Access token response:\n\tcode: #{response.code}\n\tmessage: #{response.message}\n\tbody: #{response.body}"
    )
    @access_token = response.parsed_response['access_token']
  end

  def update_article_list(access_token)
    @logger.info('Retrieving article list from Pocket API')
    options = {
      headers: default_headers,
      body: { consumer_key: @consumer_key, access_token: access_token, detailType: 'complete' }.to_json
    }
    response = HTTParty.post("#{BASE_API_URI}/get", options)
    @logger.info(
      "Article list response:\n\tcode: #{response.code}\n\tmessage: #{response.message}\n\tBody omitted for brevity."
    )
    @article_list = response.parsed_response['list'].map { |_id, article| article }
  end

  def api_auth_url(request_token)
    "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{@callback_uri}"
  end

  def verify_envs
    raise 'POCKET_CONSUMER_KEY is not set' if ENV['POCKET_CONSUMER_KEY'].nil?
    raise 'POCKET_REDIRECT_URI is not set' if ENV['POCKET_REDIRECT_URI'].nil?
  end

  def default_headers
    {
      "Content-Type": 'application/json; charset=UTF8',
      "X-Accept": 'application/json'
    }
  end
end
