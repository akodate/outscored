Meteor.publish 'tests', (options) ->
  Tests.find({}, options)

Meteor.publish 'testSections', (options) ->
  TestSections.find({}, options)

Meteor.publish 'testSection', (id) ->
  TestSections.find(_id: id)

Meteor.publish 'section', (id) ->
  Sections.find(_id: id)

Meteor.publish 'testQuestions', (id) ->
  TestQuestions.find(parent: id)

Meteor.publish 'questions', () ->
  Questions.find()

# Meteor.publish('singlePost', function(id) { return id && Posts.find(id);
# });
# Meteor.publish('comments', function(postId) { return Comments.find({postId: postId});
# });
# Meteor.publish('notifications', function() { return Notifications.find({userId: this.userId});
# });