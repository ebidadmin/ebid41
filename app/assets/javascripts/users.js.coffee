jQuery ->
	loading = "<span class='loading'><img src='/assets/loading.gif'></span>"	
	$("div#companies select").change ->
	  company_id = $(this).val()
	  $("div#branches select").after loading
	  $.ajax
	    type: "get"
	    url: "/companies/" + parseInt(company_id) + "/selected"
	