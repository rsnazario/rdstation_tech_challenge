class AddStatusToCart < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string, null: false, default: 'active'
  end
end
