class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    active_carts = Cart.joins(:cart_items).where(cart_items: { updated_at: 3.hours.ago.. })
    abandoned_carts = Cart.where.not(id: active_carts.ids)

    abandoned_carts.each(&:mark_as_abandoned)
  end
end
