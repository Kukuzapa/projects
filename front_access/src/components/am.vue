<template>
	<!--p>Hello</p-->
	<div class="container" id="main">
		<div class="row">
			<div class="col-12 text-center">
				Access Manager
			</div>

			<div class="col-3">
				{{user_name}}
			</div>
			<div class="col-6">
			
			</div>
			<div class="col-3">
				<button type="button" class="btn btn-primary btn-block" @click="logout">LOGOUT</button>
			</div>

			<div class="col-3 mb-2 mt-2">
				<button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active.node }"
                     @click="blck_show('node')">Дерево</button>
			</div>
			<div class="col-3 mb-2 mt-2">
				<button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active.role }" 
                    v-if="check_role" @click="blck_show('role')">Роли</button>
			</div>
			<div class="col-3 mb-2 mt-2">
				<button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active.user }"
                    v-if="check_user" @click="blck_show('user')">Пользователи</button>
			</div>
			<div class="col-3 mb-2 mt-2">
				<button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active.info }"
                    @click="blck_show('info')">Информация</button>
			</div>
		</div>

		<router-view :user_info="user_info" :user_id="user_id" :user_token="user_token"></router-view>
		<!--component v-bind:is="currentBlck" :info="user_info" :user="user_id"></component-->

	</div>
</template>

<script>
//const axios = require('axios');
//this.axios.defaults.headers.common['Authorization'] = 'Bearer '+this.$store.state.current.token;

export default {
	name: "am",

	//props: ['test'],

	data: function() {
		return {
			//user_list: {},
			user_id: this.$store.state.current.id,
			user_token: this.$store.state.current.token,
			user_info: {},
			user_name: this.$store.state.current.user,
			//node_info: {},
			//node_name: "",
            
            //check_tree: false,
			check_role: false,
			check_user: false,
            //check_info: false,
            active: {
                node: true,
                role: false,
                user: false,
                info: false
            }
		};
	},

	mounted: function() {
		this.get_user();
	},

	watch:{
		/*user_id: function () {
			this.check_role = false;
			this.check_user = false;
		}*/
	},

	methods: {
        logout: function() {
            this.$router.push( '/' )
        },

		blck_show: function(str) {

            //active = {};
            //active[str] = true;
			this.$router.push('/access/'+str);
		},

		logout: function(){
			this.$router.push('/');
		},

		get_user: function(q) {
			//this.blck_show("node");

			this.axios.get("/am/user/get", {
				    params: { 
						user: this.user_id,
						name: this.user_name,
						email: this.$store.state.current.email 
					}, 
					headers: { 
						['Authorization']: 'Bearer '+this.user_token 
					}
				}).then(response => {
					
                    this.user_info = response.data;
                    
                    if ( this.user_info.manager ){
                        this.check_role = true;
                    }

                    if ( this.user_info.roles && this.user_info.roles.indexOf("admins") != -1 ){
                        this.check_user = true;
                        this.check_role = true;
                    }
				});

			//this.check_info = true;
			//this.check_tree = true;
		}
  	}
};
</script>
