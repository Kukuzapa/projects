<template>
<div>

	<div class="modal" tabindex="-1" role="dialog" id="oferta_module">
  		<div class="modal-dialog modal-lg" role="document">
    		<div class="modal-content">
				<div class="modal-body">
					<oferta/>
      			</div>
    		</div>
  		</div>
	</div>


	<div class="bg-top-right">
		<div class="container">
			<div class="row">

				<div class="col-12 text-center my-5">
					<img src="/img/Get-Net_OFD.svg">
				</div>

				<form class="col-12" @submit.prevent="pay">
					<h2>Оплатить услугу</h2>
					<div class="form-group mt-3">
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text" id="blog"></span>
							</div>
							<input
								type="text"
								class="form-control border-left-0"
								placeholder="Номер договора"
								v-model="address"
								v-bind:style="{ color: contract }"
							>
						</div>
					</div>

					<div class="form-group">
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text" id="email"></span>
							</div>
							<input type="text" class="form-control border-left-0" placeholder="Email" v-model="phone">
						</div>
					</div>

					<div class="form-group">
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text" id="ruble"></span>
							</div>
							<input type="text" class="form-control border-left-0" placeholder="Сумма платежа" v-model="amount">
						</div>
					</div>

					<div class="ml-3">
						<div class="chiller_cb">
							<input id="rememberCheckbox" type="checkbox" v-model="remember" :disabled="forget">
							<label for="rememberCheckbox">Подключить автоплатёж</label>
							<span></span>
						</div>
					</div>

					<small class="ml-3">Устанавливая галочку "Подключить автоплатёж", вы соглашаетесь с условиями <a data-toggle="modal" href="#oferta_module" @click="oferta">оферты</a>.</small>

					<div class="ml-3">
						<div class="chiller_cb">
							<input id="myCheckbox" type="checkbox" v-model="forget" :disabled="remember">
							<label for="myCheckbox">Отключить автоплатёж</label>
							<span></span>
						</div>
					</div>

					<div class="text-center mt-4">
						<button type="submit" class="pay"
						:disabled="contract != 'green' || !amount || isNaN(amount) || !validate_email( phone )">Перейти к оплате</button>
					</div>
				</form>

				<div class="col-12 text-center mt-3" v-if="error">
					<div class="alert alert-danger mt-3" role="alert">
						Что-то пошло не так! Пожалуйста, повторите попытку позже.
                	</div>
				</div>

				<form action="https://pay.modulbank.ru/pay" method="post" id="module" style="display: none"></form>
			</div>
		</div>
	</div>
	<about/>
	<footer class="py-4 text-small">
		<div class="container">
			<licenses/>
			<foot/>
		</div>
	 </footer>
</div>
</template>

<script>
import About from "./about.vue"
import Licenses from "./licenses.vue"
import Foot from "./footer.vue"

import Oferta from './oferta.vue'

export default {
	name: 'pay',
    components: {
		About,
		Licenses,
		Foot,
		Oferta,
    },
	data : function(){
		return {
			address:  null,  //Номер договора
			amount:   null,  //Сумма платежа
			phone:    null,  //Почтовый ящик

			uid:      null,  //Идентификатор договора

			remember: false, //Стоит галочка подключить автоплатеж
			forget:   false, //Стоит галочка отключить автоплатёж

			error:    false,

			contract: null   //Определяет цвет и условие валидации
		}
	},

	watch: {
		address: function(){
			this.validate_contract()
		},
		amount: function() {
			this.amount = this.amount.replace(',', '.')
		}
	},

	methods: {
		oferta: function(){
			console.log( 'OFERTA' )
		},

		//Валидация номера договора
		validate_contract: function( str ){
			var self = this;
			if ( !this.address ){
				this.contract = 'red'
			}

			return this.axios.get( 'https://backend.gtn.ee/api/v1.0/account/client/list', { params: { number: this.address } } )
				.then( function(response) {
					console.log( response )

					console.log( response.data.length )

					if ( response.data.length ){
						self.contract = 'green'

						self.uid = response.data[0].uid;
					} else {
						self.contract = 'red'
					}
				} )
		},

		//Валидация почты
		validate_email: function( str ){
			var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

			return re.test(String( str ).toLowerCase());
		},

		pay: function(){
			var self = this;

			var request = {
				amount:  this.amount,
				phone:   this.phone,
				address: this.address,
				uid:     this.uid
			}

			//Вариант когда есть только Тинькофф
			if ( this.remember ){
				request.recur = 'Y'
			}

			this.axios.get( 'tinkoff/pay', { params: request } ).then( function(response) {
					document.location.href = response.data.PaymentURL;
				} )
				.catch(function(error) {
					self.error = true;
					setTimeout(function() {
						self.error = false
					}, 3000)
				})
			////END////

			/*if ( this.remember ){
                request.recur = 'Y'

				console.log( 'tinkoff' )

				this.axios.get( 'tinkoff/pay', { params: request } )
				.then( response => {
					document.location.href = response.data.PaymentURL;
				} )
				.catch(error => {
					this.error = true;
					setTimeout(() => {
						this.error = false
					}, 3000)
				})
			} else {
				console.log( 'module bank' )

				this.axios.get( 'module/pay', { params: request } )
				.then( response => {
					for ( var key in response.data ) {
						document.getElementById( 'module' ).innerHTML += '<input type="text" name="'+key+'" id="'+key+'">'
					}

					for ( var key in response.data ) {
						document.getElementById( key ).value = response.data[key]
					}

					document.getElementById( 'module' ).submit();
				} )
				.catch(error => {
					this.error = true;
					setTimeout(() => {
						this.error = false
					}, 3000)
				})
            }*/

			//console.log( request )

			/*this.axios.get( '/pay', { params: request } ).then( response => {
				document.location.href = response.data.PaymentURL;
			} )*/
		}
	}
}
</script>

<style>

	.card {
		display: inline-block;
		margin-right: 12px;
		width: 72px;
		height: 40px;
		background: #fff;
		background-position: center;
		background-repeat: no-repeat;
		border-radius: 6px;

	}

	.card.visa {
		background-image: url(/img/visa.svg);
		background-size: 35px auto;
	}

	.card.mir {
    	background-image: url(/img/mir.svg);
	}

	.card.mastercard {
    	background-image: url(/img/mastercard.svg);
	}

	@media (max-width: 500px) {

		h1, h2, h3 {
			font-size: 1.5rem;
		}

		.lead {
			font-size: 1rem;
		}

		button.pay {
			max-width: 342px;
			width: 100%;
			height: 50px;
		}
	}


	*:focus {
		outline: 0 none !important;
		border: 0 none !important;
	}

	.figure-caption {
    	font-size: 50%;
	}

    .bg-white {
		background-color: #fff;
	}

	a {
		color: #404040;
		text-decoration: underline;
	}

	a:hover {
		color: #505050;
	}

	.bg {
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-direction: column;
	}

	.span_pseudo, .chiller_cb span:before, .chiller_cb span:after {
		content: "";
		display: inline-block;
		background: #fff;
		width: 0;
		height: 0.2rem;
		position: absolute;
		transform-origin: 0% 0%;
	}

	.chiller_cb {
		position: relative;
		height: 2rem;
		display: flex;
		align-items: center;
	}

	.chiller_cb input {
		display: none;
	}

	.chiller_cb input:checked ~ span {
		background: #6FBE44;
		border-color: #6FBE44;
		border-radius: 3px;
	}

	.chiller_cb input:checked ~ span:before {
		width: 1rem;
		height: 0.15rem;
		transition: width 0.1s;
		transition-delay: 0.3s;
	}

	.chiller_cb input:checked ~ span:after {
		width: 0.4rem;
		height: 0.15rem;
		transition: width 0.1s;
		transition-delay: 0.2s;
	}

	.chiller_cb input:disabled ~ span {
		background: #ececec;
		border-color: #dcdcdc;
	}

	.chiller_cb input:disabled ~ label {
		color: #dcdcdc;
	}

	.chiller_cb input:disabled ~ label:hover {
		cursor: default;
	}

	.chiller_cb label {
		padding-left: 2rem;
		position: relative;
		z-index: 2;
		cursor: pointer;
		margin-bottom:0;
	}

	.chiller_cb span {
		display: inline-block;
		width: 1.2rem;
		height: 1.2rem;
		border: 2px solid #ccc;
		position: absolute;
		left: 0;
		transition: all 0.2s;
		z-index: 1;
		box-sizing: content-box;
		border-radius: 3px;
	}

	.chiller_cb span:before {
		transform: rotate(-55deg);
		top: 1rem;
		left: 0.37rem;
	}

	.chiller_cb span:after {
		transform: rotate(35deg);
		bottom: 0.35rem;
		left: 0.2rem;
	}

	.input-group-text{
		border: 0;
		background: white;
		background-position: center;
		background-repeat: no-repeat;
		padding-left: 50px;
	}

	#ruble{
		background-image: url(/img/ruble.svg);
	}

	#phone{
		background-image: url(/img/phone.svg);
	}

	#blog{
		background-image: url(/img/blog.svg);
	}

	#email{
		background-image: url(/img/mail.svg);
	}

	.form-control{
		border: 0;
		height: 64px;
	}

	.form-control:focus {
		box-shadow: 0 0 0 0;
	}

	button{
		background: #6FBE44;
		border-radius: 24px;
		width: 342px;
		height: 62px;
		color: #FFFFFF;
		border: 0;
		cursor: pointer;
	}

	button:disabled{
		background: #A7ADB3;
	}

	#message{
		color: #A7ADB3;
	}
</style>