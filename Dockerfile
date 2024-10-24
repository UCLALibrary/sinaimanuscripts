FROM ruby:2.6

RUN apt-get update -qq
RUN apt-get install mariadb-client build-essential libpq-dev yarn nodejs chromium-driver libatk-bridge2.0-0 libgtk-3.0 -y

WORKDIR /sinai

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN bundle install

COPY / /sinai
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

EXPOSE 3000