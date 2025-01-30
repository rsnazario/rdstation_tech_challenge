class Cart < ApplicationRecord
  # validations
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # relations
  has_many :cart_products, dependent: :destroy
  has_many :products, through: :cart_products

  # methods
  def update_total_price
    self.total_price = cart_products.sum(&:total_price)
    save!
  end
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
