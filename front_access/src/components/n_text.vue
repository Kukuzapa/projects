<template>
    <div class="row">
        <div class="col-12">
            <p>Текстовые файлы</p>
            
            <div v-if="operations.update">
                <b-form-file v-model="file" :state="Boolean(file)" placeholder="Choose a file..."></b-form-file>

                <b-alert v-if="message.err" show variant="danger" class="mt-3">{{message.err}}</b-alert>
                <b-alert v-if="message.success" show variant="success" class="mt-3">{{message.success}}</b-alert>
            
                <b-button @click="testfile" class="btn-block mt-3 btn-sm">Загрузить текстовый файл</b-button>
            </div>

            <div  v-for="text in text_list" class="mt-3">
                
                <div class="d-flex justify-content-between">
                    {{ text.file_name }}
                    <a v-if="user_id==text.userid && operations.update" href="#" @click="delete_text(text.uid_file)">Удалить</a>
                    <a v-else href="#">Операция не доступна</a>
                </div>

                <b-form-textarea
                    v-model="text.tst"
                    :rows="3"
                    :max-rows="6"
                    disabled>
                </b-form-textarea>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'n_text',

    props: ['tree','user_id','user_token','current_node_name','node_info','operations'],
    
    data: function(){
        return {
            message: {},

            text_list: null,

            file: null
        }
    },
    
    created: function(){
        this.get_node_texts();
    },
    
    methods: {
        delete_text: function( str ){

            var req = { id: this.user_id, file: str, token: this.user_token };

            this.axios.post( '/am/file/remove', req, { headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(
                response => {

                    this.message = {};

                    if ( response.data.error ){
                        this.message.err = response.data.message;
                    } else {
                        this.message.success = response.data.success;

                        this.get_node_texts();
                    }
                }
            );
        },

        get_node_texts: function(){
            this.axios.get('/am/file/list', { params: { id: this.user_id, node: this.current_node_name, type: 'text' }, headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {

                this.text_list = response.data; 
            });
        },

        testfile: function(){

            if (!this.file){
                this.message = {};
                this.message.err = 'Файл не выбран';
            }

            var formData = new FormData();

            formData.append( 'file', this.file );
            formData.append( 'id', this.user_id );
            formData.append( 'type', 'text' );
            formData.append( 'token', this.user_token );
            formData.append( 'node', this.current_node_name );

            var url = '/am/file/add';

            this.axios.post( url, formData, { headers: { 'Content-Type': 'multipart/form-data', ['Authorization']: 'Bearer '+this.user_token } } ).then(
                response => {
                    this.message = {};

                    if ( response.data.error ){
                        this.message.err = response.data.message;
                    } else {
                        this.message.success = 'Файл загружен'

                        this.get_node_texts();
                    }
                }
            );
        },
    }
}
</script>