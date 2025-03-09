require 'sinatra'
require 'json'
require './db/todos'

get '/' do
  "Hello World"
end

# TODO一覧の表示 (HTML)
get '/todos' do
  db = TodoDB.connection
  db.results_as_hash = false  # テストが配列を期待しているので false にする
  @todos = db.execute('SELECT id, title FROM todos')
  erb :todos
end

# TODO の作成
post '/todos' do
  db = TodoDB.connection
  db.execute('INSERT INTO todos (title) VALUES (?)', [params[:title]])
  redirect to('/todos')
end

# TODO の編集画面
get '/todos/:id/edit' do
  db = TodoDB.connection
  db.results_as_hash = false
  @todo = db.execute('SELECT id, title FROM todos WHERE id = ?', [params[:id].to_i]).first
  halt 404, "TODO not found" if @todo.nil?
  erb :edit
end

# TODO の更新
put '/todos/:id' do
  db = TodoDB.connection
  db.results_as_hash = false
  db.execute('UPDATE todos SET title = ? WHERE id = ?', [params[:title], params[:id].to_i])
  redirect to('/todos')
end

# TODO の削除
delete '/todos/:id' do
  db = TodoDB.connection
  db.results_as_hash = false
  todo = db.execute('SELECT id FROM todos WHERE id = ?', [params[:id].to_i]).first
  halt 404, { error: "TODO not found" }.to_json if todo.nil?
  db.execute('DELETE FROM todos WHERE id = ?', [params[:id].to_i])
  redirect to('/todos')
end

# ✅ **API エンドポイント: TODO リストの取得**
get '/api/todos' do
  content_type :json
  db = TodoDB.connection
  db.results_as_hash = false  # ⚠️ テストが配列の配列を期待しているため `false`
  todos = db.execute('SELECT id, title FROM todos')

  halt 404, [].to_json if todos.nil? || todos.empty?

  JSON.pretty_generate(todos)  # ✅ `[ [1, "TODO1"], [2, "TODO2"] ]` の形式で返す
end
