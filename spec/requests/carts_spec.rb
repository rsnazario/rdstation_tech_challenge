require 'rails_helper'

RSpec.describe "/cart", type: :request do
  let(:cart) { create(:shopping_cart) }
  let(:product) { create(:product) }
  let!(:cart_item) { create(:cart_item, cart:, product:) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
  end

  describe "GET /cart" do
    it "returns the cart details" do
      get '/cart', as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("id" => cart.id)
    end
  end

  describe "POST /cart/create" do
    context "when adding a new product" do
      let(:new_product) { create(:product) }

      it "adds the product to the cart" do
        expect {
          post '/cart', params: { product_id: new_product.id, quantity: 1 }, as: :json
        }.to change { cart.cart_items.count }.by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the product is already in the cart" do
      it "does not duplicate the item" do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        }.not_to change { cart.cart_items.count }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the product does not exist" do
      it "returns a 404 error" do
        post '/cart', params: { product_id: 99999, quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("error")
      end
    end
  end

  describe "POST /cart/add_items" do
    context "when the product is already in the cart" do
      it "updates the quantity of the existing item in the cart" do
        expect {
          post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        }.to change { cart_item.reload.quantity }.by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the product is not in the cart" do
      let(:new_product) { create(:product) }

      it "adds the product to the cart" do
        expect {
          post '/cart/add_items', params: { product_id: new_product.id, quantity: 1 }, as: :json
        }.to change { cart.cart_items.count }.by(1)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    context "when the product is in the cart" do
      it "removes the product from the cart" do
        expect {
          delete "/cart/#{product.id}", as: :json
        }.to change { cart.cart_items.count }.by(-1)
  
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "Product removed from cart")
      end
    end
  
    context "when the product is not in the cart" do
      it "returns a 404 error" do
        delete "/cart/99999", as: :json
  
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("error" => "Product not found in cart")
      end
    end
  end  
end
