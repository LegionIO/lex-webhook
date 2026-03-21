# frozen_string_literal: true

module Legion
  module Extensions
    module Webhook
      module Helpers
        module Client
          module_function

          def settings
            return Legion::Settings[:webhook] if defined?(Legion::Settings)

            {}
          end

          def endpoints_store
            @endpoints_store ||= []
          end

          def reset_endpoints!
            @endpoints_store = []
          end
        end
      end
    end
  end
end
