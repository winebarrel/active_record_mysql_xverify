require 'bundler/setup'
require 'active_record'
require 'active_record_mysql_xverify'
require 'model/book.rb'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :all do
    conn_spec = {
      adapter: 'mysql2',
      host: '127.0.0.1',
      username: 'root',
      database: 'bookshelf',
      port: 6033,
    }

    ActiveRecord::Base.establish_connection(conn_spec)

    @mysql = Mysql2::Client.new(
      host: conn_spec.fetch(:host),
      port: conn_spec.fetch(:port),
      username: conn_spec.fetch(:username)
    )

    @mysql.query('CREATE DATABASE IF NOT EXISTS bookshelf')
    @mysql.query('CREATE TABLE bookshelf.books (id INT PRIMARY KEY)')
  end

  config.after :all do
    @mysql.query('DROP DATABASE IF EXISTS bookshelf')
  end
end

module SpecHelper
  def active_record_release_connections
    ActiveRecord::Base.connection_handler.connection_pool_list.each(&:release_connection)
  end
end
include SpecHelper # rubocop:disable Style/MixinUsage
