<template>
    <div class="row">

        <b-modal ref="status" hide-footer title="Статусы домена">
            <p v-for="(st,key) in status" :key="key">
                {{key}} - {{st}}
            </p>
        </b-modal>

        <b-modal ref="nss" hide-footer title="НС Сервера">
            <p v-for="(ns,key) in nss" :key="key">
                {{key}} - {{ns}}
            </p>
        </b-modal>


        <div class="form-group col-4">
            <label for="exampleFormControlSelect1">Фильтр по имени домена</label>
            <input type="text" class="form-control" v-model="domain">
        </div>

        <div class="form-group col-4">
            <label for="exampleFormControlSelect1">Сортировка по</label>
            <select class="form-control" id="exampleFormControlSelect1" v-model="column">
                <option value="name">имени домена</option>
                <option value="exdate">дате истечения</option>
            </select>
        </div>

        <div class="form-group col-4">
            <label for="exampleFormControlSelect1">Направление сортировки</label>
            <select class="form-control" id="exampleFormControlSelect1" v-model="direction">
                <option value="ASC">По возростанию</option>
                <option value="DESC">По убыванию</option>
            </select>
        </div>


        <div class="col-12">
            <b-pagination size="md" :total-rows="totalRows" v-model="currentPage" :per-page="10" :align="'center'" :limit="10"></b-pagination>      
        </div>

        <div class="col-12">
            <table class="table">
            <thead>
                <tr>
                    <th scope="col">Имя</th>
                    <th scope="col">Владелец</th>
                    <th scope="col">Статусы</th>
                    <th scope="col">НС Сервера</th>
                    <th scope="col">Дата истечения</th>
                </tr>
            </thead>
                <tbody>
                    <tr v-for="(dom,index) in list" :key="index">
                        <td>{{dom.name}}</td>
                        <td>{{(dom.locPostalInfo_name)?dom.locPostalInfo_name:dom.locPostalInfo_org}}</td>
                        <td>
                            <i v-if="dom.status" class="fas fa-clipboard" style="cursor: pointer" @click="show_status( index )"></i>
                            <i v-else class="far fa-clipboard"></i>
                        </td>
                        <td>
                            <i v-if="dom.nss" class="fas fa-clipboard" style="cursor: pointer" @click="show_nss( index )"></i>
                            <i v-else class="far fa-clipboard"></i>
                        </td>
                        <td>{{dom.exdate}}</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div v-if="error" class="col-12 mt-2">
            <div class="alert alert-danger" role="alert">
                <!--span v-if="err_msg">{{err_msg}}</span-->
                <span>Это фиаско. Что-то, как всегда неожиданно, пошло не так.</span>
            </div>
        </div>

    </div>
</template>

<script>
export default {
    name: 'domain_list',

    data: function(){
        return{
            //count: null
            totalRows: null,
            currentPage: 1,

            list: [],

            domain: '',
            direction: 'ASC',
            column: 'name',

            status: {},
            nss: {},

            error: false,
        }
    },

    created: function(){
        //console.log( 'list' )

        this.domain_list();
    },

    watch: {
        currentPage: function(){
            this.domain_list();
        },

        direction: function(){
            this.domain_list();
        },
        
        column: function(){
            this.domain_list();
        },

        domain: function(){
            console.log( this.domain.length );

            //if ( this.domain.length > 1 ){
            this.domain_list();
            //}
        }
    },

    methods: {
        show_nss: function( num ){
            this.nss = {}

            var tmp = this.list[num].nss.split(';');

            for ( var key in tmp ){
                //console.log( tmp[key], templ[tmp[key]] );
                //this.nss[tmp[0]] = tmp[1];
                var ns = tmp[key].split('#')[0]
                var ip = tmp[key].split('#')[1]

                console.log( ip )

                if ( ip ){
                    this.nss[ns] = ip
                } else {
                    this.nss[ns] = 'N/A'
                }
                
            }

            this.$refs.nss.show();

        },

        show_status: function( num ){
            this.status = {};

            var templ = {
                clientUpdateProhibited: 'регистратору запрещено выполнять процедуры внесения изменений',
                clientRenewProhibited: 'регистратору запрещено выполнять процедуру продления домена',
                clientTransferProhibited: 'регистратору запрещено выполнять процедуру передачи доменного имени',
                clientDeleteProhibited: 'регистратору запрещено удалять домен',
                clientHold: 'запрет делегирования домена',
                changeProhibited: 'домен в состоянии «Судебный Спор»',
                serverUpdateProhibited: 'установлено ограничение регистратору на выполнение процедур внесения изменений и запрещение выполнение продления',
                serverDeleteProhibited: 'установлено ограничение регистратору на удаление доменного имени',
                serverRenewProhibited: 'установлено ограничение регистратору на продление срока регистрации доменного имени',
                serverTransferProhibited: 'установлено ограничение регистратору на передачу доменного имени другому регистратору',
                serverHold: 'установлен запрет делегирования домена',
                inactive: 'невыполнение условий делегирования домена, домен не будет делегирован',
                ok: 'у домена отсутствуют запрещающие статусы, домен не находится в процессе выполнения каких-либо операций',
                pendingCreate: 'домен находится в процессе выполнения процедуры создания',
                pendingDelete: 'домен находится в процессе выполнения процедуры удаления',
                pendingRenew: 'домен находится в процессе выполнения процедуры продления',
                pendingTransfer: 'домен находится в процессе выполнения процедуры передачи регистратору-реципиенту',
                pendingUpdate: 'домен находится в процессе выполнения процедуры изменения'
            }

            console.log( this.list[num].status );

            var tmp = this.list[num].status.split(';');

            for ( var key in tmp ){
                console.log( tmp[key], templ[tmp[key]] );
                this.status[tmp[key]] = templ[tmp[key]];
            }

            this.$refs.status.show();
        },

        domain_list: function(){
            var request = {
                column: this.column,
                dir:    this.direction,
                domain: this.domain,
                page:   this.currentPage,
            }

            this.axios.get( 'list', { params: request } ).then( response => {
                console.log( response.data )

                this.totalRows = +response.data.count;

                this.list = response.data.list;

            } ).catch( error => {
                this.error = true;
            })
        },
    }
}
</script>
