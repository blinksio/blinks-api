class NodesController < ApplicationController
  before_action :find_node_by_address, only: [:show, :graph]

  def show
    render json: @node.serialize.to_json
  end

  def graph
    nodes = [@node]
    # fetching node related nodes and 2nd degree related nodes
    nodes += @node.related_nodes + @node.related_nodes.map(&:related_nodes).flatten
    nodes.uniq!

    # storing all links
    links = []

    # adding links for all related nodes
    nodes.each do |node|
      node.related_nodes.each do |related_node|
        links << { source: node.id, target: related_node.id }
      end
    end

    nodes += Node.where(id: links.map { |link| link[:source] } + links.map { |link| link[:target] }).to_a

    render json: {
      nodes: nodes.uniq.map(&:serialize),
      links: links
    }
  end

  private

  def find_node_by_address
    # fetching node by address (case insensitive)
    @node = Node.find_by!("lower(address) = ?", params[:id].downcase)
  end

end
