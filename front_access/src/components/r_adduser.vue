<template>
    <div class="row">
        
        <div class="col-12">
            <p>Добавление/удаление пользователей в роль {{current_role_name}}. Зажатая клавиша ctrl позволяет выбирать нескольких пользователей. 
                Поставьте/уберите галочку возле имени пользователя, чтобы назначить менеджеров/менеджера роли.</p>
        </div>

        <div class="col-12">
            <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
            <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
        </div>

        <div class="col-6">
            <div class="btn-group btn-block">
                <button type="button" class="btn btn-default" @click="manager">Manager</button>
                <button type="button" class="btn btn-primary w-100" @click="rem_user">>></button>
            </div>
            <!--button type="button" class="btn btn-primary btn-block" @click="rem_user">>></button-->
            <tree
                :options = "treeOptRole"
                :data = "role_list"
                ref = "treeRoleRole"
            />
        </div>

        <div class="col-6">
            <button type="button" class="btn btn-primary btn-block" @click="add_user"><<</button>
            <tree
                :options = "treeOptUsers"
                :data = "all_user_list"
                ref = "treeRoleUsers"
            />
        </div>

        
        
        <!--tree class="col-6"
            :options = "treeOpt"
            :data = "role_list"
            @node:selected="onNodeSelected"
            @node:checked="onNodeChecked"
            @node:unchecked="onNodeUnchecked"
            ref = "treeAcc"
        /-->

        <!--div class="col-4" v-for="user in current">
            <div class="form-group form-inline">
                <label class="col-10 col-form-label">{{user.user}}</label>
                <input type="checkbox" class="col-2" v-model="user.check">
            </div>
        </div>

        <div class="col-12">
            <div class="form-group">
                <select class="form-control" @change='add_user' v-model="usr">
                    <option disabled value="" selected>Добавить пользователя</option>
                    <option v-for="user in list">{{user}}</option>
                </select>
            </div>

            <button type="button" class="btn btn-default btn-block" @click="adduser">Add users</button>

            <div class="col-12">{{message}}</div>
        </div-->
    </div>
</template>

<script>

export default {
    name: 'r_adduser',

    props: ['role_info','user_list','current_role_name','user_id','user_token'],

    data: function(){
        return {
            //message: null,
            //current: null,
            //list: null,
            //usr: ''
            message: {},

            role_list: [],

            all_user_list: [],

            treeOptRole: {
                parentSelect: true,
                checkbox: true,
                multiple: true
            },

            treeOptUsers: {
                parentSelect: true,
                //checkbox: true,
                multiple: true
            }
        }
    },

    created: function(){
        console.log( this.role_info.users )
        console.log( this.user_list )

        var tmp = [];

        for (var i=0;i<this.role_info.users.length;i++){
            
            if ( this.role_info.manager.indexOf( this.role_info.users[i] ) != -1 ){
                this.role_list.push( { text: this.role_info.users[i], state: { checked: true } } );
            } else {    
                this.role_list.push( { text: this.role_info.users[i] } );
            }

            //this.role_list.push( { text: this.role_info.users[i] } );
            tmp.push( this.role_info.users[i] );
        }

        for (var i=0;i<this.user_list.length;i++){
            console.log( this.role_list.indexOf( this.user_list[i] ) )

            if ( tmp.indexOf( this.user_list[i].user ) == -1 ){
                this.all_user_list.push( { text: this.user_list[i].user } )
            }
        }
    },

    methods: {
        manager: function(){
            this.message = {};

            var tmp = this.$refs.treeRoleRole.checked();

            console.log( tmp );

            var fin = [];

            for (var i=0;i<tmp.length;i++){
                fin.push( tmp[i].text );
            }

            var req = { id: this.user_id, role: this.current_role_name, manager: fin };

            this.axios.post('/am/role/manager', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;
                } else {
                    this.message.err = response.data.err || response.data.message;
                }
            });
        },

        rem_user: function(){
            this.message = {};

            var tmp = this.$refs.treeRoleRole.selected();

            var fin = [];

            for (var i=0;i<tmp.length;i++){
                fin.push( tmp[i].text );
            }

            var req = { id: this.user_id, role: this.current_role_name, user: fin };

            this.axios.post('/am/role/userrem', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;

                    tmp.remove();

                    for (var i=0;i<tmp.length;i++){
                        this.$refs.treeRoleUsers.append( { text: tmp[i].text } );
                    }
                } else {
                    this.message.err = response.data.err || response.data.message;
                }
            });
        },

        add_user: function(){
            this.message = {};

            var tmp = this.$refs.treeRoleUsers.selected();

            var fin = [];

            for (var i=0;i<tmp.length;i++){
                fin.push( tmp[i].text );
            }

            var req = { id: this.user_id, role: this.current_role_name, user: fin };

            this.axios.post('/am/role/useradd', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;

                    tmp.remove();

                    for (var i=0;i<tmp.length;i++){
                        this.$refs.treeRoleRole.append( { text: tmp[i].text } );
                    }
                } else {
                    this.message.err = response.data.err || response.data.message;
                }
            });
        }
    }
}
</script>
