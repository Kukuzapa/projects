//GET
$('#domain_get_submit').click(function(){
	var params = {};
	params.url = "/api/v2.1/domain/get";
	params.dataType = 'json';

	params.success = function(data) { 
		get_domain_result(data,'#domain_get_fin'); 
	}

	params.error = function(){
		$('#domain_get_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	params.data = {};

	params.data.name = $('#domain_get_name').val();
	if ( $('#domain_get_auth').val() ) { params.data.authInfo = $('#domain_get_auth').val() }

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false
});

//CHECK
$('#domain_check_submit').click(function(){
	var params = {};
	params.url = "/api/v2.1/domain/check";
	params.dataType = 'json';
	
	params.success = function(data,status){
		if ( data.check ) {
			for ( var key in data.check ) {
				if ( data.check[key] == 0 ) {
					data.check[key] = 'Имя домена занято';
				} else {
					data.check[key] = 'Имя домена свободно';
				}
			}
		}

		get_domain_result(data,'#domain_check_fin');
	}

	params.error = function(){
		$('#domain_check_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data = { name: $('#domain_check_name').val() }
	
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false
})

//CREATE
$('#domain_create_submit').click(function(){
	var params = {};
	
	params.url = '/api/v2.1/domain/create';
	params.dataType = 'json';
	
	params.data = {};
	params.data.ns = {};

	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";

	$('.dom_cr_nss_val').each(function(data){
		var ns = $.trim($(this).val());
		var ip = $.trim($('#'+$(this).data('ip')).val());

		if ( ns ){ params.data.ns[ns] = ip; }
	})

	params.success = function(data) { get_domain_result(data,'#domain_create_fin'); }

	params.error = function(){
		$('#domain_create_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	var templ = [ 'name', 'registrant', 'description', 'authInfo' ];

	for ( i=0; i<templ.length; i++ ){
		
		var tmp = $('#domain_create_'+templ[i]).val();
		
		if ( tmp ){	params.data[templ[i]] = tmp; }
	}

	params.data = JSON.stringify( params.data );
	
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false;
})

//UPDATE
$('#domain_update_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/domain/update';
	params.dataType = 'json';
	params.data = {};
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";

	params.success = function(data) { get_domain_result(data,'#domain_update_fin'); }

	params.error = function(){
		$('#domain_update_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data.status = [];
	params.data.ns = {};

	var templ = [ "clientUpdateProhibited", "clientTransferProhibited", "clientDeleteProhibited", "clientHold", "changeProhibited", "clientRenewProhibited" ];
	for ( var i=0; i<templ.length; i++ ) { if ( $('#domain_'+templ[i]).prop('checked') ) { params.data.status.push( templ[i] ); } }


	$('.dom_up_nss_val').each(function(data){
		var ns = $.trim($(this).val());
		var ip = $.trim($('#'+$(this).data('ip')).val());
		if ( ns ){ params.data.ns[ns] = ip; }
	})

	/*$('.dom_status_add').each(function(data){
		var st = $.trim($(this).val());

		if ( st && $.inArray( st, templ ) != -1 ){ params.data.status.push( st ) }
	})*/

	var templ = [ 'name', 'registrant', 'description', 'authInfo' ];

	for ( i=0; i<templ.length; i++ ){
		var tmp = $('#domain_update_'+templ[i]).val();
		if ( tmp ){	params.data[templ[i]] = tmp; }
	}
	
	params.data = JSON.stringify( params.data );

	//console.log( params.data );

	
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false;
})

//TRANSFER
$('#domain_transfer_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/domain/transfer/' + $('#domain_transfer_select').val();
	params.dataType = 'json';
	params.data = {};
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";
	params.data = { name: $('#domain_transfer_name').val(), authInfo: $('#domain_transfer_auth').val() }

	params.success = function(data) { get_domain_result(data,'#domain_transfer_fin'); }

	params.error = function(){
		$('#domain_transfer_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data = JSON.stringify( params.data );
	
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false;
})

//RENEW
$('#domain_renew_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/domain/renew';
	params.dataType = 'json';
	params.data = {};
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";

	if ( $('#domain_renew_name').val() ) { params.data.name = $('#domain_renew_name').val(); }
	if ( $('#domain_renew_curExpDate').val() ) { params.data.curExpDate = $('#domain_renew_curExpDate').val(); }

	params.success = function(data) { get_domain_result(data,'#domain_renew_fin'); }

	params.error = function(){
		$('#domain_renew_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	params.data = JSON.stringify( params.data );

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false;
})

//DELETE
$('#domain_delete_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/domain/delete';
	params.dataType = 'json';
	params.data = {};
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";
	params.data = { name: $('#domain_delete_name').val() }

	params.success = function(data) { get_domain_result(data,'#domain_delete_fin'); }

	params.error = function(){
		$('#domain_delete_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	params.data = JSON.stringify( params.data );

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);

	return false;
})

//COPY
$('#domain_copy_submit').click(function(){
	var params = {};
	params.url = "/api/v2.1/domain/copy";
	params.dataType = 'json';
	params.success = function(data) { get_domain_result(data,'#domain_copy_fin'); }

	params.error = function(){
		$('#domain_copy_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	params.data = {};
	params.data.name = $('#domain_copy_name').val();
	if ( $('#domain_copy_auth').val() ) { params.data.authInfo = $('#domain_copy_auth').val() }

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	
	return false
});

//HELPERS
function makeCounter() {
	var currentCount = 1;
  	return function() {
    	return currentCount++;
  	};
}
var counter = makeCounter();

function rem_sts_nss(rs){
	$( '.'+$(rs).data('full') ).remove();
}

function get_domain_result(data,id) {
	var templateResult = $('#result_domain').html();
	var template = Handlebars.compile(templateResult);
	$(id).html(template(data));
}

$('.domain_add_nss').click(function(){
	var value = {}
	value.count = counter();
	value.command = $(this).data('command');

	var tmp = '#' + $(this).data('id');

	var templateScript = $('#add_nss').html();
	var template = Handlebars.compile(templateScript);
	$(tmp).append(template(value));
})

$('.add_status').click(function(){
	var value = {}
	value.count = counter();
	value.obj = $(this).data('obj');

	var tmp = '#' + $(this).data('id');

	var templateScript = $('#add_sts').html();
	var template = Handlebars.compile(templateScript);
	$(tmp).append(template(value));
})



$('#domain_update_name').autocomplete({
	minChars: 3,
	noCache: true,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	onSearchComplete: function(query, suggestion) {
		if ( jQuery.isEmptyObject(suggestion) ) {
			var value = {};
			value.obj = query;

			var templateScript = $('#alarm_update').html();
			var template = Handlebars.compile(templateScript);
			$('#bad_object_update').html(template(value));
		} else {
			$('#dom_alarm').remove();
		}
	},
	params: { obj : 'dom' },
	onSelect: function(suggestion){
		$('.auto-sts-dom').each(function(data){
			$(this).remove();
		})

		$('.auto-nss').each(function(data){
			$(this).remove();
		})

		var templ = [ "clientUpdateProhibited", "clientTransferProhibited", "clientDeleteProhibited", "clientHold", "changeProhibited", "clientRenewProhibited" ];
		for ( var i=0; i<templ.length; i++ ) { $('#domain_'+templ[i]).prop('checked',false); }
		

		$('#domain_update_description').val('');
		$('#domain_update_authInfo').val('');

		$('#domain_update_description').val(suggestion.data.description);
		$('#domain_update_authInfo').val(suggestion.data.authInfo);
		
		var status
		if ( suggestion.data.status ){ 
			status = suggestion.data.status.split(';'); 
			for ( i=0; i<status.length; i++){
				$('#domain_'+status[i]).prop('checked',true);
			}
		}

		var nss
		if ( suggestion.data.nss ){ 
			nss = suggestion.data.nss.split(';'); 
			for ( i=0; i<nss.length; i++ ){
				
				var ns = nss[i].split( '#' )[0]
				var ip = nss[i].split( '#' )[1]
				if ( ip ){
					ip = ip.replace( ',', ' ' )
				}

				var value = {}
				value.count = counter();
				value.command = 'up';
				value.ns = ns;
				value.ip = ip;

				var templateScript = $('#add_nss').html();
				var template = Handlebars.compile(templateScript);
				$('#du-nss').append(template(value));
			}
		}
	} 
});

$('#domain_renew_curExpDate').datepicker({
	language: 'ru',
	format: 'yyyy-mm-dd',
	autoclose: true
});

$('.typeahead_registrar').autocomplete({
	noCache: true,
	minChars: 3,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	params: { obj : 'con' },
	onSelect: function (suggestion) {
		$( '#'+$(this).data('id') ).val(suggestion.data.contact_id);
	}
});

$('.typeahead_domain').autocomplete({
	minChars: 3,
	noCache: true,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	params: { obj : 'dom' }
});

$('#domain_renew_name').autocomplete({
	minChars: 3,
	noCache: true,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	params: { obj : 'dom' },
	onSelect: function (suggestion) {
		$('#domain_renew_curExpDate').val( suggestion.data.exdate.substr( 0, 10 ) );
	}
});

var timer;
function timeIn(id){
	clearTimeout(timer);
	timer = setTimeout(function(){
		if ( $(id).val().length == 2 ){
			$(id).autocomplete('setOptions',{ minChars: 2 });
			$(id).focus();
			$(id).autocomplete('setOptions',{ minChars: 3 });
		}
	}, 5000 );
}

$('.typeahead_domain').keydown(function(){
	timeIn(this);
})

$('.typeahead_domain').blur(function(){
	clearTimeout(timer);
})

$('.typeahead_domain').focus(function(){
	timeIn(this);
})

$('.typeahead_registrar').keydown(function(){
	timeIn(this);
})

$('.typeahead_registrar').blur(function(){
	clearTimeout(timer);
})

$('.typeahead_registrar').focus(function(){
	timeIn(this);
})


$('#domain_update_name').keydown(function(){
	timeIn(this);
})

$('#domain_update_name').blur(function(){
	clearTimeout(timer);
})

$('#domain_update_name').focus(function(){
	timeIn(this);
})


$('#domain_renew_name').keydown(function(){
	timeIn(this);
})

$('#domain_renew_name').blur(function(){
	clearTimeout(timer);
})

$('#domain_renew_name').focus(function(){
	timeIn(this);
})