class RenameTableCartProductsAndAddDefaultToCarts < ActiveRecord::Migration[7.1]
  def change
    rename_table :cart_products, :cart_items

    change_column_default :carts, :total_price, 0.0
  end
end
