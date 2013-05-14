class DashboardController < ApplicationController
  before_filter :require_login

  def overview
    @active_openings = []
    @openings_without_candidate = []

    @candidates_without_opening = []
    @candidates_without_interview = []
    @candidates_without_assessment = []
    @candidates_with_assessment = []

    @interviews = []
    @upcoming_interviews_owned_by_me = []
    @upcoming_interviews_of_mine = []
    @interviews_without_feedback = []

    if can? :manage, Opening
      @active_openings = Opening.published.owned_by(current_user.id)
      @openings_without_candidate = Opening.no_candidates.owned_by(current_user.id)
    end

    if can? :manage, Candidate
      @candidates_without_opening = Candidate.without_opening
      @candidates_without_interview = Candidate.all
    end

    if can? :manage, Interview
      @interviews = Interview.all

      interviewers = Interviewer.where(:user_id => current_user.id)
      interviewers.each do |interviewer|
        @upcoming_interviews_of_mine << interviewer.interview
      end

      openings = Opening.owned_by(current_user.id)
      openings.each do |opening|
        opening.opening_candidates.each do |opening_candidate|
          @upcoming_interviews_owned_by_me << opening_candidate.interviews
        end
      end

      @interviews_without_feedback = Interview.where(:assessment => nil)
    end

  end
end
