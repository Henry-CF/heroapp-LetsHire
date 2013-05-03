class SettingsController < AuthenticatedController

  before_filter :require_admin

  def index
  end
end

