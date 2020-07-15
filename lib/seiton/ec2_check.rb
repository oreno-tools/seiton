module Seiton
  module Ec2Check
    def generator_ec2_instances_check(delete_resources, ignore_resources = nil)
      template = <<-'EOF'
<% delete_resources.each do |resource| %>
describe ec2("<%= resource.instance_id %>") do
  it { should_not exist }
end
<%- end -%>
<% if ignore_resources %>
<% ignore_resources.each do |resource| %>
describe 'Do not delete this resource ( <%= resource.instance_id %> ).' do
  describe ec2("<%= resource.instance_id %>") do
    it { should exist }
  end
end
<%- end -%>
<% end %>
EOF
      File.open("spec/" + "ec2_instance_spec.rb", "w") do |file|
        file.puts "require 'spec_helper'"
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end

    def generator_ec2_volumes_check(delete_resources)
      template = <<-'EOF'
<% delete_resources.each do |resource| %>
describe ebs("<%= resource.volume_id %>") do
  it { should_not exist }
end
<% end %>
EOF
      File.open("spec/" + "ec2_volumes_spec.rb", "w") do |file|
        file.puts "require 'spec_helper'"
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end

    def generator_ec2_images_check(delete_resources, ignore_resources = nil)
      template = <<-'EOF'
<% delete_resources.each do |resource| %>
describe ami("<%= resource.image_id %>") do
  it { should_not exist }
end
<%- end -%>
<% if ignore_resources %>
<% ignore_resources.each do |resource| %>
describe 'Do not delete this resource ( <%= resource.name %> ).' do
  describe ami("<%= resource.image_id %>") do
    it { should exist }
  end
end
<%- end -%>
<% end %>
EOF
      File.open("spec/" + "ec2_images_spec.rb", "w") do |file|
        file.puts "require 'spec_helper'"
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end

    def generator_ec2_snapshots_check(delete_resources)
      template = <<-'EOF'
<% delete_resources.each do |resource| %>
<%= resource.snapshot_id %>
<% end %>
EOF
      File.open("spec/" + "ec2_snapshots_list.txt", "w") do |file|
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end

    def generator_ec2_eips_check(delete_resources, ignore_resources = nil)
      template = <<-'EOF'
<% delete_resources.each do |resource| %>
describe eip("<%= resource.public_ip %>") do
  it { should_not exist }
end
<% end %>
<% if ignore_resources %>
<% ignore_resources.each do |resource| %>
describe 'Do not delete this resource ( <%= resource %> ).' do
  describe eip("<%= resource %>") do
    it { should exist }
  end
end
<%- end -%>
<% end %>
EOF
      File.open("spec/" + "ec2_eips_spec.rb", "w") do |file|
        file.puts "require 'spec_helper'"
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end

  end
end
