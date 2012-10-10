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
			
	$('#new_photo').fileupload
		dataType: "script"
		add: (e, data) ->
			types = /(\.|\/)(gif|jpe?g|png)$/i
			file = data.files[0]
			if types.test(file.type) || types.test(file.name)
				data.context = $(tmpl("template-upload", file))
				$('#new_photo').append(data.context)
				data.submit()
			else
				alert("#{file.name} is not a gif, jpeg, or png image file")
		progress: (e, data) ->
			if data.context
				progress = parseInt(data.loaded / data.total * 100, 10)
				data.context.find('.bar').css('width', progress + '%')
	
	$('a.accept, a.btn').tooltip('show')
	
	