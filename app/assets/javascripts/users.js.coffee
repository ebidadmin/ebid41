jQuery ->
	loading = "<span class='loading'><img src='/assets/loading.gif'></span>"	
	$("div#companies select, select#companies").change ->
	  company_id = $(this).val()
	  $("div#branches select, select#branches").after loading
	  $.ajax
	    type: "get"
	    url: "/companies/" + parseInt(company_id) + "/selected"
	