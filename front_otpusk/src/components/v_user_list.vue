<template>
    <div class="col-12">
        <p>Список заявок срок которых еще не наступил либо начался сегодня. Заявку можно отменить. При наведении курсора на название
            колонки будет показана подсказка</p>

        <b-modal ref="cancel_modal" centered no-fade hide-footer hide-header>
            <form class="row">
                <div class="form-group col-12">
                    <label for="exampleFormControlTextarea1">Отзыв заявки {{test}}, введите ваш комментарий</label>
                    <textarea class="form-control" id="exampleFormControlTextarea1" rows="3" v-model="comment"></textarea>
                </div>
                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="vacation_cancel(test)">Отзыв заявки</button>
                </div>
            </form>
        </b-modal>

        <b-modal ref="comment_modal" centered no-fade hide-footer hide-header>
            <p v-if="res_comments.succecc">{{ res_comments.succecc }}</p>
            <ul v-else class="text-left">
                <li v-for="(comment) in res_comments">
                    <strong>{{ comment.name }}</strong>: {{ comment.comment }}
                </li>
            </ul>
            <form class="row">
                <div class="form-group col-12">
                    <label for="exampleFormControlTextarea1">Заявка {{test}}, введите ваш комментарий</label>
                    <textarea class="form-control" id="exampleFormControlTextarea1" rows="3" v-model="comment"></textarea>
                </div>
                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="vacation_comment(test)">Оставить комментарий</button>
                </div>
            </form>
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
                    <th class="d-none d-md-block" v-b-tooltip.hover title="Список комментариев к заявке. Можно добавить свой комментарий. Беленькая иконка означает отсутсвие комментариев"
                         scope="col">Комментарии</th>
                    <th v-b-tooltip.hover title="Отзыв заявки. Заявки примет статус 'Отозвано пользователем'" scope="col">Удалить</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in res">
                    <td class="d-none d-md-block">{{row.id}}</td>
                    <td>{{row.begin}}, {{ get_day_of_week(row.begin) }}</td>
                    <td class="d-none d-md-block">{{row.end}}, {{ get_day_of_week(row.end) }}</td>
                    <td>{{row.counts}}</td>
                    <td>{{(!row.status)?'В процессе':(row.status == 1)?'Одобрена':(row.status == -1)?'Отказ':'Отозвано пользователем' }}</td>
                    <td class="d-none d-md-block">
                        <i class="fas fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-if="row.comments > 0"></i>
                        <i class="far fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-else></i>    
                    </td>
                    <td><i class="fas fa-trash-alt" style="cursor: pointer" @click="show_cancel_modal(row.id)"></i></td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
export default {
    name: 'v_user_list',

    props: ['user_id','user_token'],

    data: function(){
        return {
            res: {},
            test: null,
            comment: '',
            res_comments: {}
        }
    },

    mounted: function(){
        this.get_list();
    },

    methods: {

        vacation_comment: function( vid ){

            if ( this.comment.length > 0 ){
                var req = { vacid: vid, comment: this.comment };

                var url = '/vm/user/comment?userid='+this.user_id;

                this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                    response => {
                        this.get_list();
                    }
                );
            }

            this.hide_comment_modal();
        },

        show_comment_modal: function( vid, refresh ){

            this.axios.get( '/vm/user/comment', { 
                    params: { userid: this.user_id, vacid: vid },
                    headers: {'Authorization': 'Bearer ' + this.user_token } 
                }).then( response => {
                    this.res_comments = response.data;
                    this.test = vid;
                    this.comment = '';
                    this.$refs.comment_modal.show();
                }
            )
        },
        
        show_cancel_modal: function( tst ) {
            this.test = tst;
            this.comment = '';
            this.$refs.cancel_modal.show();
        },

        hide_cancel_modal: function() {
            this.$refs.cancel_modal.hide();
        },

        hide_comment_modal: function() {
            this.$refs.comment_modal.hide();
        },

        vacation_cancel: function( vac ){
            var req = { vacid: vac };

            if ( this.comment.length > 0 ){
                req.comment = this.comment;
            }

            var url = '/vm/user/vacation/cancel?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.get_list();
                }
            );

            this.hide_cancel_modal();
        },

        get_list: function(){
            this.axios.get( '/vm/user/list', { params: { userid: this.user_id }, headers: {'Authorization': 'Bearer ' + this.user_token } }).then(
                response => {
                    if (response.data.err){
						this.$router.push('/');
					}

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
