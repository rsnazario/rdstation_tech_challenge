require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { create(:shopping_cart) }
  let(:product) { create(:product, price: 10.0) }
  let(:cart_item) { create(:cart_item, cart:, product:, quantity: 2) }

  describe "associations" do
    it "belongs to a cart" do
      expect(cart_item.cart).to eq(cart)
    end

    it "belongs to a product" do
      expect(cart_item.product).to eq(product)
    end
  end

  describe "#total_price" do
    it "calculates the total price correctly" do
      expect(cart_item.total_price).to eq(20.0) # 10.0 * 2
    end
  end

  describe "callbacks" do
    context "before_save :set_prices" do
      it "sets unit_price to the product price" do
        expect(cart_item.unit_price).to eq(10.0)
      end

      it "sets total_price correctly" do
        expect(cart_item.total_price).to eq(20.0)
      end
    end

    context "after_save :update_cart_total_price" do
      it "updates the cart total price" do
        allow(cart).to receive(:update_total_price).and_call_original
        cart_item.update(quantity: 3) # Trigger after_save

        expect(cart).to have_received(:update_total_price).at_least(:once)
      end
    end
  end
end
