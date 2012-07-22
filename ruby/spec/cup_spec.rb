require "spec_helper"
require "ugly_trivia/cup"

describe UglyTrivia::Cup do
  let(:cup) { UglyTrivia::Cup.new(2) }
  it "has a given number of dice" do
    cup.num_dice.should eq(2)
  end

  it "raises an error if asked for the last roll before rolling" do
    expect { cup.last_roll }.to raise_error(UglyTrivia::NoLastRollError)
  end

  it "returns the sum of the dice faces" do
    cup.rng = stub(:rand => 0)
    cup.roll
    cup.last_roll.should eq([1,1])
    cup.face_sum.should eq(2)
  end

  it "knows if the result is even or odd" do
    cup.rng = stub(:rand => 0)
    cup.roll
    cup.last_roll_even?.should be_true

    # returns 0 and 1 for the 2 dice
    cup.rng = [0,1].tap { |a| a.define_singleton_method(:rand) { |n| shift } }

    cup.roll
    cup.last_roll_odd?.should be_true
  end
end

