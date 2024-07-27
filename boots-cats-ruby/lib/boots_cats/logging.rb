# frozen_string_literal: true

# The main module
module BootsCats
  # Globals such as the logger
  module Logging
    class << self
      def included(base)
        base.instance_eval do
          class << self
            attr_accessor :logger
          end
          extend Forwardable

          def_delegators :@logger, :debug, :info, :warn, :error, :fatal
        end

        base.logger = Logger.new($stdout)
      end
    end
  end
end
