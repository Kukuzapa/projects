<template>
    <div class="row">
        
        <b-modal ref="request" hide-footer title="Тело запроса к реестру (json)">
            <p v-for="(req,key) in request" :key="key">{{key}}: {{req}}</p>
        </b-modal>

        <b-modal ref="response" hide-footer title="Тело ответа реестра (json)">
            <p v-for="(res,key) in response" :key="key">{{key}}: {{res}}</p>
        </b-modal>
        

        <div class="form-group col-4">
            <label for="contact_create_birthday">Начало промежутка</label>
            <date-picker v-model="from" :config="options"></date-picker>
        </div>

        <div class="form-group col-4">
            <label for="contact_create_birthday">Конец промежутка</label>
            <date-picker v-model="to" :config="options"></date-picker>
        </div>

        <div class="form-group col-4">
            <label for="exampleFormControlSelect1">Количество записей на экране</label>
            <select class="form-control" id="exampleFormControlSelect1" v-model="perPage">
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="15">15</option>
                <option value="20">20</option>
                <option value="25">25</option>
            </select>
        </div>


        <div class="col-12">
            <b-pagination size="md" :total-rows="totalRows" v-model="currentPage" :per-page="+perPage" :align="'center'" :limit="10"></b-pagination>      
        </div>

        <div class="col-12">
            <table class="table">
            <thead>
                <tr>
                    <th scope="col">id</th>
                    <th scope="col">object</th>
                    <th scope="col">command</th>
                    <th scope="col">request</th>
                    <th scope="col">response</th>
                    <th scope="col">status</th>
                    <th scope="col">date</th>
                </tr>
            </thead>
                <tbody>
                    <tr v-for="(op,index) in operations" :key="index">
                        <td>{{op.id}}</td>
                        <td>{{op.object}}</td>
                        <td>{{op.command}}</td>
                        <td><i class="fas fa-book-open" style="cursor: pointer" @click="show_request( index )"></i></td>
                        <td><i class="fas fa-book-open" style="cursor: pointer" @click="show_response( index )"></i></td>
                        <td>{{op.status}}</td>
                        <td>{{op.date}}</td>
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
var moment = require('moment');

export default {
    name: 'operation',

    data: function(){
        return {
            currentPage: 1,
            totalRows: 0,
            perPage: '10',

            operations: [],

            request: null,
            response: null,
            
            from: null,
            to: null,
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

            error: false,
        }
    },

    watch: {
        currentPage: function(){
            this.history_get();
        },

        perPage: function(){
            this.history_get();
        },

        from: function(){
            this.history_get();
        },

        to: function(){
            this.history_get();
        },
    },

    created: function(){
        var now = moment();
        this.from = now.format().split('T')[0];
        this.to   = now.format().split('T')[0];

        this.history_get();
    },

    methods: {
        show_request: function( num ){
            this.request = JSON.parse(this.operations[num].request);

            this.$refs.request.show();
        },

        show_response: function( num ){
            this.response = JSON.parse(this.operations[num].response);

            this.$refs.response.show();
        },

        history_get: function(){

            var request = {
                count:    this.perPage,
                clid:     (this.currentPage - 1)*this.perPage,
                per_from: this.from,
                per_to:   this.to,
            }
            
            this.axios.get( 'history', { params: request } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                } else {
                    console.log( response.data )

                    this.totalRows = +response.data.count

                    this.operations = response.data.list
                }
            } ).catch( error => {
                this.error = true;
			})
        }
    },
}
</script>