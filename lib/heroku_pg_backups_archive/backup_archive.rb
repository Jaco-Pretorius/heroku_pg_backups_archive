require 'aws-sdk'
require 'digest'

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
      s3_object = Aws::S3::Object.new(HerokuPgBackupsArchive.config.bucket_name, s3_path, client: s3_client)
      s3_object.upload_file(backup.file_name, sse_customer_options)
    end

    private

    attr_reader :backup

    def s3_client
      credentials = Aws::Credentials.new(
        HerokuPgBackupsArchive.config.aws_access_key_id,
        HerokuPgBackupsArchive.config.aws_secret_access_key
      )

      Aws::S3::Client.new(
        credentials: credentials,
        region: HerokuPgBackupsArchive.config.aws_region
      )
    end

    def sse_customer_options
      if HerokuPgBackupsArchive.config.sse_customer_key.nil?
        {}
      else
        {
          sse_customer_algorithm: :AES256,
          sse_customer_key: HerokuPgBackupsArchive.config.sse_customer_key,
          sse_customer_key_md5: Digest::MD5.hexdigest(HerokuPgBackupsArchive.config.sse_customer_key)
        }
      end
    end
  end
end
