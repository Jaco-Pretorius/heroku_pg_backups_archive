describe HerokuPgBackupsArchive::BackupArchive do
  describe ".perform" do
    let(:backup_object) { double(:backup_object) }
    let(:backup_archive) { double(:backup_archive) }

    before do
      allow(HerokuPgBackupsArchive::BackupArchive).to receive(:new).with(backup_object).and_return(backup_archive)
      allow(backup_archive).to receive(:perform)

      HerokuPgBackupsArchive::BackupArchive.perform(backup_object)
    end

    it "archives the backup object" do
      expect(backup_archive).to have_received(:perform)
    end
  end

  describe "#perform" do
    let(:backup_archive) { HerokuPgBackupsArchive::BackupArchive.new(backup_object) }
    let(:backup_object) do
      double(
        :backup_object,
        url: "https://example.com/foo-bar",
        finished_at: Time.parse("2015-05-05 19:11:05 +0000")
      )
    end
    let(:config) do
      double(
        :config,
        sse_customer_key: sse_customer_key,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        aws_region: aws_region,
        bucket_name: bucket_name
      )
    end
    let(:aws_access_key_id) { double(:aws_access_key_id) }
    let(:aws_secret_access_key) { double(:aws_secret_access_key) }
    let(:aws_region) { double(:aws_region) }
    let(:bucket_name) { "the-backup-bucket" }
    let(:s3_client) { double(:s3_client) }
    let(:backup_data) { double(:backup_data) }

    before do
      allow(HerokuPgBackupsArchive).to receive(:config).and_return(config)
      allow(Aws::S3::Client).to receive(:new).with(
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region: aws_region
      ).and_return(s3_client)
      allow(s3_client).to receive(:put_object)
      allow(backup_archive).to receive(:open).with("https://example.com/foo-bar").and_return(backup_data)

      backup_archive.perform
    end

    context "when a SSE-C key is configured" do
      let(:sse_customer_key) { "some-key-thats-a-secret" }

      it "writes the file to S3 with SSE-C" do
        expect(s3_client).to have_received(:put_object).with(
          body: backup_data,
          bucket: bucket_name,
          key: "2015/05/05/2015-05-05T19:11:05+00:00",
          sse_customer_algorithm: :AES256,
          sse_customer_key: sse_customer_key
        )
      end
    end

    context "when a SSE-C key is configured" do
      let(:sse_customer_key) { nil }

      it "writes the file to S3 without SSE-C" do
        expect(s3_client).to have_received(:put_object).with(
          body: backup_data,
          bucket: bucket_name,
          key: "2015/05/05/2015-05-05T19:11:05+00:00"
        )
      end
    end
  end
end
