FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install -y nodejs cron
WORKDIR /app
COPY . .
RUN bundle install
RUN  gem install rake
EXPOSE 3000
ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]