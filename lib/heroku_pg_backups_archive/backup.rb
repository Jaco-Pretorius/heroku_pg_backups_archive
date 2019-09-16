require 'time'

module HerokuPgBackupsArchive
  class Backup
    def self.create
      backup_output = CliHelper.capture_backup
      backup_id = backup_output.match(/Backing up .* to (.*)... done\n/)[1]

      new(backup_id)
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def file_name
      @file_name ||= CliHelper.download(id)
    end

    def finished_at
      @finished_at ||= begin
        info = CliHelper.fetch_backup_info(id)
        Time.parse(info.match(/Finished at:\s*(.*)\n/)[1])
      end
    end
  end
end
