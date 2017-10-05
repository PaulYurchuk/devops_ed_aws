FROM ruby:1.9.3

COPY Gemfile Gemfile
RUN bundle install

ENV AWS_ACCESS_KEY_ID AKIAIUNUWCRQDQTQINSQ
ENV AWS_SECRET_ACCESS_KEY 5VoWgMvnJ69hzjKu0Y6BjeEGxCwMdpHZBCcIZcYM

COPY example.rb example.rb

ENTRYPOINT ruby example.rb
