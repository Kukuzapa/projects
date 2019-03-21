<template>
    <div class="row">
        <div class="col-12">
            {{user_info}}
        </div>
    </div>
</template>

<script>


export default {
    name: 'info',
    props: ['user_info']
}
</script>