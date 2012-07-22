require "spec_helper"
require "ugly_trivia/game"
require "ugly_trivia/player"

describe UglyTrivia::Game do
  let (:p1) { UglyTrivia::Player.new("Bob") }
  let (:p2) { UglyTrivia::Player.new("Alice") }

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

    it "changes the current player after a correct answer" do
      expect {
        game.was_correctly_answered
      }.to change { game.current_player }.from(p1).to(p2)
    end

    it "changes the current player after a wrong answer" do
      expect {
        game.wrong_answer
      }.to change { game.current_player }.from(p1).to(p2)
    end

    it "puts a player into the penalty box if answer is wrong" do
      player = game.current_player
      expect {
        game.wrong_answer
      }.to change { game.in_penalty_box?(player) }.from(false).to(true)
    end

    context "rolling the die" do
      it "moves the current player after roll if not in penalty box" do
        game.cup.should_receive(:face_sum).and_return(5)
        expect {
          game.roll
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
            game.roll
            game.was_correctly_answered

            game.cup.should_receive(:face_sum).and_return(1)
            game.roll
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
              game.roll
            }.not_to change { game.position_for_player(player) }
            game.in_penalty_box?(player).should be_true
          end
        end
      end
    end

    context "answering a question correctly" do
      context "outside the penalty box" do
        it "adds a coin to the player's purse" do
          player = game.current_player
          expect {
            game.was_correctly_answered
          }.to change { player.coins }.by(1)
        end
      end

      context "while in penalty box" do

        context "and the last roll was odd (coming out)" do

          it "adds a coin to the player's purse" do
            # Get player 1 into penalty box
            player = game.current_player
            game.wrong_answer
            game.in_penalty_box?(player).should be_true

            # Cycle through player 2
            game.roll
            game.was_correctly_answered

            game.cup.should_receive(:face_sum).and_return(1)
            game.roll
            expect {
              game.was_correctly_answered
            }.to change { player.coins }.by(1)
          end
        end

        context "last roll was even (staying inside)" do
          it "does not add a coint" do
            # Get player 1 into penalty box
            player = game.current_player
            game.wrong_answer
            game.in_penalty_box?(player).should be_true

            # Cycle through player 2
            game.roll
            game.was_correctly_answered

            game.cup.should_receive(:face_sum).and_return(2)
            game.roll
            expect {
              game.wrong_answer
            }.not_to change { player.coins }
          end
        end
      end
    end

  end


end

