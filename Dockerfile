FROM ruby:3.3
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV APP /app
WORKDIR $APP
RUN apt-get update -qq && apt-get install -y chromium  build-essential libpq-dev nodejs npm postgresql-client \
    && npm install -g yarn \
    && gem install bundler \
    && gem install rails -v "7.2.2.1" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*