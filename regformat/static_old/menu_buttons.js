//Выбор операций регистратора
$('.reg_btn').click(function(){
	console.log('push '+$(this).text());

	$('.reg_btn').each(function(){
		$(this).attr('class','btn btn-default btn-block btn-sm reg_btn');
		$('#registrar'+$(this).text()).hide();
	})

	$(this).attr('class','btn btn-success btn-block btn-sm reg_btn');
	
	if ( $(this).text() == 'Update' ){

		var params = {};
		params.url = '/api/v2.1/registrar/get/' + format_reg( $('#registrar_update_select').val() );
		params.dataType = 'json';

		params.success = function( data ){
			$('.registrar_update_ip').each(function(){
				//if ( $(this).val() ) {
				//	params.data.ip.push( $(this).val() );
				//}
				$(this).val(null);
			})

			var addr = [];

			if ( data.registrar ) {
				if ( data.registrar.v4 ) {
					$.merge( addr, data.registrar.v4 );
				} else if ( data.registrar.v6 ) {
					$.merge( addr, data.registrar.v6 )
				}
			}

			for ( var i=0; i<addr.length; i++ ) {
				$('#regip_'+(i+1).toString()).val(addr[i]);
			}

			$('#loading').fadeOut(200);
		}

		params.error = function(){
			$('#registrar_update_fin').text( new Date($.now()) + ' Нет связи с сервером');
			$('#loading').fadeOut(200);
		}

		$('#loading').fadeIn(200);
		$.ajax(params);
		
		$('#registrar'+$(this).text()).show();
	} else {
		$('#registrar'+$(this).text()).show();
	}
})

//Выбор операций контактов
$('.con_btn').click(function(){
	console.log('push '+$(this).text());

	$('.con_btn').each(function(){
		$(this).attr('class','btn btn-default btn-block btn-sm con_btn contact'+$(this).text());
		$('#contact'+$(this).text()).hide();
	})

	$(this).attr('class','btn btn-success btn-block btn-sm con_btn contact'+$(this).text());
	$('#contact'+$(this).text()).show();
})

//Выбор операций доменов
$('.dom_btn').click(function(){
	console.log('push '+$(this).text());

	$('.dom_btn').each(function(){
		$(this).attr('class','btn btn-default btn-block btn-sm dom_btn domain'+$(this).text());
		$('#domain'+$(this).text()).hide();
	})

	$(this).attr('class','btn btn-success btn-block btn-sm dom_btn domain'+$(this).text());
	$('#domain'+$(this).text()).show();
})	

//Обработка выбора объекта
$('.main_btn').click(function(){
	//console.log('push '+$(this).text());

	$('.main_btn').each(function(i,elem){
		//console.log($(elem).text().toLowerCase());
		$('.'+$(elem).text().toLowerCase()+'Forms').hide();
		if ( $(elem).text() == 'Operations' ){
			$(elem).attr('class','main_btn btn btn-default btn-block operations');
		} else {
			$(elem).attr('class','main_btn btn btn-default btn-block d-none d-xl-block d-lg-block d-md-block '+$(elem).text().toLowerCase());	
		}
	})

	$('.'+$(this).text().toLowerCase()+'Forms').show();

	if ( $(this).text() == 'Operations' ){
		$(this).attr('class','main_btn btn btn-success btn-block operations');
		$('#history_from').val(get_today());
		$('#history_to').val(get_today());
	} else {
		$(this).attr('class','main_btn btn btn-success btn-block d-none d-xl-block d-lg-block d-md-block '+$(this).text().toLowerCase());	
	}
})