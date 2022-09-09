require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('a'..'z').to_a.sample }
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    @letters = params[:letters]
    @start_time = DateTime.strptime(params[:start_time], '%Y-%m-%d %H:%M:%S')
    @attempt = params[:game]
    @score = run_game(@attempt, @letters, @start_time, end_time)
    if Rails.cache.read('score').nil?
      Rails.cache.write('score', @score[:score])
    else
      old_score = Rails.cache.read('score')
      Rails.cache.write('score', @score[:score] + old_score[:score])
    end
    @total = Rails.cache.read('score')
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    time = end_time - start_time
    score = attempt.size / time
    if word_exist?(attempt) && word_in_grid(attempt, grid)
      { score: score, time: time, message: "Well done, #{attempt} is a great word" }
    elsif !word_exist?(attempt)
      { score: 0, time: time, message: "Sorry but #{attempt} does not seem to be a valid English word..." }
    else
      { score: 0, time: time, message: "Sorry but #{attempt} can't be build out of #{grid}" }
    end
  end

  def word_exist?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    hash = JSON.parse(URI.open(url).read)
    hash["found"]
  end

  def word_in_grid(attempt, grid)
    attempt.upcase.chars.all? { |z| attempt.upcase.count(z) <= grid.upcase.count(z) }
  end
end
