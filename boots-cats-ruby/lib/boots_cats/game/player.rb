# frozen_string_literal: true

require 'json'

module BootsCats
  class Game
    class InvalidGameRule < StandardError; end

    # Various states of the player
    PlayerStateStruct = Data.define(:Joined, :MyTurn, :Waiting, :Lost, :Won)

    # A convenient ENUM for the player states
    PlayerState = PlayerStateStruct.new(*%w[Joined MyTurn Waiting Lost Won])

    # Player class, maintains the connection and the name as immutable attributes.
    Player = Struct.new(:connection, :name) do
      # Each of the players is assigned a state based on the current game state.
      # That allows looping over all of the players and sending the appropriate
      # response based on their current state. Each time a response is received
      # from a player, that player's state changes (and possibly another player's too).
      # Therefore it feels easier to handle individual player states, and then
      # response to each player correspondingly.
      attr_reader :state

      def initialize(*)
        super

        @state = PlayerState.Joined
      end

      def disconnect
        connection.unbind
      end

      # TODO: replace this with a proper state machine gem

      def wait
        unless [PlayerState.Waiting, PlayerState.MyTurn, PlayerState.Joined].include?(state)
          raise(InvalidGameRule,
                "Invalid transition from state #{state} to Waiting")
        end

        @state = PlayerState.Waiting
      end

      def my_turn
        unless state == PlayerState.Waiting
          raise(InvalidGameRule,
                "Invalid transition from state #{state} to MyTurn")
        end

        @state = PlayerState.MyTurn
      end

      def lost
        unless state == PlayerState.MyTurn
          raise(InvalidGameRule,
                "Invalid transition from state #{state} to Won")
        end
        @state = PlayerState.Lost
      end

      def won
        unless state == PlayerState.MyTurn || state == PlayerState.Waiting
          raise(InvalidGameRule,
                "Invalid transition from state #{state} to Won")
        end

        @state = PlayerState.Won
      end

      def to_s
        "Player #{name}"
      end

      # So that we can use the player in a Set
      def <=>(other)
        name <=> other.name &&
          connection == other.connection
      end
    end
  end
end
