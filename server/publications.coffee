Meteor.publish 'tests', () ->
  Tests.find({}, {fields: {name: 1, children: 1}})

Meteor.publish 'testSections', () ->
  TestSections.find({}, {fields: {filePath: 1, original: 1}})

Meteor.publish 'testSection', (id) ->
  TestSections.find(_id: id)

Meteor.publish 'section', (id) ->
  Sections.find(_id: id)

Meteor.publish 'testQuestions', (id) ->
  TestQuestions.find(parent: id)

Meteor.publish 'questions', (testID) ->
  Questions.find(inTest: testID)

# Meteor.publish('singlePost', function(id) { return id && Posts.find(id);
# });
# Meteor.publish('comments', function(postId) { return Comments.find({postId: postId});
# });
# Meteor.publish('notifications', function() { return Notifications.find({userId: this.userId});
# });