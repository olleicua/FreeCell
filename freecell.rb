#!/usr/bin/env ruby

BG_WHITE = "\033[47m"
BLACK = "\033[30m"
RED = "\033[31m"
COLOR_RESET = "\033[0m"
SUITS = { '♠' => BLACK, '♥' => RED, '♦' => RED, '♣' => BLACK }
HELP_MESSAGE = [
  '  Type the letter above the card you would like',
  '  to move followed by the letter above the place',
  '  you would like to move it to.',
  '  Any card can go in any empty space.',
  '  If a card is at the bottom of a stack (a-h)',
  '  then the card of the same suit one rank lower',
  '  can be placed below it.',
  '  Whenever the lowest card of a given suit that',
  '  has not been removed yet is moveable it will',
  '  automatically be removed and placed in the row',
  '  at the bottom.',
  '  You win when all cards have been removed.',
  '                     *  *  *',
  '  Type `quit or exit` to exit the game.',
  '  Type `? or help` to display this message.'
].join("\n")

class Card
  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def display_rank
    @display_rank ||= ['A', *'2'..'9', '0', 'J', 'Q', 'K'][rank]
  end

  def color
    @color ||= SUITS[suit]
  end

  def to_s
    return '  ' if rank < 0

    "#{BG_WHITE}#{color}#{display_rank}#{suit}#{COLOR_RESET}"
  end

  def can_play_to_foundation?(foundations)
    foundations[suit] == rank - 1
  end
end

class Game
  def initialize
    deck = SUITS.keys.map do |suit|
      13.times.map { |rank| Card.new(rank, suit) }
    end.flatten.shuffle!
    @stacks = 8.times.map { 6.times.map { deck.pop } }
    @cells = deck
    @foundations = Hash[SUITS.keys.zip([-1]*4)]
  end

  def draw
    draw_stacks
    puts ('a'..'h').to_a.join('  ')
    draw_cells
    relevant_cell_count = [@cells.size + 1, 8].min
    puts ('i'..'p').to_a.first(@cells.size + 1).join('  ')
    draw_foundations
  end

  def auto_play_foundations
    possible_plays = true
    while possible_plays
      possible_plays = false
      @stacks.each do |stack|
        if stack.last&.can_play_to_foundation?(@foundations)
          @foundations[stack.pop.suit] += 1
          possible_plays = true
        end
      end
      @cells.each do |cell|
        if cell.can_play_to_foundation?(@foundations)
          @foundations[@cells.delete(cell).suit] += 1
          possible_plays = true
        end
      end
    end
  end

  def won?
    @foundations.values.all? { |rank| rank == 12 }
  end

  def lost?
    false # TODO: implement me
  end

  def over?
    won? || lost?
  end

  def attempt_move(move)
    from, to = move.split('').first(2).map do |c|
      if c then c.ord - 'a'.ord else nil end
    end
    return false unless from &&
                        to &&
                        valid_from?(from) &&
                        valid_to?(to)

    card = card_for_move(from)
    return false unless can_move?(card, to)

    remove_card(from)
    add_card(card, to)
  end

  private

  def valid_from?(from)
    return false if from < 0

    return !@stacks[from].empty? if from < 8

    from < 8 + @cells.size
  end

  def valid_to?(to)
    return false if to < 0

    to < 8 || (to < 16 && to == 8 + @cells.size)
  end

  def can_move?(card, to)
    return true if to == 8 + @cells.size

    stack = @stacks[to]

    return true if stack.empty?

    stack.last.suit == card.suit && stack.last.rank == card.rank + 1
  end

  def card_for_move(from)
    return @stacks[from].last if from < 8

    @cells[from - 8]
  end

  def remove_card(from)
    return @stacks[from].pop if from < 8

    @cells.delete_at(from - 8)
  end

  def add_card(card, to)
    return @stacks[to].push(card) if to < 8

    @cells.push(card)
  end

  def draw_stacks
    row = 0
    while @stacks.any? { |stack| stack.size > row }
      8.times do |column|
        print @stacks[column][row] || '  '
        print ' '
      end
      puts ''
      row += 1
    end
  end

  def draw_cells
    puts @cells.join(' ')
  end

  def draw_foundations
    foundations = SUITS.keys.map do |suit|
      Card.new(@foundations[suit], suit)
    end.join(' ')
    puts foundations
  end
end

game = Game.new
game.auto_play_foundations
game.draw

begin
  until game.over?
    print '> '
    input = gets&.chomp
    exit if input.nil? || input.match(/^(q|exit)/i)

    if input.match(/^(\?|help)/i)
      puts HELP_MESSAGE
      next
    end

    if game.attempt_move(input)
      game.auto_play_foundations
      game.draw
    else
      puts 'invalid move'
    end
  end
rescue Interrupt
  exit
end
puts 'You Win!' # TODO: implement losing
