require 'aws-sdk'

module HerokuPgBackupsArchive
  class BackupArchive
    def self.perform(backup)
      backup_archive = new(backup)
      backup_archive.perform
    end

    def initialize(backup)
      @backup = backup
    end

    def perform
      s3_path = HerokuPgBackupsArchive.config.s3_path.call(backup.finished_at)
      s3_client.put_object({
        body: backup.file_name,
        bucket: HerokuPgBackupsArchive.config.bucket_name,
        key: s3_path
      }.merge(sse_customer_options))
    end

    private

    attr_reader :backup

    def s3_client
      @s3 ||= Aws::S3::Client.new(
        access_key_id: HerokuPgBackupsArchive.config.aws_access_key_id,
        secret_access_key: HerokuPgBackupsArchive.config.aws_secret_access_key,
        region: HerokuPgBackupsArchive.config.aws_region
      )
    end

    def sse_customer_options
      if HerokuPgBackupsArchive.config.sse_customer_key.nil?
        {}
      else
        {
          sse_customer_algorithm: :AES256,
          sse_customer_key: HerokuPgBackupsArchive.config.sse_customer_key
        }
      end
    end
  end
end
