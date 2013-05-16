class DashboardController < ApplicationController
  before_filter :require_login

  def overview
    # opening related action items data providers
    @active_openings = []
    @openings_without_candidate = []

    # candidates related action items data providers
    @candidates_without_opening = []
    @candidates_without_interview = []
    @candidates_without_assessment = []
    @candidates_with_assessment = []

    # interviews related action items data providers
    @interviews_owned_by_me = []
    @interviews_interviewed_by_me = []
    @interviews_without_feedback = []

    if can? :manage, Opening
      @active_openings = Opening.published.owned_by(current_user.id)
      @openings_without_candidate = Opening.without_candidates.owned_by(current_user.id)
    end

    if can? :manage, Candidate
      @candidates_without_opening = Candidate.without_opening
      @candidates_without_interview = Candidate.without_interview
      @candidates_with_assessment = Candidate.all # TODO
      @candidates_without_assessment = Candidate.all # TODO
    end

    if can? :manage, Interview
      @interviews_owned_by_me = Interview.owned_by(current_user.id)
      @interviews_interviewed_by_me = Interview.interviewed_by_me(current_user.id)
      @interviews_without_feedback = Interview.where(:assessment => nil)
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

    @offers_rejected = OpeningCandidate.rejected?(current_user.id).length
    @offers_notconfirmed = OpeningCandidate.notconfirmed?(current_user.id).length
    @offers_accepted = OpeningCandidate.accepted?(current_user.id).length
  end
end