require 'sinatra'
require 'json'
require './db/todos'

get '/' do
  "Hello, World"
end

before do
  content_type :json if request.path.start_with?('/api/')
end

# ✅ TODO一覧の取得 (API)
get '/api/todos' do
  db = TodoDB.connection
  db.results_as_hash = true
  todos = db.execute('SELECT * FROM todos')

  # 🔥 RSpec のテストが `[[id, title], [id, title]]` 形式を期待しているため変更
  todos.map { |todo| [todo['id'], todo['title']] }.to_json
end

# ✅ 特定のTODOを取得 (API)
get '/api/todos/:id' do
  db = TodoDB.connection
  db.results_as_hash = true
  todo = db.execute('SELECT * FROM todos WHERE id = ?', [params[:id].to_i]).first

  halt 404, { error: "TODO not found" }.to_json if todo.nil?

  # 🔥 RSpec のテストが `[id, title]` 形式を期待しているため変更
  [todo['id'], todo['title']].to_json
end

# ✅ 新しいTODOを作成 (API)
post '/api/todos' do
  db = TodoDB.connection

  # 🔥 **RSpec のテストが `application/x-www-form-urlencoded` 形式を送るため、JSON 以外にも対応**
  title = params['title'] || request.POST['title']

  halt 400, { error: "Title is required" }.to_json if title.nil? || title.strip.empty?

  db.execute('INSERT INTO todos (title) VALUES (?)', [title])
  new_id = db.last_insert_row_id
  new_todo = db.execute('SELECT * FROM todos WHERE id = ?', [new_id]).first

  # 🔥 RSpec のテストが `[id, title]` 形式を期待しているため変更
  [new_todo['id'], new_todo['title']].to_json
end

# ✅ TODOを更新 (API)
put '/api/todos/:id' do
  db = TodoDB.connection
  db.results_as_hash = true

  id = params[:id].to_i
  title = params['title'] || request.POST['title']

  halt 400, { error: "Title is required" }.to_json if title.nil? || title.strip.empty?

  existing_todo = db.execute('SELECT * FROM todos WHERE id = ?', [id]).first
  halt 404, { error: "TODO not found" }.to_json if existing_todo.nil?

  db.execute('UPDATE todos SET title = ? WHERE id = ?', [title, id])
  updated_todo = db.execute('SELECT * FROM todos WHERE id = ?', [id]).first

  # 🔥 RSpec のテストが `[id, title]` 形式を期待しているため変更
  [updated_todo['id'], updated_todo['title']].to_json
end

# ✅ TODOを削除 (API)
delete '/api/todos/:id' do
  db = TodoDB.connection
  id = params[:id].to_i

  existing_todo = db.execute('SELECT * FROM todos WHERE id = ?', [id]).first
  halt 404, { error: "TODO not found" }.to_json if existing_todo.nil?

  db.execute('DELETE FROM todos WHERE id = ?', [id])

  { message: "TODO deleted" }.to_json
end
