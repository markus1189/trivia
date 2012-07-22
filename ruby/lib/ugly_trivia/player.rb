module UglyTrivia
  class Player
    attr_reader :name, :coins, :position

    def initialize(name)
      @name = name
      @coins = 0
      @position = 0
    end

    def add_coin
      @coins += 1
    end

    def move_to(pos)
      @position = pos
    end
  end
end

