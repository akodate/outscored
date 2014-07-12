Router.configure
  layoutTemplate: 'layout',
  loadingTemplate: 'loading'

Router.map( ->
  @route('home', {
    path: '/',
    waitOn: ->
      return [
        Meteor.subscribe('userData') if Meteor.userId()
        Meteor.subscribe('tests')
        Meteor.subscribe('testSections')
        Meteor.subscribe('section')
      ]
    onAfterAction: ->
      document.title = "Outsco.red"
      GAnalytics.pageview()
  })
  @route('sectionPage', {
    path: ':testName/:sectionName/:testID/:secID/:testSecID',
    waitOn: ->
      return [
        Meteor.subscribe('userData') if Meteor.userId()
        Meteor.subscribe('test', @params.testID)
        Meteor.subscribe('section', @params.secID)
        Meteor.subscribe('testSection', @params.testSecID)
        Meteor.subscribe('testQuestions', @params.testSecID)
        Meteor.subscribe('questions', @params.testID)
      ]
    data: ->
      return Sections.findOne(@params.secID)
    onAfterAction: ->
      document.title = (Tests.findOne(_id: @params.testID).name) + " | " + (/[^\/]+$/.exec(TestSections.findOne(_id: @params.testSecID).filePath))
      GAnalytics.pageview()
  })
)

Router.onBeforeAction('loading')

