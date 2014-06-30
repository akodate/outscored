@Tests = new Meteor.Collection('tests')
@Questions = new Meteor.Collection('questions')
@Sections = new Meteor.Collection('sections')
@TestSections = new Meteor.Collection('testSections')
@TestQuestions = new Meteor.Collection('testQuestions')
@MidSections = new Meteor.Collection('midSections')
@TestMidSections = new Meteor.Collection('testMidSections')

Meteor.methods

  questionViewCount: (questionID) ->
    console.log questionID + " view count increased."
    Questions.update({_id: questionID}, {$inc: {viewCount: 1}})

  questionCorrectCount: (questionID) ->
    console.log questionID + " correct count increased."
    Questions.update({_id: questionID}, {$inc: {correctCount: 1}})

  questionIncorrectCount: (questionID) ->
    console.log questionID + " incorrect count increased."
    Questions.update({_id: questionID}, {$inc: {incorrectCount: 1}})