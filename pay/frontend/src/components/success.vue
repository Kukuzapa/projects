<template>
    <div>
        <div class="bg-top-left">
            <div class="container pb-4">
                <div class="row">
                    <div class="col-12 text-center mt-5">
                        <a href="/">
                            <img src="/img/Get-Net_OFD.svg">
                        </a>
                    </div>

                    <div class="col-12 text-center mt-5">
                        <h1>Оплата прошла успешно</h1>
                    </div>

                    <div class="col-12 text-center mt-5">
                        <div id="success">
                            <img src="/img/Ellipse.svg">
                        </div>
                    </div>

                    <div class="alert alert-light col-12 text-center mt-4 msg" role="alert">
                        Идентификатор платежа:<br> {{order_id}}
                    </div>

                    <div class="alert alert-light col-12 text-center msg" role="alert">
                        Идентификатор транзакции банка:<br> {{transaction_id}}
                    </div>
                </div>
            </div>
        </div>
        <footer class="py-4 text-small">
            <div class="container">
                <foot/>
            </div>
	    </footer>
    </div>
</template>

<script>

import Foot from "./footer.vue"

export default {
    name: 'success',
    components: {
        Foot
    },
    data: function(){
        return {
            order_id:       this.$route.query.OrderId || this.$route.params.order_id,
            transaction_id: this.$route.query.PaymentId || this.$route.query.transaction_id,
        }
    },
}
</script>

<style>
    #success{
        background-image: url(/img/checkmark.svg);
        background-repeat: no-repeat;
        background-position: center;
    }

    .msg {
        border-radius: 9px;
        min-height: 64px;
        padding: 1.25rem 1.25rem;
    }
</style>
