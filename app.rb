require 'sinatra'
require './db/todos'  # データベースの設定を読み込む

get '/' do
  "Hello World"
end

# TODO一覧の表示
get '/todos' do
  db = TodoDB.connection
  db.results_as_hash = false  # 結果をハッシュではなく、配列の配列で取得
  @todos = db.execute('SELECT id, title FROM todos')  # id も取得
  erb :todos
end

# TODOの作成処理
post '/todos' do
  TodoDB.connection.execute('INSERT INTO todos (title) VALUES (?)', [params[:title]])
  redirect '/todos'  # 作成後にリストページへリダイレクト
end

# TODO編集画面の表示
get '/todos/:id/edit' do
  db = TodoDB.connection
  db.results_as_hash = false  # 結果を配列で取得
  @todo = db.execute('SELECT id, title FROM todos WHERE id = ?', [params[:id].to_i]).first

  erb :edit  # views/edit.erb を表示
end
