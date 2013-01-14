module ApplicationHelper
  def previous_sunday
    now = DateTime.now
    (now - now.wday).strftime('%b %d')
  end
end
