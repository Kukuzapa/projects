<template>
	<div class="container">
        <div class="row">
        	<button type="button" class="btn btn-primary btn-block col-12" @click="login">Вход в сервис "Менеджер отпусков"</button>
        </div>	
	</div>
</template>

<script>
export default {
	name: 'login',

	data: function(){
		return {
			response_type: 'token',
			client_id: '550a99bc-ba73-11e8-ba29-977a227fe9e2',
			state: 'kukuzapa forever',
			redirect_uri: window.location.href
		}
	},

	created: function(){
		if ( this.$route.query.access_token ) {
			this.$store.commit( 'login', { token: this.$route.query.access_token } )

			this.$router.push( '/vacation' )
		}
	},

	methods: {
		login: function(){
			window.location.href = 'https://id.gtn.ee/oauth/authorize?response_type='+this.response_type+
				'&client_id='+this.client_id+'&state=kukuzapa+forever&redirect_uri='+this.redirect_uri;
		}
	}
}
</script>