# frozen_string_literal: true

require 'json'

module BootsCats
  class Game
    # The data packet represents what the clients expect to receive from the server.
    # Each packet is converted to a JSON structure, and multiple packets can be sent
    # to each client newline-separated.
    class Packet
      attr_accessor :event, :turn, :message, :error

      def initialize(event: nil, turn: nil, message: nil, error: nil)
        self.event = event
        self.message = message
        self.error = error

        return unless turn
        raise(ArgumentError, "Invalid turn object: #{turn}, expected TurnMade instance") unless turn.is_a?(TurnMade)

        self.turn = turn
      end

      # rubocop: disable Style/StringConcatenation
      def as_json
        {}.tap do |hash|
          hash[:message] = message if message
          hash[:event] = event if event
          hash[:turn] = turn.as_hash if turn
          hash[:error] = error if error
        end.to_json + "\n"
      end
      # rubocop: enable Style/StringConcatenation
    end
  end
end
