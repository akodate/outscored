@Tests = new Meteor.Collection('tests')
@Questions = new Meteor.Collection('questions')
@Sections = new Meteor.Collection('sections')
@TestSections = new Meteor.Collection('testSections')
@TestQuestions = new Meteor.Collection('testQuestions')
@MidSections = new Meteor.Collection('midSections')
@TestMidSections = new Meteor.Collection('testMidSections')

Meteor.methods

  # Test-side methods

  testViewCount: (testID) ->
    Tests.update({_id: testID}, {$inc: {viewCount: 1}})
    # console.log testID + " test view count increased by 1."

  sectionViewCount: (sectionID) ->
    Sections.update({_id: sectionID}, {$inc: {viewCount: 1}})
    # console.log sectionID + " section view count increased by 1."

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




  # User-side methods

  subTransfer: (subUser) ->
    console.log "Checked for sub-user"
    userID = Meteor.userId()
    for arrKey, arrValue of subUser
      console.log arrKey
      console.log arrValue
      if arrKey != '_id'
        dynObj = {}
        dynObj[arrKey] = {$each: arrValue}
        Meteor.users.update({_id: userID}, {$addToSet: dynObj})

  testViewed: (testID) ->
    if Meteor.userId()
      userID = Meteor.userId()
      console.log testID + " test viewed, current user is: " + userID
      Meteor.users.update({_id: userID}, {$addToSet: {testsViewed: testID}})

  testStatus: (testID) ->
    if Meteor.userId() && !@isSimulation
      user = Meteor.user()
      test = Tests.findOne(_id: testID)
      userTestCorrect = _.intersection(test.hasQuestions, (user.questionsCorrect ||= []))
      numCorrect = userTestCorrect.length
      numSkilled = _.intersection(userTestCorrect, (user.questionsSkilled ||= [])).length
      numMastered = _.intersection(userTestCorrect, (user.questionsMastered ||= [])).length
      mastery = (numCorrect + numSkilled + numMastered) / 3 / (test.hasQuestions.length) * 100
      console.log "Test mastery is: " + mastery
      if mastery == 100
        console.log "TEST STATUS IS MASTERED!!!"
        Meteor.users.update({_id: user._id}, {$addToSet: {testsMastered: testID}})
      else if mastery > 66
        Meteor.users.update({_id: user._id}, {$addToSet: {testsSkilled: testID}})
      else if mastery > 33
        Meteor.users.update({_id: user._id}, {$addToSet: {testsExperienced: testID}})
      else if mastery > 0
        Meteor.users.update({_id: user._id}, {$addToSet: {testsAnswered: testID}})

  sectionViewed: (sectionID) ->
    if Meteor.userId()
      userID = Meteor.userId()
      console.log sectionID + " section viewed, current user is: " + userID
      Meteor.users.update({_id: userID}, {$addToSet: {sectionsViewed: sectionID}})

  sectionStatus: (sectionID) ->
    if Meteor.userId() && !@isSimulation
      user = Meteor.user()
      section = Sections.findOne(_id: sectionID)
      userSectionCorrect = _.intersection(section.hasQuestions, (user.questionsCorrect ||= []))
      numCorrect = userSectionCorrect.length
      numSkilled = _.intersection(userSectionCorrect, (user.questionsSkilled ||= [])).length
      numMastered = _.intersection(userSectionCorrect, (user.questionsMastered ||= [])).length
      mastery = (numCorrect + numSkilled + numMastered) / 3 / (section.hasQuestions.length) * 100
      console.log "Section mastery is: " + mastery
      if mastery == 100 && sectionID not in (user.sectionsMastered ||= [])
        console.log "SECTION STATUS IS MASTERED!!!"
        Meteor.users.update({_id: user._id}, {$addToSet: {sectionsMastered: sectionID}})
        return "complete"
      else if mastery > 66
        Meteor.users.update({_id: user._id}, {$addToSet: {sectionsSkilled: sectionID}})
      else if mastery > 33
        Meteor.users.update({_id: user._id}, {$addToSet: {sectionsExperienced: sectionID}})
      else if mastery > 0
        Meteor.users.update({_id: user._id}, {$addToSet: {sectionsAnswered: sectionID}})

  questionViewed: (questionID) ->
    if Meteor.userId()
      userID = Meteor.userId()
      console.log questionID + " question viewed, current user is: " + userID
      Meteor.users.update({_id: userID}, {$addToSet: {questionsViewed: questionID}})
      Meteor.users.update({_id: userID}, {$addToSet: {questionsSkipped: questionID}})

  questionCorrect: (questionID) ->
    if Meteor.userId()
      userID = Meteor.userId()
      user = Meteor.user()
      if user.questionsSkilled && questionID in user.questionsSkilled # Question mastered
        console.log questionID + " question mastered, current user is: " + userID
        Meteor.users.update({_id: userID}, {$addToSet: {questionsMastered: questionID}})
      else if user.questionsCorrect && questionID in user.questionsCorrect # Question skilled
        console.log questionID + " question skilled, current user is: " + userID
        Meteor.users.update({_id: userID}, {$addToSet: {questionsSkilled: questionID}})
      else # Question correct
        console.log questionID + " question correct, current user is: " + userID
        Meteor.users.update({_id: userID}, {$pull: {questionsIncorrect: questionID}})
        Meteor.users.update({_id: userID}, {$addToSet: {questionsCorrect: questionID}})
        Meteor.users.update({_id: userID}, {$pull: {questionsSkipped: questionID}})

  questionIncorrect: (questionID) ->
    if Meteor.userId()
      userID = Meteor.userId()
      console.log questionID + " question incorrect, current user is: " + userID
      Meteor.users.update({_id: userID}, {$pull: {questionsCorrect: questionID}})
      Meteor.users.update({_id: userID}, {$pull: {questionsSkilled: questionID}})
      Meteor.users.update({_id: userID}, {$pull: {questionsMastered: questionID}})
      Meteor.users.update({_id: userID}, {$addToSet: {questionsIncorrect: questionID}})
      Meteor.users.update({_id: userID}, {$pull: {questionsSkipped: questionID}})




# Helper methods

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