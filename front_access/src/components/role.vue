<template>
    <div class="row">

        <!--div class="col-12 mb-2">
            <vue-bootstrap-typeahead 
                v-model="query"
                :data="nodes"
                size="sm"
                :serializer="s => s.role"
                @hit = "select = $event"
            />
        </div-->

        <b-modal ref="role_add_modal" centered no-fade hide-footer title="Создание новой роли">
            <div class="row">
                <div class="col-12">
                    <form>
                        <div class="form-group">
                            <label>Имя новой роли</label>
                            <input type="text" class="form-control" v-model="new_role">
                        </div>
                    </form>

                    <div class="form-group">
                        <select class="form-control" v-model="manager">
                            <option disabled value="" selected>Укажите менеджера, если необходимо</option>
                            <option v-for="user in user_list">{{user.user}}</option>
                        </select>
                    </div>

                    <b-alert v-if="message_add_role.err" show variant="danger" class="mt-3">{{message_add_role.err}}</b-alert>
                    <b-alert v-if="message_add_role.success" show variant="success" class="mt-3">{{message_add_role.success}}</b-alert>

                    <button type="button" class="btn btn-default btn-block" @click="create">Создать роль</button>
                </div>
            </div>
        </b-modal>

        <b-modal ref="role_remove_modal" centered no-fade hide-footer title="Удаление роли">
            <p>Данная операция удалит роль {{checked_role.text}}</p>
            
            <b-alert v-if="message_del_role.err" show variant="danger" class="mt-3">{{message_del_role.err}}</b-alert>
            <b-alert v-if="message_del_role.success" show variant="success" class="mt-3">{{message_del_role.success}}</b-alert>
            
            <button type="button" class="btn btn-primary btn-block" @click="delete_role">Да, я хочу удалить роль</button>
        </b-modal>


        <div class="col-4 text-left">

            <b-dropdown id="ddown1" text="Операции администратора" class="md-2 flex-column d-flex" v-if="user_info.roles.indexOf('admins')!=-1">
                <b-dropdown-item @click="action_add_role('role_add_modal')">Добавить роль</b-dropdown-item>
                <b-dropdown-item @click="action_remove_role" :disabled="!Object.keys(checked_role).length">Удалить отмеченную роль</b-dropdown-item>
            </b-dropdown>

            <tree
                :options = "treeOpt"
                :data = "treeData"
                @node:selected="onNodeSelected"
                @node:checked="onNodeChecked"
                @node:unchecked="onNodeUnchecked"
                ref = "treeAcc"
            />
        </div>
       
        <div class="col-8">

            <div v-if="current_role_name" class="d-flex justify-content-between">
                
                <b-dropdown id="ddown1" text="Операции" class="md-2" v-if="user_info.roles.indexOf('admins')!=-1">
                    <b-dropdown-item @click="action('adduser')">Пользователи</b-dropdown-item>
                    <b-dropdown-item @click="action('node')">Назначить права на узлы для роли</b-dropdown-item>
                </b-dropdown>

                <button type="button" class="btn btn-secondary" @click="action('adduser')" v-else>Пользователи</button>

                <div class="d-flex align-items-center mt-2">
                    <h4>{{ current_role_name }}</h4>
                </div>

                <b-button class="md-2" @click="action('info')">Информация</b-button>
            </div>

            <router-view 
                :role_info="role_info" 
                :node_list="node_list" 
                :user_list="user_list" 
                :current_role_name="current_role_name"
                :user_id="user_id"
                :user_token="user_token">
            </router-view>

        </div>
    </div>
</template>

<script>
export default {
    name: 'role',

    props: ['user_id','user_token','user_info'],

    data: function(){
        return {
            role_info: {},

            message_add_role: {},

            message_del_role: {},

            new_role: null,

            current_role_name: null,

            checked_role: {},

            user_list: [],
            node_list: [],

            manager: '',

            treeData: this.getData(),

            treeOpt: {
                parentSelect: true,
                checkbox: true,
            }
        }
    },

    watch: {
        current_role_name: function(){
            this.$router.push( '/access/role/info' );
        }
    },

    created: function(){
        this.axios.get("/am/base/user", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => {
            this.user_list = response.data;
        });

        this.axios.get("/am/base/node", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => {
            this.node_list = response.data;
        });
    },

    methods: {

        delete_role: function(){
            
            var req = { id: this.user_id, role: this.checked_role.text }

            this.axios.post('/am/role/remove', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } )
            .then(response => {

                this.message_del_role = {};

                if (response.data.success){
                    this.message_del_role.success = response.data.success;

                    this.checked_role.remove();
                    
                } else {
                    this.message_del_role.err = response.data.err;
                }
            });
        },

        create: function(){

            if (!this.new_role){
                this.message_add_role = {};
                this.message_add_role.err = 'Вы не ввели имя новой роли';
                return;
            }

            var req = { id: this.user_id, role: this.new_role }

            if (this.manager.length > 0) { req.manager = this.manager }

            this.axios.post('/am/role/add', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } )
            .then(response => {

                this.message_add_role = {};

                if (response.data.success){
                    this.message_add_role.success = response.data.success;

                    this.$refs.treeAcc.append({
                        text: this.new_role,
                        id: response.data.id
                    })
                } else {
                    this.message_add_role.err = response.data.err;
                }
            });
        },

        action_add_role: function( role ){
            this.new_role = null;
            this.manager = '';
            this.message_add_role = {};

            this.$refs[role].show();

            //this.axios.get("/am/base/user", { params: { id: this.user_id } }).then( response => {
            //    this.user_list = response.data;
            //});
        },

        action_remove_role: function(){
            this.message_del_role = {};
            this.$refs.role_remove_modal.show();
        },

        action: function( str ){
            console.log( str );

            this.$router.push( '/access/role/' + str );
        },

        onNodeUnchecked: function(){
            this.checked_role = {}
        },

        onNodeChecked: function( node ){

            var tmp = this.$refs.treeAcc.checked();
            
            for(var i=0;i<tmp.length;i++){
                if (node.text!=tmp[i].text){
                    tmp[i].uncheck();
                } else {
                    //node.check();   
                }
            }

            this.checked_role = node;
        },
        
        onNodeSelected: function( node ){

            this.current_role_name = node.text;

            //this.operations = {};
            
            this.axios.get('/am/role/get', { params: { id: this.user_id, role: node.text }, headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                console.log( response.data )

                this.role_info = response.data;
                
                /*if (!response.data.err){
                    this.node_info = response.data;

                    console.log( this.node_info )

                    for(var i=0; i<node.data.grants.length; i++){
                        this.operations[node.data.grants[i]] = true;
                    }
                }*/
            });
        },

        getData: function(){
            return this.axios.get("/am/role/list", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => response.data );
        },
    },
}
</script>