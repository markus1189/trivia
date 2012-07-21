require "spec_helper"
require "ugly_trivia/game"
describe UglyTrivia::Game do
  let (:p1) { "Bob" }
  let (:p2) { "Alice" }

  context "starting a new game" do
    let (:game) { UglyTrivia::Game.new }
    it "is not playable with less than 2 players" do
      game.add(p2)

      expect {
        game.add(p1)
      }.to change { game.playable? }.from(false).to(true)
    end

    it "knows how many players it has" do
      game.how_many_players.should eq(0)

      expect {
        game.add(p1)
        game.add(p2)
      }.to change { game.how_many_players }.by(2)
    end

    it "can not be started if not playable" do
      pending
    end

    it "players are not in the penalty box" do
      game.add(p1)
      game.add(p2)

      game.in_penalty_box?(p1).should be_false
      game.in_penalty_box?(p2).should be_false
    end
  end

  context "playing a game" do
    let(:game) { UglyTrivia::Game.new.tap {|g| g.add(p1); g.add(p2) } }

    context "changes the current player after" do
      it "a correct answer" do
        expect {
          game.was_correctly_answered
        }.to change { game.current_player }.from(p1).to(p2)
      end

      it "a wrong answer" do
        expect {
          game.wrong_answer
        }.to change { game.current_player }.from(p1).to(p2)
      end
    end

    it "puts a player into the penalty box if answer is wrong" do
      player = game.current_player
      expect {
        game.wrong_answer
      }.to change { game.in_penalty_box?(player) }.from(false).to(true)
    end

    context "rolling the die" do
      it "moves the current player after roll if not in penalty box" do
        expect {
          game.roll(5)
        }.to change {game.position_for_player(p1)}.by(5)
      end

      context "while in penalty box" do
        context "and the roll is odd" do
          it "then the player is getting out of the penalty box" do
            # Get player 1 into penalty box
            player = game.current_player
            game.wrong_answer
            game.in_penalty_box?(player).should be_true

            # Cycle through player 2
            game.roll(1)
            game.was_correctly_answered

            game.roll(3)
            game.current_player_gets_out?.should be_true
          end
        end
        context "and the roll is even" do
          it "then the player remains in the penalty box" do
            # Get player 1 into penalty box
            player = game.current_player
            game.wrong_answer
            game.in_penalty_box?(player).should be_true

            expect {
              game.roll(2)
            }.not_to change { game.position_for_player(player) }
            game.in_penalty_box?(player).should be_true
          end
        end
      end
    end

  end


end

