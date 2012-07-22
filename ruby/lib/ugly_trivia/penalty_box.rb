module UglyTrivia
  PlayerNotInPenalty = Class.new(StandardError)

  class PenaltyBox
    def initialize
      @players = []
    end

    def add(player)
      @players << player unless @players.include?(player)
    end

    def remove(player)
      @players.delete(player) { raise PlayerNotInPenalty }
    end

    def penalty?(player)
      @players.include?(player)
    end

    def gets_out?(player,roll)
      !penalty?(player) or roll.even?
    end
  end
end
