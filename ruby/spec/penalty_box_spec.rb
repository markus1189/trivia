require "spec_helper"
require "ugly_trivia/penalty_box"
describe UglyTrivia::PenaltyBox do
  let (:box) { UglyTrivia::PenaltyBox.new }
  let (:player) { stub }

  it "has a list of players in penalty" do
    box.penalty?(player).should_not be_true
    box.add(player)
    box.penalty?(player).should be_true
  end

  it "can remove players" do
    box.add(player)
    box.penalty?(player).should be_true
    box.remove(player)
    box.penalty?(player).should be_false
  end

  it "should fail if the players has not been in penalty" do
    expect { box.remove(stub) }.to raise_error(UglyTrivia::PlayerNotInPenalty)
  end

  it "a player gets out if he is in the box and the roll is odd" do
    player = stub
    box.add(player)

    box.gets_out?(player, 3).should be_true
  end

  it "a player stays in the box if the roll is even" do
    player = stub
    box.add(player)

    box.gets_out?(player, 2).should be_false
  end
end

