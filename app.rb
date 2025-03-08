require 'sinatra'

get '/' do
  "Hello, World!"
end

# /todos へのルーティング
get '/todos' do
  # @todos に配列を代入
  @todos = ["TODO1", "TODO2", "TODO3"]
  
  # views/todos.erb を表示
  erb :todos
end
