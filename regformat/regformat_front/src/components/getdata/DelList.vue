<template>
    <div class="row">

        <div class="form-group col-12">
            <label>Выбор регистратора</label>
            <select class="custom-select" v-model="registrar">
                <option value="ru">Зона RU</option>
                <option value="rf">Зона RF</option>
            </select>
        </div>

        <div class="col-12">
            <b-pagination size="md" :total-rows="totalRows" v-model="currentPage" :per-page="perPage" :align="'center'" :limit="10"></b-pagination>      
        </div>

        <div v-for="(domain,index) in currentList" :key="index" class="col-4">{{domain}}</div>
    
        <div v-if="error" class="col-12 mt-2">
            <div class="alert alert-danger" role="alert">
                <span v-if="err_msg">{{err_msg}}</span>
                <span v-else>Это фиаско. Что-то, как всегда неожиданно, пошло не так.</span>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'DelList',

    data: function(){
        return {
            registrar: 'ru',
            list: [],
            error: null,
            err_msg: null,

            domain: null,

            totalRows: null,
            currentPage: 1,
            currentList: [],
            perPage: 60,
        }
    },

    watch: {
        registrar: function(){
            this.del_list();
        },

        currentPage: function(){
            this.currentList = [];

            for ( var i=(this.currentPage-1)*this.perPage; i<this.currentPage*this.perPage; i++ ){
                if ( this.list[i] ){ this.currentList.push( this.list[i] ) }
            }
        }
    },
  
    created: function(){
        this.del_list();
    },

    methods: {
        del_list: function(){
            this.error = null;
            this.err_msg = null;
            this.currentList = [];

            this.axios.get( 'getdata/' + this.registrar, { params: { type: 'DelList' } } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    console.log( response.data )
                    
                    this.totalRows = response.data.count;
                    this.list = response.data.list;

                    for ( var i=(this.currentPage-1)*this.perPage; i<this.currentPage*this.perPage; i++ ){
                        if ( this.list[i] ){ this.currentList.push( this.list[i] ) }
                    }
                }
            } ).catch( error => {
                this.error = true;
            })
        }
    },
}
</script>