<template>
    <div class="row">
        <div class="col-4 mb-2 mt-2 d-none d-md-block">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.new }" @click="show_block('new')">Новая заявка</button>
        </div>
        <div class="col-4 mb-2 mt-2 d-none d-md-block">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.list }" @click="show_block('list')">Список заявок</button>
        </div>
        <div class="col-4 mb-2 mt-2 d-none d-md-block">
            <button type="button" class="btn btn-primary btn-block" :class="{ 'btn-success': active_block.history }" @click="show_block('history')">История заявок</button>
        </div>

        <!--div class="dropdown col-12">
            <button class="btn btn-secondary dropdown-toggle btn-block" type="button" id="dropdownMenuButton" 
                data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Dropdown button
            </button>
            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                <a class="dropdown-item" href="#">Action</a>
                <a class="dropdown-item" href="#">Another action</a>
                <a class="dropdown-item" href="#">Something else here</a>
            </div>
        </div-->
        

        <div class="col-12">
            <b-dropdown id="ddown-buttons" text="Меню" class="mt-2 mb-2 w-100 d-block d-md-none" toggle-class="w-100" menu-class="w-100">
                <b-dropdown-item-button @click="show_block('new')">Новая заявка</b-dropdown-item-button>
                <b-dropdown-item-button @click="show_block('list')">Список заявок</b-dropdown-item-button>
                <b-dropdown-item-button @click="show_block('history')">История заявок</b-dropdown-item-button>
            </b-dropdown>
        </div>

        <router-view :user_id="user_id" :user_token="user_token"></router-view>
    </div>
</template>

<script>
export default {
    name: 'v_user',

    props: ['user_id','user_token'],

    data: function(){
        return {
            active_block: {
                new: true,
                list: false,
                history: false
            },
        }
    },

    methods: {
        show_block: function( str ){
            this.$router.push('/vacation/user/'+str);

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