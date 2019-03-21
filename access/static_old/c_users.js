var c_user_info = {
					template: '#user_info',
					props: ['info','node'],
				}

var c_user_node = {
					template: '#user_node',
					props: ['info','node','user'],

					data: function(){
						return {
							list: null,
							message: null,
							current: null,
							nde: '',
						}
					},

					watch: {
						node: function(){
							this.current = null;
							this.message = null;
							this.start();
						}
					},

					mounted: function(){
						this.start();
					},

					methods: {
						start: function(){
							this.current = [];
							this.list = [];
							var help = [];

							for (var key in this.info.grants){
								
								var tmp = {
									node: key,
									check: false
								}

								if (this.info.grants[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.grants[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.grants[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.grants[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.grants[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.grants[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.grants[key].length == 1) {tmp.grnt = 'pass';}

								this.current.push(tmp);
								help.push(tmp.node);
							}

							//console.log(this.current);

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

						},

						add_node:function(){
							//console.log('add_node');
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
						},

						grants:function(){
							//console.log('grants');

							var req = { id: this.user.toString(), name: this.node.title, node: {} };

							for (var i=0;i<this.current.length;i++){
								if(this.current[i].check){
									req.node[this.current[i].node] = this.current[i].grnt;
								}
							}

							//console.log(req);

							axios.post('/am/user/node', req )
								.then(response => {
									//console.log(response);

									if ( !response.data.err ){
										//this.node.moveTo(prnt,'child');
										//this.node.remove();		
		 	 							this.message = response.data.success;
		 	 						} else { this.message = response.data.err }	
								});
						}
					}
				}

var c_user_role = {
					template: '#user_role',
					props: ['info','node','user'],

					data: function(){
						return {
							current: null,
							message: null,
							list: null,
							role: '',
						}
					},

					mounted: function(){
						this.start();
					},

					watch: {
						node: function(){
							this.current = null;
							this.message = null;
							this.start();
						}
					},

					methods: {
						start: function(){
							//console.log(this.node.title);

							var help = [];
							this.current = [];
							this.list = [];

							for (var i=0;i<this.info.roles.length;i++){
								var tmp = { check: true, role: this.info.roles[i] };
								help.push(this.info.roles[i]);
								this.current.push(tmp);
							}

							//console.log( this.current );
							//console.log( help );

							axios.get('/am/base/role').then(response => {
								var resp = response.data;
								//console.log('==========================================');
								for (var i=0;i<resp.length;i++){

									for (var i=0;i<resp.length;i++){
										if (help.indexOf(resp[i].role) == -1){
											this.list.push(resp[i].role);
										}
									}
								}
								//console.log(this.list);
							});
						},

						change: function(){
							//console.log( 'Hello' )
							var tmp = {
								role: this.role,
								check: true,
								//grnt: 'pass'
							}
							this.current.push(tmp);
							var tmp = this.list.indexOf(this.role);
							this.role = '';
							this.list.splice(tmp,1);
						},

						finish: function(){
							var req = { id: this.user.toString(), name: this.node.title.toString(), role: [] };

							for (var i=0;i<this.current.length;i++){
								if (this.current[i].check == true){
									req.role.push( this.current[i].role );
								}
							}

							//console.log( req );

							axios.post('/am/user/role', req )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									//this.node.remove();	
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						},
					}
				}

var c_user_remove = {
					template: '#user_remove',
					props: ['info','node','user'],

					data: function(){
						return {
							message: null
						}
					},

					watch: {
						node: function(){
							this.message = null;
						}
					},

					methods: {
						delete_user: function(){
							//console.log( this.node.title );

							var req = { id: this.user.toString(), name: [ this.node.title.toString() ] }

							axios.post('/am/user/remove', req )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									this.node.remove();	
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}

var c_user_add = {
					template: '#user_add',
					props: ['user','node','rootNode'],

					data: function(){
						return {
							user_name: null,
							message: null,
						}
					},

					watch: {
						node: function(){
							this.user_name = null;
							this.message = null;
						}
					},

					methods: {
						add_user: function(){
							//console.log( this.user_name );

							if (!this.user_name || this.user_name.toString().length ==0){
								this.message = 'Вы не ввели имя новой роли';
								return;
							}

							var req = { id: this.user.toString(), name: this.user_name.toString() }

							axios.post('/am/user/add', req )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									this.rootNode.addChildren({
        								title: this.user_name.toString()
									});
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}

Vue.component('blck_user', {
					components: {
						'user_info': c_user_info,
						'user_add': c_user_add,
						'user_remove': c_user_remove,
						'user_role': c_user_role,
						'user_node': c_user_node,
					},
					template: '#blck_user',
					props: ['info','user'],

					data: function(){
						return {
							admin: false,
							show_btn: false,
							user_info: null,
							currentComponent: 'user_info',
							rootNode: null,
							node: null
						}
					},

					watch:{
						user: function(){
							//this.get_role();
							this.show_btn = false;
							this.currentComponent = 'user_info';
						}
					},

					mounted: function(){
						//console.log('mount user');
						this.get_user();
					},

					methods: {
						f_current_component: function(str){
							this.currentComponent = 'user_'+str;
						},
						get_user: function(){

			     			if ( $('#users').fancytree() ){
				     			$('#users').fancytree('destroy');
				     		}

				     		this.user_info = null;

				     		axios.get('/am/base/user').then(response => {

				     			var data = [];

				     			//if (this.info.roles[0] && this.info.roles.indexOf('admins') != -1){
				     				for (var i=0;i<response.data.length;i++){
				     					var tmp = {};
				     					tmp.title = response.data[i].user;
				     					tmp.key = response.data[i].id;
				     					data.push(tmp);
				     				}
				     				//this.admin = true;
				     			//} else {
				     			/*	for (var i=0;i<response.data.length;i++){
				     					if (this.info.manager[0] && this.info.manager.indexOf(response.data[i].role) != -1){
					     					var tmp = {};
					     					tmp.title = response.data[i].role;
					     					tmp.key = response.data[i].id;
					     					data.push(tmp);
					     				}
				     				}
				     				this.admin = false;
				     			}*/

				     			$('#users').fancytree({
				     				source: data,
				     				activate: (event,data) => {
				     					//console.log(data.node.title);

				     					this.show_btn = true;
				     					this.currentComponent = 'user_info';

				     					axios.get('/am/user/get', { params: { id: this.user, user: data.node.title } } ).then(response => {
				      						this.user_info = response.data;
				      						this.rootNode = $("#users").fancytree("getRootNode");
				      						this.node = $("#users").fancytree("getActiveNode");
			      						});
				     				}
				     			});

				     			//console.log(data);
				     			//console.log(this.admin);
				     		});
						}
					}
				});		