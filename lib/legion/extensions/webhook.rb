# frozen_string_literal: true

require 'legion/extensions/webhook/version'
require 'legion/extensions/webhook/helpers/signature'
require 'legion/extensions/webhook/helpers/client'
require 'legion/extensions/webhook/runners/receive'
require 'legion/extensions/webhook/runners/verify'
require 'legion/extensions/webhook/runners/endpoints'
require 'legion/extensions/webhook/client'

module Legion
  module Extensions
    module Webhook
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
    end
  end
end
