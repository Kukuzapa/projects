<template>
    <div class="col-12">
        <p>Список пользователей с возможностью назначить Администратора и поменять компетенции пользователя (для этого необходимо нажать на книжку). 
            При наведении курсора на название колонки будет показана подсказка</p>

        <b-modal ref="comp_modal" centered no-fade hide-footer hide-header>
            <div class="row">
                <div class="col-12">
                    <p>Компетенции пользователя {{name}}</p>
                </div>
                <div class="col-6">
                    <vue-bootstrap-typeahead
                        v-model="new_comp" 
                        :data="all_comp"
                        @hit = "select = $event"
                        placeholder="Введите компетенцию"
                    />
                </div>
                <div class="col-6">
                    <button type="button" class="btn btn-primary btn-block" @click="add_comp">Добавить</button>
                </div>
                <div v-for="comp in comp_list" class="col-3 mt-3">
                    <h5><span class="badge badge-secondary">{{comp}} <i style="cursor: pointer" @click="remove_comp( comp )" class="fas fa-times"></i></span></h5>
                </div>
                <div class="col-12 mt-3">
                    <button type="button" class="btn btn-primary btn-block" @click="send_comp">Обновить компетенции</button>
                </div>
            </div>
        </b-modal>


        <b-modal ref="vac_modal" no-fade hide-footer hide-header>
            <p>Таблица количества дней одобренных отпусков пользовател {{name}}</p>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Год</th>
                        <th scope="col">Тип отпуска</th>
                        <th scope="col">Количество дней</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="row in vacations">
                        <td>{{ row.year }}</td>
                        <td>{{ row.type }}</td>
                        <td>{{ row.days }}</td>
                    </tr>
                </tbody>
            </table>
        </b-modal>
        
        <table class="table table-hover">
            <thead>
                <tr>
                    <th v-b-tooltip.hover title="Имя пользователя. При нажатии открывается список компетенций с возможностью править" scope="col">Имя</th>
                    <th v-b-tooltip.hover title="Почтовый ящик пользователя." scope="col">Email</th>
                    <th v-b-tooltip.hover title="Компетенции пользователя." scope="col">Компетенции</th>
                    <th v-b-tooltip.hover title="Кол-во дней отпуска." scope="col">Кол-во дней отпуска</th>
                    <th v-b-tooltip.hover title="Признак администратора. Темная звездочка - пользователь является Администратором. 
                        При нажатии статус ставится либо снимается." scope="col">Админ</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="row in res">
                    <td>{{row.name}}</td>
                    <td>{{row.email}}</td>
                    <td class="d-flex justify-content-between">{{(!row.competense)?'Не назначены':row.competense}}
                        <i style="cursor: pointer" @click="competense_edit( row.id, row.competense, row.name )" class="fas fa-book"></i></td>
                    <td><a href="#" @click="info( row.id, row.name )">Просмотреть</a></td>
                    <td>
                        <i v-if="row.isadmin" class="fas fa-star" style="cursor: pointer" @click="admins( row.id )"></i>
                        <i v-else class="far fa-star" style="cursor: pointer" @click="admins( row.id, true )"></i>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
export default {
    name: 'v_admin_users',

    props: ['user_id','user_token','clname'],

    data: function(){
        return {
            res: {},
            competenses: null,
            name: null,
            uid: null,
            vacations: [],
            comp_list: null,
            all_comp: [],
            new_comp: null
        }
    },

    mounted: function(){
        this.get_users_new();
    },

    watch: {
        clname: function(){
            this.get_users_new();
        }
    },

    methods: {

        send_comp: function(){

            var comp = this.comp_list.join();

            var req = { competenses: comp, clid: this.uid };

            var url = '/vm/admin/user?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.competenses = response.data.success;
                    this.get_users_new();
                }
            );

            this.$refs.comp_modal.hide();
        },

        add_comp: function( comp ){
            if ( this.comp_list.indexOf( this.new_comp ) == -1 ){
                this.comp_list.push( this.new_comp );
            }
        },

        remove_comp( comp ){
            this.comp_list.splice( this.comp_list.indexOf(comp), 1 );
        },

        competense_edit: function( uid, comp, name ){

            this.name = name;

            this.uid = uid;

            this.comp_list = [];

            if (comp){
                this.comp_list = comp.split( ', ' )
            }

            this.$refs.comp_modal.show();
        },

        info: function( clid, name ){
            this.name = name;

            this.axios.get( '/vm/admin/vacations', { 
                    params: { userid: this.user_id, clid: clid, period: 'all' },
                    headers: {'Authorization': 'Bearer ' + this.user_token }
                }).then( response => {

                    this.vacations = [];

                    for (var key in response.data){
                        for (var type in response.data[key]){
                            var tmp = { year: key, type: type, days: response.data[key][type] }

                            this.vacations.push( tmp );
                        }
                    }

                    this.$refs.vac_modal.show();
                }
            )
        },

        admins: function( clid, str ){
            var req = { isadmin: str, clid: clid };

            var url = '/vm/admin/user?userid='+this.user_id;

            this.axios.post( url, req, { headers: {'Authorization': 'Bearer ' + this.user_token } } ).then(
                response => {
                    this.get_users_new();
                }
            );
        },

        get_users_new: function(){
            let req = {
                params: { userid: this.user_id }, 
                headers: {'Authorization': 'Bearer ' + this.user_token }
            }

            if ( this.clname.length > 0 ){
                req.params.clname = this.clname;
            }

            this.axios.get( '/vm/admin/users', req ).then( response => {
                    this.res = response.data.users;
                    this.all_comp = response.data.comp;
                }
            )
        },
    }
}
</script>