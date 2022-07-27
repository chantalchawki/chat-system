class AddIndexToApplications < ActiveRecord::Migration[6.1]
  def change
    add_index :applications, :token
  end
end
