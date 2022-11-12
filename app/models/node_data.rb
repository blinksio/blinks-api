class NodeData < ApplicationRecord
  belongs_to :node

  validates :node, presence: true, uniqueness: true
end
