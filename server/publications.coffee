Meteor.publish 'tests', () ->
  Tests.find({}, {fields: {name: 1, children: 1}})

Meteor.publish 'testSections', () ->
  TestSections.find({}, {fields: {filePath: 1, original: 1}})

Meteor.publish 'testSection', (id) ->
  TestSections.find(_id: id)

Meteor.publish 'section', (id) ->
  Sections.find(_id: id)

Meteor.publish 'testQuestions', (parentID) ->
  TestQuestions.find(parent: parentID)

Meteor.publish 'questions', (testID) ->
  Questions.find(inTest: testID)