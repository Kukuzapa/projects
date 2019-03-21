<template>
    <div class="row">
        <div class="col-12">
            <p>Файлы</p>

            <div v-if="operations.update">
                <b-form-file v-model="file" :state="Boolean(file)" placeholder="Choose a file..."></b-form-file>

                <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
                <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
            
                <b-button @click="testfile" class="btn-block mt-3 btn-sm">Загрузить файл</b-button>
            </div>

            <table v-if="file_list.length>0" class="table table-hover">
                <thead>
                    <tr>
                        <th scope="col">Имя файла</th>
                        <th scope="col">Ссылка на скачивание</th>
                        <th scope="col">Открыть в новом окне</th>
                        <th scope="col">Удалить(для владельца)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="file in file_list">
                        <td>{{file.file_name}}</td>
                        <td><a :href="file.file_link+'?force_download'" target="_blank">Скачать</a></td>
                        <td><a :href="file.file_link" target="_blank">Открыть</a></td>
                        <td>
                            <a v-if="user_id==file.userid && operations.update" href="#" @click="delete_file(file.uid_file)">Удалить</a>
                            <a v-else href="#">Операция не доступна</a>
                        </td>
                    </tr>
                </tbody>
            </table>
            <p v-else class="mt-3">Нет загруженных файлов</p>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_file',

    props: ['tree','user_id','user_token','current_node_name','node_info','operations'],
    
    data: function(){
        return {
            message: {},

            file_list: {},

            file: null
        }
    },
    
    created: function(){
        this.get_node_files();
    },
    
    methods: {

        delete_file: function( str ){
            var req = { id: this.user_id, file: str, token: this.user_token };

            this.axios.post( '/am/file/remove', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(
                response => {
                    this.message = {};

                    if ( response.data.error ){
                        this.message.err = response.data.message;
                    } else {
                        this.message.success = response.data.success;
                        this.get_node_files();
                    }
                }
            );
        },

        get_node_files: function(){
            this.axios.get('/am/file/list', { params: { id: this.user_id, node: this.current_node_name, type: 'file' }, headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {
                this.file_list = response.data; 
            });
        },

        testfile: function(){
            if (!this.file){
                this.message = {};
                this.message.err = 'Файл не выбран';
                return;
            }

            var formData = new FormData();

            formData.append( 'file', this.file );
            formData.append( 'id', this.user_id );
            formData.append( 'type', 'file' );
            formData.append( 'token', this.user_token );
            formData.append( 'node', this.current_node_name );

            var url = '/am/file/add';

            //headers: { ['Authorization']: 'Bearer '+this.user_token }
            
            this.axios.post( url, formData, { headers: { 'Content-Type': 'multipart/form-data', ['Authorization']: 'Bearer '+this.user_token } } ).then(
                response => {
                    this.message = {};

                    if ( response.data.error ){
                        this.message.err = response.data.message;
                    } else {
                        this.message.success = 'Файл загружен'

                        this.get_node_files();
                    }
                }
            );
        },
    }
}
</script>