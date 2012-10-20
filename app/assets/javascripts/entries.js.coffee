jQuery ->
	loading = "<span class='loading'><img src='/assets/loading.gif'></span>"	
	# $('div#veh-variant select').hide()
	$('div#veh-brand select').change ->
		brand_id = $(@).val()
		$('div#veh-model select').after(loading)
		$('div#veh-variant select').empty().hide()
		$.ajax
			type: 'get'
			url: '/car_brands/' + parseInt(brand_id) + '/selected'
	$('div#veh-model select').change ->
		model_id = $(@).val()
		$('div#veh-variant select').after(loading)
		$.ajax
			type: 'get'
			url: '/car_models/' + parseInt(model_id) + '/selected'
			
	$('a.accept').tooltip('show')
	$('a.btn').tooltip()
	
  
	
	