FROM ruby:3.0.0
RUN apt-get update -qq && apt-get install -y nodejs cron
WORKDIR /app
COPY . .
RUN gem install rake
RUN gem install whenever
RUN bundle install
EXPOSE 3000
ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]