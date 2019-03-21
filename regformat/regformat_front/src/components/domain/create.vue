<template>
    <div class="row">

        <form class="col-12">
            <div class="row">
                <div class="form-group col-12">
                    <input class="form-control" type="text" placeholder="Введите имя домена" v-model="dname">
                </div>

                <div class="form-group col-6">
                    <vue-bootstrap-typeahead 
                        v-model="cname"
                        :data="cdata"
                        :serializer="s => s.loc + ' - ' + s.tld + ' (' + s.int + ') ' + s.doc"
                        @hit="hit_registrar"
                        placeholder="Укажите владельца домена"
                    />
                </div>

                <div class="form-group col-6">
                    <input class="form-control" type="text" placeholder="Описание домена ( опц. )" v-model="descr">
                </div>

                <div class="form-group col-6">
                    <input class="form-control" type="text" placeholder="ИД Владельца домена" v-model="cntid">
                </div>

                

                <div class="form-group col-6">
                    <input class="form-control" type="text" placeholder="Код аутентификации ( опц. )" v-model="dauth">
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block mb-2" @click="add_ns">Добавить НС</button>
                </div>
                
                <div class="col-12">
                    <div v-for="(value, key) in dns" :key="key" class="row">
                        
                        <div v-if="dns[key].ns != 'FUCKOFF'" class="form-group col-6">
                            <input class="form-control" type="text" placeholder="Имя НС сервера" v-model="dns[key].ns">
                        </div>

                        <div v-if="dns[key].ns != 'FUCKOFF'" class="form-group col-6">
                            <div class="input-group">
                                <input class="form-control" type="text" placeholder="ip адреса через пробел (опц)" v-model="dns[key].ip">
                                <div class="input-group-append" @click="rem_ns( key )">
						            <span class="input-group-text">-</span>
					            </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="domain_create">Создать домен</button>
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
                    <div v-for="(value, key) in create" :key="key">
                        <p>{{ key }}: {{ value }}</p>
                    </div>
                </div>
            </div>
        </div>
    

    </div>
</template>

<script>
import Vue from 'vue'

import result from '../result.vue'
//import { timeout } from 'q';

export default {
    name: 'domain_create',

    components: { result },

    data: function(){
        return {
            dname:   null,
            cname:   null,
            cdata:   [],
            cntid:   null,
            descr:   null,
            dauth:   null,

            //dns: { 'ddd': 'fff' },
            dns: [],

            create:  null,

            //tst: null,
            
            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
            check:   null
        }
    },

    watch: {
        cname: function(){
            if ( this.cname.length >= 3 ){

                this.cdata = [];

                var request = {
                    obj:   'con',
                    query: this.cname
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

        add_ns: function(){
            Vue.set( this.dns, this.dns.length, { ns: '', ip: '' } )
        },

        rem_ns: function( num ){
            this.dns[num].ns = 'FUCKOFF' 
        },

        domain_create: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            var tmp = {
                name:        this.dname,
                registrant:  this.cntid,
                description: this.descr,
                authInfo:    this.dauth,
            }

            tmp.ns = {}

            for ( var i=0; i<this.dns.length; i++ ){
                if ( this.dns[i].ns && this.dns[i].ns != 'FUCKOFF' ){
                    tmp.ns[this.dns[i].ns] = this.dns[i].ip
                }
            }

            var request = {};

            for ( var key in tmp ){
                console.log( tmp[key] )
                if ( tmp[key] ){
                    request[key] = tmp[key]
                }
            }

            console.log( request )

            this.axios.post( 'domain/create', request ).then( response => {
                console.log( response )
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    this.create = response.data.create
                }
            } ).catch( error => {
                this.error = true;
			})
        },
    }
}
</script>
