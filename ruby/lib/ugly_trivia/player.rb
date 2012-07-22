module UglyTrivia
  class Player
    attr_reader :name, :coins

    def initialize(name)
      @name = name
      @coins = 0
    end

    def add_coin
      @coins += 1
    end
  end
end

