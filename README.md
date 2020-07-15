# seiton [![CircleCI](https://circleci.com/gh/oreno-tools/seiton.svg?style=svg)](https://circleci.com/gh/oreno-tools/seiton)

The seiton (整頓) tidies up your AWS Resources.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seiton'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install seiton
```

## Usage

### help

```sh
$ bundle exec seiton --help
Commands:
  seiton ami             # Delete the EC2 AMI.
  seiton ec2_snapshot    # Delete the EC2 Snapshot.
  seiton eip             # Delete the Elastic IP.
  seiton help [COMMAND]  # Describe available commands or one specific command
  seiton init            # Initialize seiton.
  seiton instance        # Delete the EC2 Instance.
  seiton rds_snapshot    # Delete the RDS Snapshot.
  seiton sqs_queue       # Delete the SQS Queue.
  seiton version         # Print the version number.
```

### Init

#### help

```sh
$ bundle exec seiton --help init
Usage:
  seiton init

Initialize seiton.
```

#### init

```sh
$ bundle exec seiton init
```

* Create a `check` directory in the current directory
* Create a spec_helper.rb in the `check` directory
* Create a Rakefile in the current directory

### Delete EC2 AMI

#### help

```sh
$ bundle exec seiton --help ami
Usage:
  seiton ami

Options:
  -b, [--before-datetime=BEFORE_DATETIME]  # Specify the date and time for deletion (delete resources before the specified date and time.)
  -i, [--ignores=one two three]            # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]              # Check the resources to be deleted.

Delete the EC2 AMI.
```

#### check

```sh
bundle exec seiton ami --before-datetime=2020/01/01 --check
```

#### delete

```sh
bundle exec seiton ami --before-datetime=2020/01/01
```

#### ignore

```sh
bundle exec seiton ami --before-datetime=2020/01/01 --ignores=xxxx yyyy zzzz
```

#### Testing for delete complete

```sh
bundle exec rake check:ec2_images    # AMI 
bundle exec rake check:ec2_snapshots # Snapshot
```

### Delete EIP

####  help

```sh
$ bundle exec seiton --help eip
Usage:
  seiton eip

Options:
  -i, [--ignores=one two three]  # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]    # Check the resources to be deleted.

Delete the Elastic IP.
```

#### check

```sh
bundle exec seiton eip --check
```

#### delete

```sh
bundle exec seiton eip
```

#### ignore

```sh
bundle exec seiton eip --ignores=xxx.xxx.xxx.xxx yyy.yyy.yyy.yyy
```

#### Testing for delete complete

```sh
bundle exec rake check:ec2_eips   　　　　     # Elastic IP
```

### Delete EC2 Instance

#### help

```sh
$ bundle exec seiton --help instance
Usage:
  seiton instance

Options:
  -b, [--before-datetime=BEFORE_DATETIME]  # Specify the date and time for deletion (delete resources before the specified date and time.)
  -i, [--ignores=one two three]            # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]              # Check the resources to be deleted.

Delete the EC2 Instance.
```

#### check

```sh
bundle exec seiton instance --before-datetime=2020/01/01 --check
```

#### delete

```sh
bundle exec seiton instance --before-datetime=2020/01/01
```

#### ignore

```sh
bundle exec seiton instance --before-datetime=2020/01/01 --ignores=tag_name instance_id
```

#### Testing for delete complete

```sh
bundle exec rake check:ec2_instances  # EC2 Instance
bundle exec rake check:ec2_volumes    # EC2 Volume
```

### Delete RDS Snapshot

#### help

```sh
$ bundle exec seiton --help rds_snapshot
Usage:
  seiton rds_snapshot

Options:
  -b, [--before-datetime=BEFORE_DATETIME]  # Specify the date and time for deletion (delete resources before the specified date and time.)
  -i, [--ignores=one two three]            # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]              # Check the resources to be deleted.

Delete the RDS Snapshot.
```

#### check

```sh
bundle exec seiton rds_snapshot --before-datetime=2020/01/01 --check
```

#### delete

```sh
bundle exec seiton rds_snapshot --before-datetime=2020/01/01
```

#### ignore

```sh
bundle exec seiton rds_snapshot --before-datetime=2020/01/01 --ignores=xxxx yyyy zzzz
```

#### Testing for delete complete

```sh
bundle exec rake check:db_snapshots  # RDS Snapshot
```

### Delete EC2 Snapshot

#### help

```sh
$ bundle exec seiton --help ec2_snapshot
Usage:
  seiton ec2_snapshot

Options:
  -b, [--before-datetime=BEFORE_DATETIME]  # Specify the date and time for deletion (delete resources before the specified date and time.)
  -i, [--ignores=one two three]            # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]              # Check the resources to be deleted.

Delete the EC2 Snapshot.
```

#### check

```sh
bundle exec seiton ec2_snapshot --before-datetime=2020/01/01 --check
```

#### delete

```sh
bundle exec seiton ec2_snapshot --before-datetime=2020/01/01
```

#### ignore

```sh
bundle exec seiton ec2_snapshot --before-datetime=2020/01/01 --ignores=xxxx yyyy zzzz
```

#### Testing for delete complete

```sh
bundle exec rake check:ec2_snapshots  # EC2 Snapshot
```

### Delete SQS Queue

#### help

```sh
$ bundle exec seiton help sqs_queue
Usage:
  seiton sqs_queue

Options:
  -i, [--ignores=one two three]  # Specify resources to be undeleted (you can specify multiple resources).
  -c, [--check], [--no-check]    # Check the resources to be deleted.

Delete the SQS Queue.
```

#### check

```sh
bundle exec seiton sqs_queue --check
```

#### delete

```sh
bundle exec seiton sqs_queue
```

#### ignore

```sh
bundle exec seiton sqs_queue --ignores=xxxx yyyy zzzz
```

#### Testing for delete complete

```sh
bundle exec rake check:sqs_queue  # SQS Queue
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec seiton` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/seiton.
