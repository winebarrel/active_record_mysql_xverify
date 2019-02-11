module ActiveRecordMysqlXverify
  module Utils
    class << self
      def mysql2_connection_info(conn)
        thread_id = begin
                      conn.thread_id
                    rescue StandardError
                      nil
                    end
        "host=#{conn.conninfo_hash[:host]}, dbname=#{conn.conninfo_hash[:dbname]}, " \
          "username=#{conn.query_options[:username]}, thread_id=#{thread_id}"
      end
    end
  end
end
