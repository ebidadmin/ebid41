module CartHelper
  def select_link(car_part, entry = nil)
    # (car_part.name + (link_to "+", cart_add_path(part: car_part, id: entry), class: 'btn floatright', remote: true)).html_safe
    link_to "#{car_part.highlight.name[0]}".html_safe, cart_add_path(part: car_part, id: entry), remote: true
  end
  
end
