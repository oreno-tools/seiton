module Seiton
  class Client

    def initialize
      raise 'AWS_PROFILE does not exist.' unless ENV['AWS_PROFILE']
      raise 'AWS_REGION does not exist.' unless ENV['AWS_REGION']
    end

    CLIENTS = {
      iam_user: Aws::IAM::CurrentUser,
      ec2_client: Aws::EC2::Client,
      rds_client: Aws::RDS::Client,
      sqs_client: Aws::SQS::Client
    }

    CLIENTS.each do |method_name, client|
      define_method method_name do
        eval "@#{method_name} ||= #{client}.new"
      end
    end

    resource_types = %w(image snapshot db_snapshot eip instance volume sqs_queue)
    resource_types.each do |type|
      define_method 'display_' + type + '_resources' do |*args|
        log.info('The following resources will be removed.')
        resource_rows = []
        header = []
        args.first.each do |res|
          case type
          when 'instance' then
            header = [ 'tag:Name', 'ID', 'Launch Time' ]
            resource_rows << \
              [ name_tag(res.tags).value, res.instance_id, res.launch_time ]
          when 'volume' then
            header = [ 'tag:Name', 'ID', 'Create Time', 'State' ]
            if res.tags.empty?
              resource_rows << \
                [ '', res.volume_id, res.create_time, res.state ]
            else
              resource_rows << \
                [ name_tag(res.tags).value, res.volume_id, res.create_time, res.state ]
            end
          when 'image' then
            header = [ 'tag:Name', 'Name', 'ID', 'Creation Date' ]
            if res.tags.empty?
              resource_rows << \
                [ '', res.name, res.image_id, res.creation_date ]
            else
              resource_rows << \
                [ name_tag(res.tags).value, res.name, res.image_id, res.creation_date ]
            end
          when 'snapshot' then
            header = [ 'tag:Name', 'ID', 'Start Time', 'Description' ]
            if res.tags.empty?
              resource_rows << \
                [ '', res.snapshot_id, res.start_time, res.description ]
            else
              resource_rows << \
                [ name_tag(res.tags).value, res.snapshot_id, res.start_time, res.description ]
            end
          when 'db_snapshot' then
            header = [ 'Name', 'Create Time' ]
            resource_rows << [ res.db_cluster_snapshot_identifier, res.snapshot_create_time ]
          when 'eip' then
            header = [ 'Public IP', 'Allocation ID' ]
            resource_rows << [ res.public_ip, res.allocation_id ]
          when 'sqs_queue' then
            header = [ 'Queue URL' ]
            resource_rows << [ res ]
          end
        end
        Terminal::Table.new :headings => header, :rows => resource_rows
      end

      define_method 'delete_' + type + '_action' do |*args|
        log.info('Delete Resource ' + type + ' : ' + args.first)
        begin
          case type
          when 'instance' then
            # puts args.first
            req = { instance_ids: [ args.first ] }
            method_name = 'terminate_' + type + 's'
            ec2_client.method(method_name).call(req)
          when 'volume' then
            # puts args.first
            req = { volume_id: args.first }
            method_name = 'delete_' + type
            ec2_client.method(method_name).call(req)
          when 'image' then
            req = { image_id: args.first }
            method_name = 'deregister_' + type
            ec2_client.method(method_name).call(req)
          when 'snapshot' then
            req = { snapshot_id: args.first }
            method_name = 'delete_' + type
            ec2_client.method(method_name).call(req)
          when 'db_snapshot' then
            req = { db_cluster_snapshot_identifier: args.first }
            method_name = 'delete_db_cluster_snapshot'
            rds_client.method(method_name).call(req)
          when 'eip' then
            req = { allocation_id: args.first }
            method_name = 'release_address'
            ec2_client.method(method_name).call(req)
          when 'sqs_queue' then
            req = { queue_url: args.first }
            method_name = 'delete_queue'
            sqs_client.method(method_name).call(req)
          end

          log.info('Deleted.')
        rescue StandardError => e
          log.error('Failed to delete.' + e.to_s)
        end
      end
    end

  end
end
