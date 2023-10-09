# frozen_string_literal: true

module ActiveRecordMysqlXverify
  module Verifier
    def active?
      if (@raw_connection || @connection) && _extend_verify?
        is_active = begin
          verifier = ActiveRecordMysqlXverify.verify
          verifier.call(@raw_connection || @connection)
        rescue StandardError => e
          ActiveRecordMysqlXverify.logger.warn("Connection verification failed: #{_build_verify_error_message(e)}")
          false
        ensure
          Thread.current[ActiveRecordMysqlXverify::EXTEND_VERIFY_FLAG] = false
        end

        unless is_active
          ActiveRecordMysqlXverify.logger.info(
            "Invalid connection: #{ActiveRecordMysqlXverify::Utils.mysql2_connection_info(@raw_connection || @connection)}"
          )
        end

        is_active
      else
        super
      end
    end

    def _build_verify_error_message(e)
      "cause: #{e.message} [#{e.class}, " + ActiveRecordMysqlXverify::Utils.mysql2_connection_info(@raw_connection || @connection)
    end

    def _extend_verify?
      handle_if = ActiveRecordMysqlXverify.handle_if
      (!ActiveRecordMysqlXverify.only_on_error || Thread.current[ActiveRecordMysqlXverify::EXTEND_VERIFY_FLAG]) && handle_if.call(@config)
    end
  end
end
