Router.configure({
  layoutTemplate: 'layout',
  waitOn: () ->
    return [Meteor.subscribe('notifications')]
})

Router.map(() ->
  this.route('home', {
    path: '/',
  })
)