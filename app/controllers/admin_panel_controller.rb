class AdminPanelController < ApplicationController
  before_action :authenticate_admin_panel_admin!

  layout 'admin_panel/layout'
end
