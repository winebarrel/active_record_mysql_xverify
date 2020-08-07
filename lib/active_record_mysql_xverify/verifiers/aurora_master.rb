# frozen_string_literal: true

module ActiveRecordMysqlXverify
  module Verifiers
    AURORA_MASTER = lambda do |conn|
      conn.ping && conn.query('select @@innodb_read_only').first.fetch('@@innodb_read_only').zero?
    end
  end
end
