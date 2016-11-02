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
      allow(HerokuPgBackupsArchive::ToolbeltHelper).to receive(:`) do |arg|
        case arg
        when "/path/to/heroku pg:info --app my-heroku-app | grep Followers | head -n 1 2>&1"
          follower_output
        when capture_cmd
          output
        else
          raise "Unexpected arguments #{arg}"
        end
      end
    end

    context "when there is a follower" do
      let(:follower_output) { "Followers: follower-db" }
      let(:capture_cmd) { "/path/to/heroku pg:backups capture -a my-heroku-app follower-db 2>&1" }

      it "calls the toolbelt with the appropriate arguments and returns the output" do
        expect(HerokuPgBackupsArchive::ToolbeltHelper.capture_backup).to eq output
      end
    end

    context "when there is no follower" do
      let(:follower_output) { "" }
      let(:capture_cmd) { "/path/to/heroku pg:backups capture -a my-heroku-app  2>&1" }

      it "calls the toolbelt with the appropriate arguments and returns the output" do
        expect(HerokuPgBackupsArchive::ToolbeltHelper.capture_backup).to eq output
      end
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
