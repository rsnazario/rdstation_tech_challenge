class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: cart_response(@cart), status: :ok
  end

  def create
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_products.find_by(product:)

    if cart_product
      render json: { error: 'Product already exists in the cart!' }, status: :unprocessable_entity
    else
      @cart.cart_products.create(cart_params)
      render json: cart_response(@cart), status: :ok
    end
  end

  def add_item
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_products.find_by(product:)

    if cart_product
      cart_product.update(cart_params)

      render json: cart_response(@cart), status: :ok
    else
      render json: { cart: cart_response(@cart), error: 'Product should already exist in the cart!' }, status: :unprocessable_entity
    end
  end

  def remove_product
    product = Product.find(cart_params[:product_id])
    cart_product = @cart.cart_products.find_by(product:)

    if cart_product
      cart_product.destroy
      @cart.update_total_price

      render json: { cart: cart_response(@cart), message: 'Product removed from cart' }, status: :ok
    else
      render json: { cart: cart_response(@cart), error: 'Product not found in cart' }, status: :not_found
    end
  end

  private

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(total_price: 0)
    session[:cart_id] = @cart.id
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_products.map do |cp|
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
