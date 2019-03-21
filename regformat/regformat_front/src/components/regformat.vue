<template>
    <div class="row">
        <div class="col-12 text-center">
            <h5>Гет-Нет АПИ ТЦИ v 2.2 (vue)</h5>
        </div>

       

        <div class="col-12">
            <ul class="nav nav-tabs nav-fill">
                <li class="nav-item">
                    <a class="nav-link" href="#" :class="{ active: pressed_button.domain }" @click="button_click( 'domain' )">Домены</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" :class="{ active: pressed_button.contact }" @click="button_click( 'contact' )">Контакты</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" :class="{ active: pressed_button.registrar }" @click="button_click( 'registrar' )">Регистраторы</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" :class="{ active: pressed_button.operation }" @click="button_click( 'operation' )">Операции</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" :class="{ active: pressed_button.getdata }" @click="button_click( 'getdata' )">Сервис Гет-Дата</a>
                </li>
            </ul>
        </div>

        <div class="col-12 mt-3">
            <router-view/>
        </div>
    </div>
</template>

<script>
export default {
    name: 'regformat',

    data: function(){
        return {
            pressed_button: {
                domain: true
            }
        }
    },

    created: function(){
        this.$router.push( '/domain' );
    },

    methods: {
        button_click: function( str ){
            this.pressed_button      = {}
            this.pressed_button[str] = true
            this.$router.push( '/' + str );
        },
    }
}
</script>
