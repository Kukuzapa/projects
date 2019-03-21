var c_role_info = {
					template: '#role_info',
					props: ['info','node'],
				}

var c_role_remuser = {
					template: '#role_remuser',
					props: ['info','node','user'],

					data: function(){
						return {
							message: null,
							current: null,
							//list: null,
							//usr: ''
						}
					},

					mounted: function(){
						this.start();
					},

					watch: {
						node: function(){
							this.message = null;
							this.start();
						}
					},

					methods: {
						start: function(){
							this.current = [];
							//this.list = [];
							//var help = [];

							for (var i=0;i<this.info.users.length;i++){
								var tmp = { check: false, user: this.info.users[i] };
								this.current.push(tmp);
								//help.push(tmp.user);
							}

							/*axios.get('/am/base/user').then(response => {
								var resp = response.data;

								for (var i=0;i<resp.length;i++){

									for (var i=0;i<resp.length;i++){
										if (help.indexOf(resp[i].user) == -1){
											this.list.push(resp[i].user);
										}
									}

								}
							});*/
						},

						remuser: function(){

							var req = { id: this.user.toString(), role: this.node.title, user: [] };

							for (var i=0;i<this.current.length;i++){
								if(this.current[i].check){
									//req.node[this.current[i].node] = this.current[i].grnt;
									req.user.push(this.current[i].user);
								}
							}

							//console.log(req);

							axios.post('/am/role/userrem', req )
								.then(response => {
									//console.log(response);

									if ( !response.data.err ){
		 	 							this.message = response.data.success;
		 	 						} else { this.message = response.data.err }	
								});
						}
					}
				}

var c_role_adduser = {
					template: '#role_adduser',
					props: ['info','node','user'],

					data: function(){
						return {
							message: null,
							current: null,
							list: null,
							usr: ''
						}
					},

					mounted: function(){
						this.start();
					},

					watch: {
						node: function(){
							this.message = null;
							this.start();
						}
					},

					methods: {
						start: function(){
							this.current = [];
							this.list = [];
							var help = [];

							for (var i=0;i<this.info.users.length;i++){
								help.push(this.info.users[i]);
							}

							axios.get('/am/base/user').then(response => {
								var resp = response.data;

								for (var i=0;i<resp.length;i++){

									for (var i=0;i<resp.length;i++){
										if (help.indexOf(resp[i].user) == -1){
											this.list.push(resp[i].user);
										}
									}

								}
							});
						},

						adduser: function(){
							//console.log('gg');

							var req = { id: this.user.toString(), role: this.node.title, user: [] };

							for (var i=0;i<this.current.length;i++){
								if(this.current[i].check){
									//req.node[this.current[i].node] = this.current[i].grnt;
									req.user.push(this.current[i].user);
								}
							}

							//console.log(req);

							axios.post('/am/role/useradd', req )
								.then(response => {
									//console.log(response);

									if ( !response.data.err ){
		 	 							this.message = response.data.success;
		 	 						} else { this.message = response.data.err }	
								});
						},

						add_user: function(){
							var tmp = {
								user: this.usr,
								check: true,
							}
							this.current.push(tmp);
							var tmp = this.list.indexOf(this.usr);
							this.usr = '';
							this.list.splice(tmp,1);
						}
					}
				}

var c_role_manager = {
					template: '#role_manager',
					props: ['info','node','user'],

					data: function(){
						return {
							message: null,
							current: null,
							list: null,
							usr: ''
						}
					},
					mounted: function(){
						this.start();
					},

					watch: {
						node: function(){
							this.message = null;
							this.start();
						}
					},

					methods: {
						manager: function(){

							var req = { id: this.user.toString(), role: this.node.title, manager: [] };

							for (var i=0;i<this.current.length;i++){
								if(this.current[i].check){
									//req.node[this.current[i].node] = this.current[i].grnt;
									req.manager.push(this.current[i].user);
								}
							}

							//console.log(req);

							axios.post('/am/role/manager', req )
								.then(response => {
									//console.log(response);

									if ( !response.data.err ){
										//this.node.moveTo(prnt,'child');
										//this.node.remove();		
		 	 							this.message = response.data.success;
		 	 						} else { this.message = response.data.err }	
								});
						},

						add_user: function(){
							var tmp = {
								user: this.usr,
								check: true,
								//grnt: 'pass'
							}
							this.current.push(tmp);
							var tmp = this.list.indexOf(this.usr);
							this.usr = '';
							this.list.splice(tmp,1);
						},

						start: function(){
							//console.log(this.info.manager);

							this.current = [];
							this.list = [];
							var help = [];

							for (var i=0;i<this.info.manager.length;i++){
								var tmp = { check: true, user: this.info.manager[i] };
								this.current.push(tmp);
								help.push(tmp.user);
							}

							//console.log(this.current);

							axios.get('/am/base/user').then(response => {
								var resp = response.data;


								//console.log('==========================================');
								for (var i=0;i<resp.length;i++){

									for (var i=0;i<resp.length;i++){
										if (help.indexOf(resp[i].user) == -1){
											this.list.push(resp[i].user);
										}
									}

									/*if (help.indexOf(resp[i].node) == -1){
										this.list.push(resp[i].node)	
									}*/
								}
								//console.log(this.list);
							});

						}
					}
				}

var c_role_node = {
					template: '#role_node',
					props: ['info','node','user'],

					data: function(){
						return{
							list: null,
							current: null,
							nde: '',
							message: null
						}
					},

					watch: {
						node: function(){
							//this.list = null;
							//this.current = null;
							this.message = null;
							this.start();
						}
					},

					methods: {
						add_node: function(){
							var tmp = {
								node: this.nde,
								check: true,
								grnt: 'pass'
							}
							this.current.push(tmp);
							//console.log(this.list.indexOf(this.nde));
							var tmp = this.list.indexOf(this.nde);
							this.nde = '';
							this.list.splice(tmp,1);
							//console.log(this.list);
						},

						grants: function(){
							//console.log(this.current);

							var req = { id: this.user.toString(), role: this.node.title, node: {} };

							for (var i=0;i<this.current.length;i++){
								if(this.current[i].check){
									req.node[this.current[i].node] = this.current[i].grnt;
								}
							}

							//console.log(req);

							axios.post('/am/role/node', req )
								.then(response => {
									//console.log(response);

									if ( !response.data.err ){
										//this.node.moveTo(prnt,'child');
										//this.node.remove();		
		 	 							this.message = response.data.success;
		 	 						} else { this.message = response.data.err }	
								});

						},

						start: function(){

							this.current = [];
							this.list = [];
							var help = [];
							//this.list = null;

							for (var key in this.info.node){
								
								var tmp = {
									node: key,
									check: false
								}

								if (this.info.node[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.node[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.node[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.node[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.node[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.node[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.node[key].length == 1) {tmp.grnt = 'pass';}

								this.current.push(tmp);
								help.push(tmp.node);
							}

							axios.get('/am/base/node').then(response => {
								var resp = response.data;


								//console.log('==========================================');
								for (var i=0;i<resp.length;i++){


									if (help.indexOf(resp[i].node) == -1){
										this.list.push(resp[i].node)	
									}
								}
								//console.log(this.list);
							});
						}
					},

					mounted: function(){
						this.start();
					}
				}

var c_role_remove = {
					template: '#role_remove',
					props: ['user','node'],

					data: function(){
						return {
							list: null,
							message: null
						}
					},

					watch: {
						node: function(){
							//this.role = null;
							//this.manager = '';
							this.message = null;
						}
					},

					methods: {
						delete_role: function(){
							//console.log(this.user);
							//console.log(this.node.title);

							var req = { id: this.user.toString(), role: this.node.title }

							axios.post('/am/role/remove', req )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									//this.node.moveTo(prnt,'child');
									this.node.remove();		
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}

var c_role_add = {
					template: '#role_add',
					props: ['user','rootNode','node'],
					data: function(){
						return {
							role: null,
							manager: '',
							list: null,
							message: null
						}
					},

					watch: {
						node: function(){
							this.role = null;
							this.manager = '';
							this.message = null;
						}
					},
					mounted: function(){
						/*role: null;
						manager: '';
						message: null;*/
						
						axios.get('/am/base/user').then(response => {
							var resp = response.data;

							this.list = [];

							//console.log(resp);
							for (var i=0;i<resp.length;i++){
								this.list.push(resp[i].user)
							}
						});
					},
					methods: {
						add_role: function(){
							
							//console.log(this.role);
							//console.log(this.manager);
							//console.log(this.user);

							if (!this.role || this.role.toString().length ==0){
								this.message = 'Вы не ввели имя новой роли';
								return;
							}

							var req = { id: this.user.toString(), role: this.role.toString() }

							if (this.manager.length > 0) { req.manager = this.manager }

							axios.post('/am/role/add', req )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									//this.node.moveTo(prnt,'child');
									this.rootNode.addChildren({
        								title: this.role.toString()
									        //tooltip: "This folder and all child nodes were added programmatically.",
									        //folder: true
									});
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}


Vue.component('blck_role', {
					components: {
						'role_info': c_role_info,
						'role_add': c_role_add,
						'role_remove': c_role_remove,
						'role_node': c_role_node,
						'role_manager': c_role_manager,
						'role_adduser': c_role_adduser,
						'role_remuser': c_role_remuser,
						//'node_insert': c_node_insert,
						//'node_delete': c_node_delete,
						//'node_replace': c_node_replace,
						//'node_access': c_node_access,
						//'node_update': c_node_update
					},
					template: '#blck_role',
					props: ['info','user'],

					data: function(){
						return {
							admin: false,
							show_btn: false,
							role_info: null,
							currentComponent: 'role_info',
							rootNode: null,
							node: null
						}
					},

					watch:{
						user: function(){
							//this.get_role();
							this.show_btn = false;
							this.currentComponent = 'role_info';
						}
					},

					mounted: function(){
						//console.log('mount');
						this.get_role();
					},

					methods: {
						f_current_component: function(str){
							this.currentComponent = 'role_'+str;
						},
						get_role: function(){

			     			if ( $('#roles').fancytree() ){
				     			$('#roles').fancytree('destroy');
				     		}

				     		this.role_info = null;

				     		axios.get('/am/base/role').then(response => {

				     			var data = [];

				     			if (this.info.roles[0] && this.info.roles.indexOf('admins') != -1){
				     				for (var i=0;i<response.data.length;i++){
				     					var tmp = {};
				     					tmp.title = response.data[i].role;
				     					tmp.key = response.data[i].id;
				     					data.push(tmp);
				     				}
				     				this.admin = true;
				     			} else {
				     				for (var i=0;i<response.data.length;i++){
				     					if (this.info.manager[0] && this.info.manager.indexOf(response.data[i].role) != -1){
					     					var tmp = {};
					     					tmp.title = response.data[i].role;
					     					tmp.key = response.data[i].id;
					     					data.push(tmp);
					     				}
				     				}
				     				this.admin = false;
				     			}

				     			$('#roles').fancytree({
				     				source: data,
				     				activate: (event,data) => {

				     					this.show_btn = true;
				     					this.currentComponent = 'role_info';

				     					axios.get('/am/role/get', { params: { id: this.user, role: data.node.title } } ).then(response => {
				      						this.role_info = response.data;

				      						this.rootNode = $("#roles").fancytree("getRootNode");
				      						this.node = $("#roles").fancytree("getActiveNode");
			      						});
				     				}
				     			});
				     		});
						}
					}
				});		