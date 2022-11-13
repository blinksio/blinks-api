namespace :nodes do
  desc "populates related_nodes_ids for all nodes"
  task :refresh_related_node_scores, [:symbol] => :environment do |task, args|
    nodes = Node.where(id: NodeData.pluck(:node_id)).where(spam: false)

    nodes.each_with_index do |node, i|
      puts "Refreshing related node scores for #{node.address} (#{i + 1 }/#{nodes.size})"
      node.related_node_scores(refresh: true, nodes: nodes)
    end
  end

  desc "fetches opensea data for all nodes"
  task :fetch_opensea_data, [:symbol] => :environment do |task, args|
    nodes = Node.all
    opensea_service = OpenseaService.new

    nodes.each_with_index do |node, i|
      puts "Fetching opensea data for #{node.address} (#{i + 1 }/#{nodes.size})"

      begin
        data = opensea_service.get_collection_data(node.address)
        meta = {
          opensea_url: "https://opensea.io/collection/#{data['collection']['slug']}",
          etherscan_url: "https://etherscan.io/address/#{node.address}",
        }

        meta[:external_url] = data['collection']['external_url'] if data['collection']['external_url'].present?
        meta[:twitter_url] = "https://twitter.com/#{data['collection']['twitter_username']}" if data['collection']['twitter_username'].present?
        meta[:discord_url] = data['collection']['discord_url'] if data['collection']['discord_url'].present?

        node.update(
          spam: data['collection']['hidden'],
          image_url: data['collection']['image_url'],
          meta: meta
        )
      rescue => e
        puts "Error fetching opensea data for #{node.address}: #{e.message}"
      end
    end
  end
end
