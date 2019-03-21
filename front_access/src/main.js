// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import Vuex from 'vuex'
import App from './App'
import router from './router'

import BootstrapVue from 'bootstrap-vue'
Vue.use(BootstrapVue);
import 'bootstrap-vue/dist/bootstrap-vue.css'

import axios from 'axios'
import VueAxios from 'vue-axios'

//axios.defaults.baseURL = 'http://localhost:8084';
axios.defaults.baseURL = '';
//if (this.$store){
//    axios.defaults.headers.common = {['Authorization'] : 'Bearer '+this.$store.state.current.token}
//}

import LiquorTree from 'liquor-tree'
Vue.use(LiquorTree)

Vue.use(VueAxios, axios);
Vue.use(Vuex)

import vSelect from 'vue-select'
Vue.component('v-select', vSelect)

Vue.config.productionTip = false

const store = new Vuex.Store({
    state: {
        current: {
			  token: '',
			  id: '',
              user: '',
              email: ''
        }
    },
    mutations: {
      	login (state, lgin) {
			state.current.token = lgin.token;
			state.current.id = lgin.id;
            state.current.user = lgin.user;
            state.current.email = lgin.email;
        }
    }
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>'
})
