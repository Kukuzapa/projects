<template>
	<div class="container">
		<div class="row text-center">
			<div class="col-12">
				<h5>Детали заявки</h5>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th scope="col">Автор</th>
							<th scope="col">Начало</th>
							<th scope="col">Конец</th>
							<th scope="col">Дней</th>
							<th scope="col">Тип отпуска</th>
							<th scope="col">Статус</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td>{{vacation.name}}</td>
							<td>{{vacation.begin}}</td>
							<td>{{vacation.end}}</td>
							<td>{{vacation.days}}</td>
							<td>{{vacation.type}}</td>
							<td>{{get_status( vacation.status )}}</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="col-12" v-if="vacation.status==-2">
				<p>Пользователь сам отозвал свою заявку.</p>
			</div>
			
			<div class="form-group col-12" v-if="vacation.status!=-2">
				<label for="exampleFormControlTextarea1">Решайте и комментируйте</label>
				<textarea class="form-control" id="exampleFormControlTextarea1" rows="2" v-model="comment"></textarea>
			</div>

			<div class="col-6 mb-3" v-if="vacation.status!=-2">
				<button type="button" class="btn btn-primary btn-block" @click="vacation_decision($route.params.vacid,vacation.name,'accept')">Подвердить</button>
			</div>

			<div class="col-6 mb-3" v-if="vacation.status!=-2">
				<button type="button" class="btn btn-primary btn-block" @click="vacation_decision($route.params.vacid,vacation.name,'reject')">Отказать</button>
			</div>

			<div class="col-12">
				<div class="alert alert-success" role="alert" v-if="action">
					{{action}}
				</div>
			</div>

			<div class="col-12">
				<h5>Пересечения с обладателями схожих компетенций</h5>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th scope="col">Автор</th>
							<th scope="col">Начало</th>
							<th scope="col">Конец</th>
							<th scope="col">Дней</th>
							<th scope="col">Компетенция</th>
							<th scope="col">Статус</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="row in cross">
							<td>{{row.name}}</td>
							<td>{{row.begin}}</td>
							<td>{{row.end}}</td>
							<td>{{row.days}}</td>
							<td>{{row.competense}}</td>
							<td>{{get_status( row.status )}}</td>
						</tr>
					</tbody>
				</table>
			</div>

			<div class="col-12">
				<h5>Журнал операций с заявкой</h5>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th scope="col">Дата</th>
							<th scope="col">Действие</th>
							<th scope="col">Комментарий</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="row in logs">
							<td>{{row.date_time}}</td>
							<td>{{row.action}}</td>
							<td>{{row.comment}}</td>
						</tr>
					</tbody>
				</table>
			</div>

			<!--div class="col-6">
				<h5>Все комментарии</h5>
				<table class="table table-bordered">
					<thead>
						<tr>
							<th scope="col">Автор</th>
							<th scope="col">Комментарий</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="row in comments">
							<td>{{row.name}}</td>
							<td>{{row.comment}}</td>
						</tr>
					</tbody>
				</table>
			</div-->
		</div>
	</div>
</template>

<script>
export default {
	name: 'HelloWorld',

	methods: {
		vacation_decision: function( vacid, name, decision ){
			var url = '/vm/admin/vacation/'+decision+'?userid='+this.$route.params.userid;

			var req = { vacid: vacid, name: name };
            
            if ( this.comment.length > 0 ){
                req.comment = this.comment;
			}
			
			this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
					//this.get_new();
					this.action = response.data.action;
                }
            );
		},

		get_status: function( st ){
			var status = 'Решение не принято'
			if ( st == -2 ) { status = 'Заявка отозвана пользователем' } 
			if ( st == -1 ) { status = 'Заявка отклонена' } 
			if ( st == 1 ) { status = 'Заявка одобрена' }
			return status 
		}
	},
	  
	created: function(){
		if ( !this.$route.query.access_token ) {
			window.location.href = 'https://id.gtn.ee/oauth/authorize?response_type='+this.response_type+
				'&client_id='+this.client_id+'&state=kukuzapa+forever&redirect_uri='+this.redirect_uri;
		} else {
			this.user_token = this.$route.query.access_token;
		}

		this.axios.get( '/vm/admin/link', { 
				params: { userid: this.$route.params.userid, vacid: this.$route.params.vacid },
				headers: { 'Authorization': 'Bearer ' + this.user_token }
			}).then( response => {
				this.vacation = response.data.sel;
				this.comments = response.data.com;
				this.logs = response.data.log;
				this.cross = response.data.cross;
			}).catch( response => {
				this.$router.push( '/' )
			}
		)
	},
	  
	data: function(){
		return {
			response_type: 'token',
			client_id: '550a99bc-ba73-11e8-ba29-977a227fe9e2',
			state: 'kukuzapa forever',
			redirect_uri: window.location.href,

			vacation: {},
			comments: {},
			logs: {},
			cross: {},

			comment: '',

			action: null,

			user_token: ''
		}
	},
}
</script>