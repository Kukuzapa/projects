<template>
    <div class="row">
        <div class="col-12">
            <p>Назначение прав для пользователя.</p>
            <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
            <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
        </div>

        <div class="col-12">
            <b-button class="btn-block mt-3 btn-sm" @click="send_new_grants">Установить права.</b-button>
            <b-form-group class="mt-3" v-for="(grants,node) in grant_list"
                horizontal
                :label="node"
                label-for="inputHorizontal">
                <b-form-select v-model="selected[node]" :options="options" @change="set_new_grants(node)" size="sm"/>
            </b-form-group>
        </div>
    </div>
</template>

<script>
export default {
    name: 'u_node',

    props: ['current_user_name','user_id','user_token','current_user_info','node_list'],

    data: function(){
        return{
            grant_list: {},

            options: [
                { value: '', text: 'Прав нет' },
                { value: 'access', text: 'access' },
                { value: 'delete', text: 'delete' },
                { value: 'replace', text: 'replace' },
                { value: 'insert', text: 'insert' },
                { value: 'update', text: 'update' },
                { value: 'read', text: 'read' },
                { value: 'pass', text: 'pass' },
            ],

            selected: {},

            set_grants: [],

            message: {}
        }
    },

    methods: {

        send_new_grants: function(){
            var fin = {};

            for (var i=0;i<this.set_grants.length;i++){
                fin[this.set_grants[i]] = this.selected[this.set_grants[i]];
            }

            var req = { id: this.user_id, name: this.current_user_name, node: fin };

            this.axios.post('/am/user/node', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;
                } else {
                    this.message.err = response.data.err || response.data.message;
                }
            });
        },

        set_new_grants: function( str ){
            this.set_grants.push( str );
        }
    },

    created: function(){

        for (var i=0;i<this.node_list.length;i++){
            var value = '';
            if ( this.current_user_info.grants[this.node_list[i].node] ){

                if ( this.current_user_info.grants[this.node_list[i].node].length == 7 ){ value = 'access' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 6 ){ value = 'delete' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 5 ){ value = 'replace' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 4 ){ value = 'insert' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 3 ){ value = 'update' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 2 ){ value = 'read' }
                if ( this.current_user_info.grants[this.node_list[i].node].length == 1 ){ value = 'pass' }
                
                this.grant_list[this.node_list[i].node] = value;
            } else {
                this.grant_list[this.node_list[i].node] = '';
            }
            this.selected[this.node_list[i].node] = value;
        }
    }
}
</script>
