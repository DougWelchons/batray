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
end
