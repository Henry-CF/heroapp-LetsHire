def full_title(page_title)
  base_title = 'Lets Hire'

  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end


def sign_in_as_admin
  user = User.find_by_admin true
  sign_in user
  user
end
