@Tests = new Meteor.Collection('tests')
@Questions = new Meteor.Collection('questions')
@Sections = new Meteor.Collection('sections')
@TestSections = new Meteor.Collection('testSections')
@TestQuestions = new Meteor.Collection('testQuestions')
@MidSections = new Meteor.Collection('midSections')
@TestMidSections = new Meteor.Collection('testMidSections')

Meteor.methods

  questionViewCount: (questionID) ->
    Questions.update({_id: questionID}, {$inc: {viewCount: 1}})
    currentQuestion = getCurrentQuestion(questionID)
    # console.log questionID + " view count increased to " + (currentQuestion.viewCount ||= 1)
    questionSkipCount(currentQuestion)

  questionCorrectCount: (questionID) ->
    Questions.update({_id: questionID}, {$inc: {correctCount: 1}})
    currentQuestion = getCurrentQuestion(questionID)
    # console.log questionID + " correct count increased to " + (currentQuestion.correctCount ||= 0)
    currentQuestion = questionSkipCount(currentQuestion)
    questionCorrectPercentage(currentQuestion)

  questionIncorrectCount: (questionID) ->
    Questions.update({_id: questionID}, {$inc: {incorrectCount: 1}})
    currentQuestion = getCurrentQuestion(questionID)
    # console.log questionID + " incorrect count increased to " + (currentQuestion.incorrectCount ||= 0)
    currentQuestion = questionSkipCount(currentQuestion)
    questionCorrectPercentage(currentQuestion)

  sectionViewCount: (sectionID) ->
    Sections.update({_id: sectionID}, {$inc: {viewCount: 1}})
    # console.log sectionID + " section view count increased by 1."

  testViewCount: (testID) ->
    Tests.update({_id: testID}, {$inc: {viewCount: 1}})
    # console.log testID + " test view count increased by 1."

@questionSkipCount = (currentQuestion) ->
  currentQuestion.correctCount ||= 0
  currentQuestion.incorrectCount ||= 0
  skipCount = currentQuestion.viewCount - (currentQuestion.correctCount + currentQuestion.incorrectCount)
  currentQuestion.skipCount = skipCount
  Questions.update({_id: currentQuestion._id}, {$set: {skipCount: skipCount}})
  # console.log currentQuestion._id + " skip count set to " + skipCount
  questionSkipPercentage(currentQuestion)

@questionSkipPercentage = (currentQuestion) ->
  skipPercentage = Math.round(currentQuestion.skipCount / currentQuestion.viewCount * 100)
  Questions.update({_id: currentQuestion._id}, {$set: {skipPercentage: skipPercentage}})
  # console.log currentQuestion._id + " skip percentage set to " + skipPercentage + "%"
  return currentQuestion

@questionCorrectPercentage = (currentQuestion) ->
  answeredCount = currentQuestion.correctCount + currentQuestion.incorrectCount
  correctPercentage = Math.round(currentQuestion.correctCount / answeredCount * 100)
  Questions.update({_id: currentQuestion._id}, {$set: {correctPercentage: correctPercentage}})
  # console.log currentQuestion._id + " correct percentage set to " + correctPercentage + "%"

@getCurrentQuestion = (questionID) ->
  currentQuestion = Questions.findOne({_id: questionID}, {fields: {viewCount: 1, correctCount: 1, incorrectCount: 1}})
  # console.log "Current question view count is: " + currentQuestion.viewCount
  # console.log "Current question correct count is: " + currentQuestion.correctCount
  # console.log "Current question incorrect count is: " + currentQuestion.incorrectCount
  return currentQuestion