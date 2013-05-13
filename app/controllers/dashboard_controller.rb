class DashboardController < ApplicationController
  before_filter :require_login

  def overview
    @openings = []
    @candidates = []
    @interviews = []

    if can? :manage, Opening
      @openings = Opening.owned_by(current_user.id)
    end

    if can? :manage, Candidate
      @candidates = Candidate.all
    end

    if can? :manage, Interview
      @interviews = Interview.all
    end

  end
end
