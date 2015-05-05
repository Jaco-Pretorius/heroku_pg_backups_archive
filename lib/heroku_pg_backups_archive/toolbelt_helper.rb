module HerokuPgBackupsArchive
  module ToolbeltHelper
    class << self
      def capture_backup
        run("pg:backups capture -a #{HerokuPgBackupsArchive.config.app_name}")
      end

      def fetch_backup_public_url(backup_id)
        run("pg:backups public-url #{backup_id} -q -a #{HerokuPgBackupsArchive.config.app_name}")
      end

      def fetch_backup_info(backup_id)
        run("pg:backups info #{backup_id} -a #{HerokuPgBackupsArchive.config.app_name}")
      end

      private

      def run(arguments)
        command = "#{HerokuPgBackupsArchive.config.heroku_toolbelt_path} #{arguments}"
        puts "Running: #{command}"
        output = `#{command}`
        puts "Output:\n#{output}"
        output
      end
    end
  end
end
