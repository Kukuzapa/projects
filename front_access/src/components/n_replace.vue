<template>
    <div class="row">
        <div class="col-12">
            <form>
                
                <p>Выберите из списка новый родительский узел</p>
                
                <v-select :options="prnt_list" class="mb-3 mt-3" v-model="new_prnt"></v-select>

                <button type="button" class="btn btn-default btn-block" @click="replace">Изменить родительский узел</button>

                <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
                <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
            </form>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_replace',

    props: ['user_id','tree','current_node_name','user_token'],

    data: function() {
        return {
            new_prnt: null,
            
            message: {},

            prnt_list: []
        }
    },

    watch:{
        current_node_name: function(){
            this.new_prnt = null;
            this.message = {};

            //this.prnt_list = this.get_new_parent_list();
        }
    },

    created: function(){
        this.get_new_parent_list()
    },

    methods: {

        get_new_parent_list: function(){

            //Лист узлов которые не могут быть новыми родителями. Т.е. сам узел и его дочерние узлы.
            var bad_list = [ this.current_node_name ];

            if ( this.tree.find( this.current_node_name )[0].parent ){
                bad_list.push( this.current_node_name, this.tree.find( this.current_node_name )[0].parent.text )
            }

            //console.log( this.tree.find( this.current_node_name )[0].parent.text )

            function find_current_node_children( tbl ){
                if ( tbl.children.length > 0 ){
                    for (var i=0;i<tbl.children.length;i++){
                        //console.log( tbl.children[i].data.text )
                        bad_list.push( tbl.children[i].data.text );
                        find_current_node_children( tbl.children[i] );
                    }
                } else {
                    return
                }
            }

            find_current_node_children( this.tree.find( this.current_node_name )[0] );

            //Список новых родителей
            this.prnt_list = [];

            var list = this.tree.findAll( { state : {selectable: true} } )

            for (var i=0;i<list.length;i++){
                if ( (list[i].data.grants.indexOf('insert') != -1 && (bad_list.indexOf(list[i].text) == -1 ) ) ){
                    this.prnt_list.push( list[i].text );
                }
            }
        },

        replace: function(){

            //console.log( this.new_prnt )
            //console.log( this.current_node_name )

            this.message = {};

            if ( !this.new_prnt ){
                this.message.err = 'Вы не ввели имя нового предка';
                return;
            }

            var current = this.tree.find( this.current_node_name )[0]

            //current.remove();

            //this.tree.find( this.new_prnt )[0].append( current )

            this.axios.post('/am/node/replace', { id: this.user_id, prnt: this.new_prnt, node: this.current_node_name }, { headers: { ['Authorization']: 'Bearer '+this.user_token } } )
                .then(response => {
                    this.message = {};

                    if (response.data.success){
                        this.message.success = response.data.success;

                        current.remove();

                        this.tree.find( this.new_prnt )[0].append( current )
                    } else {
                        this.message.err = response.data.err;
                    }
                });

            
        }
    }
}
</script>
