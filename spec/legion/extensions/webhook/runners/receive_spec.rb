# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/webhook/runners/receive'

RSpec.describe Legion::Extensions::Webhook::Runners::Receive do
  subject(:runner) do
    Class.new { include Legion::Extensions::Webhook::Runners::Receive }.new
  end

  let(:secret)  { 'my-secret' }
  let(:payload) { '{"action":"push"}' }

  def sign(secret, payload)
    require 'openssl'
    OpenSSL::HMAC.hexdigest('sha256', secret, payload)
  end

  describe '#receive' do
    context 'without a secret' do
      it 'returns received true' do
        result = runner.receive(path: '/hooks/test', body: payload)
        expect(result[:received]).to be(true)
      end

      it 'returns the path' do
        result = runner.receive(path: '/hooks/test', body: payload)
        expect(result[:path]).to eq('/hooks/test')
      end

      it 'returns verified false when no secret given' do
        result = runner.receive(path: '/hooks/test', body: payload)
        expect(result[:verified]).to be(false)
      end

      it 'returns the raw body as payload when no content-type header' do
        result = runner.receive(path: '/hooks/test', headers: {}, body: payload)
        expect(result[:payload]).to eq(payload)
      end
    end

    context 'with JSON content-type' do
      let(:headers) { { 'content-type' => 'application/json' } }

      it 'parses the body as JSON with symbol keys' do
        result = runner.receive(path: '/hooks/test', headers: headers, body: payload)
        expect(result[:payload]).to eq({ action: 'push' })
      end

      it 'falls back to raw body on invalid JSON' do
        result = runner.receive(path: '/hooks/test', headers: headers, body: 'not-json')
        expect(result[:payload]).to eq('not-json')
      end
    end

    context 'with HMAC signature verification' do
      let(:signature) { sign(secret, payload) }
      let(:headers) do
        { 'content-type' => 'application/json', 'x-hub-signature-256' => "sha256=#{signature}" }
      end

      it 'returns verified true with correct signature' do
        result = runner.receive(path: '/hooks/github', headers: headers, body: payload, secret: secret)
        expect(result[:verified]).to be(true)
      end

      it 'returns verified false with wrong signature' do
        bad_headers = headers.merge('x-hub-signature-256' => 'sha256=badhex00' * 4)
        result = runner.receive(path: '/hooks/github', headers: bad_headers, body: payload, secret: secret)
        expect(result[:verified]).to be(false)
      end

      it 'returns verified false when signature header is missing' do
        result = runner.receive(path: '/hooks/github', headers: { 'content-type' => 'application/json' },
                                body: payload, secret: secret)
        expect(result[:verified]).to be(false)
      end
    end

    context 'with x-signature header' do
      let(:signature) { sign(secret, payload) }
      let(:headers)   { { 'x-signature' => signature } }

      it 'detects x-signature header' do
        result = runner.receive(path: '/hooks/test', headers: headers, body: payload, secret: secret)
        expect(result[:verified]).to be(true)
      end
    end

    context 'with x-webhook-signature header' do
      let(:signature) { sign(secret, payload) }
      let(:headers)   { { 'x-webhook-signature' => signature } }

      it 'detects x-webhook-signature header' do
        result = runner.receive(path: '/hooks/test', headers: headers, body: payload, secret: secret)
        expect(result[:verified]).to be(true)
      end
    end

    context 'with default method' do
      it 'defaults method to POST' do
        result = runner.receive(path: '/hooks/test', body: '')
        expect(result[:method]).to eq('POST')
      end
    end

    context 'with empty body' do
      it 'returns empty string as payload' do
        result = runner.receive(path: '/hooks/test', headers: {}, body: '')
        expect(result[:payload]).to eq('')
      end
    end

    context 'with nil body' do
      it 'returns nil as payload' do
        result = runner.receive(path: '/hooks/test', headers: {}, body: nil)
        expect(result[:payload]).to be_nil
      end
    end
  end
end
