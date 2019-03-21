var domain_status = {
	clientUpdateProhibited: 'регистратору запрещено выполнять процедуры внесения изменений',
	clientRenewProhibited: 'регистратору запрещено выполнять процедуру продления домена',
	clientTransferProhibited: 'регистратору запрещено выполнять процедуру передачи доменного имени',
	clientDeleteProhibited: 'регистратору запрещено удалять домен',
	clientHold: 'запрет делегирования домена',
	changeProhibited: 'домен в состоянии «Судебный Спор»',

	serverUpdateProhibited: 'установлено ограничение регистратору на выполнение процедур внесения изменений и запрещение выполнение продления',
	serverDeleteProhibited: 'установлено ограничение регистратору на удаление доменного имени',
	serverRenewProhibited: 'установлено ограничение регистратору на продление срока регистрации доменного имени',

	serverTransferProhibited: 'установлено ограничение регистратору на передачу доменного имени другому регистратору',
	serverHold: 'установлен запрет делегирования домена',
	inactive: 'невыполнение условий делегирования домена, домен не будет делегирован',
	ok: 'у домена отсутствуют запрещающие статусы, домен не находится в процессе выполнения каких-либо операций',
	
	
	pendingCreate: 'домен находится в процессе выполнения процедуры создания',
	pendingDelete: 'домен находится в процессе выполнения процедуры удаления',
	pendingRenew: 'домен находится в процессе выполнения процедуры продления',
	pendingTransfer: 'домен находится в процессе выполнения процедуры передачи регистратору-реципиенту',
	pendingUpdate: 'домен находится в процессе выполнения процедуры изменения'

	//serverDeleteProhibited: 'hui',
	//serverRenewProhibited: 'zalupa'
}

var tmpc;

function get_list( dir, col, count, domain, page ){
	
	var data = {};
	data.url = '/api/v2.1/list/';
	data.dataType = 'json';

	data.data = {};
	data.data.column = col;
	data.data.dir = dir;
	data.data.count = false;
	data.data.page = page;
	data.data.domain = domain;

	if ( count ){
		data.data.count = true;
	}

	//var tmpc;

	data.success = (list) => {

		if ( list.count ){
			$('#paglist').twbsPagination('destroy');

			if (list.count == 1){
				get_list(dir,col,false,domain,'1');
			} else {
			//console.log('count'+list.count)
				$('#paglist').twbsPagination({


	  				totalPages: list.count,

	  				hideOnlyOnePage: false,
	  				//visiblePages: 7,
	  				onPageClick: function (event, page) {
	    				//$('#page-content').text('Page ' + page);
	    				//console.log(page);
	    				//console.log('fff '+dir)
	    				get_list(dir,col,false,domain,page);
	  				}
				}); 
			}
		} else {

			//console.log('hhh')

			for (var i=0;i<list.length;i++){
				//if (list[i].status){ list[i].status = list[i].status.replace(';','\r\n') }
				//if (list[i].status){ list[i].status = list[i].status.split(';').join('\r\n') }

				if (list[i].status){ list[i].status = list[i].status.split(';') }
				
				//if (list[i].nss){ list[i].nss = list[i].nss.split(';').join('\r\n') }

				if (list[i].nss){ list[i].nss = list[i].nss.split(';') }

				if (list[i].locPostalInfo_name){
					list[i].contact = list[i].locPostalInfo_name
				} else {
					list[i].contact = list[i].locPostalInfo_org
				}
			}

			var templateResult = $('#domainTable_templ').html();
			var template = Handlebars.compile(templateResult);
			$('#domainTable').html(template(list));

			$('.poptest').popover({
	    		title: 'Статусы домена',
	    		content: function(){

	    			//console.log($(this).text())
	    			var tmp1 = $(this).text().split('\n');
	    			//console.log(tmp1)

	    			var tmp = []

	    			for (var i=0;i<tmp1.length;i++){
	    				tmp1[i] = tmp1[i].replace( /\s/g, "")
	    				if (tmp1[i].length > 0){ tmp.push(tmp1[i]) }
	    			}



	    			//console.log(tmp1)

	    			var str = '';
	    			if ( tmp.length == 0 ){
	    				str = 'Статусов нет. Возможно есть смысл сихронизировать базу с реестром.'
	    			} else {
		    			for ( var i=0; i<tmp.length; i++ ){
		    				str = str+tmp[i]+' - '+domain_status[tmp[i]]+'\r\n'
		    			}
		    		}
	    			return str;
	    		},
	    		trigger: 'hover',
	    		placement: 'right'
	 	 	});
	 	}
	}
	
	$.ajax(data);
	//console.log(tmpc);
	//return tmpc;
}

$('.domainList').click(function(){
	//console.log('domainList click');

	//var tmpc;
	//get_list('ASC','name', true);

	/*$('#paglist').twbsPagination({
  		totalPages: tmpc,
  		//visiblePages: 7,
  		onPageClick: function (event, page) {
    		$('#page-content').text('Page ' + page);
  		}
	});*/

	/*var str;

	if ( $('#domainFilter').val().length == 0 ){
		str = ''
	} else {
		str = $('#domainFilter').val()
	}*/
	

	get_list('ASC','name', true, '');

	//get_list('ASC','name');

	$('.fa-angle-up').filter('.name').hide();
	$('.fa-angle-down').filter('.name').show();
	
})

$('.domainFilter').click(function(){
	//console.log('domainList click');

	var str;

	if ( $('#domainFilter').val().length == 0 ){
		str = ''
	} else {
		str = $('#domainFilter').val()
	}
	

	get_list('ASC','name', true, str);

	//get_list('ASC','name');

	$('.fa-angle-up').filter('.name').hide();
	$('.fa-angle-down').filter('.name').show();
	
})

$('.domlist').click(function(){
	//console.log($(this).data('dir'));

	//console.log($('#domainFilter').val().length)

	var str;

	if ( $('#domainFilter').val().length == 0 ){
		str = ''
	} else {
		str = $('#domainFilter').val()
	}
	
	get_list( $(this).data('dir'), $(this).data('col'), true, str );

	if ( $(this).data('col') == 'name' ){
		$('.exdate').show();
	} else {
		$('.name').show();
	}

	$(this).hide();
	$(this).siblings('span').show();

	//console.log($(this).siblings('span').data('dir') )
})

$('.test').click(function(){
	//console.log($(this).text());
	//console.log('jjjjj')
})

function go_to_update( domain ){
	//console.log( domain );
	$('#domain_update_name').val( domain );
	$('#domain_update_fin').html('');

	$('#domainUpdate').show();
	$('#domainList').hide();

	$('.domainList').attr('class','btn btn-default btn-block btn-sm domainList dom_btn');
	$('.domainUpdate').attr('class','btn btn-success btn-block btn-sm domainUpdate dom_btn');
	//$('#domain_update_name').autocomplete();
	$('#domain_update_name').change();
}

function go_to_renew( domain ){
	//console.log( domain );

	$('#domain_renew_name').val( domain );
	$('#domain_renew_fin').html('');

	$('#domainRenew').show();
	$('#domainList').hide();

	$('.domainList').attr('class','btn btn-default btn-block btn-sm domainList dom_btn');
	$('.domainRenew').attr('class','btn btn-success btn-block btn-sm domainUpdate dom_btn');

	$('#domain_renew_name').change();
}

function go_to_contact( contact ){
	//console.log( contact );

	$('#contact_update_info').val( contact );

	$('.domainForms').hide();
	$('.contactForms').show();

	//$('.contact').show();
	//$('.domain').hide();
	$('.contact').attr('class','main_btn btn btn-success btn-block d-none d-xl-block d-lg-block d-md-block contact');
	$('.domain').attr('class','main_btn btn btn-default btn-block d-none d-xl-block d-lg-block d-md-block domain');

	$('.con_btn').each(function(){
		//$(this).attr('class','btn btn-default btn-block btn-sm con_btn');
		//console.log($(this).text());
		//$('#contact'+$(this).text()).hide();
		$(this).attr('class','btn btn-default btn-block btn-sm con_btn contact'+$(this).text());
		$('#contact'+$(this).text()).hide();
	})

	//$('#contactUpdate')[0].reset();

	//document.getElementById('contactUpdate').reset();

	$('.contactUpdate').attr('class','btn btn-success btn-block btn-sm con_btn contactUpdate');
	$('#contactUpdate').show();
	//$('#domainList').hide();

	$('#contact_update_info').change();
}