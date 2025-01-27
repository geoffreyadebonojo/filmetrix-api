FROM ruby:3.1.3

# LABEL Name=api Version=0.0.1

# EXPOSE 3000

# # throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

# WORKDIR /app
# COPY . /app

# COPY Gemfile Gemfile.lock ./
# RUN bundle install

# RUN rake app:update:bin

# CMD ["rails", "server"]

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . /app

EXPOSE 3000

RUN rake app:update:bin

CMD ["rails", "server", "-b", "127.0.0.1", "-p", "3000"]
