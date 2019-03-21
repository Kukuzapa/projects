<template>
    <div class="row">

        <div class="col-12">
            <p>Назначение прав для роли {{current_role_name}}.</p>
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
    name: 'r_node',

    props: ['current_role_name','node_list','role_info','user_id'],

    data: function(){
        return{
            /*list: null,
            current: null,
            nde: '',
            message: null*/

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

            console.log( fin )

            var req = { id: this.user_id, role: this.current_role_name, node: fin };

            
            //console.log(req);

            this.axios.post('/am/role/node', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {
                console.log(response.data);

                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;
                } else {
                    this.message.err = response.data.err || response.data.message;
                }
            });
        },

        set_new_grants: function( str ){
            console.log( str );

            this.set_grants.push( str );
        }
    },

    created: function(){
        //this.start();
        console.log( this.node_list );
        console.log( this.node_list[0] );
        console.log( this.role_info.node );
        //this.grant_list = {};

        for (var i=0;i<this.node_list.length;i++){
            //console.log( this.node_list[i].node );
            var value = '';
            if ( this.role_info.node[this.node_list[i].node] ){

                //var value = '';
                if ( this.role_info.node[this.node_list[i].node].length == 7 ){ value = 'access' }
                if ( this.role_info.node[this.node_list[i].node].length == 6 ){ value = 'delete' }
                if ( this.role_info.node[this.node_list[i].node].length == 5 ){ value = 'replace' }
                if ( this.role_info.node[this.node_list[i].node].length == 4 ){ value = 'insert' }
                if ( this.role_info.node[this.node_list[i].node].length == 3 ){ value = 'update' }
                if ( this.role_info.node[this.node_list[i].node].length == 2 ){ value = 'read' }
                if ( this.role_info.node[this.node_list[i].node].length == 1 ){ value = 'pass' }
                
                //this.grant_list[this.node_list[i].node] = this.role_info.node[this.node_list[i].node]
                this.grant_list[this.node_list[i].node] = value;
            } else {
                this.grant_list[this.node_list[i].node] = '';
            }
            this.selected[this.node_list[i].node] = value;
        }
    }
}
</script>
