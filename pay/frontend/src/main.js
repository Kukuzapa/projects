import 'es6-promise/auto'

import Vue    from 'vue'
import App    from './App.vue'
import router from './router'
import store  from './store'

import axios    from 'axios'
import VueAxios from 'vue-axios'

axios.defaults.baseURL = 'http://localhost:8089';
axios.defaults.baseURL = '';

Vue.use(VueAxios, axios);

Vue.config.productionTip = false

new Vue({
	router,
	store,
	render: function (h) { return h(App) }
}).$mount('#app')
