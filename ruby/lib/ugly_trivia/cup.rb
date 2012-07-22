module UglyTrivia
  NoLastRollError = Class.new(StandardError)
  class Cup
    attr_reader :num_dice, :last_roll
    attr_accessor :rng
    def initialize(num_dice)
      @num_dice = num_dice
      @last_roll = nil
      @rng = Random.new
    end

    def roll
      @last_roll = Array.new(@num_dice) { @rng.rand(6) + 1 }

      self
    end

    def face_sum
      last_roll.inject(&:+)
    end

    def last_roll
      @last_roll or raise NoLastRollError, "Dice have never been rolled"
    end

    def last_roll_even?
      face_sum.even?
    end

    def last_roll_odd?
      face_sum.odd?
    end
  end
end
