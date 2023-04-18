# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', 'pocket_api.rb')
require 'pry'
require 'spec_helper'
require 'webmock/rspec'

RSpec.describe PocketAPI do
  let(:api) { PocketAPI.new }
  let(:consumer_key) { ENV['POCKET_CONSUMER_KEY'] }
  let(:redirect_uri) { ENV['POCKET_REDIRECT_URI'] }
  let(:base_api_uri) { 'https://getpocket.com/v3' }
  let(:article_list) do
    [
      {
        'resolved_url' => 'http://example.com',
        'resolved_title' => 'Test Article',
        'excerpt' => 'This is a test article.',
        'tags' => { 'ruby' => {} },
        'time_added' => '1234567890'
      },
      {
        'resolved_url' => 'http://blah.com',
        'resolved_title' => 'Test All the Things!',
        'excerpt' => 'Moar testing!',
        'tags' => { 'test' => {}, 'pocket' => {} },
        'time_added' => '1234567890'
      }
    ]
  end

  describe '#initialize' do
    it 'sets the consumer key and callback URI' do
      expect(api.consumer_key).to eq(consumer_key)
      expect(api.callback_uri).to eq(redirect_uri)
    end
  end

  describe '#reset' do
    it 'resets the request token, access token, and article list' do
      api.instance_variable_set(:@request_token, 'test-request-token')
      api.instance_variable_set(:@access_token, 'test-access-token')
      api.instance_variable_set(:@article_list, [{ title: 'Test Article' }])
      api.reset
      expect(api.request_token).to be_nil
      expect(api.access_token).to be_nil
      expect(api.article_list).to be_nil
    end
  end

  describe '#create_request_token' do
    before(:each) do
      stub_request(:post, "#{base_api_uri}/oauth/request")
        .with(
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: { consumer_key: consumer_key,
                  redirect_uri: redirect_uri }.to_json
        )
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: { code: 'test-request-token' }.to_json
        )
    end

    it 'creates a request token' do
      api.create_request_token
      expect(api.request_token).to eq('test-request-token')
    end
  end

  describe '#create_access_token' do
    before(:each) do
      api.instance_variable_set(:@request_token, 'test-request-token')
      stub_request(:post, "#{base_api_uri}/oauth/authorize")
        .with(
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: { consumer_key: consumer_key, code: 'test-request-token' }.to_json
        )
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: { access_token: 'test-access-token' }.to_json
        )
    end

    it 'creates an access token' do
      api.create_access_token('test-request-token')
      expect(api.access_token).to eq('test-access-token')
    end

    it 'returns true if the access token is created successfully' do
      expect(api.create_access_token('test-request-token')).to be_truthy
    end

    it 'returns false if the access token creation fails' do
      stub_request(:post, "#{base_api_uri}/oauth/authorize")
        .to_return(status: 400, body: { error: 'invalid_request' }.to_json)
      expect(api.create_access_token('test-request-token')).to be_falsey
    end
  end

  describe '#update_article_list' do
    before(:each) do
      api.instance_variable_set(:@access_token, 'test-access-token')
      # binding.pry
      stub_request(:post, "#{base_api_uri}/get")
        .with(
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: { consumer_key: consumer_key, access_token: 'test-access-token', detailType: 'complete',
                  state: 'all' }.to_json
        )
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json; charset=UTF8', 'X-Accept' => 'application/json' },
          body: {
            list: {
              '123' => {
                title: 'Test Article', tags: { 'ruby' => {} },
                time_added: '1234567890'
              }
            }
          }.to_json
        )
    end

    it 'updates the article list' do
      api.update_article_list('test-access-token')
      expect(api.article_list).to eq(
        [{ 'title' => 'Test Article', 'tags' => { 'ruby' => {} },
           'time_added' => '1234567890' }]
      )
    end
  end

  describe '#api_auth_url' do
    it 'returns the Pocket API authorization URL' do
      api.instance_variable_set(:@request_token, 'test-request-token')
      expect(api.api_auth_url('test-request-token')).to eq("https://getpocket.com/auth/authorize?request_token=test-request-token&redirect_uri=#{redirect_uri}")
    end
  end

  describe '#articles_as_yaml' do
    it 'raises an error if the article list is empty' do
      expect { api.articles_as_yaml }.to raise_error('Article list is empty')
    end

    it 'returns the article list as YAML' do
      api.instance_variable_set(:@article_list, [{ title: 'Test Article' }])
      expect(api.articles_as_yaml).to eq("---\n- :title: Test Article\n")
    end
  end

  describe '#articles_as_json' do
    it 'raises an error if the article list is empty' do
      expect { api.articles_as_json }.to raise_error('Article list is empty')
    end

    it 'returns the article list as JSON' do
      api.instance_variable_set(:@article_list, [{ title: 'Test Article' }])
      expect(api.articles_as_json).to eq('[{"title":"Test Article"}]')
    end
  end

  describe '#articles_as_csv' do
    context 'when article list is empty' do
      it 'raises an error' do
        api.instance_variable_set(:@article_list, nil)
        expect { api.articles_as_csv }.to raise_error('Article list is empty')
      end
    end

    context 'when article list is not empty' do
      it 'returns a CSV string with the correct headers and data' do
        api.instance_variable_set(:@article_list, article_list)

        expected_csv = CSV.generate do |csv|
          csv << %w[url title description tags created]
          article_list.each do |article|
            csv << api.article_csv_row(article)
          end
        end

        expect(api.articles_as_csv).to eq(expected_csv)
      end
    end
  end

  describe '#article_csv_row' do
    let(:article_with_multiple_tags) do
      {
        'resolved_url' => 'https://example.com/article1',
        'resolved_title' => 'Article 1',
        'excerpt' => 'This is article 1',
        'tags' => { 'tag1' => {}, 'tag2' => {} },
        'time_added' => '1618592800'
      }
    end

    let(:article_with_single_tag) do
      {
        'resolved_url' => 'https://example.com/article1',
        'resolved_title' => 'Article 1',
        'excerpt' => 'This is article 1',
        'tags' => { 'singleTag' => {} },
        'time_added' => '1618592800'
      }
    end

    let(:article_without_tags) do
      {
        'resolved_url' => 'https://example.com/article1',
        'resolved_title' => 'Article 1',
        'excerpt' => 'This is article 1',
        'time_added' => '1618592800'
      }
    end

    it 'returns an array with the correct data for an article with multiple tags' do
      expected_array = [
        'https://example.com/article1',
        'Article 1',
        'This is article 1',
        'tag1,tag2',
        '1618592800'
      ]

      expect(api.article_csv_row(article_with_multiple_tags)).to eq(expected_array)
    end

    it 'returns an array with the correct data for an article with a single tag' do
      expected_array = [
        'https://example.com/article1',
        'Article 1',
        'This is article 1',
        'singleTag',
        '1618592800'
      ]

      expect(api.article_csv_row(article_with_single_tag)).to eq(expected_array)
    end

    it 'returns an array with the correct data for an article without tags' do
      expected_array = [
        'https://example.com/article1',
        'Article 1',
        'This is article 1',
        '',
        '1618592800'
      ]

      expect(api.article_csv_row(article_without_tags)).to eq(expected_array)
    end
  end
end
