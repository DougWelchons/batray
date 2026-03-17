module ApplicationHelper
  STATUS_BADGE_CLASSES = {
    "drafting"  => "status-badge status-drafting",
    "submitted" => "status-badge status-submitted",
    "awarded"   => "status-badge status-awarded",
    "lost"      => "status-badge status-lost",
    "withdrawn" => "status-badge status-archived",
    "declined"  => "status-badge status-archived"
  }.freeze

  def status_badge(status)
    css_class = STATUS_BADGE_CLASSES.fetch(status.to_s, "status-badge")
    content_tag(:span, status.to_s.humanize, class: css_class)
  end

  def currency(amount)
    return "—" if amount.nil?
    number_to_currency(amount, precision: 0)
  end

  def percent(value)
    return "—" if value.nil?
    "#{value}%"
  end

  def sort_link(column, label, html_options = {})
    current = (params[:sort] == column)
    current_dir = params[:dir] == "asc" ? "asc" : "desc"
    next_dir = (current && current_dir == "asc") ? "desc" : "asc"

    icon = if current
      current_dir == "asc" ? " ↑" : " ↓"
    else
      ""
    end

    css = "sort-link"
    css += " sort-link--active" if current
    css += " #{html_options.delete(:class)}" if html_options[:class]

    filter_params = params.slice(:status, :project_type, :location, :year).permit(:status, :project_type, :location, :year).to_h
    link_to projects_path(filter_params.merge(sort: column, dir: next_dir)), class: css, **html_options do
      (label + content_tag(:span, icon, class: "sort-indicator")).html_safe
    end
  end
end
