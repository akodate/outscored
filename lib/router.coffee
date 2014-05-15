Router.configure
  layoutTemplate: 'layout',
  loadingTemplate: 'loading'

Router.map(() ->
  @route('home', {
    path: '/',
    waitOn: () ->
      return [Meteor.subscribe('tests'), Meteor.subscribe('testSections')]
  })
  @route('sectionPage', {
    path: '/:secID/:testSecID',
    waitOn: () ->
      console.log @params.secID
      console.log @params.testSecID
      return [
        Meteor.subscribe('section', @params.secID)
        Meteor.subscribe('testSection', @params.testSecID)
        Meteor.subscribe('testQuestions', @params.testSecID)
        Meteor.subscribe('questions')
      ]
    data: () ->
      return Sections.findOne(@params.secID)
  })
)

Router.onBeforeAction('loading')

