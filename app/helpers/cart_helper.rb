module CartHelper
  def select_link(car_part, entry = nil)
    # (car_part.name + (link_to "+", cart_add_path(part: car_part, id: entry), class: 'btn floatright', remote: true)).html_safe
    # link_to "#{car_part.highlight.name[0]}".html_safe, cart_add_path(part: car_part, id: entry), remote: true
    icon = content_tag :i, '', class: 'icon-chevron-right pull-right'
    link_to "#{car_part.name} #{icon}".html_safe, cart_add_path(part: car_part, id: entry), class: 'btn btn-block', remote: true
  end
  
end
