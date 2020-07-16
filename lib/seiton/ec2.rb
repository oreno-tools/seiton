module Seiton
  class Ec2 < Client

    include Seiton::Helper
    include Seiton::Ec2Check

    def ec2_instance(check = false, dt, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end
      res = ec2_client.describe_instances({
                                           filters: [{
                                                      'name': 'instance-state-name', 'values': [ 'stopped' ]
                                                     }]
                                          })
      delete_instances = []
      res.reservations.each do |i|
        i.instances.each do |delete_instance|
          if datetime_parse(delete_instance.launch_time) < datetime_parse(dt)
            delete_instances << delete_instance
          end
        end
      end

      unless ignores.nil?
        ignore_resources = []
        ignores.each do |ignore|
          ignore_resources << delete_instances.select { |delete_instance| name_tag(delete_instance.tags).value == ignore }.last
          delete_instances.delete_if { |delete_instance| name_tag(delete_instance.tags).value == ignore }
        end
      end

      if delete_instances.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_instance_resources(delete_instances)
      generator_ec2_instances_check(delete_instances, ignore_resources)
      exit 0 if check

      delete_volume_ids = []
      if process_ok?
        begin
          delete_instances.each do |instance|
            delete_instance_action(instance.instance_id)
            delete_volume_ids << volume_ids(instance.block_device_mappings)
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end
      delete_volume_ids = delete_volume_ids.flatten
      ec2_volume(delete_volume_ids) unless delete_volume_ids.empty?
    end

    def ec2_volume(delete_volume_ids)
      log.info('Start EC2 volume deleting.')
      log.info('Waiting for the status of the EC2 volume to become available.')
      loop do
        res = ec2_client.describe_volumes({ volume_ids: delete_volume_ids })
        status = res.volumes.map { |volume| volume.volume_id if volume.state == 'available' }
        if delete_volume_ids.sort == status.sort
          log.info('The status of all EC2 volumes is now available.')
          break
        else
          log.info('Waiting.')
          sleep 3
        end
      end

      delete_volumes = ec2_client.describe_volumes({ volume_ids: delete_volume_ids })
      puts display_volume_resources(delete_volumes.volumes)

      generator_ec2_volumes_check(delete_volumes.volumes)

      if process_ok?
        begin
          delete_volume_ids.each do |delete_volume_id|
            delete_volume_action(delete_volume_id)
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end

    end

    def ec2_image(check = false, dt, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end
      res = ec2_client.describe_images({ owners: ['self'] })
      delete_images = []
      res.images.each do |delete_image|
        if datetime_parse(delete_image.creation_date) < datetime_parse(dt)
          delete_images << delete_image
        end
      end

      unless ignores.nil?
        ignore_resources = []
        ignores.each do |ignore|
          delete_images.each do |delete_image|
            if name_tag(delete_image.tags).nil?
              if delete_image.name == ignore or delete_image.image_id == ignore
                ignore_resources << delete_image
              end
            elsif name_tag(delete_image.tags).value == ignore or delete_image.name == ignore
              ignore_resources << delete_image
            end
          end
          delete_images.delete_if do |delete_image|
            if name_tag(delete_image.tags).nil?
              delete_image.name == ignore
            else
              name_tag(delete_image.tags).value == ignore or \
              delete_image.name == ignore or \
              delete_image.image_id == ignore
            end
          end
        end
      end

      if delete_images.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_image_resources(delete_images)
      generator_ec2_images_check(delete_images, ignore_resources)
      exit 0 if check

      delete_image_ids = []
      if process_ok?
        begin
          delete_images.each do |image|
            delete_image_action(image.image_id)
            delete_image_ids << image.image_id
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end

      ebs_snapshot(delete_image_ids)
    end

    def ebs_snapshots(check = false, dt, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end
      res = ec2_client.describe_snapshots({ owner_ids: ['self'] })
      delete_snapshots = []
      res.snapshots.each do |delete_snapshot|
        if datetime_parse(delete_snapshot.start_time) < datetime_parse(dt)
          delete_snapshots << delete_snapshot
        end
      end

      unless ignores.nil?
        ignore_resources = []
        ignores.each do |ignore|
          delete_snapshots.each do |delete_snapshot|
            if name_tag(delete_snapshot.tags).nil?
              if delete_snapshot.snapshot_id == ignore
                ignore_resources << delete_snapshot
              end
            elsif name_tag(delete_snapshot.tags).value == ignore or delete_snapshot.snapshot_id == ignore
              ignore_resources << delete_snapshot
            end
          end
          delete_snapshots.delete_if do |delete_snapshot|
            if name_tag(delete_snapshot.tags).nil?
              delete_snapshot.snapshot_id == ignore
            else
              name_tag(delete_snapshot.tags).value == ignore or \
              delete_snapshot.snapshot_id == ignore
            end
          end
        end
      end

      if delete_snapshots.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_snapshot_resources(delete_snapshots)
      generator_ebs_snapshots_check(delete_snapshots)
      exit 0 if check

      delete_snapshot_ids = []
      if process_ok?
        begin
          delete_snapshots.each do |s|
            delete_snapshot_ids << s.snaphost_id
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end

      ebs_snapshot(delete_image_ids)
    end

    def ebs_snapshot(delete_image_ids)
      log.info('Start EC2 Snapshot deleting.')
      res = ec2_client.describe_snapshots(owner_ids: [iam_user.arn.split(':')[4]])
      delete_snapshots = []
      delete_image_ids.each do |delete_image_id|
        res.snapshots.each do |delete_snapshot|
          delete_snapshots << delete_snapshot if delete_snapshot.description.include?(delete_image_id)
        end
      end

      if delete_snapshots.empty?
        log.info('The EC2 snapshot to be deleted does not exist.')
        return true
      end

      puts display_snapshot_resources(delete_snapshots)
      generator_ebs_snapshots_check(delete_snapshots)

      if process_ok?
        begin
          delete_snapshots.each do |delete_snapshot|
            delete_snapshot_action(delete_snapshot.snapshot_id)
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end
    end

    def eip(check = false, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end
      res = ec2_client.describe_addresses({})
      delete_addresses = []
      res.addresses.each do |delete_address|
        if delete_address.instance_id.nil?
          delete_addresses << delete_address
        end
      end

      unless ignores.nil?
        ignores.each do |ignore|
          delete_addresses.delete_if { |delete_address| delete_address.public_ip == ignore }
        end
      end

      if delete_addresses.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_eip_resources(delete_addresses)
      generator_ec2_eips_check(delete_addresses, ignores)
      exit 0 if check

      if process_ok?
        begin
          delete_addresses.each do |delete_address|
            delete_eip_action(delete_address.allocation_id)
          end
        rescue StandardError => e
          log.error(e)
          exit 1
        end
      else
        exit 0
      end
    end
  end
end
