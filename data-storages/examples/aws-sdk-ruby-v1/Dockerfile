FROM ruby:1.9.3

COPY Gemfile Gemfile
RUN bundle install

ENV AWS_ACCESS_KEY_ID change-to-your-value
ENV AWS_SECRET_ACCESS_KEY change-to-your-value

COPY example.rb example.rb

ENTRYPOINT ruby example.rb
