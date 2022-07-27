class Chat < ApplicationRecord
  self.locking_column = :lock_chat

  belongs_to :application
  has_many :message
end
