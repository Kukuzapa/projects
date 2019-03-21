<template>
    <div class="row">
        <div class="col-12">
            <p>Добавление/удаление пользователя из ролей.</p>
        </div>

        <div class="col-12">
            <button type="button" class="btn btn-primary btn-block" @click="update">Применить</button>
        </div>

        <div class="col-12">
            <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
            <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
        </div>

        <div class="col-6 mt-3">
            <button type="button" class="btn btn-primary btn-block" @click="rem_role">>></button>
            <tree
                :options = "treeOpt"
                :data = "cur_roles"
                ref = "treeCurRoles"
            />
        </div>

        <div class="col-6 mt-3">
            <button type="button" class="btn btn-primary btn-block" @click="add_role"><<</button>
            <tree
                :options = "treeOpt"
                :data = "all_roles"
                ref = "treeAllRoles"
            />
        </div>
    </div>
</template>

<script>
export default {
    name: 'u_role',

    props: ['current_user_name','user_id','user_token','current_user_info','roles_list'],

    data: function(){
        return {
            treeOpt: {
                parentSelect: true,
                multiple: true
            },

            cur_roles: [],
            all_roles: [],

            message: {}
        }
    },

    created: function(){
        console.log( this.current_user_info.roles )

        if (this.current_user_info.roles){
            for (var i=0;i<this.roles_list.length;i++){
                if ( this.current_user_info.roles.indexOf( this.roles_list[i].text ) == -1 ){
                    this.all_roles.push( { text: this.roles_list[i].text } )
                } else {
                    this.cur_roles.push( { text: this.roles_list[i].text } )
                }
            }
        } else {
            for (var i=0;i<this.roles_list.length;i++){
                this.all_roles.push( { text: this.roles_list[i].text } )
            }
        }
    },

    methods: {
        add_role: function(){
            var tmp = this.$refs.treeAllRoles.selected();
            
            tmp.remove();

            for (var i=0;i<tmp.length;i++){
                this.$refs.treeCurRoles.append( { text: tmp[i].text } );
            }
        },

        rem_role: function(){
            var tmp = this.$refs.treeCurRoles.selected();
            
            tmp.remove();

            for (var i=0;i<tmp.length;i++){
                this.$refs.treeAllRoles.append( { text: tmp[i].text } );
            }
        },

        update: function(){
            var list = this.$refs.treeCurRoles.findAll( { state : {selectable: true} } ) || [];

            var fin = [];

            for(var i=0;i<list.length;i++){
                fin.push( list[i].text );
            }

            var req = { id: this.user_id, name: this.current_user_name, role: fin };

            this.axios.post('/am/user/role', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {
                
                this.message = {};

                if (response.data.success){
                    this.message.success = response.data.success;
                } else {
                    this.message.err = response.data.err || response.data.message;
                }	
            });
        }
    }
}
</script>
