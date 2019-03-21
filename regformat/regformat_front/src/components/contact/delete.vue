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
                    <label>Имя/название контакта</label>
                    <vue-bootstrap-typeahead 
                        v-model="cname"
                        :data="cdata"
                        :serializer="s => s.loc + ' - ' + s.tld + ' (' + s.int + ') ' + s.doc"
                        @hit="hit_registrar"
                        placeholder="Имя/название контакта"
                    />
                </div>

                <div class="form-group col-12">
                    <label>ИД Контакта</label>
                    <input class="form-control" type="text" placeholder="ИД Контакта" v-model="cntid">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="contact_delete">Удалить контакт.</button>
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
import Vue from 'vue'

import result from '../result.vue'

export default {
    name: 'contact_delete',

    components: { result },

    data: function(){
        return {
            tldmn: 'ru',
            cname: null,
            cntid: null,
            cdata: [],

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
            this.cdata = [];
            this.cntid = null;
        },

        cname: function(){
            if ( this.cname.length >= 3 ){

                this.cdata = [];

                var request = {
                    obj:   'con',
                    query: this.cname,
                    reg:   this.tldmn,
                }

                this.axios.get( 'base', { params: request } ).then( response => {
                    for (var i=0;i<response.data.suggestions.length;i++){

                        var data = response.data.suggestions[i].data

                        var templ = { person: '_name', organization: '_org' }

                        var tld = [ '', 'RU', 'RF' ]

                        var tmp = {
                            int: data['intPostalInfo'+templ[data.type]],
                            loc: data['locPostalInfo'+templ[data.type]],
                            tld: tld[data.id_registrars],
                            cid: data.contact_id,
                        }

                        if ( data.type == 'person' ){
                            tmp.doc = data.passport || 'N/A'
                        } else {
                            tmp.doc = data.taxpayerNumbers || 'N/A'
                        }
                        
                        Vue.set( this.cdata, this.cdata.length, tmp )                       
                    }
                } ).catch( error => {
                    this.error = true;
			    })
            }
        }
    },

    methods: {
        hit_registrar: function( tbl ){
            console.log( tbl )

            this.cntid = tbl.cid;
        },

        contact_delete: function(){
            console.log( 'DELETE' )

            this.error   = null;
            this.err_msg = null;

            this.success = null;

            var request = {
                id: this.cntid
            }

            this.axios.post( 'contact/delete/' + this.tldmn, request ).then( response => {
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
        },
    }
}
</script>

