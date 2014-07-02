Router.configure
  layoutTemplate: 'layout',
  loadingTemplate: 'loading'

Router.map(() ->
  @route('home', {
    path: '/',
    waitOn: () ->
      return [
        Meteor.subscribe('userData') if Meteor.userId()
        Meteor.subscribe('tests')
        Meteor.subscribe('testSections')
        Meteor.subscribe('section')
      ]
  })
  @route('sectionPage', {
    path: ':testID/:secID/:testSecID',
    waitOn: () ->
      return [
        Meteor.subscribe('userData') if Meteor.userId()
        Meteor.subscribe('section', @params.secID)
        Meteor.subscribe('testSection', @params.testSecID)
        Meteor.subscribe('testQuestions', @params.testSecID)
        Meteor.subscribe('questions', @params.testID)
      ]
    data: () ->
      return Sections.findOne(@params.secID)
  })
)

Router.onBeforeAction('loading')

