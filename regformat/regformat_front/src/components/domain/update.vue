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
                        @hit="selected_domain"
                    />
                </div>

                <div class="form-group col-6">
                    <label>Укажите нового владельца ( опц. )</label>
                    <vue-bootstrap-typeahead 
                        v-model="cname"
                        :data="cdata"
                        :serializer="s => s.loc + ' - ' + s.tld + ' (' + s.int + ') ' + s.doc"
                        @hit="selected_registrant"
                        placeholder="Укажите нового владельца ( опц. )"
                    />
                </div>

                <div class="form-group col-6">
                    <label>Описание домена ( опц. )</label>
                    <input class="form-control" type="text" placeholder="Описание домена ( опц. )" v-model="descr">
                </div>

                <div class="form-group col-6">
                    <label>ИД нового владельца</label>
                    <input class="form-control" type="text" placeholder="ИД нового владельца" v-model="cntid">
                </div>

                <div class="form-group col-6">
                    <label>Код аутентификации ( опц. )</label>
                    <input class="form-control" type="text" placeholder="Код аутентификации ( опц. )" v-model="dauth">
                </div>


                <p class="col-12 text-center">Статусы</p>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="" id="domain_clientUpdateProhibited" v-model="dmsts.clientUpdateProhibited">
                        <label class="form-check-label" for="domain_clientUpdateProhibited">clientUpdateProhibited</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="" id="domain_clientTransferProhibited" v-model="dmsts.clientTransferProhibited">
                        <label class="form-check-label" for="domain_clientTransferProhibited">clientTransferProhibited</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="133" id="domain_clientDeleteProhibited" v-model="dmsts.clientDeleteProhibited">
                        <label class="form-check-label" for="domain_clientDeleteProhibited">clientDeleteProhibited</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="" id="domain_clientHold" v-model="dmsts.clientHold">
                        <label class="form-check-label" for="domain_clientHold">clientHold</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="" id="domain_clientRenewProhibited" v-model="dmsts.clientRenewProhibited">
                        <label class="form-check-label" for="domain_clientRenewProhibited">clientRenewProhibited</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" value="" id="domain_changeProhibited" v-model="dmsts.changeProhibited">
                        <label class="form-check-label" for="domain_changeProhibited">changeProhibited</label>
                    </div>
                </div>


                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block mb-2" @click="add_nssrv">Добавить НС</button>
                </div>
                
                <div class="col-12">
                    <div v-for="(value, key) in nssrv" :key="key" class="row">
                        
                        <div v-if="nssrv[key].ns != 'FUCKOFF'" class="form-group col-6">
                            <input class="form-control" type="text" placeholder="Имя НС сервера" v-model="nssrv[key].ns">
                        </div>

                        <div v-if="nssrv[key].ns != 'FUCKOFF'" class="form-group col-6">
                            <div class="input-group">
                                <input class="form-control" type="text" placeholder="ip адреса через пробел (опц)" v-model="nssrv[key].ip">
                                <div class="input-group-append" @click="rem_nssrv( key )">
						            <span class="input-group-text">-</span>
					            </div>
                            </div>
                        </div>
                    </div>
                </div>


                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="get_domain_info">Обновить данные домена.</button>
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
    name: 'domain_update',

    components: { result },

    data: function(){
        return {
            dname:   null,
            ddata:   [],
            cname:   null,
            cdata:   [],
            cntid:   null,
            dauth:   null,
            descr:   null,
            nssrv:   [],
            dmsts: {
                clientUpdateProhibited:   false,
                clientDeleteProhibited:   false,
                clientRenewProhibited:    false,
                clientTransferProhibited: false,
                clientHold:               false,
                changeProhibited:         false,
            },

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
            //info:    null
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
                    //console.log( response.data )

                    for (var i=0;i<response.data.suggestions.length;i++){
                        this.ddata.push( response.data.suggestions[i].data )
                    }
                } ).catch( error => {
                    this.error = true;
			    })
            }
        },

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
        add_nssrv: function(){
            Vue.set( this.nssrv, this.nssrv.length, { ns: '', ip: '' } )
        },

        rem_nssrv: function( num ){
            this.nssrv[num].ns = 'FUCKOFF'
        },

        selected_registrant: function( tbl ){
            //console.log( tbl )

            this.cntid = tbl.cid;
        },

        selected_domain: function( tbl ){
            //console.log( tbl )

            this.nssrv = [];

            for ( var key in this.dmsts ){
                this.dmsts[key] = false;
            }

            this.dauth = tbl.authInfo;
            this.descr = tbl.description;

            if ( tbl.nss ){
                //console.log( tbl.nss )

                //console.log( tbl.nss.split( ';' ) )

                var nsip = tbl.nss.split( ';' )

                for ( var i=0; i<nsip.length; i++ ){

                    var tmp = nsip[i].split( '#' )

                    var ns = tmp[0]
                    var ip = ''
                    
                    if ( tmp[1] ) { 
                        ip = tmp[1].split( ',' ).join( ' ' )
                    }

                    Vue.set( this.nssrv, this.nssrv.length, { ns: ns, ip: ip } )

                    //console.log( { ns: ns, ip: ip } )
                }
            }

            if ( tbl.status ){
                var status = tbl.status.split( ';' )

                for ( var i=0; i<status.length; i++ ){
                    /*if ( this.dmsts[status[i]] ){
                        console.log( status[i] )
                    }*/
                    var templ = [ 'clientUpdateProhibited', 'clientDeleteProhibited', 'clientRenewProhibited', 
                        'clientTransferProhibited', 'clientHold', 'changeProhibited' ]
                    if ( templ.indexOf( status[i] ) != -1 ){
                        this.dmsts[status[i]] = true;
                    }

                    
                }
            }
        },

        get_domain_info: function(){

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            var tmp = {
                name:        this.dname,
                registrant:  this.cntid,
                description: this.descr,
                authInfo:    this.dauth,
            }

            tmp.ns = {};
            tmp.status = [];

            for ( var i=0; i<this.nssrv.length; i++ ){
                if ( this.nssrv[i].ns && this.nssrv[i].ns != 'FUCKOFF' ){
                    tmp.ns[this.nssrv[i].ns] = this.nssrv[i].ip
                }
            }

            for ( var key in this.dmsts ){
                if ( this.dmsts[key] ){
                    tmp.status.push( key )
                }
            }

            var request = {};

            for ( var key in tmp ){
                //console.log( tmp[key] )
                if ( tmp[key] ){
                    request[key] = tmp[key]
                }
            }

            //console.log( request )

            this.axios.post( 'domain/update', request ).then( response => {
                //console.log( response )
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    //this.create = response.data.create
                }
            } ).catch( error => {
                this.error = true;
			})
        },
    }
}
</script>


