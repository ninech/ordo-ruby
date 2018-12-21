FROM docker-registry.nine.ch/ninech/ruby:bionic
LABEL maintainer="engineering@nine.ch"

# Setup sqlite3 db
RUN apt-get update
RUN apt-get install sqlite3 libsqlite3-dev

# Copy the main application.
COPY . /app/

# Cache bundle install
RUN bundle install -j $(nproc)
RUN bundle exec appraisal install