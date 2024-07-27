# frozen_string_literal: true

require 'spec_helper'

module BootsCats
  class Game
    RSpec.describe Sender do
      subject(:sender) { described_class.new(player_set) }

      let(:game) { BootsCats.game = Game.new }
      let(:player_set) { game.players }
      let(:connections) do
        [
          instance_double(Server::Connection, 'connection1', send_data: nil),
          instance_double(Server::Connection, 'connection2', send_data: nil)
        ]
      end
      let(:players) do
        [
          Player.new(name: 'player1', connection: connections.first),
          Player.new(name: 'player2', connection: connections.last)
        ]
      end

      before do
        players.each do |player|
          allow(player.connection).to receive(:send_data)
          game.join(player)
        end
      end

      describe 'game' do
        subject { game }

        its(:players) { is_expected.to eq player_set }
      end

      describe '#broadcast' do
        let(:current_player) { game.players.current }
        let(:turn) { TurnMade.new(game:, player: current_player, said: '2') }
        let(:packet_hash) { { event: Event.Start, turn: } }
        let(:packet) { Packet.new(**packet_hash) }

        it 'sends the packet to all players' do
          expect(current_player.connection).to receive(:send_data).with(packet.as_json)

          sender.broadcast(**packet_hash, to: current_player)
        end
      end
    end
  end
end
