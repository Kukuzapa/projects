<template>
    <form class="col-12">
        <p>Создание заявки. При наведении курсора на кнопку будет показана подсказка</p>
        <div class="row">
            
            <div class="form-group col-12">
                <label for="datepicker-trigger">Выбор даты начала и окончания отпуска</label>
                <div class="datepicker-trigger">
                    <input
                        type="text"
                        id="datepicker-trigger"
                        placeholder="Выберите даты"
                        class="form-control col-12"
                        :value="get_period( b_date_2, e_date_2 )"
                    >

                    <AirbnbStyleDatepicker
                        :trigger-element-id="'datepicker-trigger'"
                        :mode="'range'"
                        :fullscreen-mobile="true"
                        :dateOne="b_date_2"
                        :dateTwo="e_date_2"
                        @date-one-selected="val => { b_date_2 = val }"
                        @date-two-selected="val => { e_date_2 = val }"
                        @apply = "vacation_check"
                    />
                </div>
            </div>

            <div class="form-group col-12">
                <label for="exampleFormControlTextarea1">Оставьте комментарий, если необходимо</label>
                <textarea class="form-control" id="exampleFormControlTextarea1" rows="3" v-model="comment"></textarea>
            </div>

            <div class="form-check col-12 col-sm-6 mb-3">
                <input class="form-check-input" type="radio" name="exampleRadios" id="exampleRadios1" value="org" v-model="vac_type" checked>
                <label class="form-check-label" for="exampleRadios1">
                    За счет организации
                </label>
            </div>

            <div class="form-check col-12 col-sm-6 mb-3">
                <input class="form-check-input" type="radio" name="exampleRadios" id="exampleRadios2" value="cli" v-model="vac_type">
                <label class="form-check-label" for="exampleRadios2">
                    За свой счет
                </label>
            </div>

            

            <div class="form-group col-12 d-none d-md-block" v-if="res.alert">
                <div class="alert alert-warning" role="alert">
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
                            <tr v-for="(row,key) in res.alert">
                                <td>{{ row.id }}</td>
                                <td>{{ row.name }}</td>
                                <td>{{ row.begin }}, {{ get_day_of_week(row.begin) }}</td>
                                <td>{{ row.end }}, {{ get_day_of_week(row.end) }}</td>
                                <td>{{ row.competense }}</td>
                                <td>{{ (!row.status)?'В процессе':(row.status == 1)?'Одобрена':'Отказ' }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-12 d-block d-md-none">
                <p v-for="(row,key) in res.alert" class="alert alert-warning">
                    <strong>Номер</strong> {{ row.id }}, <strong>Автор</strong> {{ row.name }}, <strong>Начало</strong> {{ row.name }},
                    <strong>Конец</strong> {{ row.name }}, <strong>Компетенции</strong> {{ row.name }}, <strong>Статус</strong> {{ row.name }}
                </p>
            </div>

            <div class="form-group col-12" v-if="res.succecc">
                <div class="alert alert-success" role="alert">
                    {{res.succecc}}
                </div>
            </div>

            <div class="form-group col-12" v-if="res.err">
                <div class="alert alert-danger" role="alert">
                    {{res.err}}
                </div>
            </div>

            <!--div class="col-6" v-b-tooltip.hover title="Проверка заявки на возможные пересечения с владельцами схожих компетенций">
                <button type="button" class="btn btn-primary btn-block" @click="vacation_check">Проверка заявки</button>
            </div-->

            <div class="col-12 mb-3" v-b-tooltip.hover title="Отправка заявки на рассмотрение администратору">
                <button type="button" class="btn btn-primary btn-block" @click="vacation_send">Отправить заявку</button>
            </div>
        </div>
    </form>
</template>

<script>
export default {
    name: 'v_user_new',

    props: ['user_id','user_token'],

    data: function(){
        return {
            b_date_2: '',
            e_date_2: '',
           
            res: {},
            comment: '',

            vac_type: 'org'
        }
    },

    watch: {
        b_date: function(){
            this.e_options.minDate = this.b_date;
        }
    },

    methods: {
        get_period: function( date1, date2 ){
            var period = ''

            if ( date1 ){
                period = period + date1+', '+this.get_day_of_week( date1 );
            }

            if ( date2 ){
                period = period + ' - ' + date2+', '+this.get_day_of_week( date2 );
            }

            return period;
        },

        get_day_of_week( date ){
            var split = date.split('-')
            var dat = new Date(split[0],split[1]-1,split[2])
            return dat.toLocaleString('ru', {weekday: 'short'});
        },

        vacation_check: function(){
            if ( this.b_date_2.length == 0 || this.e_date_2.length == 0 ){
                this.res = { err: 'Не указана дата начала/окончания отпуска' };
                return;
            }

            var req = { userid: this.user_id, begin_date: this.b_date_2, end_date: this.e_date_2 };

            var url = '/vm/user/vacation/check?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.res = response.data;
                }
            );
        },

        vacation_send: function(){
            if ( this.b_date_2.length == 0 || this.e_date_2.length == 0 ){
                this.res = { err: 'Не указана дата начала/окончания отпуска' };
                return;
            }

            var req = { begin_date: this.b_date_2, end_date: this.e_date_2, type: this.vac_type };
            
            if ( this.comment.length > 0 ){
                req.comment = this.comment;
            }

            var url = '/vm/user/vacation/send?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.res = response.data;
                }
            );
        }
    }
}
</script>
