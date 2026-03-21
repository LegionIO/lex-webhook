# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/webhook/runners/endpoints'

RSpec.describe Legion::Extensions::Webhook::Runners::Endpoints do
  subject(:runner) do
    Class.new { include Legion::Extensions::Webhook::Runners::Endpoints }.new
  end

  before { runner.send(:endpoint_registry).clear }

  describe '#list_endpoints' do
    it 'returns an empty array when no endpoints are registered' do
      result = runner.list_endpoints
      expect(result[:endpoints]).to eq([])
    end

    it 'returns a copy of the registry' do
      runner.register_endpoint(path: '/hooks/test')
      result = runner.list_endpoints
      expect(result[:endpoints].size).to eq(1)
    end
  end

  describe '#register_endpoint' do
    it 'registers a new endpoint and returns registered true' do
      result = runner.register_endpoint(path: '/hooks/github')
      expect(result[:registered]).to be(true)
      expect(result[:path]).to eq('/hooks/github')
    end

    it 'stores the path in the registry' do
      runner.register_endpoint(path: '/hooks/github')
      endpoints = runner.list_endpoints[:endpoints]
      expect(endpoints.map { |e| e[:path] }).to include('/hooks/github')
    end

    it 'stores the secret when provided' do
      runner.register_endpoint(path: '/hooks/github', secret: 'mysecret')
      entry = runner.list_endpoints[:endpoints].first
      expect(entry[:secret]).to eq('mysecret')
    end

    it 'stores the description when provided' do
      runner.register_endpoint(path: '/hooks/github', description: 'GitHub push events')
      entry = runner.list_endpoints[:endpoints].first
      expect(entry[:description]).to eq('GitHub push events')
    end

    it 'omits nil fields from the stored entry' do
      runner.register_endpoint(path: '/hooks/minimal')
      entry = runner.list_endpoints[:endpoints].first
      expect(entry.key?(:secret)).to be(false)
      expect(entry.key?(:description)).to be(false)
    end

    it 'updates an existing endpoint and returns registered false, updated true' do
      runner.register_endpoint(path: '/hooks/github', secret: 'old')
      result = runner.register_endpoint(path: '/hooks/github', secret: 'new')
      expect(result[:registered]).to be(false)
      expect(result[:updated]).to be(true)
    end

    it 'does not duplicate an existing endpoint on update' do
      runner.register_endpoint(path: '/hooks/github')
      runner.register_endpoint(path: '/hooks/github')
      expect(runner.list_endpoints[:endpoints].size).to eq(1)
    end

    it 'updates the secret on an existing endpoint' do
      runner.register_endpoint(path: '/hooks/github', secret: 'old')
      runner.register_endpoint(path: '/hooks/github', secret: 'new')
      entry = runner.list_endpoints[:endpoints].first
      expect(entry[:secret]).to eq('new')
    end

    it 'accepts extra kwargs without error' do
      expect { runner.register_endpoint(path: '/hooks/test', extra: 'ignored') }.not_to raise_error
    end
  end

  describe '#remove_endpoint' do
    before { runner.register_endpoint(path: '/hooks/github') }

    it 'removes an existing endpoint and returns removed true' do
      result = runner.remove_endpoint(path: '/hooks/github')
      expect(result[:removed]).to be(true)
      expect(result[:path]).to eq('/hooks/github')
    end

    it 'actually removes the endpoint from the registry' do
      runner.remove_endpoint(path: '/hooks/github')
      expect(runner.list_endpoints[:endpoints]).to be_empty
    end

    it 'returns removed false when the endpoint does not exist' do
      result = runner.remove_endpoint(path: '/hooks/nonexistent')
      expect(result[:removed]).to be(false)
    end

    it 'only removes the matching endpoint' do
      runner.register_endpoint(path: '/hooks/other')
      runner.remove_endpoint(path: '/hooks/github')
      paths = runner.list_endpoints[:endpoints].map { |e| e[:path] }
      expect(paths).to eq(['/hooks/other'])
    end

    it 'accepts extra kwargs without error' do
      expect { runner.remove_endpoint(path: '/hooks/github', meta: 'ignored') }.not_to raise_error
    end
  end
end
