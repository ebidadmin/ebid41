$ ->
	$('.form-search input').live 'keyup', ->
		$.get($(".form-search").attr("action"), $(".form-search").serialize(), null, "script")
	$('#parts-pagination a').live 'click', ->
		$.getScript(@.href)
		return false