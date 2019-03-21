<template>
    <div class="col-12">
        <p>Список заявок решение по которым еще не принято. При наведении курсора на название колонки будет показана подсказка</p>

        <b-modal ref="comment_modal" centered no-fade hide-footer hide-header>
            <p v-if="res_comments.succecc">{{ res_comments.succecc }}</p>
            
            <ul v-else class="text-left">
                <li v-for="(comment) in res_comments">
                    <strong>{{ comment.name }}</strong>: {{ comment.comment }}
                </li>
            </ul>
        </b-modal>

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

        <b-modal ref="decision_modal" centered no-fade hide-footer hide-header>
            <h4>Заявка № {{vacid}} пользователя {{name}}</h4>

            <p>Кол-во одобренных заявок пользователя за текущий период</p>

            <table class="table">
                <thead>
                    <tr>
                        <th scope="col">Тип отпуска</th>
                        <th scope="col">Кол-во дней</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(days,type) in vacations">
                        <td class="text-left">{{type}}</td>
                        <td>{{days}}</td>
                    </tr>
                </tbody>
            </table>
            
            <form class="row">
                
                <div class="form-group col-12">
                    <label for="exampleFormControlTextarea1">Решайте и комментируйте</label>
                    <textarea class="form-control" id="exampleFormControlTextarea1" rows="3" v-model="comment"></textarea>
                </div>

                <div class="col-6">
                    <button type="button" class="btn btn-primary btn-block" @click="vacation_accept(vacid)">Подвердить</button>
                </div>

                <div class="col-6">
                    <button type="button" class="btn btn-primary btn-block" @click="vacation_reject(vacid)">Отказать</button>
                </div>

            </form>
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
                    <th v-b-tooltip.hover title="Список комментариев к заявке. Беленькая иконка означает отсутсвие комментариев"
                        scope="col">Комментарии</th>
                    <th v-b-tooltip.hover title="Пересечение заявки с заявками владельцев схожих компетенций" scope="col">Пересечения</th>
                    <th v-b-tooltip.hover title="Отказ либо подтверждение заявки" scope="col">Решение</th>
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
                    <td>
                        <i class="fas fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-if="row.comments > 0"></i>
                        <i class="far fa-comment-alt" style="cursor: pointer" @click="show_comment_modal(row.id)" v-else></i>
                    </td>
                    <td><i class="fas fa-random" style="cursor: pointer" @click="show_cross_modal(row.id,row.user)"></i></td>
                    <td><i class="fas fa-pen-alt" style="cursor: pointer" @click="show_decision_modal(row.id,row.name,row.user)"></i></td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
export default {
    name: 'v_admin_new',

    props: ['user_id','clname','user_token'],

    data: function(){
        return {
            res: {},
            res_comments: {},
            res_cross: {},
            vacid: null,
            name: null,
            comment: '',
            vacations: {},

            limit: 8,
            current_page: 1,
            count: null
        }
    },

    mounted: function(){
        this.get_new('count');
        this.get_new();
    },

    watch: {
        clname: function(){
            this.get_new('count');
            this.get_new();
        },
        current_page: function(){
            this.get_new();
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

        vacation_reject: function(){
            var req = { vacid: this.vacid, name: this.name };
            
            if ( this.comment.length > 0 ){
                req.comment = this.comment;
            }

            var url = '/vm/admin/vacation/reject?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.get_new();
                }
            );

            this.$refs.decision_modal.hide();
        },

        show_decision_modal: function( vid, name, clid ) {

            let date = new Date;

            this.axios.get( '/vm/admin/vacations', { 
                    params: { userid: this.user_id, clid: clid, period: date.getFullYear() },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {
                    this.vacations = response.data
                    this.vacid = vid;
                    this.name = name;
                    this.comment = '';
                    this.$refs.decision_modal.show();
                }
            )
        },

        vacation_accept: function(){

            var req = { vacid: this.vacid, name: this.name };
            
            if ( this.comment.length > 0 ){
                req.comment = this.comment;
            }

            var url = '/vm/admin/vacation/accept?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.get_new();
                }
            );

            this.$refs.decision_modal.hide();
        },

        show_comment_modal: function( vid ){
            this.axios.get( '/vm/admin/comment', { 
                    params: { userid: this.user_id, vacid: vid, token: this.user_token },
                    headers: {'Authorization': 'Bearer ' + this.user_token } 
                }).then( response => {
                    this.res_comments = response.data;
                    this.$refs.comment_modal.show();
                }
            )
        },
        
        get_new: function( count ){
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

            this.axios.get( '/vm/admin/new', req ).then(
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
