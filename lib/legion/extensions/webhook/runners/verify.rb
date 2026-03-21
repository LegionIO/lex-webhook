# frozen_string_literal: true

require 'legion/extensions/webhook/helpers/signature'

module Legion
  module Extensions
    module Webhook
      module Runners
        module Verify
          def verify(secret:, signature:, payload:, algorithm: 'sha256', **)
            valid = Helpers::Signature.verify(
              secret:    secret,
              signature: signature,
              payload:   payload,
              algorithm: algorithm
            )
            { valid: valid, algorithm: algorithm }
          end

          def compute_signature(secret:, payload:, algorithm: 'sha256', **)
            sig = Helpers::Signature.compute(secret: secret, payload: payload, algorithm: algorithm)
            { signature: sig }
          end
        end
      end
    end
  end
end
