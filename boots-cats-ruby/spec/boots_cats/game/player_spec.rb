# frozen_string_literal: true

require 'spec_helper'

module BootsCats
  class Game
    RSpec.describe Player do
      subject(:player) { described_class.new(connection, name) }

      let(:connection) { instance_double(Server::Connection, 'connection') }
      let(:name) { '::ffff:127.0.0.1:5555' }

      describe 'initial state' do
        its(:state) { is_expected.to be PlayerState.Joined }

        describe 'transition to playing' do
          before { player.wait }

          its(:state) { is_expected.to be PlayerState.Waiting }

          describe 'valid transitions' do
            before { player.won }

            its(:state) { is_expected.to be PlayerState.Won }
          end

          describe 'invalid transitions' do
            it 'raises an error when trying to transition to Lost' do
              expect { player.lost }.to raise_error(InvalidGameRule)
            end
          end

          describe 'transition to my turn' do
            before { player.my_turn }

            its(:state) { is_expected.to be PlayerState.MyTurn }

            describe 'transition to my waiting' do
              before { player.wait }

              its(:state) { is_expected.to be PlayerState.Waiting }
            end

            describe 'transition to lost' do
              before { player.lost }

              its(:state) { is_expected.to be PlayerState.Lost }
            end

            describe 'transition to won' do
              before { player.won }

              its(:state) { is_expected.to be PlayerState.Won }
            end
          end
        end
      end
    end
  end
end
