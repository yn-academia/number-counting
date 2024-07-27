# frozen_string_literal: true

require 'eventmachine'

require 'boots_cats'
require 'boots_cats/game'
require 'boots_cats/game/player'

# Main module
module BootsCats
  class Server
    # Connection to the client
    class Connection < EventMachine::Connection
      include BootsCats::Logging

      attr_accessor :server, :player

      def post_init
        port, ip = Socket.unpack_sockaddr_in(get_peername)
        name = "::ffff:#{ip}:#{port}"

        self.player = Game::Player.new(self, name)
        game.join(player)
        info "Server::Connection: player joined: [#{name}] as player ##{game.players.size}"
      end

      def receive_data(data)
        data = data.strip
        info "Server::Connection: received data: [#{data}] from #{player.name}"
        game.receive(player, data)
      end

      def unbind
        info "Server::Connection: #{player.name} disconnecting"
        server.connections.delete(self)
      end

      def game
        ::BootsCats.game
      end
    end
  end
end
