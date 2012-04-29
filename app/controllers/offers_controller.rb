class OffersController < ApplicationController

  # Lists offers
  def index
    @offers = current_account.offers.all(:order => "created_at DESC")
  end
  
  # New offer form
  def new
    @offer = Offer.new
  end
  
  # Creates offer
  def create
    @offer = current_account.offers.build(params[:offer])
    if @offer.save
      flash[:notice] = "Offer was created"
      redirect_to offers_url
    else
      render :new
    end
  end
  
  # Edit offer form
  def edit
    @offer = offer
  end
  
  # Update offer
  def update
    @offer = offer
    if @offer.update_attributes(params[:offer])
      flash[:notice] = "Offer was updated"
      redirect_to offers_url
    else
      render :edit
    end
  end
  
  # Removes offer
  def destroy
    @offer = offer

    # Remove current offer from account if it's the same offer
    current_account.current_offer = nil if current_account.current_offer == @offer

    @offer.destroy
    flash[:notice] = "Offer was deleted"
    redirect_to offers_url
  end
  
  private
  
  # Loads offer
  def offer
    @offer ||= Offer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to offers_url
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :offers
  end

end
