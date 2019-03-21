<template>
    <div class="row">
        
        <div class="col-12 text-center mb-2">
            {{command}}
        </div>
        
        <div class="col-3">
            <nav class="nav flex-column reg_ver_tabs border-right">
                <a class="nav-link" href="#" :class="{ active: pressed_button.DomainDistrib }" @click="button_click( 'DomainDistrib' )">
                    Распределение зарегистрированных доменов среди регистраторов.
                </a>

                <a class="nav-link" href="#" :class="{ active: pressed_button.DelList }" @click="button_click( 'DelList' )">
                    Список освобождаемых доменов.
                </a>

                <a class="nav-link" href="#" :class="{ active: pressed_button.DelReport }" @click="button_click( 'DelReport' )">
                    Отчет об удалении доменов.
                </a>

                <!--a class="nav-link" href="#" :class="{ active: pressed_button.check }">Заглушка</a-->
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
    name: 'getdata',

    data: function(){
        return {
            //registrar: 'ru',
            pressed_button: {},
            command: null,
            command: 'Get-Data',
        }
    },

    methods: {
        button_click: function( str ){
            console.log( str )

            this.pressed_button      = {}
            this.pressed_button[str] = true

            var templ = {
                DomainDistrib: 'Статистика распределения новых зарегистрированных доменов среди регистраторов. Обновляется раз в сутки после 00:00 по МСК.',
                DelList: 'Список освобождаемых доменов. Обновляется раз в сутки в 12:00 по МСК (кроме выходных, праздничных и последующего за ними дней).',
                DelReport: 'Отчет об удалении доменов. Обновляется раз в сутки в 18:00 по МСК (кроме выходных, праздничных и последующего за ними дней).'
            }

            this.command = templ[str];

            this.$router.push( '/getdata/' + str );
        },
    },
}
</script>