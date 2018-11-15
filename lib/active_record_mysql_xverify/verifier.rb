module ActiveRecordMysqlXverify
  module Verifier
    def active?
      if _extend_verify?
        is_active = begin
                      verifier = ActiveRecordMysqlXverify.verify
                      verifier.call(@connection)
                    rescue StandardError => e
                      ActiveRecordMysqlXverify.logger.warn("Connection verification failed: #{_build_verify_error_message(e)}")
                      false
                    ensure
                      Thread.current[ActiveRecordMysqlXverify::EXTEND_VERIFY_FLAG] = false
                    end

        unless is_active
          ActiveRecordMysqlXverify.logger.info(
            "Invalid connection: #{ActiveRecordMysqlXverify::Utils.mysql2_connection_info(@connection)}"
          )
        end

        is_active
      else
        super
      end
    end

    def _build_verify_error_message(e)
      "cause: #{e.message} [#{e.class}, " + ActiveRecordMysqlXverify::Utils.mysql2_connection_info(@connection)
    end

    def _extend_verify?
      handle_if = ActiveRecordMysqlXverify.handle_if
      (Thread.current[ActiveRecordMysqlXverify::EXTEND_VERIFY_FLAG] || !ActiveRecordMysqlXverify.only_on_error) && handle_if.call(@config)
    end
  end
end
