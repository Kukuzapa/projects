<template>
    <div class="col-12">

        <b-pagination align="center" :total-rows="count" v-model="current_page" :per-page="limit" class="mt-2" :limit="15"></b-pagination>

        <table class="table">
            <thead>
                <tr>
                    <th scope="col">Номер</th>
                    <th scope="col">Автор</th>
                    <th scope="col">Время</th>
                    <th scope="col">Заявка</th>
                    <th scope="col">Действие</th>
                    <th scope="col">Комментарий</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in res">
                    <td>{{row.id}}</td>
                    <td>{{row.name}}</td>
                    <td>{{row.date_time}}</td>
                    <td>{{row.vacation_id}}</td>
                    <td>{{row.action}}</td>
                    <td>{{row.comment}}</td>
                </tr>
            </tbody>
        </table>
        
    </div>
</template>

<script>
export default {
    name: 'v_admin_log',

    props: ['user_id','user_token','clname'],

    data: function(){
        return {
            res: {},

            limit: 8,
            current_page: 1,
            count: null
        }
    },

    watch: {
        current_page: function(){
            this.get_log();
        },
        clname: function(){
            this.get_log('count');
            this.get_log();
        }
    },

    mounted: function(){
        this.get_log('count');
        this.get_log();
    },

    methods: {
        get_log: function( count ){
            let req = {
                params: { userid: this.user_id, page: this.current_page, limit: this.limit },
                headers: {'Authorization': 'Bearer ' + this.user_token }
            }

            if ( count ){
                req.params.count = 'count';
            }

            if ( this.clname.length > 0 ){
                req.params.clname = this.clname;
            }

            this.axios.get( '/vm/admin/log', req ).then( response => {
                    if ( count ){
                        this.count = +response.data.count;
                    } else {
                        this.res = response.data;
                    }
                }
            )
        }
    }
}
</script>