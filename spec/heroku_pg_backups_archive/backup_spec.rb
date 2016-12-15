describe HerokuPgBackupsArchive::Backup do
  describe ".create" do
    let(:backup_output) { double(:backup_output) }
    let(:backup_object) { double(:backup_object) }

    before do
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:capture_backup).and_return(backup_output)
      allow(HerokuPgBackupsArchive::Backup).to receive(:new).with(backup_output).and_return(backup_object)
    end

    it "creates a new backup and returns a `Backup` object" do
      expect(HerokuPgBackupsArchive::Backup.create).to eq backup_object
    end
  end

  let(:backup_output) do
    <<-SQL
Starting backup of postgresql-curly-63501... done

Use Ctrl-C at any time to stop monitoring progress; the backup will continue running.
Use heroku pg:backups:info to check progress.
Stop a running backup with heroku pg:backups:cancel.

Backing up IVORY to b022... done
    SQL
  end

  describe "#id" do
    it "extracts the ID from output" do
      expect(HerokuPgBackupsArchive::Backup.new(backup_output).id).to eq "b022"
    end
  end

  describe "#url" do
    let(:backup_object) { HerokuPgBackupsArchive::Backup.new(backup_output) }
    let(:public_url) { "http://example.com/foo3432423\n" }

    before do
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:fetch_backup_public_url).with("b022").and_return(public_url)
    end

    it "returns the chomped URL returned by heroku" do
      expect(backup_object.url).to eq "http://example.com/foo3432423"
    end
  end

  describe "#finished_at" do
    let(:backup_object) { HerokuPgBackupsArchive::Backup.new(backup_output) }
    let(:backup_info) do
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
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:fetch_backup_info).with("b022").and_return(backup_info)
    end

    it "returns the time that the backup finished" do
      expect(backup_object.finished_at).to eq Time.parse("2016-12-15 15:19:39 +0000")
    end
  end
end
