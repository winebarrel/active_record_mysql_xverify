FROM rubylang/ruby:2.7

RUN apt-get update && \
  apt-get install -y \
  mysql-client \
  libmysqlclient-dev \
  rubygems

WORKDIR /mnt
COPY Gemfile* ./
COPY lib/active_record_mysql_xverify/version.rb ./lib/active_record_mysql_xverify/
COPY Appraisals ./
COPY activerecord_mysql_xverify.gemspec ./
RUN gem update bundler -f && \
  bundle install && \
  bundle exec appraisal install
