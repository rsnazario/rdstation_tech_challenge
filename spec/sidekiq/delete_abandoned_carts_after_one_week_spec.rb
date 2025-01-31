require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DeleteAbandonedCartsAfterOneWeek, type: :job do
  let!(:active_cart) { create(:shopping_cart) }
  let!(:old_cart) { create(:shopping_cart, :abandoned) }
  let!(:recently_abandoned_cart) { create(:shopping_cart, :recently_abandoned) }

  before do
    Sidekiq::Testing.fake!
  end

  it "enqueues the job in Sidekiq" do
    expect {
      DeleteAbandonedCartsAfterOneWeek.perform_async
    }.to change(DeleteAbandonedCartsAfterOneWeek.jobs, :size).by(1)
  end

  it "deletes abandoned carts older than one week" do
    expect { DeleteAbandonedCartsAfterOneWeek.new.perform }
      .to change { Cart.where(status: 'abandoned').count }.by(-1)

      expect(Cart.exists?(old_cart.id)).to be_falsey
      expect(Cart.exists?(active_cart.id)).to be_truthy
      expect(Cart.exists?(recently_abandoned_cart.id)).to be_truthy
  end
end
