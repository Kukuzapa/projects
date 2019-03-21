<template>
    <div class="col-12">
        <p>Список заявок дата начала которых меньше сегодняшнего дня либо заявок отозванных пользователем. Помните, что Администратор может внезапно отменить любую из них. Будьте
            бдительны. При наведении курсора на название колонки будет показана подсказка</p>

        <b-modal ref="comment_modal" centered no-fade hide-footer hide-header>
            <p v-if="res_comments.succecc">{{ res_comments.succecc }}</p>
            
            <ul v-else class="text-left">
                <li v-for="(comment) in res_comments">
                    <strong>{{ comment.name }}</strong>: {{ comment.comment }}
                </li>
            </ul>
        </b-modal>

        <table class="table">
            <thead>
                <tr>
                    <th class="d-none d-md-block" v-b-tooltip.hover title="Номер заявки в БД" scope="col">Номер</th>
                    <th v-b-tooltip.hover title="Дата начала отпуска" scope="col">Начало</th>
                    <th class="d-none d-md-block" v-b-tooltip.hover title="Дата окончания отпуска" scope="col">Конец</th>
                    <th v-b-tooltip.hover title="Кол-во дней отпуска. Включает дату начала и окончания" scope="col">Дней</th>
                    <th v-b-tooltip.hover title="Статус заявки. В процессе - администратор не принял определенного решения. Одобрена - Администратор
                        одобрил заявку. Отказ - заявка не одобрена Администратором. Отозвано пользователем - пациент передумал" scope="col">Статус</th>
                    <th v-b-tooltip.hover title="Список комментариев к заявке. Можно добавить свой комментарий. Беленькая иконка означает отсутсвие комментариев"
                        scope="col">Комментарии</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in res">
                    <td class="d-none d-md-block">{{row.id}}</td>
                    <td>{{row.begin}}, {{ get_day_of_week(row.begin) }}</td>
                    <td class="d-none d-md-block">{{row.end}}, {{ get_day_of_week(row.end) }}</td>
                    <td>{{row.counts}}</td>
                    <td>{{(!row.status)?'В процессе':(row.status == 1)?'Одобрена':(row.status == -1)?'Отказ':'Отозвано пользователем' }}</td>
                    <td>
                        <i class="fas fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-if="row.comments > 0"></i>
                        <i class="far fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-else></i>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
//const axios = require('axios');

export default {
    name: 'v_user_history',

    props: ['user_id','user_token'],

    data: function(){
        return {
            res: {},
            res_comments: {},
            test: null
        }
    },

    mounted: function(){
        this.get_history();
    },

    methods: {

        show_comment_modal: function( vid ){

            this.axios.get( '/vm/user/comment', { 
                    params: { userid: this.user_id, vacid: vid },
                    headers: {'Authorization': 'Bearer ' + this.user_token } 
                }).then( response => {
                    //if (response.data.err){
					//	this.$router.push('/');
					//}

                    this.res_comments = response.data;
                    this.test = vid;
                    this.$refs.comment_modal.show();
                }
            )
        },

        get_history: function(){
            this.axios.get( '/vm/user/history', { 
                    params: { userid: this.user_id },
                    headers: {'Authorization': 'Bearer ' + this.user_token } 
                }).then( response => {
                    //if (response.data.err){
					//	this.$router.push('/');
					//}

                    this.res = response.data;
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
