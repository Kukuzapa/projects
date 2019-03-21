<template>
    <div class="row">

        <form class="col-12">
            <div class="row">

                <div class="form-group col-12">
                    <label>Выбор регистратора</label>
                    <select class="custom-select" v-model="tldmn">
                        <option value="ru">Зона RU</option>
                        <option value="rf">Зона RF</option>
                    </select>
                </div>

               

                <div class="form-group col-12">
                    <label>ИД Контакта</label>
                    <input class="form-control" type="text" placeholder="ИД Контакта" v-model="cntid">
                </div>


                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="contact_check">Проверить зантость идентификатора контакта</button>
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
//import Vue from 'vue'

import result from '../result.vue'

export default {
    name: 'contact_check',

    components: { result },

    data: function(){
        return {
            tldmn: 'ru',
            //cname: null,
            //cdata: [],
            cntid: null,
            //cauth: null,

            check:  null,

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    watch: {
        tldmn: function(){
            this.cntid = null;
        },
    },

    methods: {
        hit_registrar: function( tbl ){
            this.cntid = tbl.cid;
        },

        contact_check: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            var request = {
                id: this.cntid
            }

            var templ = [ 'Контакт с таким идентификатором существует.', 'Контакт с таким идентификатором не существует.' ]
            
            this.axios.get( 'contact/check/' + this.tldmn, { params: request } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    this.check = templ[response.data.check[this.cntid]]
                }
            } ).catch( error => {
                this.error = true;
			})
        },
    }
    
}
</script>
