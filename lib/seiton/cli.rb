# coding: utf-8
require 'thor'
require 'aws-sdk'
require 'date'
require 'time'
require 'terminal-table'
require 'logger'
require 'erb'

module Seiton
  class CLI < Thor
    default_command :version

    desc 'version', 'Print the version number.'
    def version
      puts Seiton::VERSION
    end

    desc 'ami', 'Delete the EC2 AMI.'
    option :before_datetime, type: :string, aliases: '-b', desc: 'Specify the date and time for deletion (delete resources before the specified date and time.)'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def ami
      unless options[:before_datetime] then
        puts '--before-datetime must be specified. (--before-datetime=YYYY/MM/DD)'
        exit 1
      end
      seiton = Seiton::Ec2.new
      seiton.ec2_image(options[:check], options[:before_datetime], options[:ignores])
    end

    desc 'ec2_snapshot', 'Delete the EC2 Snapshot.'
    option :before_datetime, type: :string, aliases: '-b', desc: 'Specify the date and time for deletion (delete resources before the specified date and time.)'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def ec2_snapshot
      unless options[:before_datetime] then
        puts '--before-datetime must be specified. (--before-datetime=YYYY/MM/DD)'
        exit 1
      end
      seiton = Seiton::Ec2.new
      seiton.ec2_snapshots(options[:check], options[:before_datetime], options[:ignores])
    end

    desc 'instance', 'Delete the EC2 Instance.'
    option :before_datetime, type: :string, aliases: '-b', desc: 'Specify the date and time for deletion (delete resources before the specified date and time.)'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def instance
      unless options[:before_datetime] then
        puts '--before-datetime must be specified. (--before-datetime=YYYY/MM/DD)'
        exit 1
      end
      seiton = Seiton::Ec2.new
      seiton.ec2_instance(options[:check], options[:before_datetime], options[:ignores])
    end

    desc 'rds_snapshot', 'Delete the RDS Snapshot.'
    option :before_datetime, type: :string, aliases: '-b', desc: 'Specify the date and time for deletion (delete resources before the specified date and time.)'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def rds_snapshot
      unless options[:before_datetime] then
        puts '--before-datetime must be specified. (--before-datetime=YYYY/MM/DD)'
        exit 1
      end
      seiton = Seiton::Rds.new
      seiton.rds_snapshot(options[:check], options[:before_datetime], options[:ignores])
    end

    desc 'eip', 'Delete the Elastic IP.'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def eip
      seiton = Seiton::Ec2.new
      seiton.eip(options[:check], options[:ignores])
    end

    desc 'sqs_queue', 'Delete the SQS Queue.'
    option :ignores, type: :array, aliases: '-i', desc: 'Specify resources to be undeleted (you can specify multiple resources).'
    option :check, type: :boolean, aliases: '-c', desc: 'Check the resources to be deleted.'
    def sqs_queue
      seiton = Seiton::Sqs.new
      seiton.sqs_queue(options[:check], options[:ignores])
    end

  end
end
