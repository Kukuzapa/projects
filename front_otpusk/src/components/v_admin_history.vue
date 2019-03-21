<template>
    <div class="col-12">
        <p>Список заявок дата окончания которых уже прошла либо отзванных пользователем. При наведении курсора на название колонки будет показана подсказка</p>
        <b-modal ref="cross_modal" no-fade hide-footer hide-header size="lg">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Номер</th>
                        <th scope="col">Автор</th>
                        <th scope="col">Начало</th>
                        <th scope="col">Конец</th>
                        <th scope="col">Компетенции</th>
                        <th scope="col">Статус</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="row in res_cross">
                        <td>{{ row.id }}</td>
                        <td>{{ row.name }}</td>
                        <td>{{ row.begin }}, {{ get_day_of_week(row.begin) }}</td>
                        <td>{{ row.end }}, {{ get_day_of_week(row.end) }}</td>
                        <td>{{ row.competense }}</td>
                        <td>{{ (!row.status)?'В процессе':(row.status == 1)?'Одобрена':(row.status == -2)?'Отозвана':'Отказ' }}</td>
                    </tr>
                </tbody>
            </table>
        </b-modal>

        <b-modal ref="comment_modal" centered no-fade hide-footer hide-header>
            <p v-if="res_comments.succecc">{{ res_comments.succecc }}</p>
            
            <ul v-else class="text-left">
                <li v-for="(comment) in res_comments">
                    <strong>{{ comment.name }}</strong>: {{ comment.comment }}
                </li>
            </ul>
        </b-modal>

        <b-pagination align="center" :total-rows="count" v-model="current_page" :per-page="limit" class="mt-2" :limit="15"></b-pagination>

        <table class="table">
            <thead>
                <tr>
                    <th v-b-tooltip.hover title="Номер заявки в БД" scope="col">Номер</th>
                    <th v-b-tooltip.hover title="Автор заявки" scope="col">Автор</th>
                    <th v-b-tooltip.hover title="Дата начала отпуска" scope="col">Начало</th>
                    <th v-b-tooltip.hover title="Дата окончания отпуска" scope="col">Конец</th>
                    <th v-b-tooltip.hover title="Кол-во дней отпуска. Включает дату начала и окончания" scope="col">Дней</th>
                    <th v-b-tooltip.hover title="Тип отпуска" scope="col">Тип отпуска</th>
                    <th v-b-tooltip.hover title="Статус заявки. В процессе - администратор не принял определенного решения. Одобрена - Администратор
                        одобрил заявку. Отказ - заявка не одобрена Администратором. Отозвано пользователем - пациент передумал" scope="col">Статус</th>
                    <th v-b-tooltip.hover title="Список комментариев к заявке. Беленькая иконка означает отсутсвие комментариев" scope="col">Комментарии</th>
                    <th v-b-tooltip.hover title="Пересечение заявки с заявками владельцев схожих компетенций" scope="col">Пересечения</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in res">
                    <td>{{row.id}}</td>
                    <td>{{row.name}}</td>
                    <td>{{row.begin}}, {{ get_day_of_week(row.begin) }}</td>
                    <td>{{row.end}}, {{ get_day_of_week(row.end) }}</td>
                    <td>{{row.counts}}</td>
                    <td>{{(row.vac_type_id==1)?'За счет работодателя':(row.vac_type_id==2)?'За свой счет':'Тип отпуска не определен'}}</td>
                    <td>{{(!row.status)?'В процессе':(row.status == 1)?'Одобрена':(row.status == -1)?'Отказ':'Отозвано пользователем' }}</td>
                    <td>
                        <i class="fas fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-if="row.comments > 0"></i>
                        <i class="far fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-else></i>
                    </td>
                    <td><i class="fas fa-random" style="cursor: pointer" @click="show_cross_modal(row.id,row.user_id)"></i></td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
const axios = require('axios');

export default {
    name: 'v_admin_history',

    props: ['user_id','clname','user_token'],

    data: function(){
        return {
            res: {},
            res_cross: {},
            res_comments: {},

            limit: 8,
            current_page: 1,
            count: null
        }
    },

    mounted: function() {
        this.get_history( 'count' );
        this.get_history();
    },

    watch: {
        clname: function(){
            this.get_history( 'count' );
            this.get_history();
        },
        current_page: function(){
            this.get_history();
        },
    },

    methods: {
        show_cross_modal: function( vid,user ){
            this.axios.get( '/vm/admin/cross', { 
                    params: { userid: this.user_id, vacid: vid, clid: user },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {
                    this.res_cross = response.data;
                    this.$refs.cross_modal.show();
                }
            )
        },

        show_comment_modal: function( vid ){
            this.axios.get( '/vm/admin/comment', { 
                    params: { userid: this.user_id, vacid: vid },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {
                    this.res_comments = response.data;
                    this.$refs.comment_modal.show();
                }
            )
        },

        get_history: function( count ){
            var req = { 
                params: { userid: this.user_id, page: this.current_page, limit: this.limit }, 
                headers: {'Authorization': 'Bearer ' + this.user_token } 
            }

            if ( this.clname.length > 0 ){
                req.params.clname = this.clname;
            }

            if ( count ){
                req.params.count = 'count';
            }

            this.axios.get( '/vm/admin/history', req ).then(
                response => {
                    if ( count ){
                        this.count = +response.data.count;
                    } else {
                        this.res = response.data;
                    }
                }
            )
        },

        get_day_of_week( date ){
            var split = date.split('-')
            var dat = new Date(split[0],split[1]-1,split[2])
            return dat.toLocaleString('ru', {weekday: 'short'});
        }
    }
}
</script>