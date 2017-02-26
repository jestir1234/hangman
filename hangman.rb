require 'sinatra'
require 'sinatra/reloader'
require 'byebug'

@@secret_word = nil
@@guessed_word_status = []
@@remaining_guesses = nil
get '/' do

  game = Hangman.new("dictionary.txt")
  if @@secret_word.nil?
    @@secret_word = game.secret_word
    game.set_up_guessed_word_status
    game.set_up_remaining_guesses
  end

  if params["letter"].nil?
    player_guess = ""
  else
    player_guess = params["letter"].downcase
  end
  game.check_letter(player_guess) ? hit = true : hit = false
  game.update_word_status(player_guess)
  
  if hit
    puts "Got a hit!"
  else
    @@remaining_guesses -= 1
  end

  if @@remaining_guesses == -1
    puts "RESETING THE SECRET WORD ************************"
    reset
  end


  puts @@secret_word
  print @@guessed_word_status.join
  puts @@remaining_guesses
  puts params

  erb :index, :locals => {:player_guess => player_guess, :secret_word => @@secret_word, :word_status => @@guessed_word_status.join, :hit => hit}
end

def reset
  @@secret_word = nil
  @@guessed_word_status = []
  @@remaining_guesses = nil
end

class Hangman

  attr_accessor :dictionary, :computer, :player, :secret_word

  def initialize(dictionary)
    @dictionary = []

    File.foreach("dictionary.txt") do |line|
      @dictionary << line.chomp
    end

    @computer = Computer.new(self)
    @player = Player.new(self)

    @secret_word = computer_selects_word
  end

  def computer_selects_word
    @computer.pick_random_word
  end

  def set_up_guessed_word_status
    @@secret_word.length.times { @@guessed_word_status << "_"}
  end

  def check_letter(letter)
    return false if letter == ""
    return true if @@secret_word.include?(letter)
  end

  def update_word_status(letter)
    @@secret_word.split("").each_with_index do |char, i|
      if char == letter
        @@guessed_word_status[i] = letter
      end
    end
  end

  def find_remaining_guesses
    @@guessed_word_status.select { |char| char == "_"}.length
  end

  def set_up_remaining_guesses
    if secret_word.length <= 5
      @@remaining_guesses = 5
    else
      @@remaining_guesses = secret_word.length
    end
  end

end

class Computer

  attr_accessor :game, :dictionary

  def initialize(game)
    @game = game
    @dictionary = game.dictionary
  end

  def pick_random_word
    @dictionary[rand(1..(dictionary.length - 1))]
  end

end

class Player

  attr_accessor :game

  def initialize(game)
    @game = game
  end

end
