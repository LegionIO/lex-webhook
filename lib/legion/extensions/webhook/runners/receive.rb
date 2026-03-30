# frozen_string_literal: true

require 'legion/json'
require 'legion/extensions/webhook/helpers/signature'

module Legion
  module Extensions
    module Webhook
      module Runners
        module Receive
          def receive(path:, **opts)
            headers = opts.fetch(:headers, {})
            body    = opts.fetch(:body, '')
            method  = opts.fetch(:method, 'POST')
            secret  = opts[:secret]

            verified = verify_signature(headers: headers, body: body, secret: secret)
            payload  = parse_body(headers: headers, body: body)

            { received: true, path: path, method: method, payload: payload, verified: verified }
          end

          private

          def verify_signature(headers:, body:, secret:)
            return false if secret.nil?

            sig_header = find_signature_header(headers)
            return false if sig_header.nil?

            Helpers::Signature.verify(secret: secret, signature: sig_header, payload: body)
          end

          def find_signature_header(headers)
            normalized = headers.transform_keys { |key| key.to_s.downcase }
            normalized['x-hub-signature-256'] ||
              normalized['x-hub-signature'] ||
              normalized['x-signature'] ||
              normalized['x-webhook-signature']
          end

          def parse_body(headers:, body:)
            return body if body.nil? || body.empty?

            content_type = headers.transform_keys { |key| key.to_s.downcase }['content-type'].to_s
            return Legion::JSON.load(body) if content_type.include?('json')

            body
          rescue StandardError => _e
            body
          end
        end
      end
    end
  end
end
