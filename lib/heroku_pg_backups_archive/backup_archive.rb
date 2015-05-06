require "open-uri"
require "aws-sdk"
require "base64"

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
      s3.put_object(write_parameters)
    end

    private

    attr_reader :backup

    def s3
      @s3 ||= Aws::S3::Client.new(
        access_key_id: HerokuPgBackupsArchive.config.aws_access_key_id,
        secret_access_key: HerokuPgBackupsArchive.config.aws_secret_access_key,
        region: HerokuPgBackupsArchive.config.aws_region
      )
    end

    def archive_path
      "#{backup.finished_at.strftime("%Y/%m/%d")}/#{backup.finished_at.iso8601}"
    end

    def backup_data
      open(backup.url)
    end

    def write_parameters
      {
        body: backup_data,
        bucket: HerokuPgBackupsArchive.config.bucket_name,
        key: archive_path
      }.merge(sse_customer_options)
    end

    def sse_customer_options
      unless HerokuPgBackupsArchive.config.sse_customer_key.nil?
        {
          sse_customer_algorithm: :AES256,
          sse_customer_key: HerokuPgBackupsArchive.config.sse_customer_key
        }
      else
        {}
      end
    end
  end
end
