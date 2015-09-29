require 'sinatra/base'
require 'slim'
require './lib/calculations'
require './helpers/format_helper'

class MyApp < Sinatra::Base
  helpers FormatHelper

  get '/' do
    slim :index
  end

  post '/calculations' do
    puts params
    @calculations = Calculations.new(params)
    @calculations.run
    slim :show
  end

  run! if app_file == $0
end