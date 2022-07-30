class EventsController < ApplicationController
  before_action :authenticate_user, only: [:create]

  def index 
    # Jbuilder render example
    @events = { "event":"Moderat live", "status":"on sale", "sold":100}
  end

  def create 
    # JSON render example
      render json: {"event":"Moderat live", "status":"created successfully" }, status: :not_found
  end

end
