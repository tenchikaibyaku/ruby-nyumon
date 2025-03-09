# require 'sinatra'
require 'sinatra/activerecord'
require './models/todo'
require 'json'

set :database_file, 'config/database.yml'

get '/' do
  "Hello, World"
end

before do
  content_type :json if request.path.start_with?('/api/')
end

# ✅ TODO一覧の取得
get '/api/todos' do
  todos = Todo.all
  todos.map { |todo| [todo.id, todo.title, todo.completed] }.to_json
end

# ✅ 特定のTODOを取得
get '/api/todos/:id' do
  todo = Todo.find_by(id: params[:id])
  halt 404, { error: "TODO not found" }.to_json if todo.nil?
  [todo.id, todo.title, todo.completed].to_json
end

# ✅ 新しいTODOを作成
post '/api/todos' do
  request.body.rewind
  params = JSON.parse(request.body.read) rescue params

  title = params['title']
  halt 400, { error: "Title is required" }.to_json if title.nil? || title.strip.empty?

  todo = Todo.create(title: title)
  [todo.id, todo.title, todo.completed].to_json
end

# ✅ TODOを更新
put '/api/todos/:id' do
  todo = Todo.find_by(id: params[:id])
  halt 404, { error: "TODO not found" }.to_json if todo.nil?

  request.body.rewind
  params = JSON.parse(request.body.read) rescue params

  title = params['title']
  halt 400, { error: "Title is required" }.to_json if title.nil? || title.strip.empty?

  todo.update(title: title)
  [todo.id, todo.title, todo.completed].to_json
end

# ✅ TODOを削除
delete '/api/todos/:id' do
  todo = Todo.find_by(id: params[:id])
  halt 404, { error: "TODO not found" }.to_json if todo.nil?

  todo.destroy
  { message: "TODO deleted" }.to_json
end
