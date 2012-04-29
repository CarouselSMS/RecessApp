class LocationsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => proc { |e| flash[:notice] = "Location not found"; redirect_to locations_url }

  # Lists locations
  def index
    @locations = current_account.locations.all(:order => "name")
  end
  
  # New location form
  def new
    @location = current_account.locations.build
  end
  
  # Create a location
  def create
    @location = current_account.locations.build(params[:location])
    if @location.save
      flash[:notice] = "Location was added"
      redirect_to locations_url
    else
      render :new
    end
  end
  
  # Edit location
  def edit
    @location = current_account.locations.find(params[:id])
  end
  
  # Update location
  def update
    @location = current_account.locations.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = "Location was updated"
      redirect_to locations_url
    else
      render :edit
    end
  end

  # Removes the location
  def destroy
    @location = current_account.locations.find(params[:id])
    flash[:notice] = "Location was removed" if @location.destroy
    redirect_to locations_url
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :account
  end

end
