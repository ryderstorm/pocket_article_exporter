# frozen_string_literal: true

require 'httparty'
require 'logger'

# Class for interacting with the Pocket API
class PocketAPI
  BASE_API_URI = 'https://getpocket.com/v3'

  attr_reader :request_token, :access_token, :consumer_key, :callback_uri, :article_list

  def initialize
    @logger = Logger.new($stdout)
    @consumer_key = ENV['POCKET_CONSUMER_KEY']
    @callback_uri = ENV['POCKET_REDIRECT_URI']
    verify_envs
  end

  def reset
    @logger.info('Resetting PocketAPI instance')
    @request_token = nil
    @access_token = nil
    @article_list = nil
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
    if response.code == 200
      @access_token = response.parsed_response['access_token']
      true
    else
      @logger.error("Error creating access token: #{response.message}")
      false
    end
  end

  def update_article_list(access_token)
    @logger.info('Retrieving article list from Pocket API')
    options = {
      headers: default_headers,
      body: { consumer_key: @consumer_key, access_token: access_token, detailType: 'complete', state: 'all' }.to_json
    }
    response = HTTParty.post("#{BASE_API_URI}/get", options)
    @logger.info(
      "Article list response:\n\tcode: #{response.code}\n\tmessage: #{response.message}\n\tbody: #{response.body}"
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

  def articles_as_yaml
    raise 'Article list is empty' if @article_list.nil?

    @article_list.to_yaml
  end

  def articles_as_json
    raise 'Article list is empty' if @article_list.nil?

    @article_list.to_json
  end

  def articles_as_csv
    raise 'Article list is empty' if @article_list.nil?

    CSV.generate do |csv|
      csv << %w[url title description tags created]
      @article_list.each do |article|
        csv << article_csv_row(article)
      end
    end
  end

  def article_csv_row(article)
    tags = article['tags']&.keys&.join(',')

    [article['resolved_url'], article['resolved_title'], article['excerpt'], tags.nil? ? '' : tags,
     article['time_added']]
  end
end
