require 'sinatra'
require './db/todos'

get '/' do
  "Hello, World!"
end

get '/todos' do
  @todos = TodoDB.connection.execute('SELECT title FROM todos')  # `DB` を正しく参照
  erb :todos
end
