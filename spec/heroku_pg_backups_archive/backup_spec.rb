describe HerokuPgBackupsArchive::Backup do
  let(:backup_output) do
    <<-SQL
Starting backup of postgresql-curly-63501... done

Use Ctrl-C at any time to stop monitoring progress; the backup will continue running.
Use heroku pg:backups:info to check progress.
Stop a running backup with heroku pg:backups:cancel.

Backing up IVORY to b022... done
    SQL
  end

  before do
    allow(HerokuPgBackupsArchive::CliHelper).to receive(:capture_backup).and_return(backup_output)
  end

  describe ".create" do
    it "captures a new backup and returns a `Backup` object" do
      backup = HerokuPgBackupsArchive::Backup.create
      expect(backup.id).to eq 'b022'
    end
  end

  describe "#file_name" do
    before do
      allow(HerokuPgBackupsArchive::CliHelper).to receive(:download).with("b022").and_return('b022.dump')
    end

    it "returns the chomped URL returned by heroku" do
      backup_object = HerokuPgBackupsArchive::Backup.new('b022')
      expect(backup_object.file_name).to eq 'b022.dump'
    end
  end

  describe "#finished_at" do
    let(:backup_info_output) do
      <<-SQL
=== Backup b022
Database:         COLOR
Started at:       2016-12-15 15:17:54 +0000
Finished at:      2016-12-15 15:19:39 +0000
Status:           Completed
Type:             Manual
Original DB Size: 192.33MB
Backup Size:      39.79MB (79% compression)

=== Backup Logs
2016-12-15 15:17:54 +0000 pg_dump: reading schemas
2016-12-15 15:17:54 +0000 pg_dump: reading user-defined tables
2016-12-15 15:17:57 +0000 pg_dump: reading extensions
      SQL
    end

    before do
      allow(HerokuPgBackupsArchive::CliHelper).to receive(:fetch_backup_info).with('b022').and_return(backup_info_output)
    end

    it "returns the time that the backup finished" do
      backup_object = HerokuPgBackupsArchive::Backup.new('b022')
      expect(backup_object.finished_at).to eq Time.parse('2016-12-15 15:19:39 +0000')
    end
  end
end
