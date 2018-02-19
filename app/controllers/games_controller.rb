require "open-uri"
class GamesController < ApplicationController
  VOWELS = %w(A E I O U Y)

  def new
    @letters = Array.new(5) {VOWELS.sample}
    @letters += Array.new(5) {(('A'..'Z').to_a - VOWELS).sample}
    @letters.shuffle!
    @start_time = Time.now
  end

  def score
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @word = params[:word].upcase
    @grid = params[:letters]

    if included?(@word, @grid)
      if english_word?(@word) == true
        @result= "Well Done"
        @score = compute_score(@start_time, @end_time, @word)
      else
        @result ="Not an english word"
        @score = 0
      end
    else
      @result = "Not in the grid"
      @score = 0
    end
  end

  def included?(word,letters)
    return word.chars.all? do |letter|
      word.count(letter) <= letters.count(letter)
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}").read
    @json = JSON.parse(response)
    if @json["found"] == true
      return true
    end
  end

  def compute_score(start_time, end_time, word)
    time_taken = end_time - start_time
    ((word.length * 10 / time_taken)*10).round
  end
end
