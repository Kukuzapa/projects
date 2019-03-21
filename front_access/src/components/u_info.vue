<template>
    <div class="row">
        <div class="col-12">
            {{current_user_info}}
        </div>
    </div>
</template>

<script>


export default {
    name: 'u_info',
    props: ['current_user_info']
}
</script>