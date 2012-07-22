require "spec_helper"
require "ugly_trivia/player"

describe UglyTrivia::Player do
  let(:p) { UglyTrivia::Player.new("Bob") }

  it "has a name" do
    p = UglyTrivia::Player.new("Bob")
    p.name.should eq("Bob")
  end

  it "tracks the number of coins" do
    expect { p.add_coin }.to change { p.coins }.by(1)
  end

  it "as a starting position of 0" do
    p.position.should eq(0)
  end

  it "the position can be changed" do
    expect { p.move_to(5) }.to change { p.position }.from(0).to(5)
  end
end

