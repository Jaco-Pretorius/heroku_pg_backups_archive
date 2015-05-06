module HerokuPgBackupsArchive
  class Backup
    def self.create
      backup_output = ToolbeltHelper.capture_backup
      new(backup_output)
    end

    attr_reader :id

    def initialize(backup_output)
      @id = extract_id(backup_output)
    end

    def url
      @url ||= ToolbeltHelper.fetch_backup_public_url(id).chomp
    end

    def finished_at
      @finished_at ||= begin
        info = ToolbeltHelper.fetch_backup_info(id)
        Time.parse(info.match(/Finished:\s*(.*)\n/)[1])
      end
    end

    private

    def extract_id(backup_output)
      backup_output.match(/---backup---> (.*)\n/)[1]
    end
  end
end
