class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: cart_response(@cart), status: :ok
  end

  def create
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_items.find_by(product:)

    if !cart_product
      @cart.cart_items.create(cart_params)
    end

    render json: cart_response(@cart), status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def add_items
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_items.find_by(product:)

    if cart_product
      cart_product.quantity += cart_params[:quantity]
      cart_product.save
    else
      @cart.cart_items.create(cart_params)
    end

    render json: cart_response(@cart), status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def remove_product
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_items.find_by(product:)

    if cart_product
      cart_product.destroy
      @cart.update_total_price
    end

    render json: { cart: cart_response(@cart), message: 'Product removed from cart' }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { cart: cart_response(@cart), error: 'Product not found in cart' }, status: :not_found
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(total_price: 0)
    session[:cart_id] = @cart.id

    @cart.update(status: 'active', last_interaction_at: nil)
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |cp|
        {
          id: cp.product.id,
          name: cp.product.name,
          quantity: cp.quantity,
          unit_price: cp.unit_price.to_f,
          total_price: cp.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
