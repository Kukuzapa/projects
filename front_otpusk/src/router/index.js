import Vue from 'vue'
import Router from 'vue-router'

import HelloWorld from '@/components/HelloWorld'

import login from '@/components/login'

import vacation from '@/components/vacation'

import v_user from '@/components/v_user'
import v_user_new from '@/components/v_user_new'
import v_user_list from '@/components/v_user_list'
import v_user_history from '@/components/v_user_history'

import v_admin from '@/components/v_admin'
import v_admin_new from '@/components/v_admin_new'
import v_admin_list from '@/components/v_admin_list'
import v_admin_history from '@/components/v_admin_history'
import v_admin_users from '@/components/v_admin_users'
import v_admin_log from '@/components/v_admin_log'

Vue.use(Router)

export default new Router({
	mode: 'history',
	routes: [
		{
	  		path: '/',
	  		name: 'login',
	  		component: login
		},
		{
			path: '/vacation/link/:userid/:vacid',
			name: 'HelloWorld',
			component: HelloWorld
		},
		{
			path: '/vacation',
			name: 'vacation',
			component: vacation,
			redirect: '/vacation/user/new',
			children: [
				{
					path: '/vacation/user',
					name: 'v_user',
					component: v_user,
					redirect: '/vacation/user/new',
					children: [
						{
							path: '/vacation/user/new',
							name: 'v_user_new',
							component: v_user_new
						},
						{
							path: '/vacation/user/list',
							name: 'v_user_list',
							component: v_user_list
						},
						{
							path: '/vacation/user/history',
							name: 'v_user_history',
							component: v_user_history
						}
					]
				},
				{
					path: '/vacation/admin',
					name: 'v_admin',
					component: v_admin,
					redirect: '/vacation/admin/new',
					children: [
						{
							path: '/vacation/admin/new',
							name: 'v_admin_new',
							component: v_admin_new
						},
						{
							path: '/vacation/admin/list',
							name: 'v_admin_list',
							component: v_admin_list
						},
						{
							path: '/vacation/admin/history',
							name: 'v_admin_history',
							component: v_admin_history
						},
						{
							path: '/vacation/admin/users',
							name: 'v_admin_users',
							component: v_admin_users
						},
						{
							path: '/vacation/admin/log',
							name: 'v_admin_log',
							component: v_admin_log
						}
					]
				},
			]
		}
  	]
})
