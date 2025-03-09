require 'sqlite3'

DB_PATHS = {
  'development' => 'db/development.sqlite3',
  'test' => 'db/test.sqlite3'
}

ENV['RACK_ENV'] ||= 'development'
DB = SQLite3::Database.new(DB_PATHS[ENV['RACK_ENV']])
DB.results_as_hash = true  # **ここを追加**

# テーブルの作成（存在しない場合）
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
SQL

# サンプルの TODO を追加（テーブルが空の場合のみ）
if DB.execute('SELECT COUNT(*) FROM todos')[0][0] == 0
  sample_todos = [
    "TechTrain で Ruby を学ぶ",
    "SQLite の基本を理解する",
    "TODO アプリを完成させる"
  ]

  sample_todos.each do |title|
    DB.execute('INSERT INTO todos (title) VALUES (?)', [title])
  end
end

# **DB を他のファイルで使えるようにエクスポート**
module TodoDB
  def self.connection
    DB
  end
end
