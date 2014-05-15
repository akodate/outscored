Router.configure
  layoutTemplate: 'layout',
  loadingTemplate: 'loading'
  waitOn: () ->
    return [Meteor.subscribe('tests'), Meteor.subscribe('testSections')]

Router.map(() ->
  this.route('home', {
    path: '/',
  })


)

Router.onBeforeAction('loading')