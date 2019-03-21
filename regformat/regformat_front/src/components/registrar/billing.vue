<template>
    <div class="row">
        <form class="col-12">
            <div class="row">

                <div class="form-group col-6">
                    <label>Выбор регистратора</label>
                    <select class="custom-select" v-model="registrar">
                        <option value="ru">Зона RU</option>
                        <option value="rf">Зона RF</option>
                    </select>
                </div>

                <div class="form-group col-6">
                    <label>Тип запроса</label>
                    <select class="custom-select" v-model="billing">
                        <option value="balance">Баланс</option>
                        <option value="billing">Биллинг</option>
                        <option value="forecast">Прогноз</option>
                    </select>
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-primary btn-block" @click="registrar_billing">Запросить информацию о регистраторе</button>
                </div>

            </div>
        </form>

        <div v-if="error" class="col-12 mt-2">
            <div class="alert alert-danger" role="alert">
                <span v-if="err_msg">{{err_msg}}</span>
                <span v-else>Это фиаско. Что-то, как всегда неожиданно, пошло не так.</span>
            </div>
        </div>

        <div v-if="success" class="col-12 mt-2">
            <div class="row">
                <div class="col-6 mt-3">
                    <result :trid="trid" :msg="message" :rslt="result"/>
                </div>
                <div class="col-6 mt-3">
                    <div v-for="(value, key) in response" :key="key">
                        <p>{{ key }}: {{ value }}</p>
                    </div>
                </div>
            </div>
        </div>

    </div>
</template>

<script>
import result from '../result.vue'

export default {
    name: 'registrar_billing',

    components: { result },

    data: function(){
        return {
            registrar: 'ru',
            billing: 'balance',

            response:  null,

            error:   null,
            success: null,
            err_msg: null,
            message: null,
            trid:    null,
            result:  null,
        }
    },

    methods: {
        registrar_billing: function(){
            this.error   = null;
            this.err_msg = null;
            this.success = null;
            
            this.axios.get( 'registrar/billing/' + this.registrar, { params: { billing: this.billing } } ).then( response => {
                if ( response.data.error ){
                    this.error   = true;
                    this.err_msg = response.data.message;
                } else {
                    this.success = true;
                    this.trid = response.data.clTRID
                    this.message = response.data.message
                    this.result = response.data.result

                    this.response = response.data[this.billing]
                }
            } ).catch( error => {
                this.error = true;
			})
        }
    }
}
</script>