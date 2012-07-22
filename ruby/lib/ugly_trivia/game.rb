require_relative "moderators"
module UglyTrivia
  PlayerNotFoundError = Class.new(StandardError)
  UnknownCategoryError = Class.new(StandardError)
  class Game
    def  initialize
      @players = []
      @places = Array.new(6, 0)
      @purses = Array.new(6, 0)
      @in_penalty_box = Array.new(6) { false }

      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      @current_player_index = 0
      @is_getting_out_of_penalty_box = false

      @moderator = GameModerator.silent

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
      @players.push player
      @places[how_many_players] = 0
      @purses[how_many_players] = 0

      @moderator.added_player(player,how_many_players)
      true
    end

    def how_many_players
      @players.length
    end

    def position_for_player(p)
      index = @players.index(p)
      @places.fetch(index)
    end

    def in_penalty_box?(p)
      index = @players.index(p)
      index or raise PlayerNotFoundError
      @in_penalty_box.fetch(index)
    end

    def current_player_gets_out?
      @is_getting_out_of_penalty_box
    end

    def roll(roll)
      @moderator.current_player(current_player)
      @moderator.rolled(current_player,roll)

      if in_penalty_box?(current_player)
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          @moderator.player_gets_out_of_penalty_box(current_player)
          @places[@current_player_index] = @places[@current_player_index] + roll
          @places[@current_player_index] = @places[@current_player_index] - 12 if @places[@current_player_index] > 11

          @moderator.moved_player(current_player,
                                  position_for_player(current_player),
                                  current_category)
          ask_question
        else
          @moderator.player_stays_in_penalty_box(current_player)
          @is_getting_out_of_penalty_box = false
          end

      else

        @places[@current_player_index] = @places[@current_player_index] + roll
        @places[@current_player_index] = @places[@current_player_index] - 12 if @places[@current_player_index] > 11

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
                 when 'Sports'
                   @sports_questions.shift
                 when 'Rock'
                   @rock_questions.shift
                 else
                   raise UnknownCategoryError, current_category
                 end

      @moderator.announce_question(question)
    end

    def current_category
      return 'Pop' if @places[@current_player_index] == 0
      return 'Pop' if @places[@current_player_index] == 4
      return 'Pop' if @places[@current_player_index] == 8
      return 'Science' if @places[@current_player_index] == 1
      return 'Science' if @places[@current_player_index] == 5
      return 'Science' if @places[@current_player_index] == 9
      return 'Sports' if @places[@current_player_index] == 2
      return 'Sports' if @places[@current_player_index] == 6
      return 'Sports' if @places[@current_player_index] == 10
      return 'Rock'
    end

  public

    def was_correctly_answered
      if in_penalty_box?(current_player)
        if @is_getting_out_of_penalty_box
          @moderator.correct_answer(current_player,
                                    @purses[@current_player_index])

          @purses[@current_player_index] += 1

          winner = did_player_win()
          @current_player_index += 1
          @current_player_index = 0 if @current_player_index == @players.length

          winner
        else
          @current_player_index += 1
          @current_player_index = 0 if @current_player_index == @players.length
          true
        end



      else

        @moderator.correct_answer(
          current_player,
          @purses[@current_player_index]
        )

        @purses[@current_player_index] += 1

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
      !(@purses[@current_player_index] == 6)
    end
  end

end
