import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

//import result from './components/result.vue'

//Vue.use( result )

import axios    from 'axios'
import VueAxios from 'vue-axios'

axios.defaults.baseURL = 'http://84.38.3.34:8080/api/v2.1';
axios.defaults.baseURL = '/api/v2.1';

Vue.use(VueAxios, axios);

import VueBootstrapTypeahead from 'vue-bootstrap-typeahead'

// Global registration
Vue.component('vue-bootstrap-typeahead', VueBootstrapTypeahead)

import datePicker from 'vue-bootstrap-datetimepicker';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css';
Vue.use(datePicker);

//import vPagination from 'vue-plain-pagination';
//Vue.use(vPagination);

import BootstrapVue from 'bootstrap-vue'

Vue.use(BootstrapVue);

import 'bootstrap-vue/dist/bootstrap-vue.css'


Vue.config.productionTip = false

new Vue({
	router,
  	store,
  	render: function (h) { return h(App) }
}).$mount('#app')
