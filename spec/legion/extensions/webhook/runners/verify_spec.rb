# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/webhook/runners/verify'

RSpec.describe Legion::Extensions::Webhook::Runners::Verify do
  subject(:runner) do
    Class.new { include Legion::Extensions::Webhook::Runners::Verify }.new
  end

  let(:secret)  { 'verify-secret' }
  let(:payload) { 'hello world' }

  def sign(secret, payload, algorithm = 'sha256')
    require 'openssl'
    OpenSSL::HMAC.hexdigest(algorithm, secret, payload)
  end

  describe '#verify' do
    it 'returns valid true for a correct signature' do
      sig    = sign(secret, payload)
      result = runner.verify(secret: secret, signature: sig, payload: payload)
      expect(result[:valid]).to be(true)
    end

    it 'returns valid false for a wrong signature' do
      result = runner.verify(secret: secret, signature: 'wrong', payload: payload)
      expect(result[:valid]).to be(false)
    end

    it 'returns the algorithm in the result' do
      sig    = sign(secret, payload)
      result = runner.verify(secret: secret, signature: sig, payload: payload)
      expect(result[:algorithm]).to eq('sha256')
    end

    it 'supports sha1 algorithm' do
      sig    = sign(secret, payload, 'sha1')
      result = runner.verify(secret: secret, signature: sig, payload: payload, algorithm: 'sha1')
      expect(result[:valid]).to be(true)
      expect(result[:algorithm]).to eq('sha1')
    end

    it 'accepts extra kwargs without error' do
      sig    = sign(secret, payload)
      result = runner.verify(secret: secret, signature: sig, payload: payload, extra_key: 'ignored')
      expect(result[:valid]).to be(true)
    end
  end

  describe '#compute_signature' do
    it 'returns a hex signature string' do
      result = runner.compute_signature(secret: secret, payload: payload)
      expect(result[:signature]).to match(/\A[0-9a-f]+\z/)
    end

    it 'matches OpenSSL directly' do
      expected = sign(secret, payload)
      result   = runner.compute_signature(secret: secret, payload: payload)
      expect(result[:signature]).to eq(expected)
    end

    it 'supports sha512 algorithm' do
      expected = sign(secret, payload, 'sha512')
      result   = runner.compute_signature(secret: secret, payload: payload, algorithm: 'sha512')
      expect(result[:signature]).to eq(expected)
    end

    it 'accepts extra kwargs without error' do
      result = runner.compute_signature(secret: secret, payload: payload, meta: 'ignored')
      expect(result[:signature]).to be_a(String)
    end
  end
end
