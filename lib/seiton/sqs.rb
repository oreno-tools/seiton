module Seiton
  class Sqs < Client

    include Seiton::Helper
    include Seiton::SqsCheck

    def sqs_queue(check = false, ignores)
      if check
        log.info('List up the resources to be removed.')
      else
        log.info('Start deleting.')
      end

      delete_resources = []
      loop do
        res = sqs_client.list_queues({})
        res.queue_urls.each do |r|
          delete_resources << r
        end
        break if res.next_token.nil?
      end

      unless ignores.nil?
        ignore_resouces = []
        ignores.each do |ignore|
          ignore_resouces << delete_resources.select { |delete_resource| delete_resource.include?(ignore) }.last
          delete_resources.delete_if { |delete_resource| delete_resource.include?(ignore) }
        end
      end

      if delete_resources.empty?
        log.info('The resource to be deleted does not exist.')
        exit 0
      end

      puts display_sqs_queue_resources(delete_resources)
      generator_sqs_queue_check(delete_resources, ignore_resouces)
      exit 0 if check

      if process_ok?
        begin
          delete_resources.each do |delete_resource|
            delete_sqs_queue_action(delete_resource)
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
