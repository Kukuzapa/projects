// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import Vuex from 'vuex'
import App from './App'
import router from './router'

import axios from 'axios'
import VueAxios from 'vue-axios'

//axios.defaults.baseURL = 'http://localhost:8087';
axios.defaults.baseURL = '';

Vue.use(VueAxios, axios);

import BootstrapVue from 'bootstrap-vue'

Vue.use(BootstrapVue);

import 'bootstrap-vue/dist/bootstrap-vue.css'

import VueBootstrapTypeahead from 'vue-bootstrap-typeahead'

import AirbnbStyleDatepicker from 'vue-airbnb-style-datepicker'
import 'vue-airbnb-style-datepicker/dist/styles.css'

Vue.use(AirbnbStyleDatepicker,{
	daysShort: ['Пн','Вт','Ср','Чт','Пт','Сб','Вс'],
	monthNames: [
		'Январь',
		'Февраль',
		'Март',
		'Апрель',
		'Май',
		'Июнь',
		'Июль',
		'Август',
		'Сентябрь',
		'Октябрь',
		'Ноябрь',
		'Декабрь',
	],
	texts: {
		apply: 'Принять',
		cancel: 'Отмена',
		//keyboardShortcuts: 'Keyboard Shortcuts',
	},
})

Vue.component('vue-bootstrap-typeahead', VueBootstrapTypeahead)

Vue.use(Vuex)

Vue.config.productionTip = false

const store = new Vuex.Store({
    state: {
      	current: {
        	token: '',
      	}
  	},
  	mutations: {
    	login (state, lgin) {
    		state.current.token = lgin.token;
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
