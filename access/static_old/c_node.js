var c_node_update = {
					template: '#node_update',
					props: ['info','tree','node','user'],
					data: function(){
						return {
							comment: this.info.info.comment,
							password: this.info.info.password,
							email: this.info.info.email,
							url: this.info.info.url,
							files: this.info.info.files,
							message: null
						}
					},
					watch: {
						info: function(){
							this.comment = this.info.info.comment;
							this.password = this.info.info.password;
							this.email = this.info.info.email;
							this.url = this.info.info.url;
							this.files = this.info.info.files;
							this.message = null;
						}
						
					},
					methods: {
						update: function(){
							var tmp = ['comment','password','email','url','files'];

							var req = {
								id: this.user.toString(),
								node: this.node.title,
							}

							for (var i=0;i<tmp.length;i++){
								if (this[tmp[i]] && this[tmp[i]].length > 0){
									req[tmp[i]] = this[tmp[i]]
								}
							}

							axios.post('/am/node/update', req ).then(response => {
								if ( !response.data.err ){
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}

var c_node_info = {
					template: '#node_info',
					props: ['info','tree','node'],
					data: function(){
						return {
							comment: this.info.info.comment,
							password: this.info.info.password,
							email: this.info.info.email,
							url: this.info.info.url,
							files: this.info.info.files
						}
					},
					watch: {
						info: function(){
							this.comment = this.info.info.comment;
							this.password = this.info.info.password;
							this.email = this.info.info.email;
							this.url = this.info.info.url;
							this.files = this.info.info.files;
						}
					}
				}

var c_node_access = {
					template: '#node_access',
					props: ['info','tree','node','user'],

					data: function(){
						return {
							show_u: true,
							show_r: false,
							u_list: null,
							r_list: null,
							a_u_lst: null,
							a_r_lst: null,
							rls: '',
							usr: '',
							msg_u: null,
							msg_r: null
						}
					},

					watch: {
						node: function(){
							this.u_list = [];
							this.a_u_lst = [];

							this.r_list = [];
							this.a_r_lst = [];

							var help_u = [];
							var help_r = [];

							for ( var key in this.info.users ){
								var tmp = {
									user: key,
									check: false
								}

								if (this.info.users[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.users[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.users[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.users[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.users[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.users[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.users[key].length == 1) {tmp.grnt = 'pass';}

								this.u_list.push(tmp);
								help_u.push(tmp.user);
							}

							axios.get('/am/base/user').then(response => {
								var resp = response.data

								for (var i=0;i<resp.length;i++){
									if (help_u.indexOf(resp[i].user) == -1){
										this.a_u_lst.push(resp[i].user)
									}
								}
							});

							/////////////////////////////////////////
							for ( var key in this.info.roles ){
								var tmp = {
									role: key,
									check: false
								}

								if (this.info.roles[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.roles[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.roles[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.roles[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.roles[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.roles[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.roles[key].length == 1) {tmp.grnt = 'pass';}

								this.r_list.push(tmp);
								help_r.push(tmp.role);
							}

							axios.get('/am/base/role').then(response => {
								var resp = response.data

								for (var i=0;i<resp.length;i++){
									if (help_r.indexOf(resp[i].role) == -1){
										this.a_r_lst.push(resp[i].role)
									}
								}
							});

							this.usr = '';
							this.rls = '';
							this.show_u = true
						}
					},
					
					methods: {
						show: function(str){
							if (str == 'users'){this.show_u = true; this.show_r = false;} else {this.show_u = false; this.show_r = true;}
						},

						test_u: function(){
							var tmp = {};

							for (var i=0;i<this.u_list.length;i++){
								if (this.u_list[i].check){
									tmp[this.u_list[i].user] = this.u_list[i].grnt;
								}
							}

							axios.post('/am/node/user', { id: this.user.toString(), node: this.node.title, user: tmp } )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									//this.node.moveTo(prnt,'child');
	 	 							this.msg_u = response.data.success;
	 	 						} else { this.msg_u = response.data.err }	
							});

							//console.log(tmp);
							
						},
						test_r: function(){
							var tmp = {};

							for (var i=0;i<this.r_list.length;i++){
								if (this.r_list[i].check){
									tmp[this.r_list[i].role] = this.r_list[i].grnt;
								}
							}

							axios.post('/am/node/role', { id: this.user.toString(), node: this.node.title, role: tmp } )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									//this.node.moveTo(prnt,'child');
	 	 							this.msg_r = response.data.success;
	 	 						} else { this.msg_r = response.data.err }	
							});

							//console.log(tmp);
							
						},
						add_user: function(){
							var tmp = {
								user: this.usr,
								check: true,
								grnt: 'pass'
							}
							this.u_list.push(tmp);
						},
						add_role: function(){
							var tmp = {
								role: this.rls,
								check: true,
								grnt: 'pass'
							}
							this.r_list.push(tmp);
						}

					},

					mounted: function(){
							this.u_list = [];
							this.a_u_lst = [];

							this.r_list = [];
							this.a_r_lst = [];

							var help_u = [];
							var help_r = [];

							for ( var key in this.info.users ){
								var tmp = {
									user: key,
									check: false
								}

								if (this.info.users[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.users[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.users[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.users[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.users[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.users[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.users[key].length == 1) {tmp.grnt = 'pass';}

								this.u_list.push(tmp);
								help_u.push(tmp.user);
							}

							axios.get('/am/base/user').then(response => {
								var resp = response.data

								for (var i=0;i<resp.length;i++){
									if (help_u.indexOf(resp[i].user) == -1){
										this.a_u_lst.push(resp[i].user)
									}
								}
							});

							/////////////////////////////////////////
							for ( var key in this.info.roles ){
								var tmp = {
									role: key,
									check: false
								}

								if (this.info.roles[key].length == 7) {tmp.grnt = 'access';}
								if (this.info.roles[key].length == 6) {tmp.grnt = 'delete';}
								if (this.info.roles[key].length == 5) {tmp.grnt = 'replace';}
								if (this.info.roles[key].length == 4) {tmp.grnt = 'insert';}
								if (this.info.roles[key].length == 3) {tmp.grnt = 'update';}
								if (this.info.roles[key].length == 2) {tmp.grnt = 'read';}
								if (this.info.roles[key].length == 1) {tmp.grnt = 'pass';}

								this.r_list.push(tmp);
								help_r.push(tmp.role);
							}

							axios.get('/am/base/role').then(response => {
								var resp = response.data

								for (var i=0;i<resp.length;i++){
									if (help_r.indexOf(resp[i].role) == -1){
										this.a_r_lst.push(resp[i].role)
									}
								}
							});


					},
					
				}

var c_node_replace = {
					template: '#node_replace',
					props: ['user','tree','node'],
					data: function() {
						return {
							new_prnt: null,
							message: null,
							new: null,
							prnt: null
						}
					},

					watch:{
						node: function(){
							this.new_prnt = null;
						},
						user: function() {
							this.message = null;
						}
					},
					
					methods: {
						replace: function(){

							if (! this.new_prnt){
								this.message = 'Вы не ввели имя нового предка';
								return;
							}

							var prnt = this.tree.findFirst(this.new_prnt);
							
							axios.post('/am/node/replace', { id: this.user.toString(), prnt: prnt.title, node: this.node.title } )
							.then(response => {
								//console.log(response);

								if ( !response.data.err ){
									this.node.moveTo(prnt,'child');
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							});
						}
					}
				}

var c_node_insert = {
					template: '#node_insert',
					props: ['tree','user','node'],
					data: function(){
						return {
							child: null,
							message: null
						}
					},
					watch:{
						node: function(){
							this.child = null;
						},
						user: function() {
							this.message = null;
						}
					},
					methods: {
						insert: function(){
							
							if (!this.child){
								this.message = 'Введите имя нового узла';
								return;
							}
							
							axios.post('/am/node/add', { id: this.user.toString(), prnt: this.node.title, chld: this.child.toString() } )
							.then(response => { 
								//console.log(response);

								if ( !response.data.err ){
									this.node.addChildren({
	    								title: this.child.toString(),
	    								key: response.data.id
	 	 							});
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							})
						}
					}
				}

var c_node_delete = {
					template: '#node_delete',
					props: ['tree','user'],
					data: function(){
						return {
							message: null
						}
					},
					watch: {
						user: function() {
							this.message = null;
						}
					},
					methods: {
						delete_node: function(){
							//console.log(this.tree.remove())
							//console.log(this.tree.title);
							var node = this.tree.getActiveNode();

							axios.post('/am/node/remove', { id: this.user.toString(), node: node.title } )
							.then(response => { 
								//console.log(response);

								if ( !response.data.err ){
									node.remove();
	 	 							this.message = response.data.success;
	 	 						} else { this.message = response.data.err }	
							})
						}
					}
				}


Vue.component('blck_node', {
					components: {
						'node_info': c_node_info,
						'node_insert': c_node_insert,
						'node_delete': c_node_delete,
						'node_replace': c_node_replace,
						'node_access': c_node_access,
						'node_update': c_node_update
					},
					template: '#blck_node',
					props: ['user'],
					data: function(){
						return {
							name: null,
							info: null,
							tree: null,
							currentComponent: 'node_info',
							node: null
						}
					},

					watch: {
						node: function(){
							this.currentComponent = 'node_info';
						},
						user: function(){
							this.get_tree();
							this.currentComponent = 'node_info';
						}
					},

					mounted: function(){
						if (this.user){
							this.get_tree();
						}
						
					},

					methods:{
						f_current_component: function(str){
							this.currentComponent = 'node_'+str;
						},
						f_show_node_btn: function(str){
							if (this.info && this.info.grnts){
								if (this.info.grnts.indexOf(str) >= 0){
									return true;
								}

								if( this.info.grnts.indexOf('admins') >= 0 ){
									return true;
								}
							}
						},
						
						get_tree: function(){
							//console.log(this.user);
			     			this.info = null;

			     			if ( $('#tree').fancytree() ){
				     			$('#tree').fancytree('destroy');
				     		}

			     			$("#tree").fancytree({
			  					source: {
			  						url: '/am/node/tree',
			  						data: { id: this.user },
			  						//cache: false
			  					},
			  					activate: (event, data) => {
			      					this.name = data.node.title;
			      					//console.log(this.name);
			      					axios.get('/am/node/get', { params: { id: this.user, node: this.name } } ).then(response => {
			      						this.info = response.data;
			      						if (this.info.err){
			      							this.info.info = {};
			      							this.info.info.comment = '';
											this.info.info.password = '';
											this.info.info.email = '';
											this.info.info.url = '';
											this.info.info.files = '';
			      						}
			      					});
			      					//console.log(data.node.key);
			      					//console.log($('#tree').fancytree('getNodeByKey',data.node.key));
			      					this.node = $("#tree").fancytree("getActiveNode");
			      					this.tree = $("#tree").fancytree("getTree");
			      					//console.log(this.tree.getActiveNode().title);
			    				}
			  				});
						}
					}
				});