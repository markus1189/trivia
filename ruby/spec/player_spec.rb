require "spec_helper"
require "ugly_trivia/player"

describe UglyTrivia::Player do
  it "has a name" do
    p = UglyTrivia::Player.new("Bob")
    p.name.should eq("Bob")
  end

  it "tracks the number of coins" do
    p = UglyTrivia::Player.new("Bob")
    expect { p.add_coin }.to change { p.coins }.by(1)
  end
end

