require "heroku_pg_backups_archive/version"
require "heroku_pg_backups_archive/config"
require "heroku_pg_backups_archive/backup"
require "heroku_pg_backups_archive/backup_archive"
require "heroku_pg_backups_archive/backup_failed_error"
require "heroku_pg_backups_archive/toolbelt_helper"
require "heroku_pg_backups_archive/railtie"

module HerokuPgBackupsArchive
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def backup_and_archive
      backup = Backup.create
      BackupArchive.perform(backup)
    end
  end
end
