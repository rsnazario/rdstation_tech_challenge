class CartProduct < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  before_save :set_prices
  after_save :update_cart_total_price

  def total_price
    product.price * quantity
  end

  private

  def set_prices
    self.unit_price = product.price
    self.total_price = total_price
  end

  def update_cart_total_price
    cart.update_total_price
  end
end
