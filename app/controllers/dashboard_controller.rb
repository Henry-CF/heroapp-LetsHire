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

    # data displayed in charts
    @openings_created_by_me = Opening.openings_created_by_me(current_user.id).length
    @openings_assigned_to_me = Opening.openings_assigned_to_me(current_user.id).length
    @openings_without_interviewers = Opening.openings_without_interviewers.length

  end
end
