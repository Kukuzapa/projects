<template>
    <div class="container">
        <div class="row">
        
            <div class="col-4 text-center font-weight-bold">
                Vacation Manager
            </div>

            <div class="col-4 col-md-4">
				{{user_name}}, {{user_email}}
			</div>

            <div class="col-4 col-md-4">
				<button type="button" class="btn btn-primary btn-block" @click="logout">Выход</button>
			</div>

			<div class="col-12">
                <span v-for="(days,type) in vacations">
                    <strong>{{type}}</strong>: {{days}}.
                </span>
			</div>
			

            <div class="col-6 mb-2 mt-2 order-5">
                <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.user }" v-if="user_admin" @click="show_block('user')">User</button>
            </div>
            <div class="col-6 mb-2 mt-2 order-6">
                <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.admin }" v-if="user_admin" @click="show_block('admin')">Admin</button>
            </div>

        </div>
        <hr v-if="user_admin" noshade>        
        <router-view :user_id="user_id" :user_token="user_token"></router-view>
    </div>
</template>

<script>
//const axios = require('axios');

export default {
    name: 'vacation',

    data: function(){
        return {
            user_admin: false,
            user_id: null,
            user_name: null,
            user_email: null,
            user_token: this.$store.state.current.token,

            vacations: {},
            
            active_block: {
                user: true,
                admin: false
            }
        }
    },

    created: function() {
        this.get_user();
    },

    watch: {
        user_id: function(){

            let date = new Date();

            this.axios.get( '/vm/user/vacations', { 
                    params: { userid: this.user_id, clid: this.user_id, period: date.getFullYear() },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {
                    this.vacations = response.data
                }
            )
        }
    },

    methods: {
        logout: function(){
            
            this.axios.get( '/vm/user/login', { 
                    params: { userid: this.user_id },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {} )

			this.$router.push('/');
		},

        show_block: function( str ){

            if ( this.$route.path.split('/')[2] != str ){

                this.$router.push('/vacation/'+str);

                for (var key in this.active_block ){
                    if ( key == str ){
                        this.active_block[key] = true;
                    } else {
                        this.active_block[key] = false;
                    }
                }
            }
        },

        get_user: function(){
            this.axios.get( '/vm/user/get', { 
                    //params: { token: this.user_token },
                    headers: { 'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {
                    this.user_name = response.data.name
                    this.user_email = response.data.email
                    this.user_id = response.data.id

                    this.show_block( 'user' );

                    if ( response.data.isadmin ){
                        this.user_admin = true;
                    }
                }
            )
        }
    }
}
</script>
