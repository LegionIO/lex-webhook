# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/webhook/client'

RSpec.describe Legion::Extensions::Webhook::Client do
  subject(:client) { described_class.new }

  it 'includes Runners::Receive' do
    expect(client).to respond_to(:receive)
  end

  it 'includes Runners::Verify' do
    expect(client).to respond_to(:verify)
    expect(client).to respond_to(:compute_signature)
  end

  it 'includes Runners::Endpoints' do
    expect(client).to respond_to(:list_endpoints)
    expect(client).to respond_to(:register_endpoint)
    expect(client).to respond_to(:remove_endpoint)
  end

  it 'accepts kwargs in constructor' do
    c = described_class.new(timeout: 10)
    expect(c).to be_a(described_class)
  end
end
