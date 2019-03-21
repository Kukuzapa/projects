<template>
    <div class="row">

        <form class="col-12">

            
            
            <div class="row">
                <div class="form-group col-12">
                    <label>Выбор регистратора</label>
                    <select class="custom-select" v-model="registrar">
                        <option value="ru">Зона RU</option>
                        <option value="rf">Зона RF</option>
                    </select>
                </div>

                <div class="col-4 mt-3" v-for="(value,index) in iplist" :key="index">
                    <input type="text" class="form-control" placeholder="допустимый адрес" v-model="iplist[index]">
                </div>

                <div class="col-12 mt-3">
                    <button type="button" class="btn btn-primary btn-block" @click="registrar_update">Обновить список адресов.</button>
                </div>
            </div>


            <!--div class="col-12">
                <button type="button" class="btn btn-primary btn-block" @click="registrar_update">Обновить список адресов.</button>
            </div-->
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
    name: 'registrar_update',

    components: { result },

    data: function(){
        return {
            registrar: 'ru',

            iplist: [],

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    watch: {
        registrar: function(){
            this.registrar_get()
        }
    },

    created: function(){
        

        /*this.error   = null;
        this.err_msg = null;
        this.success = null;

        this.axios.get( 'registrar/get/' + this.registrar ).then( response => {
            if ( response.data.error ){
                this.error   = true;
                this.err_msg = response.data.message;
            } else {

                for ( var i=0; i<response.data.registrar.v4.length; i++ ){
                    Vue.set( this.iplist, this.iplist.length, response.data.registrar.v4[i] )
                }

                for ( var i=0; i<response.data.registrar.v6.length; i++ ){
                    Vue.set( this.iplist, this.iplist.length, response.data.registrar.v6[i] )
                }

                for ( var i=0; i<20; i++ ){
                    if (!this.iplist[i]){ Vue.set( this.iplist, i, '' ) }
                }
            }
        } ).catch( error => {
            this.error = true;
        })*/

        this.registrar_get();
    },

    methods: {
        registrar_get: function(){
            
            console.log( this.registrar );

            this.iplist = [];

            this.error   = null;
            this.err_msg = null;
            this.success = null;

            this.axios.get( 'registrar/get/' + this.registrar ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {

                    for ( var i=0; i<response.data.registrar.v4.length; i++ ){
                        Vue.set( this.iplist, this.iplist.length, response.data.registrar.v4[i] )
                    }

                    for ( var i=0; i<response.data.registrar.v6.length; i++ ){
                        Vue.set( this.iplist, this.iplist.length, response.data.registrar.v6[i] )
                    }

                    for ( var i=0; i<20; i++ ){
                        if (!this.iplist[i]){ Vue.set( this.iplist, i, '' ) }
                    }
                }
            } ).catch( error => {
                this.error = true;
            })
        },

        registrar_update: function(){
            this.error   = null;
            this.err_msg = null;
            this.success = null;

            console.log( this.iplist )

            var request = { ip: [] }

            for ( var i=0; i<this.iplist.length; i++ ){
                if ( this.iplist[i] ){ request.ip.push( this.iplist[i] ) }
            }

            console.log( request.ip )

            this.axios.post( 'registrar/update/' + this.registrar, request ).then( response => {
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
    }
}
</script>