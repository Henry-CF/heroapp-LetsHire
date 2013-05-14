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

    # FIXME: Do we arrange interview on Sunday and Saturday ?
    @dates = []
    @interviews_assigned_to_me = []
    @interviews_upcoming_today = []
    (0..6).reverse_each do |i|
      date = (Time.now - i.days).to_date
      @dates << "#{date.month}-#{date.day}"
      @interviews_assigned_to_me << Interview.assigned_to_me(current_user.id, date.to_s).length
      @interviews_upcoming_today << Interview.upcoming_today(current_user.id, date.to_s).length
    end

    @interviews_rejected = OpeningCandidate.rejected?(current_user.id).length
    @interviews_notconfirmed = OpeningCandidate.notconfirmed?(current_user.id).length
    @interviews_accepted = OpeningCandidate.accepted?(current_user.id).length
  end
end
