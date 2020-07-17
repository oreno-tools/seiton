module Seiton
  class Init
    def self.welcome
      puts 'Welcome to seiton (整頓) !!'
      create_directory
      write_rakefile
    end

    def self.create_directory
      puts 'Create spec directory...'
      FileUtils.mkdir_p('spec') unless FileTest.exist?('spec')
      spec_helper = <<~SPEC_HELPER
require 'awspec'
Awsecrets.load(secrets_path: File.expand_path('./secrets.yml', File.dirname(__FILE__)))
      SPEC_HELPER

      File.open('spec/spec_helper.rb', 'w') do |f|
        f.puts(spec_helper)
      end
    end

    def self.write_rakefile
      puts 'Write Rakefile...'
      rakefile = <<~RAKE_FILE
require 'rspec/core/rake_task'
require 'aws-sdk'
require 'highline'
require 'logger'

namespace :check do
  targets1 = []
  targets2 = []
  Dir.glob(['./spec/*']).each do |file|
    target = File.basename(file)
    if target.include?('_spec.rb') then
      targets1 << File.basename(target, '_spec.rb')
    elsif target.include?('_list.txt') then
      targets2 << File.basename(target, '_list.txt')
    end
  end

  targets1.each do |target|
    desc "Test for \#{target} deleted"

    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      # t.rspec_opts = ["--format documentation", "--format html", "--out ./result_html/\#{target}_result.html"]
      t.rspec_opts = ["--format documentation"]
      t.pattern = "spec/\#{target}_spec.rb"
      t.verbose = true
    end if target != 'ebs_snapshot'
  end

  targets2.each do |target|
    desc "Test for \#{target} deleted"
    task target.to_sym do
      log.info('Check that ' + target + ' has been deleted.')
      resouces = []
      File.open('./spec/' + target + '_list.txt', "r") do |f|
        f.each_line do |line|
          resouces << line.chomp
        end
      end
      eval "check_\#{target}(resouces)"
    end
  end
end

def ec2_client
  @ec2_client ||= Aws::EC2::Client.new
end

def rds_client
  @rds_client ||= Aws::RDS::Client.new
end

def hl
  @hl ||= HighLine.new
end

def log
  @log ||= Logger.new(STDOUT)
end

def ignore_resource?(resource)
  if resource.include?('ignore|')
    r = resource.split('|').last
    log.info('[ ' + hl.color("!", :yellow) + ' ] ' + r + ' is not for deletion.')
    not_deleted = '[ ' + hl.color("\\u2714".encode('utf-8'), :green) + ' ] ' + r + ' exists.'
    deleted = '[ ' + hl.color("\\u2715".encode('utf-8'), :red) + ' ] ' + r + ' has been removed.'
  else
    r = resource
    deleted = '[ ' + hl.color("\\u2714".encode('utf-8'), :green) + ' ] ' + r + ' has been removed..'
    not_deleted = '[ ' + hl.color("\\u2715".encode('utf-8'), :red) + ' ] ' + r + ' exists.'
  end
  return r, deleted, not_deleted
end

def check_ec2_snapshots(resouces)
  resouces.each do |resouce|
    r, deleted, not_deleted = ignore_resource?(resouce)
    begin
      ec2_client.describe_snapshots({ snapshot_ids: [ r ] })
      log.info(not_deleted)
    rescue
      log.info(deleted)
    end
  end
end

def check_ec2_eips(resouces)
  resouces.each do |resouce|
    r, deleted, not_deleted = ignore_resource?(resouce)
    res = ec2_client.describe_addresses({ filters: [{ name: 'public-ip', values: [r] }] })
    if res.addresses.empty?
      log.info(deleted)
    else
      log.info(not_deleted)
    end
  end
end

def check_db_snapshots(resouces)
  resouces.each do |resouce|
    r, deleted, not_deleted = ignore_resource?(resouce)
    res = rds_client.describe_db_cluster_snapshots(db_cluster_snapshot_identifier: r)
    if res.db_cluster_snapshots.empty?
      log.info(deleted)
    else
      log.info(not_deleted)
    end
  end
end
      RAKE_FILE

      File.open('Rakefile', 'w') do |f| 
        f.puts(rakefile)
      end unless FileTest.exist?('Rakefile')
    end
  end
end
