class AddIndexToChats < ActiveRecord::Migration[6.1]
  def change
    add_index :chats, :number
  end
end
