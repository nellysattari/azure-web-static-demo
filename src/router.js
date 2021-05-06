import Vue from 'vue'
import Router from 'vue-router'


Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'facephoto',
      component: () => import(/* webpackChunkName: "home" */ './components/FaceRecognition.vue')
    },
     
  ]
})
 
 