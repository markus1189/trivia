require "spec_helper"
require "ugly_trivia/board.rb"

describe UglyTrivia::Board do
  let(:board) { UglyTrivia::Board.new(6) }

  it "has fields" do
    UglyTrivia::Board.new(6).num_fields.should eq(6)
  end

  it "can move players" do
    player = Struct.new(:position).new(1)
    def player.move_to(n); self.position = n; end
    expect {
      board.move_player(player, 3)
    }.to change { player.position }.from(1).to(4)
  end

  it "wraps moves around the board limits" do
    player = Struct.new(:position).new(4)
    def player.move_to(n); self.position = n; end

    expect {
      board.move_player(player, 3)
    }.to change { player.position }.from(4).to(1)
  end

  it "has different fields" do
    expected = ['Pop','Science','Sports','Rock']
    (0...4).map { |i| board[i] }.map(&:category).should eq(expected)
  end
end

