# frozen_string_literal: true

require 'spec_helper'

module BootsCats
  class Game
    RSpec.describe PlayerSet do
      subject(:player_set) { described_class.new }

      context 'when player set is empty' do
        its(:size) { is_expected.to be_zero }
      end

      context 'when player set has one player' do
        let(:player1) { instance_double(Player, 'player1', name: 'player1') }

        before { player_set.add(player1) }

        its(:size) { is_expected.to eq(1) }
        its(:current) { is_expected.to eq(player1) }

        context 'when another player is added' do
          let(:player2) { instance_double(Player, 'player2', name: 'player2') }

          before { player_set.add(player2) }

          its(:size) { is_expected.to eq(2) }
          its(:current) { is_expected.to eq(player1) }

          describe '#next' do
            before { player_set.next }

            its(:current) { is_expected.to eq(player2) }

            describe '#remove player2' do
              before { player_set.remove(player2) }

              its(:size) { is_expected.to be(1) }
              its(:current) { is_expected.to be(player1) }
            end
          end
        end
      end
    end
  end
end
