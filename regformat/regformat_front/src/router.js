import Vue from 'vue'
import Router from 'vue-router'

import regformat from './components/regformat.vue'

import domain from './components/domain.vue'

import domain_get    from './components/domain/get.vue'
import domain_check  from './components/domain/check.vue'
import domain_create from './components/domain/create.vue'
import domain_update from './components/domain/update.vue'
import domain_delete from './components/domain/delete.vue'
import domain_renew  from './components/domain/renew.vue'
import domain_transfer  from './components/domain/transfer.vue'
import domain_copy  from './components/domain/copy.vue'
import domain_list  from './components/domain/list.vue'

import contact from './components/contact.vue'

import contact_get    from './components/contact/get.vue'
import contact_check    from './components/contact/check.vue'
import contact_create    from './components/contact/create.vue'
import contact_update    from './components/contact/update.vue'
import contact_delete    from './components/contact/delete.vue'
import contact_copy    from './components/contact/copy.vue'

import registrar from './components/registrar.vue'

import registrar_get from './components/registrar/get.vue'
import registrar_limits from './components/registrar/limits.vue'
import registrar_billing from './components/registrar/billing.vue'
import registrar_update from './components/registrar/update.vue'
import registrar_poll from './components/registrar/poll.vue'

import operation from './components/operation.vue'

import getdata from './components/getdata.vue'

import DomainDistrib from './components/getdata/DomainDistrib.vue'
import DelList from './components/getdata/DelList.vue'
import DelReport from './components/getdata/DelReport.vue'
//DelReport

Vue.use(Router)

export default new Router({
  	mode: 'history',
  	base: process.env.BASE_URL,
  	routes: [
		{
			path: '/',
			name: 'regformat',
			component: regformat,
			children: [
				{
					path: '/domain',
					name: 'domain',
					component: domain,
					children: [
						{
							path: '/domain/get',
							name: 'domain_get',
							component: domain_get
						},
						{
							path: '/domain/check',
							name: 'domain_check',
							component: domain_check
						},
						{
							path: '/domain/create',
							name: 'domain_create',
							component: domain_create
						},
						{
							path: '/domain/update',
							name: 'domain_update',
							component: domain_update
						},
						{
							path: '/domain/delete',
							name: 'domain_delete',
							component: domain_delete
						},
						{
							path: '/domain/renew',
							name: 'domain_renew',
							component: domain_renew
						},
						{
							path: '/domain/transfer',
							name: 'domain_transfer',
							component: domain_transfer
						},
						{
							path: '/domain/copy',
							name: 'domain_copy',
							component: domain_copy
						},
						{
							path: '/domain/list',
							name: 'domain_list',
							component: domain_list
						},
					]
				},
				{
					path: '/contact',
					name: 'contact',
					component: contact,
					children: [
						{
							path: '/contact/get',
							name: 'contact_get',
							component: contact_get
						},
						{
							path: '/contact/check',
							name: 'contact_check',
							component: contact_check
						},
						{
							path: '/contact/create',
							name: 'contact_create',
							component: contact_create
						},
						{
							path: '/contact/update',
							name: 'contact_update',
							component: contact_update
						},
						{
							path: '/contact/delete',
							name: 'contact_delete',
							component: contact_delete
						},
						{
							path: '/contact/copy',
							name: 'contact_copy',
							component: contact_copy
						},
					]
				},
				{
					path: '/registrar',
					name: 'registrar',
					component: registrar,
					children: [
						{
							path: '/registrar/get',
							name: 'registrar_get',
							component: registrar_get
						},
						{
							path: '/registrar/limits',
							name: 'registrar_limits',
							component: registrar_limits
						},
						{
							path: '/registrar/billing',
							name: 'registrar_billing',
							component: registrar_billing
						},
						{
							path: '/registrar/update',
							name: 'registrar_update',
							component: registrar_update
						},
						{
							path: '/registrar/poll',
							name: 'registrar_poll',
							component: registrar_poll
						},
					]
				},
				{
					path: '/operation',
					name: 'operation',
					component: operation
				},
				{
					path: '/getdata',
					name: 'getdata',
					component: getdata,
					children: [
						{
							path: '/getdata/DomainDistrib',
							name: 'DomainDistrib',
							component: DomainDistrib
						},
						{
							path: '/getdata/DelList',
							name: 'DelList',
							component: DelList
						},
						{
							path: '/getdata/DelReport',
							name: 'DelReport',
							component: DelReport
						},
					]
				},
			]
		},
		
  	]
})
