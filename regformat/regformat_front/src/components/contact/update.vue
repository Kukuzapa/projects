<template>
    <div class="row">
        
        <div class="form-group col-12">
            <vue-bootstrap-typeahead 
                v-model="cname"
                :data="cdata"
                :serializer="s => s.loc + ' - ' + s.tld + ' (' + s.int + ') ' + s.doc"
                @hit="hit_registrar"
                placeholder="Укажите владельца домена (имя/название)"
            />

            <div v-if="tldmn" class="row mt-3">
                
                <div v-if="ctype=='person'" class="form-group col-6">
                    <label for="contact_create_name">Имя физ. лица</label>
                    <input type="text" class="form-control" id="contact_create_name" v-model="plname">
                </div>
                <div v-if="ctype=='organization'" class="form-group col-12">
                    <label for="contact_create_org">Название организации</label>
                    <input type="text" class="form-control" id="contact_create_org" v-model="olname">
                </div>

                <div v-if="ctype=='person'" class="form-group col-6">
                    <label for="contact_create_intname">Имя физ. лица ( англ. )</label>
                    <input type="text" class="form-control" id="contact_create_int_name" v-model="piname">
                </div>
                <div v-if="ctype=='organization'" class="form-group col-6">
                    <label for="contact_create_intorg">Название организации ( англ. )</label>
                    <input type="text" class="form-control" id="contact_create_int_org" v-model="oiname">
                </div>

                <div class="form-group col-6">
                    <label>Подтверждение данных</label>
                    <select class="custom-select" v-model="verif">
                        <option value="verified">Данные прошли проверку</option>
                        <option value="unverified">Проверка не проведена</option>
                    </select>
                </div>

                <div v-if="ctype=='person'" class="form-group col-6">
                    <label for="contact_create_birthday">Дата рождения</label>
                    <date-picker v-model="pbday" :config="options"></date-picker>
                </div>

                <div v-if="ctype=='organization'" class="form-group col-6">
                    <label for="contact_create_taxpayerNumbers">ИНН</label>
                    <input type="text" class="form-control" id="contact_create_taxpayerNumbers" v-model="orginn">
                </div>
                <div v-if="ctype=='person'" class="form-group col-12">
                    <label for="contact_create_passport">Паспортные данные</label>
                    <textarea class="form-control" id="contact_create_passport" v-model="ppassp"></textarea>
                </div>

                <div v-if="ctype=='organization'" class="form-group col-6">
                    <label for="contact_create_legaddress">Юридический адрес</label>
                    <input type="text" class="form-control" id="contact_create_leg_address" v-model="legaddr">
                </div>

                <div class="form-group col-12">
                    <label for="contact_create_address">Адрес</label>
                    <input type="text" class="form-control" id="contact_create_address" v-model="address">
                </div>

                <p class="col-12 text-center">Статусы</p>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="clientUpdateProhibited" v-model="status.clientUpdateProhibited">
                        <label class="form-check-label" for="clientUpdateProhibited">clientUpdateProhibited</label>
                    </div>
                </div>
                <div class="form-group col-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox"  id="clientDeleteProhibited" v-model="status.clientDeleteProhibited">
                        <label class="form-check-label" for="clientDeleteProhibited">clientDeleteProhibited</label>
                    </div>
                </div>

                <div class="col-6">
                    <div v-for="(value, index) in phone" :key="index" class="row">
                        <div v-if="phone[index] != 'FUCKOFF'" class="form-group col-12">
                            <label v-if="index==0">Телефон (минимум один)</label>
                            <div class="input-group mb-1">
                                <input type="text" class="form-control" v-model="phone[index]">
                                <div class="input-group-append">
                                    <span v-if="index==0" class="input-group-text" @click="add_ep( 'phone' )">+</span>
                                    <span v-else class="input-group-text" @click="rem_ep( 'phone', index )">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-6">
                    <div v-for="(value, index) in email" :key="index" class="row">
                        <div v-if="email[index] != 'FUCKOFF'" class="form-group col-12">
                            <label v-if="index==0">Email (минимум один)</label>
                            <div class="input-group mb-1">
                                <input type="text" class="form-control" v-model="email[index]">
                                <div class="input-group-append">
                                    <span v-if="index==0" class="input-group-text" @click="add_ep( 'email' )">+</span>
                                    <span v-else class="input-group-text" @click="rem_ep( 'email', index )">-</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="contact_update">Обновить данные контакта.</button>
                </div>
            </div>
        </div>

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
    name: 'contact_update',

    components: { result },

    data: function(){
        return{
            cname: null,
            cdata: [],

            tldmn:   null,
            ctype:   null,
            plname:  null,
            olname:  null,
            piname:  null,
            oiname:  null,
            pbday:   null,
            orginn:  null,
            ppassp:  null,
            address: null,
            legaddr: null,
            phone: [],
            email: [],

            cliid: null,

            verif: null,
            status: {
                clientUpdateProhibited: false,
                clientDeleteProhibited: false,
            },

            options: {
                format: 'YYYY-MM-DD',
                icons: {
                    time: 'far fa-clock',
                    date: 'far fa-calendar',
                    up: 'fas fa-arrow-up',
                    down: 'fas fa-arrow-down',
                    previous: 'fas fa-chevron-left',
                    next: 'fas fa-chevron-right',
                    today: 'fas fa-calendar-check',
                    clear: 'far fa-trash-alt',
                    close: 'far fa-times-circle'
                }
            },

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    watch: {
        cname: function(){
            //console.log( this.cname )

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
                            int: data['intPostalInfo'+templ[data.type]] || 'N/A',
                            loc: data['locPostalInfo'+templ[data.type]],
                            tld: tld[data.id_registrars],
                            cid: data.contact_id,
                        }

                        if ( data.type == 'person' ){
                            tmp.doc = data.passport || 'N/A'
                        } else {
                            tmp.doc = data.taxpayerNumbers || 'N/A'
                        }

                        tmp.all = data;
                        
                        Vue.set( this.cdata, this.cdata.length, tmp )                       
                    }
                } ).catch( error => {
                    this.error = true;
			    })
            }
        }
    },

    methods: {
        split_str: function( str, num ){

            var arr = [];

            if ( !str ){
                return arr;
            }

            for (var i = 0; i < str.length; i+=num) {
                arr.push(str.slice(i, i + num));
            }

            return arr;
        },

        add_ep: function( str ){
            if ( str == 'phone' ){
                Vue.set( this.phone, this.phone.length, '' )
            } else {
                Vue.set( this.email, this.email.length, '' )
            }
        },

        rem_ep: function( str, num ){
            if ( str == 'phone' ){
                Vue.set( this.phone, num, 'FUCKOFF' )
            } else {
                Vue.set( this.email, num, 'FUCKOFF' )
            }
        },

        hit_registrar: function( tbl ){
            this.phone = []
            this.email = []

            for ( var key in this.status ){
                this.status[key] = false;
            }


            //console.log( tbl )

            if ( tbl.all.id_registrars == 1 ){
                this.tldmn = 'ru'
            } else {
                this.tldmn = 'rf'
            }

            this.ctype = tbl.all.type;
            this.verif = tbl.all.verified || 'unverified';

            if ( tbl.all.status ){
                var status = tbl.all.status.split( ';' )

                for ( var i=0; i<status.length; i++ ){
                    var templ = [ 'clientUpdateProhibited', 'clientDeleteProhibited' ]
                    
                    if ( templ.indexOf( status[i] ) != -1 ){
                        this.status[status[i]] = true;
                    }
                }
            }

            if ( tbl.all.email ){
                var tmp = tbl.all.email.split( ';' )

                for ( var i=0; i<tmp.length; i++ ){
                    Vue.set( this.email, this.email.length, tmp[i] )
                }
            }

            if ( tbl.all.voice ){
                var tmp = tbl.all.voice.split( ';' )

                for ( var i=0; i<tmp.length; i++ ){
                    Vue.set( this.phone, this.phone.length, tmp[i] )
                }
            }

            this.cliid = tbl.all.contact_id

            if ( this.ctype == 'person' ){
                this.plname = tbl.all.locPostalInfo_name
                this.piname = tbl.all.intPostalInfo_name
                this.pbday  = tbl.all.birthday
                this.ppassp = tbl.all.passport
                this.address = tbl.all.locPostalInfo_address
            } else {
                this.olname = tbl.all.locPostalInfo_org
                this.oiname = tbl.all.intPostalInfo_org
                this.legaddr = tbl.all.legalInfo_address
                this.address = tbl.all.locPostalInfo_address
                this.orginn = tbl.all.taxpayerNumbers
            }
        },

        contact_update: function(){
            this.error   = null;
            this.err_msg = null;
            this.success = null;

            var status = []

            for ( var key in this.status ){
                if ( this.status[key] ){
                    status.push( key )
                }
            }
            
            var request = {
                person: {
                    name: this.plname,
                    int_name: this.piname,
                    birthday: this.pbday,
                    email: this.email,
                    voice: this.phone,
                    passport: this.split_str( this.ppassp, 250 ),
                    address: this.split_str( this.address, 250 ),
                    id: this.cliid,
                    verified: this.verif,
                    status: status,
                },

                organization: {
                    email: this.email,
                    voice: this.phone,
                    address: this.split_str( this.address, 250 ),
                    leg_address: this.split_str( this.legaddr, 250 ),
                    org: this.olname,
                    int_org: this.oiname,
                    taxpayerNumbers: this.orginn,
                    id: this.cliid,
                    verified: this.verif,
                    status: status,
                }
            }

            console.log( request[this.ctype] )

            this.axios.post( 'contact/update/' + this.tldmn, request[this.ctype] ).then( response => {
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
        }
    },
}
</script>
