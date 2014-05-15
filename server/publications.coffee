Meteor.publish('tests', (options) ->
  return Tests.find({}, options)
)
Meteor.publish('testSections', (options) ->
  return TestSections.find({}, options)
)