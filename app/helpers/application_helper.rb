module ApplicationHelper

  # Return the full title on a per-page basis
  def full_title(page_title)
    base_title = 'Lets Hire'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def sortable(model_name, column, title=nil)
    title ||= column.titleize
    css_class = column == sort_column(model_name) ? "current #{sort_direction}" : nil
    direction = column == sort_column(model_name) && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def sort_column(model_name)
    model_name.constantize.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
