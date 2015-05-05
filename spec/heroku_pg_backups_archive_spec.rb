describe HerokuPgBackupsArchive do
  describe ".backup_and_archive" do
    let(:backup) { double(:backup) }

    before do
      allow(HerokuPgBackupsArchive::Backup).to receive(:create).and_return(backup)
      allow(HerokuPgBackupsArchive::BackupArchive).to receive(:perform)

      HerokuPgBackupsArchive.backup_and_archive
    end

    it "creates a backup and archives it" do
      expect(HerokuPgBackupsArchive::BackupArchive).to have_received(:perform).with(backup)
    end
  end
end
