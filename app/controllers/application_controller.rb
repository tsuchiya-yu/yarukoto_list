class ApplicationController < ActionController::Base
  include InertiaRails::Controller

  inertia_share flash: -> { { notice: flash[:notice], alert: flash[:alert] }.compact }
end
