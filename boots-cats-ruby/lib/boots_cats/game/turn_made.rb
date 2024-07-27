# frozen_string_literal: true

require 'json'

module BootsCats
  class Game
    # Instances of this class represent the last turn a player has made in the game,
    # which includes their name, their response (in #said) and the decision whether
    # this was a valid response or not.
    #
    # The instance is then used to broadcast the player's turn to all the *other* players
    # in the game, before sending the event that potentially removes that player
    # from the game.
    class TurnMade
      attr_reader :player, :said, :number, :valid, :game

      def initialize(game:, player:, said:)
        @game = game

        raise(ArgumentError, 'No game has been defined') unless @game

        @player = player
        @said = said

        @number = if @game&.number.nil?
                    Integer(said)
                  else
                    @game.number
                  end

        @valid = valid?
      end

      def to_s
        as_json
      end

      def as_json
        as_hash.to_json
      end

      def as_hash
        {
          player: player.name,
          said:
        }
      end

      private

      def validator
        @validator ||=
          lambda { |num, target|
            (num % target).zero? || num.to_s.include?(target.to_s)
          }
      end

      # @return [String] either the number, or "cats", "boots" or "boots and cats"
      def answer
        return @answer if @answer

        cats = validator[number, 5]
        boots = validator[number, 7]

        @answer = boots_and_cats(boots, cats)
      end

      def boots_and_cats(boots, cats)
        if boots && cats
          'boots & cats'
        elsif boots
          'boots'
        elsif cats
          'cats'
        else
          number.to_s
        end
      end

      def valid?
        said == answer
      end
    end
  end
end
