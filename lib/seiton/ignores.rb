module Seiton
  class Ignores
    def initialize(ignores_file, ignores_list)
      @file = ignores_file
      @list = ignores_list
    end

    def generate
      ignores = nil
      begin
        File.open(@file) do |file|
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
      end unless @file.nil?

      ignores.concat(@list) unless @list.nil?

      ignores
    end
  end
end
