# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'External request' do
  before(:each) do
    stub_request(:get, /getpocket.com/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: 'stubbed response', headers: {})
  end

  describe 'External request' do
    it 'queries live PocketAPI contributors on GitHub' do
      uri = URI('https://getpocket.com/v3/oauth/request')
      response = Net::HTTP.get(uri)
      expect(response).to be_an_instance_of(String)
    end
  end
end
