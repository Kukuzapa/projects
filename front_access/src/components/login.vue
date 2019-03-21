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
			client_id: '6192c9c2-a135-11e8-ba29-4f04e5ae533e',
			state: 'kukuzapa access manager',
			redirect_uri: window.location.href
		}
	},

	created: function(){
		if ( this.$route.query.access_token ) {
			
            //var id = '';
            //var name = '';
            
            this.axios.get( 'https://id.gtn.ee/rc/api/v1.0/userinfo', { 
                    headers: { 'Authorization': 'Bearer ' + this.$route.query.access_token }
                }).then( response => {
                    console.log( response );
                    //id = response.data.sub;
                    //name = response.data.name;

                    this.$store.commit( 'login', { 
                        token: this.$route.query.access_token, 
                        id: response.data.sub, 
						user: response.data.name,
						email: response.data.email,
                    } )

                    this.$router.push( '/access' )
                } )

            //console.log( 'GGGG', id, name )

            
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