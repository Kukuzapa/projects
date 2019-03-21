import Vue from 'vue'
import Router from 'vue-router'
//import HelloWorld from '@/components/HelloWorld'

import login from '@/components/login'

import am from '@/components/am'

import info from '@/components/info'

import node from '@/components/node'
import n_insert from '@/components/n_insert'
import n_replace from '@/components/n_replace'
import n_info from '@/components/n_info'
import n_delete from '@/components/n_delete'
import n_access from '@/components/n_access'
import n_text from '@/components/n_text'
import n_file from '@/components/n_file'

import role from '@/components/role'
import r_info from '@/components/r_info'
import r_adduser from '@/components/r_adduser'
import r_node from '@/components/r_node'

import user from '@/components/user'
import u_info from '@/components/u_info'
import u_role from '@/components/u_role'
import u_node from '@/components/u_node'

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
			path: '/access',
			name: 'access',
			component: am,
			children: [
				{
					path: '/access/info',
					name: 'info',
					component: info
				},
				{
					path: '/access/role',
					name: 'role',
					component: role,
					children: [
						{
							path: '/access/role/info',
							name: 'r_info',
							component: r_info
						},
						/*{
							path: '/access/role/add',
							name: 'r_add',
							component: r_add
						},
						{
							path: '/access/role/remove',
							name: 'r_remove',
							component: r_remove
						},*/
						{
							path: '/access/role/node',
							name: 'r_node',
							component: r_node
						},
						/*{
							path: '/access/role/manager',
							name: 'r_manager',
							component: r_manager
						},*/
						{
							path: '/access/role/adduser',
							name: 'r_adduser',
							component: r_adduser
						},
						/*{
							path: '/access/role/remuser',
							name: 'r_remuser',
							component: r_remuser
						}*/
					]
				},
				{
					path: '/access/user',
					name: 'user',
					component: user,
					children: [
						{
							path: '/access/user/info',
							name: 'u_info',
							component: u_info
						},
						/*{
							path: '/access/user/add',
							name: 'u_add',
							component: u_add
						},
						{
							path: '/access/user/remove',
							name: 'u_remove',
							component: u_remove
						},*/
						{
							path: '/access/user/role',
							name: 'u_role',
							component: u_role
						},
						{
							path: '/access/user/node',
							name: 'u_node',
							component: u_node
						}
					]
				},
				{
					path: '/access/node',
					name: 'node',
					component: node,
					children: [
						{
							path: '/access/node/info',
							name: 'n_info',
							component: n_info
						},
						{
							path: '/access/node/insert',
							name: 'n_insert',
							component: n_insert
						},
						{
							path: '/access/node/replace',
							name: 'n_replace',
							component: n_replace
						},
						{
							path: '/access/node/access',
							name: 'n_access',
							component: n_access
						},
						//{
						//	path: '/access/node/update',
						//	name: 'n_update',
						//	component: n_update
						//}
						//,
						{
							path: '/access/node/delete',
							name: 'n_delete',
							component: n_delete
						},
						{
							path: '/access/node/text',
							name: 'n_text',
							component: n_text
						},
						{
							path: '/access/node/file',
							name: 'n_file',
							component: n_file
						}
					]
				}
			]
		}
	]
})
