FROM rubylang/ruby:2.7

RUN apt-get update && \
  apt-get install -y \
  mysql-client \
  libmysqlclient-dev \
  rubygems

WORKDIR /mnt
