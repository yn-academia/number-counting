# frozen_string_literal: true

require 'rspec'

module BootsCats
  class Game
    RSpec.describe TurnMade do
      subject(:turn) { described_class.new(game:, player:, said:) }

      let(:player) { double('player', name: '#ffff:127.0.0.1:5555') }
      let(:game) { Game.new }

      describe 'the neither 5 nor 7 number' do
        let(:number) { 4 }
        let(:said) { '4' }

        its(:valid?) { is_expected.to be true }
      end

      describe 'the number that has or is divisible by 5' do
        before { game.number = number }

        let(:number) { 10 }
        let(:said) { 'cats' }

        describe 'valid response' do
          its(:valid?) { is_expected.to be true }
        end

        describe 'invalid response to 11' do
          let(:number) { 11 }

          its(:valid?) { is_expected.to be false }
        end

        describe 'invalid response to 10' do
          let(:said) { '10' }

          its(:valid?) { is_expected.to be false }
        end
      end
    end
  end
end
