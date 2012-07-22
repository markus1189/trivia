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
end

