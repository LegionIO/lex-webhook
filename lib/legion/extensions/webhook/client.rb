# frozen_string_literal: true

require 'legion/extensions/webhook/runners/receive'
require 'legion/extensions/webhook/runners/verify'
require 'legion/extensions/webhook/runners/endpoints'

module Legion
  module Extensions
    module Webhook
      class Client
        include Runners::Receive
        include Runners::Verify
        include Runners::Endpoints

        def initialize(**opts)
          @opts = opts
        end
      end
    end
  end
end
