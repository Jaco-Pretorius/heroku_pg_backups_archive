module HerokuPgBackupsArchive
  module CliHelper
    class << self
      def capture_backup
        run("pg:backups:capture")
      end

      def download_backup(backup_id)
        backup_file_name = "#{backup_id}.dump"
        run("pg:backups:download #{backup_id} -o #{backup_file_name}")
        backup_file_name
      end

      def fetch_backup_info(backup_id)
        run("pg:backups:info #{backup_id}")
      end

      private

      def run(arguments)
        app_name = HerokuPgBackupsArchive.config.app_name
        command = "heroku run 'heroku #{arguments}' -a #{app_name}"
        puts "Running: #{command}"

        output = `#{command} 2>&1`
        raise OperationFailedError.new(output) unless $?.success?
        puts "Output:\n#{output}"
        return output
      end
    end
  end
end
