# frozen_string_literal: true

require 'logger'
require 'forwardable'
require 'eventmachine'

require 'boots_cats/version'

# The main module
module BootsCats
  PORT = 7535
  HOST = '127.0.0.1'

  class << self
    extend Forwardable
    attr_accessor :game, :logger, :server

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal
  end

  # Logging helper
  module Logging
    class << self
      def included(base)
        base.extend Forwardable
        base.def_delegators :BootsCats, :debug, :info, :warn, :error, :fatal
      end
    end
  end
end

require 'boots_cats/server'
require 'boots_cats/server/connection'

require 'boots_cats/game'
require 'boots_cats/game/player'
require 'boots_cats/game/player_set'
require 'boots_cats/game/turn_made'
require 'boots_cats/game/packet'
require 'boots_cats/game/sender'

# Instantiate the server, game and logger
module BootsCats
  self.logger ||= Logger.new($stdout)

  log_level = ENV.fetch('LOG_LEVEL', 'INFO')
  const = Logger.const_get(log_level.upcase)

  logger.level = const

  self.server ||= ::BootsCats::Server.new
  self.game ||= ::BootsCats::Game.new

  class << self
    def start
      ::EventMachine.run do
        ::BootsCats.server.start
        ::BootsCats.info 'EventMachine Server started.'
      end
    rescue Interrupt
      ::BootsCats.info 'Received Interrupt: shutting down ...'
      begin
        stop
      rescue StandardError
        nil
      end
      exit(0)
    end

    def stop
      server.stop
    end
  end
end
