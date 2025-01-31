class DeleteAbandonedCartsAfterOneWeek
  include Sidekiq::Job

  def perform(*args)
    abandoned_carts = Cart.where(status: 'abandoned').where.not(last_interaction_at: 1.week.ago..)

    abandoned_carts.destroy_all
  end
end
