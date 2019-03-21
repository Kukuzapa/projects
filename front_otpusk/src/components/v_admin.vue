<template>
    <div class="row">
        <div class="col-12 mb-2">
            <vue-bootstrap-typeahead 
                v-model="clname"
                :data="clients"
                size="sm"
                :serializer="s => s.name"
                @hit = "select = $event"
                placeholder="Введите имя пользователя в качестве фильтра"
            />
        </div>

        <div class="col-12 mb-2 mt-2">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.new }" @click="show_block('new')">Новые заявки, необработанные</button>
        </div>
        <div class="col-3 mb-2 mt-2">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.list }" @click="show_block('list')">Список актуальных заявок</button>
        </div>
        <div class="col-3 mb-2 mt-2">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.history }" @click="show_block('history')">История заявок</button>
        </div>
        <div class="col-3 mb-2 mt-2">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.users }" @click="show_block('users')">Компетенции и пользователи</button>
        </div>
        <div class="col-3 mb-2 mt-2">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.log }" @click="show_block('log')">Журнал операций</button>
        </div>

        <router-view :user_id="user_id" :clname="clname" :user_token="user_token"></router-view>
    </div>
</template>

<script>
export default {
    name: 'v_admin',

    props: ['user_id','user_token'],

    data: function(){
        return {
            active_block: {
                new: true,
                list: false,
                history: false,
                users: false,
                log: false
            },
            clname: '',
            clients: []
        }
    },

    watch: {
        clname: function(){
            this.axios.get('/vm/admin/find', { 
                params: { userid: this.user_id, clname: this.clname }, 
                headers: {'Authorization': 'Bearer ' + this.user_token }
            } ).then(response => {
                if ( response.data.length ){
                    this.clients = response.data
                } else {
                    this.clients = []
                }
            });
        }
    },

    methods: {
        show_block: function( str ){
            this.$router.push('/vacation/admin/'+str);

            for (var key in this.active_block ){
                if ( key == str ){
                    this.active_block[key] = true;
                } else {
                    this.active_block[key] = false;
                }
            }
        },
    },

    mounted: function(){
        this.show_block('new');
    }
}
</script>
