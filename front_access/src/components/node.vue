<template>
    <div class="row">

        <!--div class="col-12 mb-2">
            <vue-bootstrap-typeahead 
                v-model="query"
                :data="nodes"
                size="sm"
                :serializer="s => s.node+', '+s.url"
                @hit = "select = $event"
            />
        </div-->
        
        <div class="col-4 text-left">
            <tree
                :options = "treeOpt"
                :data = "treeData"
                @node:selected="onNodeSelected"
                ref = "treeAcc"
            />
            <div id="tree"></div>
        </div>
        <div class="col-8">

            <div v-if="current_node_name" class="d-flex justify-content-between">
                
                <b-dropdown id="ddown1" text="Операции" class="md-2" 
                    :disabled="!operations.insert && !operations.replace && !operations.access && !operations.delete">
                    <b-dropdown-item @click="action('insert')" :disabled="!operations.insert">Добавить дочерний узел</b-dropdown-item>
                    <b-dropdown-item @click="action('replace')" :disabled="!operations.replace">Изменить родительский узел</b-dropdown-item>
                    <b-dropdown-item @click="action('access')" :disabled="!operations.access">Назначить права на узел</b-dropdown-item>
                    <b-dropdown-item @click="action('delete')" :disabled="!operations.delete">Удалить узел</b-dropdown-item>
                </b-dropdown>

                <div class="d-flex align-items-center mt-2">
                    <h4>{{ current_node_name }}</h4>
                </div>

                <!--b-button class="md-2" @click="action('info')" :disabled="!operations.read">Информация</b-button-->
                <b-dropdown id="ddown1" text="Информация" class="md-2" 
                    :disabled="!operations.read">
                    <b-dropdown-item @click="action('info')" :disabled="!operations.read">Общая информация</b-dropdown-item>
                    <b-dropdown-item @click="action('file')" :disabled="!operations.read">Файлы</b-dropdown-item>
                    <b-dropdown-item @click="action('text')" :disabled="!operations.read">Текст</b-dropdown-item>
                    <!--b-dropdown-item @click="action('delete')" :disabled="!operations.delete">Удалить узел</b-dropdown-item-->
                </b-dropdown>
            </div>

           
            <!--b-form-file v-model="file" :state="Boolean(file)" placeholder="Choose a file..."></b-form-file>
           
            <b-button @click="testfile" class="btn-block mt-3 btn-sm">Установить права ролей</b-button-->

            <router-view 
                :tree="tree" 
                :user_id="user_id" 
                :node_info="node_info" 
                :user_token="user_token" 
                :current_node_name="current_node_name"
                :operations="operations">
            </router-view>
        </div>
    </div>
</template>

<script>
export default {
    name: 'node',

    data: function () {
        return {
            

            current_node_name: null,
            
            node_info: null,

            tree: null,

            //currentComponent: 'node_info',
            node: null,

            query: '',
            nodes: [],
            select: {},

            
            operations: {},
            
            treeData: this.getData(),

            treeOpt: {
                parentSelect: true,
            }
        }
    },

    props: ['user_id','user_token'],

    watch: {
        current_node_name: function(){
            this.$router.push( '/access/node/info' );
        }
    },

    

    methods: {
   
        //handleFileUpload: function(){
            //this.file = this.$refs.file.files[0];
        //},

        

        getData: function(){
            return this.axios.get("/am/node/tree", { params: { id: this.user_id }, headers: { ['Authorization']: 'Bearer '+this.user_token } }).then( response => response.data );
        },

        action: function( str ){
            console.log( '/access/node/' + str )

            if ( str == 'insert' || str == 'replace' || str == 'delete' || str == 'info' || str == 'access' || str == 'text' || str == 'file' ){
                console.log( this.$refs.treeAcc )

                this.tree = this.$refs.treeAcc;

                this.$router.push( '/access/node/' + str );
            }
        },

        onNodeSelected: function( node ){
            console.log( node );

            console.log( node.data.grants )

            this.current_node_name = node.text;

            this.operations = {};
            
            this.axios.get('/am/node/get', { params: { id: this.user_id, node: node.text }, headers: { ['Authorization']: 'Bearer '+this.user_token } } ).then(response => {
                
                if (!response.data.err){
                    this.node_info = response.data;

                    console.log( this.node_info )

                    for(var i=0; i<node.data.grants.length; i++){
                        this.operations[node.data.grants[i]] = true;
                    }
                }
            });
        },
    },
}
</script>

