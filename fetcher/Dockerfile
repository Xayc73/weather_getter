FROM ruby:3.4

WORKDIR /app

RUN gem install bundler --no-document

COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app

CMD ["ruby", "main.rb"]




