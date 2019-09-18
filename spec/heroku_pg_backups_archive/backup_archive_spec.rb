describe HerokuPgBackupsArchive::BackupArchive do
  describe '#perform' do
    let(:backup_archive) { HerokuPgBackupsArchive::BackupArchive.new(backup_object) }
    let(:backup_object) do
      double(
        :backup_object,
        file_name: 'backup.dump',
        finished_at: Time.parse('2015-05-05')
      )
    end
    let(:config) do
      double(
        :config,
        sse_customer_key: sse_customer_key,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        aws_region: aws_region,
        bucket_name: bucket_name,
        s3_path: lambda { |time| 'some/s3/path' }
      )
    end
    let(:aws_access_key_id) { double(:aws_access_key_id) }
    let(:aws_secret_access_key) { double(:aws_secret_access_key) }
    let(:aws_region) { double(:aws_region) }
    let(:bucket_name) { 'the-backup-bucket' }
    let(:s3_client) { double(:s3_client, put_object: nil) }
    let(:backup_file_contents) { double(:backup_file_contents) }

    before do
      allow(HerokuPgBackupsArchive).to receive(:config).and_return(config)
      allow(Aws::S3::Client).to receive(:new).with(
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region: aws_region
      ).and_return(s3_client)
      allow(File).to receive(:open).with('backup.dump', 'rb').and_yield(backup_file_contents)

      backup_archive.perform
    end

    context 'when a SSE-C key is configured' do
      let(:sse_customer_key) { 'some-key-thats-a-secret' }

      it 'writes the file to S3 with SSE-C' do
        expect(s3_client).to have_received(:put_object).with(
          body: backup_file_contents,
          bucket: bucket_name,
          key: 'some/s3/path',
          sse_customer_algorithm: :AES256,
          sse_customer_key: sse_customer_key
        )
      end
    end

    context 'when a SSE-C key is configured' do
      let(:sse_customer_key) { nil }

      it 'writes the file to S3 without SSE-C' do
        expect(s3_client).to have_received(:put_object).with(
          body: backup_file_contents,
          bucket: bucket_name,
          key: 'some/s3/path'
        )
      end
    end
  end
end
