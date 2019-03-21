<template>
    <div class="row">

        <form class="col-12">
            <div class="row">
                <div class="form-group col-6">
                    <vue-bootstrap-typeahead 
                        v-model="dname"
                        :data="data"
                        placeholder="Введите имя домена"
                    />
                </div>

                <div class="form-group col-6">
                    <input class="form-control" type="text" placeholder="Введите код аутентификации ( опц. )" v-model="dauth">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="get_domain_info">Запросить информацию</button>
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
                    <div v-for="(value, key) in info" :key="key">
                        <p>{{ key }}: {{ value }}</p>
                    </div>
                </div>
            </div>
        </div>
    
    </div>
</template>

<script>
import result from '../result.vue'

export default {
    name: 'domain_get',

    components: { result },

    data: function(){
        return {
            dname:   '',
            dauth:   null,
            error:   null,
            success: null,
            data:    [],
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
            info:    null
        }
    },

    watch: {
        dname: function(){
            if ( this.dname.length >= 3 ){

                this.data = [];

                var request = {
                    obj:   'dom',
                    query: this.dname
                }

                this.axios.get( 'base', { params: request } ).then( response => {
                    for (var i=0;i<response.data.suggestions.length;i++){
                        this.data.push( response.data.suggestions[i].value )
                    }
                } ).catch( error => {
                    this.error = true;
			    })
            }
        }
    },

    methods: {

        get_domain_info: function(){

            this.error   = null;
            this.err_msg = null;

            this.success = null;

            var request = {
                name: this.dname
            }

            if ( this.dauth ){
                request.authInfo = this.dauth;
            }
            
            this.axios.get( 'domain/get', { params: request } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    this.info = response.data.domain
                }
            } ).catch( error => {
                this.error = true;
			})
        },
    }
}
</script>


