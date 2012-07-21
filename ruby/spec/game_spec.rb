require "spec_helper"
require "ugly_trivia/game"
describe UglyTrivia::Game do
  context "starting a new game" do
    it "is not playable with less than 2 players" do
      game = UglyTrivia::Game.new
      game.add(stub)

      expect {
        game.add(stub)
      }.to change { game.playable? }.from(false).to(true)
    end

    it "knows how many players it has" do
      game = UglyTrivia::Game.new
      game.how_many_players.should eq(0)

      expect {
        game.add("Bob")
        game.add("Alice")
      }.to change { game.how_many_players }.by(2)
    end

    it "can not be started if not playable" do
      pending
    end
  end

end

