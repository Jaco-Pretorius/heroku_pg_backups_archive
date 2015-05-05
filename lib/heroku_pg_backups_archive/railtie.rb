if defined?(Rails)
  module HerokuPgBackupsArchive
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/heroku_pg_backups_archive.rake"
      end
    end
  end
end
