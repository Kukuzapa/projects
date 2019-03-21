<template>
    <div class="row">

        <div class="col-12 text-center mb-2">
            Операции с Доменами{{command}}
        </div>
        
        <div class="col-3">
            <nav class="nav flex-column reg_ver_tabs border-right">
                <a class="nav-link" href="#" :class="{ active: pressed_button.get }" @click="button_click( 'get' )">Информация</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.check }" @click="button_click( 'check' )">Проверить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.create }" @click="button_click( 'create' )">Создать</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.update }" @click="button_click( 'update' )">Обновить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.delete }" @click="button_click( 'delete' )">Удалить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.renew }" @click="button_click( 'renew' )">Продлить</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.transfer }" @click="button_click( 'transfer' )">Перенести</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.copy }" @click="button_click( 'copy' )">Скопировать</a>
                <a class="nav-link" href="#" :class="{ active: pressed_button.list }" @click="button_click( 'list' )">Список</a>
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
    name: 'domain',

    data: function(){
        return {
            pressed_button: {
                get: true
            },
            command: ', получение данных о домене.',
        }
    },

    created: function(){
        this.$router.push( '/domain/get' );
    },

    methods: {
        button_click: function( str ){
            this.pressed_button      = {}
            this.pressed_button[str] = true

            var templ = {
                get: ', получение данных о домене.',
                check: ', проверка существования домена.',
                create: ', создание нового домена.',
                update: ', обновление домена.',
                delete: ', удаление домена.',
                renew: ', продление регистрации домена.',
                transfer: ', передача домена.',
                copy: ', копирование информации о домене в БД.',
                list: ', список доменов из БД.'
            }

            console.log( '/domain/' + str )

            //if ( str == 'get' || str == 'check' || str == 'create' || str == 'update' || str == 'delete' || str == 'renew' || str == 'transfer' || str == 'copy' ){
                this.command = templ[str]
                this.$router.push( '/domain/' + str );
            //}
        },
    }
}
</script>

<style>
    .reg_ver_tabs a:hover{
        color: #0056b3
    }

    .reg_ver_tabs a.active{
        color: #495057
    }
</style>
