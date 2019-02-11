require 'logger'
require 'active_support'
require 'active_record_mysql_xverify/version'
require 'active_record_mysql_xverify/constants'
require 'active_record_mysql_xverify/logger'
require 'active_record_mysql_xverify/utils'
require 'active_record_mysql_xverify/config'
require 'active_record_mysql_xverify/error_handler'
require 'active_record_mysql_xverify/verifier'
require 'active_record_mysql_xverify/verifiers/aurora_master'

ActiveSupport.on_load :active_record do
  require 'active_record/connection_adapters/postgresql_adapter'
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend ActiveRecordMysqlXverify::Verifier
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend ActiveRecordMysqlXverify::ErrorHandler
end
