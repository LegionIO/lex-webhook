# frozen_string_literal: true

module Legion
  module Extensions
    module Webhook
      module Runners
        module Endpoints
          def list_endpoints(**)
            { endpoints: endpoint_registry.dup }
          end

          def register_endpoint(path:, secret: nil, description: nil, **)
            existing = endpoint_registry.find { |e| e[:path] == path }
            if existing
              existing[:secret]      = secret
              existing[:description] = description
              return { registered: false, updated: true, path: path }
            end

            entry = { path: path, secret: secret, description: description }.compact
            endpoint_registry << entry
            { registered: true, updated: false, path: path }
          end

          def remove_endpoint(path:, **)
            before = endpoint_registry.size
            endpoint_registry.reject! { |e| e[:path] == path }
            removed = endpoint_registry.size < before
            { removed: removed, path: path }
          end

          private

          def endpoint_registry
            @endpoint_registry ||= []
          end
        end
      end
    end
  end
end
