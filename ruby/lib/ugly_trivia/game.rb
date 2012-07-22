require_relative "moderators"
require_relative "board"
require_relative "cup"

module UglyTrivia
  PlayerNotFoundError = Class.new(StandardError)
  UnknownCategoryError = Class.new(StandardError)
  class Game
    attr_reader :cup, :board, :moderator

    def  initialize(opts={
      :moderator => GameModerator.silent,
      :board => Board.new(6),
      :cup => Cup.new(2)
    })

      @players = []
      @moderator = opts.fetch(:moderator) { GameModerator.silent }
      @board = opts.fetch(:board) { Board.new(6) }
      @cup = opts.fetch(:cup)

      @in_penalty_box = Array.new(6) { false }

      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      @current_player_index = 0
      @is_getting_out_of_penalty_box = false

      50.times do |i|
        @pop_questions.push "Pop Question #{i}"
        @science_questions.push "Science Question #{i}"
        @sports_questions.push "Sports Question #{i}"
        @rock_questions.push create_rock_question(i)
      end
    end

    def create_rock_question(index)
      "Rock Question #{index}"
    end

    def current_player
      @players.fetch(@current_player_index)
    end

    def playable?
      how_many_players >= 2
    end

    def add(player)
      player.move_to(0)
      @players << player

      @moderator.added_player(player,how_many_players)
      true
    end

    def how_many_players
      @players.length
    end

    def position_for_player(p)
      p.position
    end

    def coins_for(p)
      index = @players.index(p)
      p.coins
    end

    def in_penalty_box?(p)
      index = @players.index(p)
      index or raise PlayerNotFoundError
      @in_penalty_box.fetch(index)
    end

    def current_player_gets_out?
      @is_getting_out_of_penalty_box
    end

    def roll
      @cup.roll
      roll = @cup.face_sum

      @moderator.current_player(current_player)
      @moderator.rolled(current_player,roll)

      if in_penalty_box?(current_player)
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          @moderator.player_gets_out_of_penalty_box(current_player)
          @board.move_player(current_player,roll)

          @moderator.moved_player(current_player,
                                  position_for_player(current_player),
                                  current_category)
          ask_question
        else
          @moderator.player_stays_in_penalty_box(current_player)
          @is_getting_out_of_penalty_box = false
          end

      else

        @board.move_player(current_player,roll)

        @moderator.moved_player(current_player,
                                position_for_player(current_player),
                                current_category)

        ask_question
      end
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

  public

    def was_correctly_answered
      if in_penalty_box?(current_player)
        if @is_getting_out_of_penalty_box
          @moderator.correct_answer(current_player)

          current_player.add_coin

          winner = did_player_win()
          @current_player_index = 1
          @current_player_index = 0 if @current_player_index == @players.length

          winner
        else
          @current_player_index += 1
          @current_player_index = 0 if @current_player_index == @players.length
          true
        end

      else

        @moderator.correct_answer(current_player)

        current_player.add_coin

        winner = did_player_win
        @current_player_index += 1
        @current_player_index = 0 if @current_player_index == @players.length

        return winner
      end
    end

    def wrong_answer
      @moderator.wrong_answer(current_player)
  		@in_penalty_box[@current_player_index] = true

      @current_player_index += 1
      @current_player_index = 0 if @current_player_index == @players.length
  		return true
    end

  private

    def did_player_win
      !(current_player.coins == 6)
    end
  end

end
