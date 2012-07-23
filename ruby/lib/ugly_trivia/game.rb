require_relative "moderators"
require_relative "board"
require_relative "cup"
require_relative "penalty_box"

module UglyTrivia
  PlayerNotFoundError = Class.new(StandardError)
  UnknownCategoryError = Class.new(StandardError)
  class Game
    attr_reader :cup, :board, :moderator, :penalty_box

    def initialize(opts={})
      @players     = []
      @moderator   = opts.fetch(:moderator)   { GameModerator.silent }
      @board       = opts.fetch(:board)       { Board.new(6) }
      @cup         = opts.fetch(:cup)         { Cup.new(2) }
      @penalty_box = opts.fetch(:penalty_box) { PenaltyBox.new }

      create_card_deck
    end

    def create_card_deck
      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      50.times do |i|
        @pop_questions.push "Pop Question #{i}"
        @science_questions.push "Science Question #{i}"
        @sports_questions.push "Sport Question #{i}"
        @rock_questions.push "Rock Question #{i}"
      end
    end

    def current_player
      @players.first
    end

    def num_players
      @players.size
    end

    def playable?
      num_players >= 2
    end

    def finished?
      @players.any? { |p| p.coins >= 6 }
    end

    def winner
      finished? and @players.max_by(&:coins)
    end

    def add(player)
      player.move_to(0)
      @players << player

      @moderator.added_player(player,num_players)

      self
    end

    def next_player
      @players.rotate!
    end

    def in_penalty_box?(p)
      @penalty_box.penalty?(p)
    end

    def current_player_gets_out?
      @penalty_box.gets_out?(current_player,@cup.face_sum)
    end

    def roll
      @cup.roll
      roll = @cup.face_sum

      @moderator.current_player(current_player)
      @moderator.rolled(current_player,roll)

      if in_penalty_box?(current_player)
        if current_player_gets_out?
          @penalty_box.remove(current_player)
          @moderator.player_gets_out_of_penalty_box(current_player)

          @board.move_player(current_player,roll)
          @moderator.moved_player(current_player,current_category)

          ask_question
        else
          @moderator.player_stays_in_penalty_box(current_player)
        end

      else

        @board.move_player(current_player,roll)

        @moderator.moved_player(current_player,current_category)

        ask_question
      end
    end

    def was_correctly_answered
      correct_answer
    end

    def correct_answer
      unless in_penalty_box?(current_player) && !current_player_gets_out?
        current_player.add_coin
        @moderator.correct_answer(current_player)
      end

      next_player
    end

    def wrong_answer
      @moderator.wrong_answer(current_player)
      @penalty_box.add(current_player)

      next_player
    end

    private

    def ask_question
      question = case current_category
                 when 'Pop'
                   @pop_questions.shift
                 when 'Science'
                   @science_questions.shift
                 when 'Sport'
                   @sports_questions.shift
                 when 'Rock'
                   @rock_questions.shift
                 else
                   raise UnknownCategoryError, current_category
                 end

      @moderator.announce_question(question)
    end

    def current_category
      @board[current_player.position].category
    end

    def did_player_win
      !(current_player.coins == 6)
    end
  end

end
