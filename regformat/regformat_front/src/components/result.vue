<template>
    <div>
        <p>Номер операции - {{trid}}</p>
        <div v-for="(value, key) in rslt" :key="key">
            <p>{{ value.code }}, {{ value.msg }}<span v-if="value.reason">, {{value.reason}}</span></p>
        </div>
        <p v-if="msg">Есть неразобранные сообщения реестра, {{msg.msgQ}} штук.</p>
    </div>
</template>

<script>
export default {
    name: 'result',
    props: [ 'trid', 'msg', 'rslt' ]
}
</script>
