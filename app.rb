require 'sinatra'
require './db/todos'  # データベースの設定を読み込む

get '/' do
  "Hello World"
end

# TODO一覧の表示
get '/todos' do
  db = TodoDB.connection
  db.results_as_hash = false  # テストが配列を期待しているので false にする
  @todos = db.execute('SELECT id, title FROM todos')
  erb :todos
end

# TODOの作成処理
post '/todos' do
  db = TodoDB.connection
  db.execute('INSERT INTO todos (title) VALUES (?)', [params[:title]])
  redirect to('/todos')  # 作成後にリストページへリダイレクト
end

# TODOの編集画面を表示
get '/todos/:id/edit' do
  db = TodoDB.connection
  db.results_as_hash = false  # テストが配列を期待しているので false にする
  @todo = db.execute('SELECT id, title FROM todos WHERE id = ?', [params[:id].to_i]).first

  # `@todo` が `nil` の場合はエラーハンドリングする
  halt 404, "TODO not found" if @todo.nil?

  erb :edit
end

# TODOの更新処理 (PUT /todos/:id)
put '/todos/:id' do
  db = TodoDB.connection
  db.results_as_hash = false  # 配列形式で取得

  # 更新前のデータ取得（デバッグ用）
  before_update = db.execute('SELECT title FROM todos WHERE id = ?', [params[:id].to_i]).first
  puts "Before Update: #{before_update.inspect}"

  # 更新クエリ実行
  db.execute('UPDATE todos SET title = ? WHERE id = ?', [params[:title], params[:id].to_i])

  # 更新後の影響行数を確認
  affected_rows = db.changes
  puts "Rows Updated: #{affected_rows}"  # `1` でなければ更新失敗

  # **テストコードが `expect(updated_todo[0])` を期待しているため、1次元配列に変換**
  updated_todo = db.execute('SELECT title FROM todos WHERE id = ?', [params[:id].to_i])
  updated_todo = updated_todo.map(&:first)  # [["更新後のTODO"]] → ["更新後のTODO"]

  # デバッグ出力
  puts "Updated TODO: #{updated_todo.inspect}"  # `["更新後のTODO"]` になっているか確認

  # `expect(updated_todo[0])` に対応
  redirect to('/todos')
end

# TODOの削除処理 (DELETE /todos/:id)
delete '/todos/:id' do
  db = TodoDB.connection

  # 削除クエリ実行
  db.execute('DELETE FROM todos WHERE id = ?', [params[:id].to_i])

  # デバッグ出力
  puts "Deleted TODO ID: #{params[:id].to_i}"

  redirect to('/todos')  # 削除後に一覧画面へリダイレクト
end
