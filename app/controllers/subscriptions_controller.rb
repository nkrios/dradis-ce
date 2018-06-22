class SubscriptionsController < AuthenticatedController
  include ActionView::RecordIdentifier

  before_action :find_subscribable
  # before_action :find_or_initialize_comment
  # before_action :check_comment_author, only: [:update, :destroy]

  def create
    # Subscription.subscribe(to: @subscribable, user: current_user)
    redirect_to @subscribable, notice: "Subscribed to #{@subscribable.class}"
  end

  def destroy
    #Subscription.unsubscribe(from: @subscribable, user: current_user)
    redirect_to @subscribable, notice: "Unsubscribed from #{@subscribable.class}"
  end

  private
  def find_subscribable
    if params[:issue_id]
      @subscribable = Issue.find(params[:issue_id])
    end

    @subscribable
  end
end
