FROM rubylang/ruby:2.5-bionic

RUN apt-get update && \
  apt-get install -y \
  mysql-client \
  libmysqlclient-dev \
  rubygems

COPY ./ /mnt/
WORKDIR /mnt
RUN gem update bundler -f && \
  bundle install && \
  bundle exec appraisal install
