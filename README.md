# active_record_mysql_xverify

It is a library that performs extended verification when an error occurs when executing SQL.

[![Gem Version](https://badge.fury.io/rb/active_record_mysql_xverify.svg)](http://badge.fury.io/rb/active_record_mysql_xverify)
[![Build Status](https://travis-ci.org/winebarrel/active_record_mysql_xverify.svg?branch=master)](https://travis-ci.org/winebarrel/active_record_mysql_xverify)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_mysql_xverify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_mysql_xverify

## Usage

```ruby
#!/usr/bin/env ruby
require 'active_record'
require 'active_record_mysql_xverify'
require 'logger'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     '127.0.0.1',
  username: 'root',
  database: 'bookshelf',
)

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.formatter = proc {|_, _, _, message| "#{message}\n" }

ActiveRecordMysqlXverify.verify = ->(conn) do
  conn.ping && false # force reconnect
end
# Default: ->(conn) { conn.ping }

ActiveRecordMysqlXverify.handle_if = ->(config) do
  config[:host] == '127.0.0.1'
end
# Default: ->(_) { true }

ActiveRecordMysqlXverify.only_on_error = false
# Default: true

# CREATE DATABASE IF NOT EXISTS bookshelf;
# CREATE TABLE bookshelf.books (id INT PRIMARY KEY);
class Book < ActiveRecord::Base; end

Book.count
prev_thread_id = Book.connection.raw_connection.thread_id

ActiveRecord::Base.connection_handler.connection_pool_list.each(&:release_connection)

Book.count
curr_thread_id = Book.connection.raw_connection.thread_id

p curr_thread_id == prev_thread_id #=> false
```


## Rails configuration

In `config/environments/production.rb`:

```ruby
ActiveRecordMysqlXverify.verify = ->(conn) do
  conn.ping && conn.query('show variables like "innodb_read_only"').first.fetch(1) == 'OFF'
end
# Same as below:
#   ActiveRecordMysqlXverify.verify = ActiveRecordMysqlXverify::Verifiers::AURORA_MASTER
```

## Rails log example

```
Started PATCH "/items/1" for 127.0.0.1 at 2018-11-15 15:47:31 +0900
Processing by ItemsController#update as */*
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"...", "item"=>{"name"=>"1", "price"=>"1", "time"=>"1542264451"}, "commit"=>"Update Item", "id"=>"1"}
  Item Load (26.6ms)  SELECT  `items`.* FROM `items` WHERE `items`.`id` = 1 LIMIT 1
Completed 500 Internal Server Error in 136ms (ActiveRecord: 131.3ms)
ActiveRecord::StatementInvalid (Mysql2::Error: MySQL client is not connected: ROLLBACK):

...

Mysql2::Error::ConnectionError (Can't connect to MySQL server on 'my-cluster.cluster-xxx.ap-northeast-1.rds.amazonaws.com' (61)):

...

Started PATCH "/items/1" for 127.0.0.1 at 2018-11-15 15:47:35 +0900
Processing by ItemsController#update as */*
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"...", "item"=>{"name"=>"1", "price"=>"1", "time"=>"1542264454"}, "commit"=>"Update Item", "id"=>"1"}
  SQL (27.8ms)  UPDATE `items` SET `time` = '1542264454', `updated_at` = '2018-11-15 06:47:35' WHERE `items`.`id` = 1
Completed 500 Internal Server Error in 134ms (ActiveRecord: 126.9ms)
ActiveRecord::StatementInvalid (Mysql2::Error: The MySQL server is running with the --read-only option so it cannot execute this statement: UPDATE `items` SET `time` = '1542264454', `updated_at` = '2018-11-15 06:47:35' WHERE `items`.`id` = 1):

...

Started PATCH "/items/1" for 127.0.0.1 at 2018-11-15 15:47:36 +0900
Invalid connection: host=my-cluster.cluster-xxx.ap-northeast-1.rds.amazonaws.com, database=my_production_db, username=scott, thread_id=4
Processing by ItemsController#update as */*
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"...", "item"=>{"name"=>"1", "price"=>"1", "time"=>"1542264456"}, "commit"=>"Update Item", "id"=>"1"}
  SQL (35.8ms)  UPDATE `items` SET `time` = '1542264456', `updated_at` = '2018-11-15 06:47:37' WHERE `items`.`id` = 1
Completed 500 Internal Server Error in 145ms (ActiveRecord: 140.8ms)
ActiveRecord::StatementInvalid (Mysql2::Error: The MySQL server is running with the --read-only option so it cannot execute this statement: UPDATE `items` SET `time` = '1542264456', `updated_at` = '2018-11-15 06:47:37' WHERE `items`.`id` = 1):

...
...
...

Started PATCH "/items/1" for 127.0.0.1 at 2018-11-15 15:47:49 +0900
Invalid connection: host=my-cluster.cluster-xxx.ap-northeast-1.rds.amazonaws.com, database=my_production_db, username=scott, thread_id=11
Processing by ItemsController#update as */*
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"...", "item"=>{"name"=>"1", "price"=>"1", "time"=>"1542264469"}, "commit"=>"Update Item", "id"=>"1"}
  Item Load (44.6ms)  SELECT  `items`.* FROM `items` WHERE `items`.`id` = 1 LIMIT 1
   (36.5ms)  BEGIN
  SQL (29.5ms)  UPDATE `items` SET `time` = '1542264469', `updated_at` = '2018-11-15 06:47:50' WHERE `items`.`id` = 1
   (34.5ms)  COMMIT
Redirected to http://localhost:3000/items/1
Completed 302 Found in 150ms (ActiveRecord: 145.2ms)
```
