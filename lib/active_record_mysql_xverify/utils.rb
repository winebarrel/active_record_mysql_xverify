# frozen_string_literal: true

module ActiveRecordMysqlXverify
  module Utils
    class << self
      def mysql2_connection_info(conn)
        thread_id = begin
                      conn.thread_id
                    rescue StandardError
                      nil
                    end

        "host=#{conn.query_options[:host]}, database=#{conn.query_options[:database]}, " \
          "username=#{conn.query_options[:username]}, thread_id=#{thread_id}"
      end
    end
  end
end
