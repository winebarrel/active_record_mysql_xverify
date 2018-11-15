module ActiveRecordMysqlXverify
  class << self
    def logger
      @logger ||= if defined?(Rails)
                    Rails.logger || ActiveRecord::Base.logger || Logger.new($stderr)
                  else
                    ActiveRecord::Base.logger || Logger.new($stderr)
                  end
    end
  end
end
