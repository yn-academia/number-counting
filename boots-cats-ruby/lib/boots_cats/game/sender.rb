# frozen_string_literal: true

require 'json'

require 'boots_cats/game/packet'

module BootsCats
  class Game
    # Class responsible for communicating with the players
    class Sender
      include Logging

      attr_reader :player_set

      def initialize(player_set)
        @player_set = player_set
      end

      # This receives a hash of options that is passed on to the Packet's constructor.
      # It then sends the package to all players, unless +to+ or +except+ are specified.
      # If +to+ is specified, the package is only sent to that player.
      # If +except+ is specified, the package is sent to all players except that one.
      # @param [Player] except the player to exclude from the broadcast
      # @param [Player] to the player to send the package to
      # @param [Hash] opts the options to create the packet with
      def broadcast(except: nil,
                    to: nil,
                    **opts)
        player_set.each do |player|
          next if except && player == except
          next if to && player != to

          notify(player, Game::Packet.new(**opts))
        end
      end

      # Messages and Errors

      def message(text, to: nil, except: nil)
        broadcast(except:, to:, message: text)
      end

      def error(text, to: nil, except: nil)
        broadcast(except:, to:, error: text)
      end

      # Win or Lose

      def lose(player)
        broadcast(to: player, event: Event.Lose)
      end

      def win(player)
        broadcast(to: player, event: Event.Win)
      end

      private

      def notify(player, packet)
        debug("Sending package to #{player.name}: #{packet.as_json.strip}")
        player.connection.send_data(packet.as_json)
      end
    end
  end
end
