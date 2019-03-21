<template>
    <div class="row">
        
        <!--div class="col-12 mb-2">
            <vue-bootstrap-typeahead 
                v-model="query"
                :data="nodes"
                size="sm"
                :serializer="s => s.user"
                @hit = "select = $event"
            />
        </div-->

        <div class="col-4 text-left">
            <tree
                :options = "treeOpt"
                :data = "treeData"
                @node:selected="onNodeSelected"
                ref = "treeAcc"
            />
        </div>
        
        <div class="col-8">

            <div v-if="current_user_name" class="d-flex justify-content-between">
                
                <b-dropdown id="ddown1" text="Операции" class="md-2">
                    <b-dropdown-item @click="action('role')">Роли пользователя</b-dropdown-item>
                    <b-dropdown-item @click="action('node')">Назначить права на узлы для пользователя</b-dropdown-item>
                </b-dropdown>

                <div class="d-flex align-items-center mt-2">
                    <h4>{{ current_user_name }}</h4>
                </div>

                <b-button class="md-2" @click="action('info')">Информация</b-button>
            </div>
            
            <!--div class="btn-group d-flex mb-2" role="group" aria-label="Basic example">
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('info')">info</button>
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('add')">add</button>
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('remove')">remove</button>
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('role')">role</button>
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('node')">node</button>
                <button type="button" class="btn btn-primary w-100" v-if="show_btn" @click="current('update')">update</button>
            </div-->
            <!--keep-alive>
                <component v-bind:is="currentComponent" :info="user_info" :user="user" :rootNode="rootNode" :node="node" v-if="info"></component>
            </keep-alive-->
            <router-view 
                :user_id="user_id" 
                :user_token="user_token"
                :current_user_info="current_user_info"
                :roles_list="roles_list"
                :current_user_name="current_user_name"
                :node_list="node_list">
            </router-view>
        </div>
    </div>
</template>

<script>
export default {
    name: 'user',

    props: ['user_id','user_token'],

    data: function(){
        return {

            treeData: this.getData(),

            treeOpt: {
                parentSelect: true,
                //checkbox: true,
                multiple: false
            },

            current_user_name: null,

            current_user_info: null,

            roles_list: [],

            node_list: [],
        }
    },

    watch: {
        current_user_name: function(){
            this.$router.push( '/access/user/info' );
        }
    },

    created: function(){
        this.axios.get("/am/role/list", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response =>{
            //console.log( response.data );

            this.roles_list = response.data;

            /*for (var i=0;i<response.data.length;i++){
                console.log( response.data[i].text )

                this.cur_roles = [];
                this.all_roles = [];

                if ( this.current_user_info.roles.indexOf( response.data[i].text ) == -1 ){
                    this.all_roles.push( { text: response.data[i].text } )
                } else {
                    this.cur_roles.push( { text: response.data[i].text } )
                }
            }*/

            //console.log( this.all_roles );
        });

        this.axios.get("/am/base/node", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => {
            this.node_list = response.data;
        });
    },

    methods: {
        action: function( str ){
            console.log( str );

            if ( str == 'role' || str == 'info' || str == 'node' ){
                this.$router.push( '/access/user/' + str );
            }
        },

        getData: function(){
            return this.axios.get("/am/base/user", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => {
                //response.data 
                //return [{text:'test'}]
                console.log( response.data );
                var tmp = [];
                
                for (var i=0;i<response.data.length;i++){
                    tmp.push( { text: response.data[i].user, id: response.data[i].userid } )
                }

                return tmp;

            });
        },

        onNodeSelected: function( node ){
            console.log( node );

            this.current_user_name = node.text;

            this.axios.get('/am/user/get', { params: { id: this.user_id, user: node.id }, headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                console.log( response.data )

                this.current_user_info = response.data;
                
                /*if (!response.data.err){
                    this.node_info = response.data;

                    console.log( this.node_info )

                    for(var i=0; i<node.data.grants.length; i++){
                        this.operations[node.data.grants[i]] = true;
                    }
                }*/
            });
        }
    }    
}
</script>
