describe HerokuPgBackupsArchive do
  describe ".backup_and_archive" do
    let(:backup) { double(:backup) }
    let(:config) { double(:config, after_complete: after_complete) }

    before do
      allow(HerokuPgBackupsArchive).to receive(:config).and_return(config)
      allow(HerokuPgBackupsArchive::Backup).to receive(:create).and_return(backup)
      allow(HerokuPgBackupsArchive::BackupArchive).to receive(:perform)
    end

    context "when there's no after_complete proc specified" do
      let(:after_complete) { nil }

      before do
        HerokuPgBackupsArchive.backup_and_archive
      end

      it "creates a backup and archives it" do
        expect(HerokuPgBackupsArchive::BackupArchive).to have_received(:perform).with(backup)
      end
    end

    context "when there is an after_complete proc specified" do
      let(:after_complete) { double(:after_complete) }

      before do
        allow(after_complete).to receive(:call)

        HerokuPgBackupsArchive.backup_and_archive
      end

      it "creates a backup, archives it, and calls the after_complete proc" do
        expect(HerokuPgBackupsArchive::BackupArchive).to have_received(:perform).with(backup).ordered
        expect(after_complete).to have_received(:call).ordered
      end
    end
  end
end
