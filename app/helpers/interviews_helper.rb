module InterviewsHelper
  def is_interviewer?(interviewers)
    return true if current_user.admin?
    interviewers.each do |interviewer|
      return true if current_user.id == interviewer.user_id
    end
    nil
  end
end
