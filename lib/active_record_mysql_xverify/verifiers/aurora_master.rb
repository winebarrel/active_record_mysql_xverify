# frozen_string_literal: true

module ActiveRecordMysqlXverify
  module Verifiers
    AURORA_MASTER = lambda do |conn|
      conn.ping && conn.query(
        'select @@innodb_read_only',
        {
          as: :hash,
          async: false,
          symbolize_keys: false,
          cast: true,
        }
      ).first.fetch('@@innodb_read_only').zero?
    end
  end
end
