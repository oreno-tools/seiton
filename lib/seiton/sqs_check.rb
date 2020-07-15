module Seiton
  module SqsCheck
    def generator_sqs_queue_check(delete_resouces, ignore_resources = nil)
      template = <<-'EOF'
<% delete_resouces.each do |resource| %>
describe sqs("<%= resource.queue_name %>") do
  it { should_not exist }
end
<%- end -%>
<% if ignore_resources %>
<% ignore_resources.each do |resource| %>
describe 'Do not delete this resource ( <%= resource.queue_name %> ).' do
  describe sqs("<%= resource.queue_name %>") do
    it { should exist }
  end
end
<%- end -%>
<% end %>
EOF
      File.open("spec/" + "sqs_queue_spec.rb", "w") do |file|
        file.puts "require 'spec_helper'"
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end
  end
end
