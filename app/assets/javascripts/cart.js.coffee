$ ->
	delay = (->
	  timer = 0
	  (callback, ms) ->
	    clearTimeout timer
	    timer = setTimeout(callback, ms)
	)()
	
	$('.form-search input, #car_part_search input').live 'keyup', ->
	  delay (->
	    $.get $(".form-search").attr("action"), $(".form-search").serialize(), null, "script"
	  ), 300	  
	$('#parts-pagination a').live 'click', ->
		$.getScript(@.href)
		return false