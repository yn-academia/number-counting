# frozen_string_literal: true

module BootsCats
  class Game
    # A collection of all connected players
    class PlayerSet
      extend Forwardable
 
      class InvalidActionError < StandardError; end

      def_delegators :@players, :size, :empty?, :each, :find, :<<, :[]
     
      # This file could easily be also Enumerable
      # however we dont currebtly hse that.
      # To use Enumerable methods, uncomment this line:
      # include Enumerable

      attr_reader :current_index

      def initialize
        @players = []
        @current_index = nil
      end

      def current
        return nil if current_index.nil?

        if block_given?
          yield(self[current_index])
        else
          self[current_index]
        end
      end

      def next(&)
        if current_index
          @current_index += 1
          @current_index %= @players.size
        else
          @current_index = 0
        end

        current(&)
      end

      def add(player)
        @current_index ||= 0

        @players << player
      end

      def remove(player)
        index = @players.find_index(player)
        raise InvalidActionError, 'Can not lose a player that is not the current player' if index != current_index

        @players.delete(player)
        return unless @current_index == @players.size

        @current_index = 0
      end
    end
  end
end
