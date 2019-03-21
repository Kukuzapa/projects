//CREATE
$('#contact_create_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/contact/create/' + format_reg( $('#contact_create_select').val() );
	params.dataType = 'json';
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";
	params.data = {};

	params.data.voice = [];

	params.data.email = [];

	$('.con_cr_voice_val').each(function(data){
		params.data.voice.push( $(this).val() );
	})

	$('.con_cr_email_val').each(function(data){
		params.data.email.push( $(this).val() );
	})

	//console.log( $('#contact_create_type').val() );

	if ( $('#contact_create_type').val() == 'person' ) {
		var templ  = [ 'passport', 'address' ];
		var templ2 = [ 'name', 'int_name', 'birthday' ];
	} else {
		var templ  = [ 'leg_address', 'address' ];
		var templ2 = [ 'org', 'int_org', 'taxpayerNumbers' ];
	}

	for ( i=0; i<templ.length; i++ ){
		var val = $('#contact_create_'+templ[i]).val();
		if ( val ){	
			params.data[templ[i]] = [];
			var array = params.data[templ[i]];
			var tmp = '';
			for ( var j = 0; j < val.length; j++ ){
				tmp = tmp + val[j];
				if ( (j+1) % 250 == 0 ){
					array.push( tmp );
					tmp = '';
				}
			}
			if ( tmp.length > 0 ){ array.push( tmp ) } 
		}
	}

	for ( i=0; i<templ2.length; i++ ){
		var tmp = $('#contact_create_'+templ2[i]).val();
		if ( tmp ){	params.data[templ2[i]] = tmp; }
	}

	params.success = function(data){
		get_contact_result(data,'#contact_create_fin');
	}

	params.error = function(){
		$('#contact_create_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data = JSON.stringify( params.data );
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//UPDATE
$('#contact_update_submit').click(function(){
	var params         = {};
	params.url         = '/api/v2.1/contact/update/' + format_reg( $('#contact_update_select').val() );
	params.dataType    = 'json';
	params.type        = 'POST';
	params.contentType = "application/json; charset=utf-8";
	
	params.data        = {};
	params.data.voice  = [];
	params.data.status = [];
	params.data.email  = [];

	$('.con_up_voice_val').each(function(data){
		params.data.voice.push( $(this).val() );
	})

	$('.con_up_email_val').each(function(data){
		params.data.email.push( $(this).val() );
	})

	var templ = [ "clientUpdateProhibited", "clientDeleteProhibited" ];
	for ( var i=0; i<templ.length; i++ ) { if ( $('#contact_'+templ[i]).prop('checked') ) { params.data.status.push( templ[i] ); } }

	/*$('.con_status_add').each(function(data){
		var st = $.trim($(this).val());
		if ( st && $.inArray( st, templ ) != -1 ){ params.data.status.push( st ) }
	})*/

	var templ = [ 'passport', 'leg_address', 'address' ];

	for ( i=0; i<templ.length; i++ ){
		var val = $('#contact_update_'+templ[i]).val();
		if ( val ){	
			params.data[templ[i]] = [];
			var array = params.data[templ[i]];
			var tmp = '';
			for ( var j = 0; j < val.length; j++ ){
				tmp = tmp + val[j];
				if ( (j+1) % 250 == 0 ){
					array.push( tmp );
					tmp = '';
				}
			}
			if ( tmp.length > 0 ){ array.push( tmp ) } 
		}
	}

	var templ = [ 'name', 'org', 'int_name', 'int_org', 'taxpayerNumbers', 'birthday', 'verified', 'id' ];

	for ( i=0; i<templ.length; i++ ){
		var tmp = $('#contact_update_'+templ[i]).val();
		if ( tmp ){	params.data[templ[i]] = tmp; }
	}

	params.success = function(data){
		get_contact_result(data,'#contact_update_fin');

		//var templateScript = $('#templ_domain_update').html();
		//var template = Handlebars.compile(templateScript);
		//$('#contact_update_fin').html(template(data));
	}

	params.error = function(){
		$('#contact_update_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	console.log(params.data);

	params.data = JSON.stringify( params.data );


					
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);

	return false;
})

//CHECK
$('#contact_check_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/contact/check/' + format_reg( $('#contact_check_select').val() );
	params.dataType = 'json';
	params.data = { id: $('#contact_check_id').val() }
	params.success = function(data){
		if ( data.check ) {
			for ( var key in data.check ) {
				if ( data.check[key] == 0 ) {
					data.check[key] = 'Занят';
				} else {
					data.check[key] = 'свободен';
				}
			}
		}

		get_contact_result(data,'#contact_check_fin');
	}

	params.error = function(){
		$('#contact_check_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//DELETE
$('#contact_delete_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/contact/delete/' + format_reg( $('#contact_delete_select').val() );
	params.dataType = 'json';
	params.data = {};
	params.type = 'POST';
	params.contentType = "application/json; charset=utf-8";
	params.data = { id: $('#contact_delete_id').val() }
	params.success = function(data){
		get_contact_result(data,'#contact_delete_fin');

		//var templateScript = $('#templ_domain_update').html();
		//var template = Handlebars.compile(templateScript);
		//$('#contact_delete_fin').html(template(data));
	}

	params.error = function(){
		$('#contact_delete_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	params.data = JSON.stringify( params.data );
	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//GET
$('#contact_get_submit').click(function(){
	var params = {};
	params.url = '/api/v2.1/contact/get/' + format_reg( $('#contact_get_select').val() );
	params.dataType = 'json';
	params.data = {};
	//params.data = { name: $('#contact_get_name').val(), authInfo: $('#domain_transfer_auth').val() }
	params.data.id = $('#contact_get_id').val();
	if ( $('#contact_get_auth').val().length > 0 ){
		params.data.authInfo = $('#contact_get_auth').val();
	}
	params.success = function(data){
		//alert(data.contact.verified)
		if ( data.contact ){
			if ( data.contact.verified == 'verified' ){
				data.contact.verified = 'Подтвержден';
			} else {
				data.contact.verified = 'Не подтвержден';
			}
		}

		get_contact_result(data,'#contact_get_fin');

		//var templateScript = $('#templ_contact_get').html();
		//var template = Handlebars.compile(templateScript);
		//$('#contact_get_fin').html(template(data));
	}

	params.error = function(){
		$('#contact_get_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}

	$('#loading').fadeIn(200);
	$.ajax(params);
	$('#loading').fadeOut(200);
	return false;
})

//COPY
$('#contact_copy_submit').click(function(){
	var params = {};
	params.url = "/api/v2.1/contact/copy/" + format_reg( $('#contact_copy_select').val() );
	params.dataType = 'json';
	params.success = function(data,status){
		get_contact_result(data,'#contact_copy_fin');

		//var templateScript = $('#templ_domain_update').html();
		//var template = Handlebars.compile(templateScript);
		//$('#contact_copy_fin').html(template(data));
	}

	params.error = function(){
		$('#contact_copy_fin').text( new Date($.now()) + ' Нет связи с сервером');
	}
	
	params.data = { id: $('#contact_copy_id').val() }
	if ( $('#contact_copy_auth').val() ) { params.data['authInfo'] = $('#contact_copy_auth').val() }
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

$('.add_voice_email').click(function(){
	var value = {};
	value.command = $(this).data('command');
	value.value = $(this).data('value');
	value.count = counter();

	var tmp = '#' + $(this).data('id');


	var templateScript = $('#templ_email_voice').html();
	var template = Handlebars.compile(templateScript);
	$(tmp).append(template(value));
})

function rem_voice_email(rve){
	$( '#'+$(rve).data('rem') ).remove();
}

$('.contact_type').change(function(){
	var tmp = $(this).val();

	if ( tmp == 'organization' ) {
		$('.show_org_' + $(this).data('command')).show();
		$('.show_person_' + $(this).data('command')).hide();
	} else {
		$('.show_org_' + $(this).data('command')).hide();
		$('.show_person_' + $(this).data('command')).show();
	}
})

$('.birthday').datepicker({
	language: 'ru',
	format: 'yyyy-mm-dd',
	autoclose: true
});

$('.typeahead_contact').autocomplete({
	noCache: true,
	minChars: 3,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	params: { obj : 'con' },
	onSearchStart: function(params){
		params.reg = format_reg( $( '#'+$(this).data('reg') ).val() );
	},
	onSelect: function (suggestion) {
		$( '#'+$(this).data('id') ).val( suggestion.data.contact_id );
	}
});

$('#contact_update_info').autocomplete({
	//lookupLimit: 5,
	minChars: 3,
	noCache: true,
	serviceUrl: "/api/v2.1/base",
	dataType: 'json',
	params: { obj : 'con' },
	onSelect: function (suggestion) {
		$( '#'+$(this).data('id') ).val( suggestion.id );
		
		$('#contact_update_fin').html('');

		var templ = [ "clientUpdateProhibited", "clientDeleteProhibited" ];
		for ( var i=0; i<templ.length; i++ ) { $('#contact_'+templ[i]).prop('checked',false); }

		$('#contact_update_select').val('rf');

		//console.log('RF')

		if ( suggestion.data.id_registrars == 1 ) {
			$('#contact_update_select').val('REGFORMAT-RU');

			//console.log('RU')

			//console.log( $('#contact_update_select').val() )
		}

		var templ = {
			birthday              : 'contact_update_birthday',
			locPostalInfo_org     : 'contact_update_org',
			locPostalInfo_address : 'contact_update_address',
			legalInfo_address     : 'contact_update_leg_address',
			passport              : 'contact_update_passport',
			contact_id            : 'contact_update_id',
			locPostalInfo_name    : 'contact_update_name',
			intPostalInfo_org     : 'contact_update_int_org',
			taxpayerNumbers       : 'contact_update_taxpayerNumbers',
			intPostalInfo_name    : 'contact_update_int_name',
			type                  : 'contact_update_type',
			verified              : 'contact_update_verified'
		}
		for ( var key in templ ) {
			console.log( suggestion.data.type );

			if ( suggestion.data.type == 'person' ) {
				$('.show_org_cu').hide();
				$('.show_person_cu').show();
				
			} else {
				$('.show_person_cu').hide();
				$('.show_org_cu').show();
			}
			
			$( '#'+templ[key] ).val( suggestion.data[key] );
		}

		$('.auto-sts-con').each(function(data){
			$(this).remove();
		})

		$('.auto-email-voice').each(function(data){
			$(this).remove();
		})

		var status
		if ( suggestion.data.status ){ 
			status = suggestion.data.status.split(';'); 
			for ( i=0; i<status.length; i++){
				$('#contact_'+status[i]).prop('checked',true);
				/*var value = {};
				value.count = counter();
				value.sts = status[i];
				value.obj = 'con';
				var templateScript = $('#add_sts').html();
				var template = Handlebars.compile(templateScript);
				$('#c-sts').append(template(value));*/
			}
		}

		if ( suggestion.data.voice ) {
			var voice = suggestion.data.voice.split(';');
			$('#contact_update_voice').val(voice[0]);
			for (var i = 1; i < voice.length; i++) {
				var value = {};
				value.command = 'up';
				value.value = 'voice';
				value.count = counter();
				value.val   = voice[i];
				var tmp = '#cu-voice';
				var templateScript = $('#templ_email_voice').html();
				var template = Handlebars.compile(templateScript);
				$(tmp).append(template(value));
			}
		}

		if ( suggestion.data.email ) {
			var email = suggestion.data.email.split(';');
			$('#contact_update_email').val(email[0]);
			for (var i = 1; i < email.length; i++) {
				var value = {};
				value.command = 'up';
				value.value = 'email';
				value.count = counter();
				value.val   = email[i];
				var tmp = '#cu-email';
				var templateScript = $('#templ_email_voice').html();
				var template = Handlebars.compile(templateScript);
				$(tmp).append(template(value));
			}
		}
	}
})

function get_contact_result(data,id) {
	var templateResult = $('#result_contact').html();
	var template = Handlebars.compile(templateResult);
	$(id).html(template(data));
}

$('.typeahead_contact').keydown(function(){
	timeIn(this);
})

$('.typeahead_contact').blur(function(){
	clearTimeout(timer);
})

$('.typeahead_contact').focus(function(){
	timeIn(this);
})

$('#contact_update_info').keydown(function(){
	timeIn(this);
})

$('#contact_update_info').blur(function(){
	clearTimeout(timer);
})

$('#contact_update_info').focus(function(){
	timeIn(this);
})