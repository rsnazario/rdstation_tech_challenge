require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let!(:product_1) { Product.create(name: 'Product One', price: 1999.99) }
  let!(:product_2) { Product.create(name: 'Product Two', price: 2499.99) }

  let!(:cart) { Cart.create!(status: 'active', total_price: 100) }
  let!(:cart_product_1) { CartItem.create!(cart: cart, product: product_1, total_price: 50, updated_at: 5.hours.ago) }
  let!(:cart_product_2) { CartItem.create!(cart: cart, product: product_2, total_price: 50, updated_at: 1.hour.ago) }

  let!(:old_cart) { Cart.create!(status: 'active', total_price: 100) }
  let!(:old_cart_product_1) { CartItem.create!(cart: old_cart, product: product_1, total_price: 50, updated_at: 4.hours.ago) }
  let!(:old_cart_product_2) { CartItem.create!(cart: old_cart, product: product_2, total_price: 50, updated_at: 4.hours.ago) }

  describe '#perform' do
    it 'marks carts with old cart products as abandoned' do
      MarkCartAsAbandonedJob.new.perform

      expect(cart.reload.status).to eq('active')
      expect(old_cart.reload.status).to eq('abandoned')
    end

    it 'does not mark carts that still have recent interactions as abandoned' do
      MarkCartAsAbandonedJob.new.perform

      cart.reload

      expect(cart.status).to eq('active')
    end
  end
end
