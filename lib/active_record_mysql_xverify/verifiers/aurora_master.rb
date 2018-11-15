module ActiveRecordMysqlXverify
  module Verifiers
    AURORA_MASTER = lambda do |conn|
      conn.ping && conn.query('show variables like "innodb_read_only"').first.fetch(1) == 'OFF'
    end
  end
end
