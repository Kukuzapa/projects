<template>
    <div class="row">
        
        
        <div class="col-12 text-center mb-2">
            Операции с регистратором{{command}}
        </div>
        
        <div class="col-3">
            <nav class="nav flex-column reg_ver_tabs border-right">
                <a class="nav-link" href="#" :class="{ active: pressed_button.get }" @click="button_click( 'get' )">Информация</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.limits }" @click="button_click( 'limits' )">Ограничения</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.billing }" @click="button_click( 'billing' )">Биллинг</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.update }" @click="button_click( 'update' )">Обновить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.poll }" @click="button_click( 'poll' )">Сообщения</a>
            </nav>
        </div>

        <div class="col-9"> 
            <div class="row">
                <div class="col-12">
                    <router-view/>
                </div>
            </div>
        </div>
        
    </div>
</template>

<script>
export default {
    name: 'registrar',

    data: function(){
        return {
            pressed_button: {
                get: true
            },
            command: ', получение данных о регистраторе.',
        }
    },

    created: function(){
        this.$router.push( '/registrar/get' );
    },

    methods: {
        button_click: function( str ){
            this.pressed_button      = {}
            this.pressed_button[str] = true

            var templ = {
                get: ', получение данных о регистраторе.',
                limits: ', получение ограничений регистратора.',
                billing: ', получение финансовой информации.',
                update: ', обновление списка доступных адресов.',
                poll: ', запрос сообщений от ТЦИ.',
            }

            //if ( str == 'get' || str == 'limits' || str == 'billing' || str == 'update' ){
                this.command = templ[str]
                this.$router.push( '/registrar/' + str );
            //}
        },
    }
}
</script>