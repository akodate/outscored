Meteor.publish 'tests', () ->
  Tests.find({}, {fields: {name: 1, children: 1}})

Meteor.publish 'test', (id) ->
  Tests.find(_id: id)

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

Meteor.publish "userData", () ->
  if !! @userId
    Meteor.users.find({_id: @userId}, {fields: {testsViewed: 1, testsAnswered: 1, testsExperienced: 1, testsSkilled: 1, testsMastered: 1, sectionsViewed: 1, sectionsAnswered: 1, sectionsSkilled: 1, sectionsMastered: 1, questionsViewed: 1, questionsSkipped: 1, questionsCorrect: 1, questionsSkilled: 1, questionsMastered: 1, questionsIncorrect: 1}})