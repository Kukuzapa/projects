<template>
    <div class="row">

        <form class="col-12">
            <div class="row">

                <div class="form-group col-12">
                    <label>Введите имя домена</label>
                    <input class="form-control" type="text" placeholder="Введите имя домена" v-model="dname">
                </div>

                <div class="form-group col-12">
                    <label>Код аутентификации</label>
                    <input class="form-control" type="text" placeholder="Код аутентификации" v-model="dauth">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="domain_transfer">Скопировать данные домена в наш кеш</button>
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
    name: 'domain_copy',

    components: { result },

    data: function(){
        return {
            dname:   '',
            dauth:   null,
            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    methods: {
        domain_transfer: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            this.axios.get( 'domain/copy', { params: { name: this.dname, authInfo: this.dauth } } ).then( response => {
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
