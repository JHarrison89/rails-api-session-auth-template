# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user, only: [:show_example]

  def index
    # Jbuilder render example
    @events = [
      { "event": 'Moderat live', "status": 'on sale', "sold": 100 },
      { "event": 'Moderat live', "status": 'on sale', "sold": 100 }
    ]
  end

  def show_example # dummy show action (no event records in db)
    # JSON render example
    render json: { "event": 'Moderat live', "status": 'created successfully' }, status: :not_found
  end
end
