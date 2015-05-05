desc "Capture a backup and archive it to S3"
task heroku_pg_backups_archive: :environment do
  HerokuPgBackupsArchive.backup_and_archive
end
