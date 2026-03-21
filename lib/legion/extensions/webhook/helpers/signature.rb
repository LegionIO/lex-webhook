# frozen_string_literal: true

require 'openssl'

module Legion
  module Extensions
    module Webhook
      module Helpers
        module Signature
          module_function

          def verify(secret:, signature:, payload:, algorithm: 'sha256') # rubocop:disable Naming/PredicateMethod
            computed = compute(secret: secret, payload: payload, algorithm: algorithm)
            bytes_match?(computed, signature)
          end

          def compute(secret:, payload:, algorithm: 'sha256')
            OpenSSL::HMAC.hexdigest(algorithm, secret, payload)
          end

          def bytes_match?(lhs, rhs)
            return false if lhs.nil? || rhs.nil?

            lhs_clean = lhs.sub(/\A\w+=/, '')
            rhs_clean = rhs.sub(/\A\w+=/, '')
            return false if lhs_clean.bytesize != rhs_clean.bytesize

            lhs_clean.bytes.zip(rhs_clean.bytes).reduce(0) { |acc, (x, y)| acc | (x ^ y) }.zero?
          end
        end
      end
    end
  end
end
