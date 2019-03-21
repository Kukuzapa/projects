<template>
    <div class="row">

        <form class="col-12">
            <div class="row">

                <div class="form-group col-12">
                    <vue-bootstrap-typeahead 
                        v-model="dname"
                        :data="ddata"
                        :serializer="s => s.name"
                        placeholder="Введите имя домена"
                    />
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="domain_delete">Удалить домен</button>
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
    name: 'domain_delete',

    components: { result },

    data: function(){
        return {
            dname:   '',
            ddata:    [],
            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    watch: {
        dname: function(){
            if ( this.dname.length >= 3 ){

                this.ddata = [];

                var request = {
                    obj:   'dom',
                    query: this.dname
                }

                this.axios.get( 'base', { params: request } ).then( response => {
                    for (var i=0;i<response.data.suggestions.length;i++){
                        this.ddata.push( response.data.suggestions[i].data )
                    }
                } ).catch( error => {
                    this.error = true;
			    })
            }
        },
    },

    methods: {
        domain_delete: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            this.axios.post( 'domain/delete', { name: this.dname } ).then( response => {
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
