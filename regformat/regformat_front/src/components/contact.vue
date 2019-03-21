<template>
    <div class="row">
        
        
        <div class="col-12 text-center mb-2">
            Операции с Контактами{{command}}
        </div>
        
        <div class="col-3">
            <nav class="nav flex-column reg_ver_tabs border-right">
                <a class="nav-link" href="#" :class="{ active: pressed_button.get }" @click="button_click( 'get' )">Информация</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.check }" @click="button_click( 'check' )">Проверить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.create }" @click="button_click( 'create' )">Создать</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.update }" @click="button_click( 'update' )">Обновить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.delete }" @click="button_click( 'delete' )">Удалить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.renew }" @click="button_click( 'copy' )">Копировать</a>
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
    name: 'contact',

    data: function(){
        return {
            pressed_button: {
                get: true
            },
            command: ', получение данных о контакте.',
        }
    },

    created: function(){
        this.$router.push( '/contact/get' );
    },

    methods: {
        button_click: function( str ){
            this.pressed_button      = {}
            this.pressed_button[str] = true

            var templ = {
                get: ', получение данных о контакте.',
                check: ', проверка занятости идентификатора контакта (т.к. идентификатором контакта является uuid, то операция лишена смысла).',
                create: ', создание нового контакта.',
                update: ', обновление данных о контакте.',
                delete: ', удаление домена.',
                renew: ', копирование контакта в кеш.',
            }

            //if ( str == 'get' || str == 'check' || str == 'create' || str == 'update' || str == 'delete' || str =='copy' ){
                this.command = templ[str]
                this.$router.push( '/contact/' + str );
            //}
        },
    }
}
</script>