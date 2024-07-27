# frozen_string_literal: true

require 'json'
require 'stringio'

module BootsCats
  # Main Game engine that handles the logic of players joining the game, startiong
  # the game and responding with the appropriate response to the clients.

  class Game
    include Logging

    # Various events
    EventStruct = Data.define(:Start, :Turn, :Timeout, :Win, :Lose)

    # A convenient ENUM for the player states
    Event = EventStruct.new(*%w[start turn timedout win lose])

    attr_accessor :players,
                  :number,
                  :sender,
                  :active

    def initialize
      self.players = PlayerSet.new # Set.new
      self.number = nil
      self.sender = Sender.new(players)
      self.active = false

      ::BootsCats.game = self
    end

    def current_player
      players.current
    end

    def start
      current_player.my_turn
      sender.broadcast(to: current_player, event: Event.Start)
      # Implement a server-side timeout
    end

    def stop
      self.active = false
      self.number = nil
      players.each(&:disconnect)
      self.players = PlayerSet.new
    end

    def join(player)
      players.add(player)
      player.wait
      if players.size == 1
        sender.message('No other players', to: player)
      elsif players.size >= 2
        other_players = StringIO.new
        players.each do |p|
          next if p == player

          other_players.print(', ') unless other_players.string.empty?
          other_players.print(p.name)
        end
        sender.message("Other players: #{other_players.string}", to: player)
        sender.message("New Player: #{player.name}", except: player)

        start if players.size == 2
      end
    end

    def receive(player, data)
      data = data.strip
      if player != players.current
        error("It's not #{player.name}'s turn")
        sender.broadcast('It is not your turn', to: player)
        return
      end

      if players.size >= 2 && number.nil?
        self.number = Integer(data)
      else
        self.number += 1
      end

      turn = TurnMade.new(game: self, player:, said: data)

      if turn.valid
        info("player #{player.name} made a valid turn #{turn}")
        sender.broadcast(except: current_player, turn:)
        players.next
        sender.broadcast(to: current_player, event: Event.Turn)
      else
        info("player #{current_player.name} made an invalid turn #{turn} and LOST")
        sender.lose(player)
        players.remove(player)
      end

      return unless players.size == 1

      sender.win(current_player)
      stop
    end

    def leave(player)
      players.remove(player)
      player.connection.close
    end

    # MAX_SECONDS = 10
    #
    # def wait_for_timeout
    #   this_player = current_player
    #   time = 0
    #   q = Queue.new
    #   t = Thread.new do
    #     while current_player == this_player
    #       sleep 1
    #       time += 1
    #       if time >= MAX_SECONDS
    #         q << this_player
    #         break
    #       end
    #     end
    #   end
    #
    #   t.join
    #
    #   lose!(q.pop, TIMEOUT)
    # end
  end
end
