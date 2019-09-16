module HerokuPgBackupsArchive
  class Config
    attr_accessor :app_name,
      :sse_customer_key,
      :bucket_name,
      :aws_access_key_id,
      :aws_secret_access_key,
      :aws_region,
      :after_complete

    def initialize
      @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
      @aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      @aws_region = 'us-east-1'
    end
  end
end
