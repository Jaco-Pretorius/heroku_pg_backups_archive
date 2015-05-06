describe HerokuPgBackupsArchive::Config do
  describe "#initialize" do
    let(:config) { HerokuPgBackupsArchive::Config.new }
    let(:aws_access_key_id) { "aws_access_key_id" }
    let(:aws_secret_access_key) { "aws_secret_access_key" }

    before do
      ENV["AWS_ACCESS_KEY_ID"] = aws_access_key_id
      ENV["AWS_SECRET_ACCESS_KEY"] = aws_secret_access_key
    end

    after do
      ENV["AWS_ACCESS_KEY_ID"] = nil
      ENV["AWS_SECRET_ACCESS_KEY"] = nil
    end

    it "sets sensible defaults" do
      expect(config.heroku_toolbelt_path).to eq "vendor/heroku-toolbelt/bin/heroku"
      expect(config.aws_access_key_id).to eq aws_access_key_id
      expect(config.aws_secret_access_key).to eq aws_secret_access_key
      expect(config.aws_region).to eq "us-east-1"
    end
  end
end
