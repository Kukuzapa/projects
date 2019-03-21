<template>
    <div class="row">
        <div class="col-12">
            <p>Назначение прав на узел</p>
            <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
            <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
        </div>
        
        <div class="col-6">
            <b-button @click="send_new_grants('roles')" class="btn-block mt-3 btn-sm">Установить права ролей</b-button>
            <b-form-group class="mt-3"  v-for="(grants,roles) in node_info.roles"
                horizontal
                :label="roles"
                label-for="inputHorizontal">
                <b-form-select v-model="selected.roles[roles]" :options="options" @change="set_new_grants(roles,'roles')" size="sm"/>
            </b-form-group>
        </div>
        
        <div class="col-6">
            <b-button @click="send_new_grants('users')" class="btn-block mt-3 btn-sm">Установить права пользователей</b-button>
            <b-form-group class="mt-3"  v-for="(grants,users) in node_info.users"
                horizontal
                :label="users"
                label-for="inputHorizontal">
                <b-form-select v-model="selected.users[users]" :options="options" @change="set_new_grants(users,'users')" size="sm"/>
            </b-form-group>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_access',

    props: ['tree','current_node_name','user_id','user_token','node_info'],

    data: function(){
        return {
            message: {},

            selected: {
                users: {},
                roles: {}
            },

            //set_users_grants: {},

            set_grants: {
                roles: [],
                users: []
            },

            options: [
                { value: '', text: 'Прав нет' },
                { value: 'access', text: 'access' },
                { value: 'delete', text: 'delete' },
                { value: 'replace', text: 'replace' },
                { value: 'insert', text: 'insert' },
                { value: 'update', text: 'update' },
                { value: 'read', text: 'read' },
                { value: 'pass', text: 'pass' },
            ]
        }
    },

    watch: {
        node: function() {
            this.message = {};
        }
    },

    mounted: function(){
        //console.log( this.node_info.roles, ' ', this.node_info.roles.length );
        //console.log( this.node_info.users );
    },

    created: function(){
        //var roles = this.node_info.roles;

        var templ = [ 'roles', 'users' ];

        //console.log( roles )

        for (var i=0;i<templ.length;i++){

            var tmp = this.node_info[templ[i]]

            for (var key in tmp){
                //console.log( key )
                //options.push( { value: roles[i], text: roles[i] } )
                var value = '';
                if ( tmp[key].length == 7 ){ value = 'access' }
                if ( tmp[key].length == 6 ){ value = 'delete' }
                if ( tmp[key].length == 5 ){ value = 'replace' }
                if ( tmp[key].length == 4 ){ value = 'insert' }
                if ( tmp[key].length == 3 ){ value = 'update' }
                if ( tmp[key].length == 2 ){ value = 'read' }
                if ( tmp[key].length == 1 ){ value = 'pass' }

                //this.selected[key.toString()] = value;

                //Vue.set(vm.selected, key.toString(), value)

                this.$set(this.selected[templ[i]], key.toString(), value)
            }
        }

        /*for (var key in roles){
            console.log( key )
            //options.push( { value: roles[i], text: roles[i] } )
            var value = '';
            if ( roles[key].length == 7 ){ value = 'access' }
            if ( roles[key].length == 6 ){ value = 'delete' }
            if ( roles[key].length == 5 ){ value = 'replace' }
            if ( roles[key].length == 4 ){ value = 'insert' }
            if ( roles[key].length == 3 ){ value = 'update' }
            if ( roles[key].length == 2 ){ value = 'read' }
            if ( roles[key].length == 1 ){ value = 'pass' }

            //this.selected[key.toString()] = value;

            //Vue.set(vm.selected, key.toString(), value)

            this.$set(this.selected.roles, key.toString(), value)
        }*/
        
        console.log( this.selected )
    },

    methods: {

        send_new_grants: function(type){
            var tmp = {};

            var sended = this.set_grants[type];

            for(var i=0;i<sended.length;i++){
                tmp[sended[i]] = this.selected[type][sended[i]];
            }

            var req = {
                id: this.user_id,
                node: this.current_node_name,
                //role: role
            }

            var url = '/am/node/role'

            if (type == 'roles'){
                req.role = tmp;
            } else {
                req.user = tmp;
                var url = '/am/node/user';
            }

            console.log( req )

            

            this.axios.post( url, req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {
                console.log( response.data );

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;

                    //this.tree.find( this.current_node_name )[0].remove();

                    //parent.append( { text: this.child.toString(), id: response.data.id } )
                } else {
                    this.message.err = response.data.err;
                }

            });

            //console.log(user)
        },

        //test: function(){
        //    console.log( this.selected )
        //},

        set_new_grants: function( str, type ){
            //console.log( str )
            //console.log( this.selected[type][str] );

            //var x = this.selected[type][str]

            if( this.set_grants[type].indexOf(str) == -1 ){
                this.set_grants[type].push( str )
            }

            //this.set_roles_grants[str] = this.selected[str];

            //this.$set(this.set_roles_grants, str, x)
        }
        
    }


    
}
</script>

