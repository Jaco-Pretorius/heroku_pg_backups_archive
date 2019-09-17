module HerokuPgBackupsArchive
  module CliHelper
    class << self
      def capture_backup
        run("pg:backups:capture -a #{app_name}")
      end

      def download_backup(backup_id)
        backup_file_name = "#{backup_id}.dump"
        run("pg:backups:download #{backup_id} -o #{backup_file_name}")
        backup_file_name
      end

      def fetch_backup_info(backup_id)
        run("pg:backups:info #{backup_id} -a #{app_name}")
      end

      private

      def app_name
        HerokuPgBackupsArchive.config.app_name
      end

      def run(arguments)
        command = "heroku #{arguments}"
        puts "Running: #{command}"

        output = `#{command} 2>&1`
        raise OperationFailedError.new(output) unless $?.success?
        puts "Output:\n#{output}"
        return output
      end
    end
  end
end
