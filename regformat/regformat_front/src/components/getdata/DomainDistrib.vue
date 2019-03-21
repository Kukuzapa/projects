<template>
    <div class="row">

        <div class="form-group col-12">
            <label>Выбор регистратора</label>
            <select class="custom-select" v-model="registrar">
                <option value="ru">Зона RU</option>
                <option value="rf">Зона RF</option>
            </select>
        </div>

        <div class="col-12">
            <table class="table">
            <thead>
                <tr>
                    <th scope="col">Регистратор</th>
                    <th scope="col">Количество доменов</th>
                </tr>
            </thead>
                <tbody>
                    <tr v-for="(dom,index) in list" :key="index">
                        <td>{{dom.reg}}</td>
                        <td>{{dom.count}}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    
    
        <div v-if="error" class="col-12 mt-2">
            <div class="alert alert-danger" role="alert">
                <span v-if="err_msg">{{err_msg}}</span>
                <span v-else>Это фиаско. Что-то, как всегда неожиданно, пошло не так.</span>
            </div>
        </div>
    
    </div>

    
</template>

<script>


export default {
    name: 'DomainDistrib',

    //props: [ 'registrar' ],

    data: function(){
        return {
            registrar: 'ru',
            list: [],
            error: null,
            err_msg: null,
        }
    },

    watch: {
        registrar: function(){
            this.domain_distrib();
        }
    },
  
    created: function(){
        this.domain_distrib();
    },

    methods: {
        domain_distrib: function(){
            this.error = null;
            this.err_msg = null;

            this.axios.get( 'getdata/' + this.registrar, { params: { type: 'DomainDistrib' } } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    console.log( response.data )

                    this.list = response.data;
                }
            } ).catch( error => {
                this.error = true;
            })
        }
    },

}
</script>