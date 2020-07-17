module Seiton
  class Rds < Client

    include Seiton::Helper
    include Seiton::RdsCheck

    def rds_snapshot(check = false, dt, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end
      res = rds_client.describe_db_cluster_snapshots({})
      delete_db_snapshots = []
      res.db_cluster_snapshots.each do |delete_db_snapshot|
        if datetime_parse(delete_db_snapshot.snapshot_create_time.to_s) < datetime_parse(dt)
          delete_db_snapshots << delete_db_snapshot
        end
      end

      unless ignores.nil?
        ignore_resouces = []
        ignores.each do |ignore|
          ignore_resouces << delete_db_snapshots.select { |delete_db_snapshot| delete_db_snapshot.db_cluster_snapshot_identifier == ignore }.last
          delete_db_snapshots.delete_if { |delete_db_snapshot| delete_db_snapshot.db_cluster_snapshot_identifier == ignore }
        end
      end

      if delete_db_snapshots.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_db_snapshot_resources(delete_db_snapshots)
      generator_db_snapshots_check(delete_db_snapshots, ignore_resouces)
      exit 0 if check

      if process_ok?
        begin
          delete_db_snapshots.each do |delete_db_snapshot|
            delete_db_snapshot_action(delete_db_snapshot.db_cluster_snapshot_identifier)
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
