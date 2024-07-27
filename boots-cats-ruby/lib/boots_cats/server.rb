# frozen_string_literal: true

require 'eventmachine'

require 'boots_cats'
require 'boots_cats/game'
require 'boots_cats/server/connection'

# Main module
module BootsCats
  # Server class that handles connections from the client using EventMachine
  class Server
    include BootsCats::Logging

    attr_accessor :connections

    def initialize
      @connections = []
    end

    def start
      info "Starting EventMachine server, listening on #{BootsCats::HOST}:#{BootsCats::PORT} ..."
      @signature = EventMachine.start_server(::BootsCats::HOST, ::BootsCats::PORT,
                                             ::BootsCats::Server::Connection) do |conn|
        conn.server = self
      end
    end

    def stop
      info 'Stopping server ...'
      EventMachine.stop_server(@signature)

      return if wait_for_connections_and_stop

      # Still some connections running, schedule a check later
      EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
      info 'Server stopped.'
    end

    def wait_for_connections_and_stop
      if @connections.empty?
        EventMachine.stop
        true
      else
        info "Waiting for #{@connections.size} connection(s) to finish ..."
        false
      end
    end
  end
end
