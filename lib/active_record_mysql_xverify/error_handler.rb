module ActiveRecordMysqlXverify
  module ErrorHandler
    def execute_and_clear(*)
      super
    rescue StandardError
      _flag_extend_verify!
      raise
    end

    def _flag_extend_verify!
      Thread.current[ActiveRecordMysqlXverify::EXTEND_VERIFY_FLAG] = true
    end
  end
end
