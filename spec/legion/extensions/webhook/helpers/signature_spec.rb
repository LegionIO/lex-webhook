# frozen_string_literal: true

require 'spec_helper'
require 'legion/extensions/webhook/helpers/signature'

RSpec.describe Legion::Extensions::Webhook::Helpers::Signature do
  let(:secret)  { 'test-secret' }
  let(:payload) { '{"action":"push"}' }

  describe '.compute' do
    it 'returns a hex string' do
      result = described_class.compute(secret: secret, payload: payload)
      expect(result).to match(/\A[0-9a-f]+\z/)
    end

    it 'returns consistent output for the same inputs' do
      r1 = described_class.compute(secret: secret, payload: payload)
      r2 = described_class.compute(secret: secret, payload: payload)
      expect(r1).to eq(r2)
    end

    it 'returns different output for different secrets' do
      r1 = described_class.compute(secret: 'secret-a', payload: payload)
      r2 = described_class.compute(secret: 'secret-b', payload: payload)
      expect(r1).not_to eq(r2)
    end

    it 'returns different output for different payloads' do
      r1 = described_class.compute(secret: secret, payload: 'payload-a')
      r2 = described_class.compute(secret: secret, payload: 'payload-b')
      expect(r1).not_to eq(r2)
    end

    it 'supports sha1 algorithm' do
      result = described_class.compute(secret: secret, payload: payload, algorithm: 'sha1')
      expect(result).to match(/\A[0-9a-f]+\z/)
    end

    it 'supports sha512 algorithm' do
      result = described_class.compute(secret: secret, payload: payload, algorithm: 'sha512')
      expect(result).to match(/\A[0-9a-f]+\z/)
    end
  end

  describe '.verify' do
    let(:signature) { described_class.compute(secret: secret, payload: payload) }

    it 'returns true for a valid bare signature' do
      expect(described_class.verify(secret: secret, signature: signature, payload: payload)).to be(true)
    end

    it 'returns true for a prefixed signature (sha256=...)' do
      prefixed = "sha256=#{signature}"
      expect(described_class.verify(secret: secret, signature: prefixed, payload: payload)).to be(true)
    end

    it 'returns false for an invalid signature' do
      expect(described_class.verify(secret: secret, signature: 'badhex', payload: payload)).to be(false)
    end

    it 'returns false when secret is wrong' do
      other_sig = described_class.compute(secret: 'wrong-secret', payload: payload)
      expect(described_class.verify(secret: secret, signature: other_sig, payload: payload)).to be(false)
    end

    it 'returns false when payload is tampered' do
      expect(described_class.verify(secret: secret, signature: signature, payload: 'tampered')).to be(false)
    end

    it 'supports sha1 algorithm with matching signature' do
      sha1_sig = described_class.compute(secret: secret, payload: payload, algorithm: 'sha1')
      expect(described_class.verify(secret: secret, signature: sha1_sig, payload: payload, algorithm: 'sha1')).to be(true)
    end
  end

  describe '.bytes_match?' do
    it 'returns true for equal strings' do
      expect(described_class.bytes_match?('abcdef', 'abcdef')).to be(true)
    end

    it 'returns false for different strings of same length' do
      expect(described_class.bytes_match?('abcdef', 'abcxyz')).to be(false)
    end

    it 'returns false for different length strings' do
      expect(described_class.bytes_match?('abc', 'abcd')).to be(false)
    end

    it 'returns false when lhs is nil' do
      expect(described_class.bytes_match?(nil, 'abc')).to be(false)
    end

    it 'returns false when rhs is nil' do
      expect(described_class.bytes_match?('abc', nil)).to be(false)
    end

    it 'strips sha256= prefix before comparing' do
      expect(described_class.bytes_match?('sha256=abc', 'abc')).to be(true)
    end

    it 'strips prefix from both sides' do
      expect(described_class.bytes_match?('sha256=abc', 'sha256=abc')).to be(true)
    end
  end
end
