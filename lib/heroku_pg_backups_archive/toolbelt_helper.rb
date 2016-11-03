module HerokuPgBackupsArchive
  module ToolbeltHelper
    RETRIES = 5

    class << self
      def capture_backup
        run("pg:backups capture -a #{HerokuPgBackupsArchive.config.app_name} #{follower_db(HerokuPgBackupsArchive.config.app_name)}")
      end

      def fetch_backup_public_url(backup_id)
        run("pg:backups public-url #{backup_id} -q -a #{HerokuPgBackupsArchive.config.app_name}")
      end

      def fetch_backup_info(backup_id)
        run("pg:backups info #{backup_id} -a #{HerokuPgBackupsArchive.config.app_name}")
      end

      private

      def follower_db(app)
        output = run("pg:info --app #{app} | grep Followers | head -n 1")
        output.split(" ").last
      end

      def run(arguments)
        command = "#{HerokuPgBackupsArchive.config.heroku_toolbelt_path} #{arguments}"
        puts "Running: #{command}"

        retries_remaining = RETRIES
        begin
          output = `#{command} 2>&1`
          raise OperationFailedError.new(output) unless $?.success?
          puts "Output:\n#{output}"
          return output
        rescue OperationFailedError => ex
          retries_remaining -= 1
          if retries_remaining > 0
            puts "Failed, retrying..."
            retry
          else
            puts "Still failing after #{RETRIES} retries, giving up."
            raise ex
          end
        end
      end
    end
  end
end
