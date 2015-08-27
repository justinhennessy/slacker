require 'logger'

class SendLog
  def self.log
    if @logger.nil?
      @logger = Logger.new "/srv/app/application.log"
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end
end
