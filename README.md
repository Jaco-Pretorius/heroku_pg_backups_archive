# HerokuPgBackupsArchive

This gem allows you to backup your heroku postgres database and archive it to S3, optionally with [SSE-C](http://docs.aws.amazon.com/AmazonS3/latest/dev/ServerSideEncryptionCustomerKeys.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'heroku_pg_backups_archive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroku_pg_backups_archive

## Usage

There is some configuration required. For a rails application, create a file like `config/initializers/heroku_pg_backups_archive.rb` with contents like:

```
HerokuPgBackupsArchive.configure do |config|
  # Required
  config.app_name = "your-heroku-app-name"
  config.bucket_name = "your-s3-bucket-name"

  # Optional
  config.sse_customer_key = "your-sse-c-key" # leave blank to disable SSE-C
  config.aws_access_key_id = "aws-secret-key-id" # defaults to `ENV["AWS_ACCESS_KEY_ID"]` when not explicitly set
  config.aws_secret_access_key = "aws-secret-access-key" # defaults to `ENV["AWS_SECRET_ACCESS_KEY"]` when not explicitly set
  config.aws_region = "some-region" # defaults to `us-east-1` when not explicitly set
  config.after_complete = lambda { puts "I'm all done!" } # defaults to no action
end
```

To run the backup, simply run:

```
rake heroku_pg_backups_archive
```

To make the heroku cli available on your dyno, you can use [heroku-buildpack-cli](https://github.com/heroku/heroku-buildpack-cli).

### `aws-sdk` Dependency

If you have a dependency on version 1 of the `aws-sdk` gem you will need to update your gemfile to depend on `aws-sdk-v1`. This will allow your app to continue to function as normal, but allow this gem to use newer features in version 2 of the SDK.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/heroku_pg_backups_archive/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
