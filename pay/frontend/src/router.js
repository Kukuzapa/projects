import Vue from 'vue'
import Router from 'vue-router'

import pay from './components/pay'
/*import tst from './components/tst'*/

import success from './components/success'
import fail from './components/fail'


Vue.use(Router)

export default new Router({
	mode: 'history',
	base: process.env.BASE_URL,
	routes: [
		{
			path: '/',
			name: 'pay',
			component: pay
		},
		/*{
			path: '/pay',
			name: 'tst',
			component: tst
		},*/
		{
			path: '/success/:order_id',
			name: 'success',
			component: success
		},
		{
			path: '/success',
			name: 'success',
			component: success
		},
		{
			path: '/fail/:order_id',
			name: 'fail',
			component: fail
		},
		{
			path: '/fail',
			name: 'fail',
			component: fail
		},
		
		
		//{
			//path: '/recur',
			//name: 'recur',
			//component: recur
		//},
	]
})
