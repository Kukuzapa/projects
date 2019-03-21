$('#history_submit').click(function(){

	$('#pagination').twbsPagination('destroy');

	var cnt = {}
	cnt.url = '/api/v2.1/history';
	cnt.dataType = 'json';

	cnt.data = {};

	cnt.data.count = $('#history_count').val();
	cnt.data.type  = 'client';
	cnt.data.per_from = $('#history_from').val();
	cnt.data.per_to = $('#history_to').val();

	
	var fst = {};
            	//var cnt = {}
	fst.url = '/api/v2.1/history';
	fst.dataType = 'json';

	fst.data = {};

	fst.data.count = $('#history_count').val();
	fst.data.clid  = '0';
	fst.data.per_from = $('#history_from').val();
	fst.data.per_to = $('#history_to').val();

	fst.success = function(data){
		//console.log(data);
		for (var i = 0; i < data.length; i++) {
			data[i].request = JSON.stringify(data[i].request,null, 2).replace(/"/g, '').replace(/\\/g, '');
			data[i].response = JSON.stringify(data[i].response,null, 2).replace(/"/g, '').replace(/\\/g, '');
		}
		var templateResult = $('#history_templ').html();
		var template = Handlebars.compile(templateResult);
		$('#history_fin').html(template(data));
		$('[data-toggle="popover"]').popover({
			trigger: 'hover',
			placement: 'auto',
			container: 'body'
		});
	}
	$.ajax(fst);

	cnt.success = function(data) {
		//console.log(data);
		$('#pagination').twbsPagination({
			totalPages: data,
			//onInit: function () {
            	//console.log('kkkk');
            	//$('#history_fin').text('ff');
       		//},
       		onPageClick: function (event, page) {
            	//$('#history_fin').text('Page ' + page);
            	var pag = {};
            	//var cnt = {}
				pag.url = '/api/v2.1/history';
				pag.dataType = 'json';

				pag.data = {};

				pag.data.count = $('#history_count').val();
				pag.data.clid  = (page - 1) * pag.data.count;
				//console.log(pag.data.clid);
				pag.data.per_from = $('#history_from').val();
				pag.data.per_to = $('#history_to').val();

				pag.success = function(data){
					//console.log(data);
					for (var i = 0; i < data.length; i++) {
						data[i].request = JSON.stringify(data[i].request,null, 2).replace(/"/g, '').replace(/\\/g, '');
						data[i].response = JSON.stringify(data[i].response,null, 2).replace(/"/g, '').replace(/\\/g, '');
					}
					var templateResult = $('#history_templ').html();
					var template = Handlebars.compile(templateResult);
					$('#history_fin').html(template(data));
					$('[data-toggle="popover"]').popover({
						trigger: 'hover',
						placement: 'auto',
						container: 'body'
					});
				}
				$.ajax(pag);
        	}
		})
	}

	$.ajax(cnt);
	return false;
});

function get_today() {
	var now   = new Date();
	var month = '-'+(now.getMonth()+1);
	if ( month.length == 2 ) { month = '-0' + (now.getMonth()+1); }
	return now.getFullYear()+month+'-'+now.getDate();
}

$('#history_from').datepicker({	
	language: 'ru',
	format: 'yyyy-mm-dd',
	autoclose: true
});

$('#history_to').datepicker({

	language: 'ru',
	format: 'yyyy-mm-dd',
	autoclose: true
});