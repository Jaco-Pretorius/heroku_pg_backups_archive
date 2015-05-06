describe HerokuPgBackupsArchive::ToolbeltHelper do
  let(:config) do
    double(
      :config,
      heroku_toolbelt_path: "/path/to/heroku",
      app_name: "my-heroku-app"
    )
  end

  before do
    allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:puts)
    allow(HerokuPgBackupsArchive).to receive(:config).and_return(config)
  end

  describe ".capture_backup" do
    let(:output) { double(:output) }

    before do
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:`).with(
        "/path/to/heroku pg:backups capture -a my-heroku-app 2>&1"
      ).and_return(output)
    end

    it "calls the toolbelt with the appropriate arguments and returns the output" do
      expect(HerokuPgBackupsArchive::ToolbeltHelper.capture_backup).to eq output
    end
  end

  describe ".fetch_backup_public_url" do
    let(:backup_id) { "b022" }
    let(:output) { double(:output) }

    before do
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:`).with(
        "/path/to/heroku pg:backups public-url b022 -q -a my-heroku-app 2>&1"
      ).and_return(output)
    end

    it "calls the toolbelt with the appropriate arguments and returns the output" do
      expect(HerokuPgBackupsArchive::ToolbeltHelper.fetch_backup_public_url(backup_id)).to eq output
    end
  end

  describe ".fetch_backup_info" do
    let(:backup_id) { "b022" }
    let(:output) { double(:output) }

    before do
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:`).with(
        "/path/to/heroku pg:backups info b022 -a my-heroku-app 2>&1"
      ).and_return(output)
    end

    it "calls the toolbelt with the appropriate arguments and returns the output" do
      expect(HerokuPgBackupsArchive::ToolbeltHelper.fetch_backup_info(backup_id)).to eq output
    end
  end
end
