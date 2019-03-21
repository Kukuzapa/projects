//GET
$('#registrar_get_submit').click(function(){
	
	var params = {};
	params.url = '/api/v2.1/registrar/get/' + format_reg( $('#registrar_get_select').val() );
	params.dataType = 'json';

	params.success = function(data){
		get_registrar_result(data,'#registrar_get_fin');
	}

	params.error = function(){
		$('#registrar_get_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//LIMITS
$('#registrar_limits_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/registrar/limits/' + format_reg( $('#registrar_limits_select').val() );
	params.dataType = 'json';

	params.success = function(data){
		get_registrar_result(data,'#registrar_limits_fin');
	}

	params.error = function(){
		$('#registrar_limits_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//BILLING
$('#registrar_billing_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/registrar/billing/' + format_reg( $('#registrar_billing_select').val() );
	params.dataType = 'json';

	params.data = { billing: $('#registrar_billing_type').val() }

	params.success = function(data){
		get_registrar_result(data,'#registrar_billing_fin');
	}

	params.error = function(){
		$('#registrar_billing_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//UPDATE
$('#registrar_update_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/registrar/update/' + format_reg( $('#registrar_update_select').val() );
	params.dataType = 'json';

	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";
	params.data = {};
	params.data.ip = [];

	$('.registrar_update_ip').each(function(){
		if ( $(this).val() ) {
			params.data.ip.push( $(this).val() );
		}
	})

	params.success = function(data){
		get_registrar_result(data,'#registrar_update_fin');
	}

	params.error = function(){
		$('#registrar_update_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data = JSON.stringify( params.data );
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//POLL
$('#registrar_poll_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/registrar/poll/' + format_reg( $('#registrar_poll_select').val() );
	params.dataType = 'json';

	params.success = function(data){
		get_registrar_result(data,'#registrar_poll_fin');
		$('#loading').fadeOut(200);
	}

	params.error = function(){
		$('#registrar_poll_fin').text( new Date($.now()) + ' Нет связи с сервером');
		$('#loading').fadeOut(200);
	}

	/*params.always = function(){
		console.log('always')
		
	}*/

	$('#loading').fadeIn(200);
	$.ajax(params);
	//$('#loading').fadeOut(200);
	return false;
})

//HELPERS
function get_registrar_result(data,id) {
	var templateResult = $('#result_registrar').html();
	var template = Handlebars.compile(templateResult);
	$(id).html(template(data));
}

function format_reg( str ) {
	if ( str == 'REGFORMAT-RU' ) {
		return 'ru';
	} else {
		return 'rf';
	}
}

$('#registrar_update_select').change(function(){
	$('.registrar_update_ip').each(function(){
		$(this).val('');
	})

	var params = {};
	params.url = '/api/v2.1/registrar/get/' + format_reg( $('#registrar_update_select').val() );
	params.dataType = 'json';

	params.success = function(data){
		var addr = [];

		if ( data.registrar ) {
			if ( data.registrar.v4 ) {
				$.merge( addr, data.registrar.v4 );
			} else if ( addr, data.registrar.v6 ) {
				$.merge( addr, data.registrar.v6 )
			}
		}

		for ( var i=0; i<addr.length; i++ ) {
			$('#regip_'+(i+1).toString()).val(addr[i]);
		}
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
})

$('#registrar_update_submit').mouseenter(function(){
	//alert('jj')
	var templateScript = $('#templ_registrar_ip').html();
	var template = Handlebars.compile(templateScript);
	$('#bad_registrar_update').html(template());
})