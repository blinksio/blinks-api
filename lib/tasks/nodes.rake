namespace :nodes do
  desc "populates related_nodes_ids for all nodes"
  task :refresh_related_node_scores, [:symbol] => :environment do |task, args|
    nodes = Node.where(id: NodeData.pluck(:node_id))

    nodes.each_with_index do |node, i|
      puts "Refreshing related node scores for #{node.address} (#{i + 1 }/#{nodes.size})"
      node.related_node_scores(refresh: true, nodes: nodes)
    end
  end
end
