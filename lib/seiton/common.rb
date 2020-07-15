module Seiton
  module Helper
    def process_ok?
      while true
        puts 'Do you want to continue? [y|n]:'
        response = STDIN.gets.chomp
        case response
        when /^[yY]/
          log.info('Continue.')
          return true
        when /^[nN]/, /^$/
          log.warn('Abort.')
          return false
        end
      end
    end

    def datetime_parse(datetime)
      if datetime.to_s.include?('-')
        Time.parse(datetime.to_s.tr('-', '/')).to_i
      else
        Time.parse(datetime).to_i
      end
    end

    def log
      Logger.new(STDOUT)
    end

    def name_tag(tags)
      tags.select { |tag| tag.value if tag.key == 'Name' }.last
    end

    def volume_ids(mappings)
      volume_ids = []
      mappings.each do |mapping|
        volume_ids << mapping.ebs.volume_id unless mapping.ebs.delete_on_termination
      end
      volume_ids
    end

    def ignores(ignores_file, ignore_list)
      ignores = nil
      begin
        File.open(ignores_file) do |file|
          file.read.split("\n").each do |ignore|
            ignores << ignore
          end
        end
      rescue SystemCallError => e
        puts e.message
        exit 1
      rescue IOError => e
        puts e.message
        exit 1
      end unless ignore_file.nil?
      ignores.concat(ignore_list) unless ignore_list.nil?

      ignores
    end
  end
end
