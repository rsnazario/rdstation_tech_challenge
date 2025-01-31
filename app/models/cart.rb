class Cart < ApplicationRecord
  # validations
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # relations
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # enums
  enum status: {
    active: 'active',
    abandoned: 'abandoned',
  }

  # methods
  def update_total_price
    update(total_price: cart_items.sum(&:total_price))
  end

  def mark_as_abandoned
    update(status: 'abandoned', last_interaction_at: Time.now)
  end

  def remove_if_abandoned
    self.destroy!
  end
end
