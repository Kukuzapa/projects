<template>
    <div class="row">
        <!--div class="col-12">
            Т.к. тестовый сервер каждый день помещает пару тысяч сообщений для нас и запрос каждого занимает время. А сейчас их очень много, то запрос не готов. И готов будет на боевой схеме.
        </div-->
        <form class="col-12">
            <div class="row">

                <div class="form-group col-12">
                    <label>Выбор регистратора</label>
                    <select class="custom-select" v-model="registrar">
                        <option value="ru">Зона RU</option>
                        <option value="rf">Зона RF</option>
                    </select>
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="registrar_poll">Запросить сообщения реестра ТЦИ</button>
                </div>

            </div>
        </form>

        <div v-if="error" class="col-12 mt-2">
            <div class="alert alert-danger" role="alert">
                <span v-if="err_msg">{{err_msg}}</span>
                <span v-else>Это фиаско. Что-то, как всегда неожиданно, пошло не так.</span>
            </div>
        </div>

        <div v-if="success" class="col-12 mt-2">
            <result :trid="trid" :msg="message" :rslt="result"/>
        </div>
              
    </div>
</template>

<script>
import result from '../result.vue'

export default {

    name: 'registrar_poll',

    components: { result },

    data: function(){
        return {
            registrar: 'ru',

            poll:  null,

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    created: function(){
        this.get_poll();
    },

    methods: {
        get_poll: function(){
            this.axios.get( 'poll/' + this.registrar, { params: { page: 1 } } ).then( response => {
            //this.axios.get( 'http://84.38.3.34:8080/api/v2.1/poll/' + this.registrar, { params: { page: 2 } } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    //this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result
                }
            } ).catch( error => {
                this.error = true;
			})
        },

        registrar_poll: function(){
            this.error   = null;
            this.err_msg = null;
            this.success = null;
            
            this.axios.get( 'registrar/poll/' + this.registrar ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result
                }
            } ).catch( error => {
                this.error = true;
			})
        }
    }
   
}
</script>