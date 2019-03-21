<template>
    <div class="row">

        <form class="col-12">
            <div class="row">

                <div class="form-group col-6">
                    <label>Выбор регистратора</label>
                    <select class="custom-select" v-model="tldmn">
                        <option value="ru">Зона RU</option>
                        <option value="rf">Зона RF</option>
                    </select>
                </div>

                <div class="form-group col-6">
                    <label>Тип нового контакта</label>
                    <select class="custom-select" v-model="ctype">
                        <option value="organization">Юридичиское лицо</option>
                        <option value="person">Физическое лицо/ИП</option>
                    </select>
                </div>

                <div v-if="ctype=='person'" class="form-group col-12">
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
                <div class="form-group col-12">
                    <label for="contact_create_address">Адрес</label>
                    <input type="text" class="form-control" id="contact_create_address" v-model="address">
                </div>
                <div v-if="ctype=='organization'" class="form-group col-12">
                    <label for="contact_create_legaddress">Юридический адрес</label>
                    <input type="text" class="form-control" id="contact_create_leg_address" v-model="legaddr">
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
                    <button type="button" class="btn btn-primary btn-block" @click="contact_create">Создать контакт</button>
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

export default {
    name: 'contact_create',

    components: { result },

    data: function(){
        return{
            tldmn: 'ru',
            ctype: 'organization',

            plname: null,
            olname: null,

            piname: null,
            oiname: null,

            pbday:  null,

            orginn: null,

            ppassp: null,

            address: null,
            legaddr: null,

            phone: [ '' ],
            email: [ '' ],

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

        contact_create: function(){
            this.error   = null;
            this.err_msg = null;
            this.success = null;
            
            var request = {
                person: {
                    name: this.plname,
                    int_name: this.piname,
                    birthday: this.pbday,
                    email: this.email,
                    voice: this.phone,
                    passport: this.split_str( this.ppassp, 250 ),
                    address: this.split_str( this.address, 250 ),
                },

                organization: {
                    email: this.email,
                    voice: this.phone,
                    address: this.split_str( this.address, 250 ),
                    leg_address: this.split_str( this.legaddr, 250 ),
                    org: this.olname,
                    int_org: this.oiname,
                    taxpayerNumbers: this.orginn,
                }
            }

            this.axios.post( 'contact/create/' + this.tldmn, request[this.ctype] ).then( response => {
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
        }
    }
}
</script>

