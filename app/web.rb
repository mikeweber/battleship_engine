require 'sinatra'
require_relative './main'

set :public_folder, 'public'

get '/' do
  haml :game
end

post '/make_move' do
  
end

get '/style.css' do
  sass :style
end