<template>
    <div class="row">
        <div class="col-12">
            <p>Данная операция удалит узел {{current_node_name}}</p>
            
            <button type="button" class="btn btn-primary btn-block" @click="delete_node">Удаление</button>
            
            <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
            <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_delete',

    props: ['tree','user_id','user_token','current_node_name'],
    data: function(){
        return {
            message: {}
        }
    },
    watch: {
        node: function() {
            this.message = {};
        }
    },
    methods: {
        delete_node: function(){

            this.message = {};

            this.axios.post('/am/node/remove', { id: this.user_id, node: this.current_node_name }, { headers: { ['Authorization']: 'Bearer '+this.user_token } } )
            .then(response => { 

                 this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;

                    this.tree.find( this.current_node_name )[0].remove();

                    //parent.append( { text: this.child.toString(), id: response.data.id } )
                } else {
                    this.message.err = response.data.err;
                }	
            })
        }
    }
}
</script>
