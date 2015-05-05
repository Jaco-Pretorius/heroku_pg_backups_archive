require "open-uri"
require "aws-sdk-v1"
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
      bucket.objects[archive_path].write(backup_data, write_options)
    end

    private

    attr_reader :backup

    def bucket
      @bucket ||= s3.buckets[HerokuPgBackupsArchive.config.bucket_name]
    end

    def s3
      @s3 ||= AWS::S3.new(
        access_key_id: HerokuPgBackupsArchive.config.aws_access_key_id,
        secret_access_key: HerokuPgBackupsArchive.config.aws_secret_access_key
      )
    end

    def archive_path
      "#{backup.finished_at.strftime("%Y/%m/%d")}/#{backup.finished_at.iso8601}"
    end

    def backup_data
      open(backup.url)
    end

    def write_options
      unless HerokuPgBackupsArchive.config.sse_customer_key.nil?
        {
          sse_customer_algorithm: :AES256,
          sse_customer_key: Base64.encode64(HerokuPgBackupsArchive.config.sse_customer_key),
          sse_customer_key_md5: Base64.encode64(OpenSSL::Digest::MD5.digest(HerokuPgBackupsArchive.config.sse_customer_key))
        }
      else
        {}
      end
    end
  end
end
