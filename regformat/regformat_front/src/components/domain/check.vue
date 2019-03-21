<template>
    <div class="row">

        <form class="col-12">
            <div class="row">
                <div class="form-group col-12">
                    <input class="form-control" type="text" placeholder="Введите имя домена" v-model="dname">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="get_domain_check">Проверить занятость данного имени</button>
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
            <div class="row">
                <div class="col-6 mt-3">
                    <result :trid="trid" :msg="message" :rslt="result"/>
                </div>
                <div class="col-6 mt-3">
                    {{check}}
                </div>
            </div>
        </div>
    
    </div>
</template>

<script>
import result from '../result.vue'

export default {
    name: 'domain_check',

    components: { result },

    data: function(){
        return {
            dname:   '',
            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
            check:   null
        }
    },

    methods: {
        get_domain_check: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            var request = {
                name: this.dname
            }

            var templ = [ 'Имя домена занято.', 'Имя домена свободно.' ]
            
            this.axios.get( 'domain/check', { params: request } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    this.check = templ[response.data.check[this.dname]]
                }
            } ).catch( error => {
                this.error = true;
			})
        },
    }
}
</script>
