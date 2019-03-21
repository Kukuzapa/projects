<template>
    <div class="row">
        <div class="col-12">
            <form>
                <div class="form-group">
                    <label for="formGroupExampleInput">Введите имя нового узла</label>
                    <input type="text" class="form-control" id="formGroupExampleInput" v-model="child">
                </div>

                <button type="button" class="btn btn-default btn-block" @click="insert">Добавить новый узел</button>
                
                <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
                <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
            </form>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_insert',

    props: ['user_id','current_node_name','user_token','tree'],

    data: function () {
        return {
            child: null,
            message: {},
        }
    },

    watch: {
        current_node_name: function () {
            this.child = null;
            this.message = {};
        },
    },

    methods: {
        insert: function(){

            this.message = {};

            if ( !this.child ){
                this.message.err = 'Неправда ваша, дяденька. Нет имени - нет конфет.'
                return 
            } 

            var parent = this.tree.find( this.current_node_name )[0]

            this.axios.post('/am/node/add', { id: this.user_id, prnt: this.current_node_name, chld: this.child.toString() }, { headers: { ['Authorization']: 'Bearer '+this.user_token } } )
                .then(response => { 

                    this.message = {};

                    if (response.data.success){
                        this.message.success = response.data.success;

                        parent.append( { text: this.child.toString(), id: response.data.id, data: { grants: ["pass","read","delete","insert","replace","access","update"] } } )
                    } else {
                        this.message.err = response.data.err;
                    }
                
                })
        }
    }
}
</script>

