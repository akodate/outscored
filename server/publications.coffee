Meteor.publish('tests', (options) ->
  return Tests.find({}, options)
)