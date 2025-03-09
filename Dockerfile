FROM ruby:3.2

# 作業ディレクトリを設定
WORKDIR /app

# アプリケーションのコードをコンテナにコピー
COPY . /app/

# 必要な Gem をインストール
RUN bundle install

# アプリケーションを実行
CMD ["ruby", "app.rb"]
