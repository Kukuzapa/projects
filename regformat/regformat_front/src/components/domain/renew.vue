<template>
    <div class="row">

        <form class="col-12">
            <div class="row">

                <div class="form-group col-6">
                    <label>Введите имя домена</label>
                    <vue-bootstrap-typeahead 
                        v-model="dname"
                        :data="ddata"
                        :serializer="s => s.name"
                        placeholder="Введите имя домена"
                        @hit="selected_domain"
                    />
                </div>

                <div class="form-group col-6">
                    <label>Дата окончания регистрации</label>
                    <input class="form-control" type="text" placeholder="Дата окончания регистрации" v-model="exdte">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="domain_renew">Удалить домен</button>
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
    name: 'domain_renew',

    components: { result },

    data: function(){
        return {
            dname:   '',
            ddata:   [],
            exdte:   null,

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
        selected_domain: function( tbl ){
            console.log( tbl )

            this.exdte = tbl.exdate.split( ' ' )[0]
        },

        domain_renew: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            this.axios.post( 'domain/renew', { name: this.dname, curExpDate: this.exdte } ).then( response => {
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
