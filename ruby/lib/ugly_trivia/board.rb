module UglyTrivia
  class Field
    attr_reader :category

    def initialize(category)
      @category = category
    end
  end

  class Board
    def initialize(size)
      @fields = Array.new(size) {|n|
        if (n % 4) == 0
          create_pop_field
        elsif (n % 4) == 1
          create_science_field
        elsif (n % 4) == 2
          create_sports_field
        elsif (n % 4) == 3
          create_rock_field
        else
          raise ArgumentError
        end
      }
    end

    def create_pop_field
      Field.new('Pop')
    end

    def create_science_field
      Field.new('Science')
    end

    def create_sports_field
      Field.new('Sports')
    end

    def create_rock_field
      Field.new('Rock')
    end

    def num_fields
      @fields.size
    end

    def move_player(player, n)
      player.move_to( ( player.position + n ) % num_fields )
    end

    def [](i)
      @fields.fetch(i)
    end
  end
end

