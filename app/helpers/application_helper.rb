module ApplicationHelper
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end
  
  def subtitle(subtitle)
    content_for(:subtitle) { (content_tag :small, subtitle).html_safe }
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def relative_root_path
    if user_signed_in?
      if can? :access, :all
        entries_path(s: 'for-decision')
      elsif can? :access, :buyer
        buyer_dashboard_path
      elsif can? :access, :seller
        seller_dashboard_path 
      end
    else
      root_path
    end
  end
  
  def nav_link(text, page, *args) 
    content_tag :li, (link_to text, page, *args), class: current?(page)
  end 

  def current?(page_name)
    "active" if current_page? page_name
  end
  
  def drop_link(text)
    link_to("#{text} #{content_tag :b, '', class: 'caret'}".html_safe, '#', class: "dropdown-toggle", "data-toggle" => "dropdown")
  end

  def drop_active?(action)
    "active" if params[:action] == action
  end
  
  def drop_active_cont?(controller)
    "active" if params[:controller] == controller
  end

  def link_with_icon(name, page, icon_name, klass=nil, white=false, print=false)
    icon = content_tag(:i, '', class: "icon-#{icon_name}#{' icon-white' if white == true}")
    if print == true
  		link_to (icon + ' ' + name), page, class: "btn #{klass}", onclick: "window.print(); return false" 
    else
      link_to (icon + ' ' + name), page, class: "btn #{klass}"
    end
  end
  
  def dl_helper(tag, item, klass=nil)
    (content_tag :dt, tag, class: "#{klass}") + (content_tag :dd, item.html_safe, class: "#{klass}")
  end
  
  def time_in_words(time)
    distance_in_hours   = ((time.abs) / 3600).round
    distance_in_minutes = (((time.abs) % 3600) / 60).round

    difference_in_words = ''

    difference_in_words << "#{distance_in_hours}hr " if distance_in_hours > 0
    difference_in_words << "#{distance_in_minutes}min"
  end
  
  def long_date(date)
    date.strftime('%d %b %Y, %a %R')
  end
  
  def regular_date(date, requirement=nil)
    case requirement
    when 'short' then date.strftime("%d %b '%y")
    when 'short_time' then date.strftime("%d %b '%y, %R")
    when 'short_daytime' then date.strftime("%d %b '%y, %a %R")
    when 'day' then date.strftime("%d %b '%y, %a")
    else date.strftime("%d %b %Y")
    end
  end

  def currency(target, ph=nil)
    if (target && target > 0) || (target && target < 0)
      number_to_currency target, unit: "#{ph}"
    else
      '-'
    end
  end
  
  def percentage(target, prec = 2, indicator = nil)
    if target && target > 0
      number_to_percentage target, precision: prec
    elsif target.blank?
      ''
    elsif indicator.present?
      'FREE'
    end
  end
  
  def shorten(target, size)
    truncate(target, length: size, separator: ' ')
  end

  
  
  # FOR SEARCH BARS
  def refresh_button
    link_with_icon 'Refresh', request.path, 'refresh'
  end
 
  # FOR ORDERS & FEES
  def display_seller_company
    content_tag :span, "#{@seller_company} &raquo;".html_safe, class: 'label label-info' if @seller_company
  end
  
  def display_buyer_company
    content_tag :span, @buyer_company, class: 'label label-info' if @buyer_company
  end

  def link_with_icon(name, page, icon_name, klass=nil, white=false, print=false)
    icon = content_tag(:i, '', class: "icon-#{icon_name}#{' icon-white' if white == true}")
    if print == true
  		link_to (icon + ' ' + name), page, class: "btn #{klass}", onclick: "window.print(); return false" 
    else
      link_to (icon + ' ' + name), page, class: "btn #{klass}"
    end
  end
  
  def link_with_icon_js(name, page, icon_name, klass=nil, white=false)
    icon = content_tag(:i, '', class: "icon-#{icon_name}#{' icon-white' if white == true}")
    link_to (icon + ' ' + name), page, class: "btn #{klass}", remote: true
  end
  
  def link_with_icon_delete(name, page, klass = nil, white = false, remote = false)
    icon = content_tag(:i, '', class: "icon-trash#{' icon-white' if white == true}")
    if remote == true
      link_to (icon + ' ' + name), page, class: "btn #{klass}", data: { confirm: 'Are you sure you want to delete?' }, method: :delete, remote: true
    else
      link_to (icon + ' ' + name), page, class: "btn #{klass}", data: { confirm: 'Are you sure you want to delete?' }, method: :delete
    end
  end
  
  def tooltip_helper(tooltip_content, singular_form, icon_name, klass = nil)
    content_tag :span, class: "#{klass}", rel: 'tooltip', title: "#{pluralize tooltip_content, singular_form}" do
      content_tag(:i, '', class: "icon-#{icon_name}") + content_tag(:span, tooltip_content)
    end.html_safe
  end
  
  def clearfix_div
    content_tag :div, '', class: 'clearfix'
  end

end
