module Seiton
  module RdsCheck
    def generator_db_snapshots_check(delete_resouces, ignore_resouces = nil)
      template = <<-'EOF'
<% delete_resouces.each do |resouce| %>
<%= resouce.db_cluster_snapshot_identifier %>
<%- end -%>
<% if ignore_resouces %>
<% ignore_resouces.each do |resouce| %>
ignore|<%= resouce.db_cluster_snapshot_identifier %>
<%- end -%>
<% end %>
EOF
      File.open("spec/" + "db_snapshots_list.txt", "w") do |file|
        file.puts ERB.new(template, nil, "-").result(binding).gsub(/^\n/, "")
      end
    end
  end
end
