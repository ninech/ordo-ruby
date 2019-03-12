ARG RUBY_VERSION=2.3.4
FROM ruby:${RUBY_VERSION}
LABEL maintainer="engineering@nine.ch"

# Setup sqlite3 db
RUN apt-get update
RUN apt-get install -y sqlite3 libsqlite3-dev

# Copy gemfile
COPY Gemfile Gemfile.lock ordy.gemspec Appraisals ./
COPY gemfiles ./gemfiles

# Cache bundle install
RUN bundle install -j $(nproc)
RUN bundle exec appraisal install

# Copy the main application.
COPY . /app/