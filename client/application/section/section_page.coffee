@QuestionResults = new Meteor.Collection(null)

JP_DIGIT_REGEX = /^(\d):/
JP_PARENTH_REGEX = /^（(\d)）/
JP_CIRCLE_REGEX = /^[①②③④]/

Template.sectionPage.created = () ->

  if Outscored.find().count() == 0
    Outscored.insert({})

  outscoredUpdate({currentQuestionNum: 1})
  outscoredUpdate({clickedChoice: false})
  outscoredUpdate({isTextCovered: false})
  outscoredUpdate({grayedOut: false})
  outscoredUpdate({noChoicesIn: false})
  resetQuestion()
  QuestionResults.remove({})
  sectionSetup()



Template.sectionPage.rendered = () ->

  sectionStyleSetup()
  shuffleChoices()

Template.sectionPage.events
  "click .previous-question": (event, ui) ->
    previousQuestion()

  "click .next": (event, ui) ->
    # Unless user clicks on grayed-out next button
    unless $(event.currentTarget).hasClass('finish') && outscoredFind('grayedOut')
      nextQuestion()

  "click .choice": (event, ui) ->
    if outscoredFind('clickedChoice') == false
      $('.next-question, .previous-question').hide()
      outscoredUpdate({noChoicesIn: true})
      outscoredUpdate({clickedChoice: true})
      choice = event.target.innerText
      thisQuestion = QuestionResults.findOne({result: true})
      choice = choice.replace(/^\s*\$*|\s+$/g, "")
      answer = thisQuestion.answer.replace(/^\s*\$*|\s+$/g, "")
      console.log "CHOICE: " + choice
      console.log "ANSWER: " + answer
      if answer.match('^' + choice + '$')
        correctClick(event)
      # else if answer.match(/^.$/)
      #   selection = processSelection(choice)
      #   if selection == answer
      #     correctClick(event)
      #   else
      #     incorrectClick(event)
      else
        incorrectClick(event)
      $('.question-heading, .question-content').hide()
      $('.answer-area').show()

  "click .explanation-button, click .text-button": (event, ui) ->
    if !outscoredFind('grayedOut')
      Meteor.setTimeout (() ->
        outscoredUpdate({grayedOut: true})
        grayOut()
      ), 10

  "click .finish": (event, ui) ->
    if outscoredFind('grayedOut')
      outscoredUpdate({grayedOut: false})
      grayIn()


Template.question.rendered = () ->

  Meteor.setTimeout (() ->
    choicesIn()
    Meteor.setInterval choicesIn, 300
  ), 500
  choiceStatus()




Template.sectionPage.helpers

  questions: ->
    return QuestionResults.find(result: true)

  sectionName: ->
    return TestSections.findOne().filePath

  correctBarWidth: ->
    if (Meteor.userId() && Meteor.user().questionsCorrect) || (subUser() && subUser().questionsCorrect)
      user = Meteor.user() || subUser()
      numQuestions = QuestionResults.find().count()
      width = (_.intersection(outscoredFind('questionIDArray'), user.questionsCorrect).length) / numQuestions / 3 * 100
      if width < 2 then width = 2
      return width
    else 0

  skilledBarWidth: ->
    if (Meteor.userId() && Meteor.user().questionsSkilled) || (subUser() && subUser().questionsSkilled)
      user = Meteor.user() || subUser()
      numQuestions = QuestionResults.find().count()
      width = (_.intersection(outscoredFind('questionIDArray'), user.questionsSkilled).length) / numQuestions / 3 * 100
      if width < 2 && width > 0 then width = 2
      return width
    else 0

  masteredBarWidth: ->
    if (Meteor.userId() && Meteor.user().questionsMastered) || (subUser() && subUser().questionsMastered)
      user = Meteor.user() || subUser()
      numQuestions = QuestionResults.find().count()
      width = (_.intersection(outscoredFind('questionIDArray'), user.questionsMastered).length) / numQuestions / 3 * 100
      if width < 2 && width > 0 then width = 2
      return width
    else 0




Template.question.helpers

  questionHeading: ->
    if Meteor.userId() || subUser()
      user = Meteor.user() || subUser()
      questionID = getCurrentQuestionID()
      if (user.questionsMastered && questionID in user.questionsMastered) || (user.questionsSkilled && questionID in user.questionsSkilled)
        if Localization.findOne().region == 'JP'
          return "マステリー問題"
        else
          return "Mastery question"
      else if user.questionsCorrect && questionID in user.questionsCorrect
        if Localization.findOne().region == 'JP'
          return "復習問題"
        else
          return "Review question"
      else
        if Localization.findOne().region == 'JP'
          return "問題"
        else
          return "Question"
    else
      if Localization.findOne().region == 'JP'
        return "問題"
      else
        return "Question"


  currentQuestionNum: ->
    if Meteor.userId() || subUser()
      user = Meteor.user() || subUser()
      questionID = getCurrentQuestionID()
      if (user.questionsMastered && questionID in user.questionsMastered) || (user.questionsSkilled && questionID in user.questionsSkilled)
        (_.intersection(outscoredFind('questionIDArray'), user.questionsMastered).length + 1) || 1
      else if user.questionsCorrect && questionID in user.questionsCorrect
        (_.intersection(outscoredFind('questionIDArray'), user.questionsSkilled).length + 1) || 1
      else
        (_.intersection(outscoredFind('questionIDArray'), user.questionsCorrect).length + 1) || 1
    else
      return @.order

  totalQuestions: ->
    return QuestionResults.find().count()

  choice: ->
    choice = @.replace(/^\w*<br>*/, '')
    # choice = choice.replace(JP_DIGIT_REGEX, '')
    # choice = choice.replace(JP_PARENTH_REGEX, '')
    # choice = choice.replace(JP_CIRCLE_REGEX, '')
    return choice

  # answer: ->
  #   answer = @.answer
  #   firstChoice = @.choices[0].replace(/^\w*<br>*/, '')
  #   if @.answer.match(/\d/) && (firstChoice.match(JP_DIGIT_REGEX) || firstChoice.match(JP_PARENTH_REGEX) || firstChoice.match(JP_CIRCLE_REGEX))
  #     for choice in @.choices
  #       choice = choice.replace(/^\w*<br>*/, '')
  #       console.log "choice" + choice
  #       console.log "answer" + answer
  #       console.log "processed" + processSelection(choice)
  #       if answer == processSelection(choice)
  #         answer = choice.replace(/^\w*<br>*/, '')
  #         answer = answer.replace(JP_DIGIT_REGEX, '')
  #         answer = answer.replace(JP_PARENTH_REGEX, '')
  #         answer = answer.replace(JP_CIRCLE_REGEX, '')
  #         QuestionResults.update({result: true}, {$set: {answer: answer}})
  #         return answer
  #   else
  #     return answer

  isCorrect: ->
    return outscoredFind('isCorrect')

  isSkilled: ->
    return outscoredFind('isSkilled')

  isMastered: ->
    return outscoredFind('isMastered')

  isIncorrect: ->
    return outscoredFind('isIncorrect')

  explanationFilter: ->
    explanation = QuestionResults.findOne(result: true).explanation
    return explanation.replace(/\n|<.*?>|解説無し/m, '')

  textCovered: ->
    return outscoredFind('isTextCovered')

  viewExplanation: ->
    explanation = QuestionResults.findOne(result: true).explanation
    return outscoredFind('grayedOut') && explanation.replace(/<(?:.|\n)*?>/gm, '')




# Helpers

@sectionSetup = () ->
  # Get IDs of original questions from test questions
  originals = []
  TestQuestions.find({}, {sort: {order: 1}}).forEach (doc) ->
    console.log "Order: " + doc.order
    originals.push(doc.original)
  # Fill client-side questions collection with originals, assign order and active tag
  originals = QIDArrayShuffle(originals)
  outscoredUpdate({questionIDArray: originals})
  for original, i in originals
    thisID = QuestionResults.insert(Questions.findOne(_id: original))
    QuestionResults.update(thisID, {$set: {order: (i + 1), result: false}})
  QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})

@QIDArrayShuffle = (originals) ->
  if Meteor.userId() || subUser()
    user = Meteor.user() || subUser()
    originals = _.shuffle(originals)
    if user.questionsMastered
      console.log "Mastered questions found, pushing to back."
      originals = masteredToBack(user, originals)
    return originals
  else
    return originals

@masteredToBack = (user, originals) ->
  normalArr = []
  masteredArr = []
  # Partition into normal and mastered arrays, push mastered to end
  (if id not in user.questionsMastered then normalArr else masteredArr).push id for id in originals
  if normalArr && masteredArr
    originals = normalArr.concat(masteredArr)
  else
    originals

@sectionStyleSetup = () ->
  $('.previous-question').hide()
  $('.navbar-fixed-bottom').css('position', 'relative')
  $('.navbar-fixed-bottom').css('position', 'absolute')

@shuffleChoices = () ->
  currentQuestion = getCurrentQuestion()
  questionViewCount(getCurrentQuestionID())
  shuffledChoices = _.shuffle(currentQuestion.choices)
  QuestionResults.update(result: true, {$set: {choices: shuffledChoices}})

@choicesIn = () ->
  if outscoredFind('noChoicesIn')
    $($('.not-animated-choice')[0]).removeClass('not-animated-choice')
      .addClass('animated fadeIn').show()
  else
    $($('.not-animated-choice')[0]).removeClass('not-animated-choice')
      .addClass('animated bounceInUp').show()

@choiceStatus = () ->
  if Meteor.userId() || subUser()
    user = Meteor.user() || subUser()
    questionID = getCurrentQuestionID()
    if user.questionsMastered && questionID in user.questionsMastered
      $('.choice').addClass('mastered-choice')
    else if user.questionsSkilled && questionID in user.questionsSkilled
      $('.choice').addClass('skilled-choice')
    else if user.questionsCorrect && questionID in user.questionsCorrect
      $('.choice').addClass('correct-choice')

@choiceColor = () ->
  if Meteor.userId() || subUser()
    user = Meteor.user() || subUser()
    questionID = getCurrentQuestionID()
    if user.questionsMastered && questionID in user.questionsMastered
      return 'rgba(0,255,255,.3)'
    else if user.questionsSkilled && questionID in user.questionsSkilled
      return 'rgba(0,128,128,.3)'
    else if user.questionsCorrect && questionID in user.questionsCorrect
      return 'rgba(0,128,0,.3)'
    else if user.questionsIncorrect && questionID in user.questionsIncorrect
      $('.choice').removeClass('correct-choice skilled-choice mastered-choice')
      return 'black'
    else
      return 'black'

@questionOut = () ->
  $('.question, .choice').addClass('bounceOutLeft')
  Meteor.setTimeout nextQuestion, 500

@previousQuestion = () ->
  $('.next-question, .previous-question').show()
  current = outscoredFind('currentQuestionNum')
  outscoredUpdate({currentQuestionNum: current - 1})
  if outscoredFind('currentQuestionNum') <= 1
    $('.previous-question').hide()
  cycleQuestion()
  outscoredUpdate({noChoicesIn: false})

@nextQuestion = () ->
  $('.next-question, .previous-question').show()
  current = outscoredFind('currentQuestionNum')
  outscoredUpdate({currentQuestionNum: current + 1})
  if outscoredFind('currentQuestionNum') >= QuestionResults.find().count()
    $('.next-question').hide()
  cycleQuestion()
  outscoredUpdate({noChoicesIn: false})

@cycleQuestion = () ->
  reloadQuestion()
  QuestionResults.update({}, {$set: {result: false}}, {multi: true})
  if Meteor.userId() || subUser()
    QuestionResults.update(_id: outscoredFind('questionIDArray')[0], {$set: {result: true}})
  else
    QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})
  resetQuestion()
  QIDArray = masteredToBack((Meteor.user() || subUser()), outscoredFind('questionIDArray'))
  outscoredUpdate({questionIDArray: QIDArray})
  shuffleChoices()

@reloadQuestion = () ->
  if Meteor.userId() || subUser()
    questionIDArray = outscoredFind('questionIDArray')
    console.log questionIDArray
    arrLength = questionIDArray.length
    questionID = questionIDArray.shift()
    console.log questionIDArray
    if outscoredFind('isMastered')
      console.log "Mastered, pushed to end of array."
      questionIDArray.push(questionID)
    else if outscoredFind('isSkilled')
      index = getIndex(30, 100, arrLength)
      console.log "Skilled, new index is: " + index + "/" + arrLength
      questionIDArray.splice((index - 1), 0, questionID)
    else if outscoredFind('isCorrect')
      index = getIndex(10, 50, arrLength)
      console.log "Correct, new index is: " + index + "/" + arrLength
      questionIDArray.splice((index - 1), 0, questionID)
    else if outscoredFind('isIncorrect')
      index = getIndex(10, 30, arrLength)
      console.log "Incorrect, new index is: " + index + "/" + arrLength
      questionIDArray.splice((index - 1), 0, questionID)
    console.log questionIDArray
    outscoredUpdate({questionIDArray: questionIDArray})

@getIndex = (lower, upper, arrLength) ->
  lowerLimit = Math.round(lower * arrLength / 100)
  upperLimit = Math.round(upper * arrLength / 100)
  return Math.floor(Math.random() * (upperLimit - lowerLimit)) + lowerLimit

@resetQuestion = () ->
  outscoredUpdate({isCorrect: false})
  outscoredUpdate({isSkilled: false})
  outscoredUpdate({isMastered: false})
  outscoredUpdate({isIncorrect: false})
  outscoredUpdate({clickedChoice: false})

# @processSelection = (choice) ->
#   if choice.match(JP_DIGIT_REGEX)
#     choice.match(JP_DIGIT_REGEX)[1]
#   else if choice.match(JP_PARENTH_REGEX)
#     choice.match(JP_PARENTH_REGEX)[1]
#   else if choice.match(JP_CIRCLE_REGEX)
#     selection = choice.match(JP_CIRCLE_REGEX)[0]
#     switch selection
#       when '①' then '1'
#       when '②' then '2'
#       when '③' then '3'
#       when '④' then '4'
#       else selection

@correctClick = (event) ->
  questionCorrectCount(getCurrentQuestionID())
  masteryStatus()
  fadeInAnswer()
  correctClickAnimate()
  Meteor.setTimeout correctAnswer, 500

@correctClickAnimate = () ->
  $(event.target).css
    backgroundColor: 'lime'
  $(event.target).animate
    backgroundColor: choiceColor(),
    1500

@correctAnswer = () ->
  questionID = getCurrentQuestionID()
  if Meteor.userId() || subUser()
    user = Meteor.user() || subUser()
    if user.questionsMastered && questionID in user.questionsMastered
      outscoredUpdate({isMastered: true})
    else if user.questionsSkilled && questionID in user.questionsSkilled
      outscoredUpdate({isSkilled: true})
    else
      outscoredUpdate({isCorrect: true})
  else
    outscoredUpdate({isCorrect: true})
  Meteor.setTimeout questionOut, 1000

@incorrectClick = (event) ->
  questionIncorrectCount(getCurrentQuestionID())
  displayX()
  incorrectClickAnimate()
  Meteor.setTimeout (() ->
    fadeInAnswer()
    Meteor.setTimeout incorrectAnswer, 500
  ), 500

@incorrectClickAnimate = () ->
  $(event.target).css
    backgroundColor: 'red'
  $(event.target).animate
    backgroundColor: choiceColor(),
    1500

@displayX = () ->
  $('.x').show()
  $('.x').css
    color: 'red'
  $('.x').animate
    color: 'transparent',
    500
  Meteor.setTimeout (() ->
    $('.x').hide()
  ), 500

@incorrectAnswer = () ->
  outscoredUpdate({isIncorrect: true})
  $('.incorrect').css
    color: 'white'
  $('.incorrect').animate
    color: 'red',
    1500
  Meteor.setTimeout (() ->
    fadeInExplanation('.incorrect')
  ), 500

@fadeInAnswer = () ->
  $('.answer').show()
  $('.answer').css
    backgroundColor: 'white'
  $('.answer').animate
    backgroundColor: 'black',
    1500

@fadeInExplanation = (answerClass) ->
  $('.explanation').show()
  $('.explanation').css
    opacity: 0
  $('.explanation').animate
    opacity: 1,
    1500
  $('.choices').animate
    opacity: .2,
    1500
  # Are finish buttons covering text?
  if $('.finish')[0]
    # parseInt($(answerClass).css('font-size')) to get heading font size
    if $(answerClass).offset().top > $('.finish').offset().top
      outscoredUpdate({isTextCovered: true})
    else
      outscoredUpdate({isTextCovered: false})

@grayOut = () ->
  $('.choices').scrollTop(0)
  $('.finish').animate
    opacity: .3,
    500
  $('.choices').css
    opacity: .2
  $('.choices').animate
    opacity: 1,
    500

@grayIn = () ->
  $('.choices').scrollTop(0)
  $('.finish').animate
    opacity: 1,
    500
  $('.choices').animate
    opacity: .2,
    500

@masteryStatus = () ->
  if Meteor.userId() || subUser()
    currentTestSection = TestSections.findOne()
    currentTestID = currentTestSection.inTest
    testStatus(currentTestID)
    currentSectionID = currentTestSection.original
    sectionStatus(currentSectionID)

@getCurrentQuestion = () ->
  QuestionResults.findOne(result: true)

@getCurrentQuestionID = () ->
  QuestionResults.findOne(result: true)._id




# Meteor methods
  # Question side:

@questionViewCount = (questionID) ->
  Meteor.call( "questionViewCount", questionID, (error, id) ->
    if (error)
      alert error.reason
  )
  questionViewed(questionID)

@questionCorrectCount = (questionID) ->
  Meteor.call( "questionCorrectCount", questionID, (error, id) ->
    if (error)
      alert error.reason
  )
  questionCorrect(questionID)

@questionIncorrectCount = (questionID) ->
  Meteor.call( "questionIncorrectCount", questionID, (error, id) ->
    if (error)
      alert error.reason
  )
  questionIncorrect(questionID)

  # User side:

@testStatus = (testID) ->
  if Meteor.userId()
    Meteor.call( "testStatus", testID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subTestStatus(testID)

@sectionStatus = (sectionID) ->
  if Meteor.userId()
    Meteor.call( "sectionStatus", sectionID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subSectionStatus(sectionID)

@questionViewed = (questionID) ->
  if Meteor.userId()
    Meteor.call( "questionViewed", questionID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subQuestionViewed(questionID)

@questionCorrect = (questionID) ->
  if Meteor.userId()
    Meteor.call( "questionCorrect", questionID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subQuestionCorrect(questionID)

@questionIncorrect = (questionID) ->
  if Meteor.userId()
    Meteor.call( "questionIncorrect", questionID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subQuestionIncorrect(questionID)




# Sub-user methods

subTestStatus = (testID) ->
  user = subUser()
  test = Tests.findOne(_id: testID)
  userTestCorrect = _.intersection(test.hasQuestions, (user.questionsCorrect ||= []))
  numCorrect = userTestCorrect.length
  numSkilled = _.intersection(userTestCorrect, (user.questionsSkilled ||= [])).length
  numMastered = _.intersection(userTestCorrect, (user.questionsMastered ||= [])).length
  mastery = (numCorrect + numSkilled + numMastered) / 3 / (test.hasQuestions.length) * 100
  console.log "Test mastery is: " + mastery
  if mastery == 100
    console.log "TEST STATUS IS MASTERED!!!"
    subUserUpdate({_id: user._id}, {$addToSet: {testsMastered: testID}})
  else if mastery > 66
    subUserUpdate({_id: user._id}, {$addToSet: {testsSkilled: testID}})
  else if mastery > 33
    subUserUpdate({_id: user._id}, {$addToSet: {testsExperienced: testID}})
  else if mastery > 0
    subUserUpdate({_id: user._id}, {$addToSet: {testsAnswered: testID}})

subSectionStatus = (sectionID) ->
  user = subUser()
  section = Sections.findOne(_id: sectionID)
  userSectionCorrect = _.intersection(section.hasQuestions, (user.questionsCorrect ||= []))
  numCorrect = userSectionCorrect.length
  numSkilled = _.intersection(userSectionCorrect, (user.questionsSkilled ||= [])).length
  numMastered = _.intersection(userSectionCorrect, (user.questionsMastered ||= [])).length
  mastery = (numCorrect + numSkilled + numMastered) / 3 / (section.hasQuestions.length) * 100
  console.log "Section mastery is: " + mastery
  if mastery == 100
    console.log "SECTION STATUS IS MASTERED!!!"
    subUserUpdate({_id: user._id}, {$addToSet: {sectionsMastered: sectionID}})
  else if mastery > 66
    subUserUpdate({_id: user._id}, {$addToSet: {sectionsSkilled: sectionID}})
  else if mastery > 33
    subUserUpdate({_id: user._id}, {$addToSet: {sectionsExperienced: sectionID}})
  else if mastery > 0
    subUserUpdate({_id: user._id}, {$addToSet: {sectionsAnswered: sectionID}})

subQuestionViewed = (questionID) ->
  userID = subUser()._id
  console.log questionID + " question viewed, current user is: " + userID
  subUserUpdate({_id: userID}, {$addToSet: {questionsViewed: questionID}})
  subUserUpdate({_id: userID}, {$addToSet: {questionsSkipped: questionID}})

subQuestionCorrect = (questionID) ->
  userID = subUser()._id
  user = subUser()
  if user.questionsSkilled && questionID in user.questionsSkilled # Question mastered
    console.log questionID + " question mastered, current user is: " + userID
    subUserUpdate({_id: userID}, {$addToSet: {questionsMastered: questionID}})
  else if user.questionsCorrect && questionID in user.questionsCorrect # Question skilled
    console.log questionID + " question skilled, current user is: " + userID
    subUserUpdate({_id: userID}, {$addToSet: {questionsSkilled: questionID}})
  else # Question correct
    console.log questionID + " question correct, current user is: " + userID
    subUserUpdate({_id: userID}, {$pull: {questionsIncorrect: questionID}})
    subUserUpdate({_id: userID}, {$addToSet: {questionsCorrect: questionID}})
    subUserUpdate({_id: userID}, {$pull: {questionsSkipped: questionID}})

subQuestionIncorrect = (questionID) ->
  userID = subUser()._id
  console.log questionID + " question incorrect, current user is: " + userID
  subUserUpdate({_id: userID}, {$pull: {questionsCorrect: questionID}})
  subUserUpdate({_id: userID}, {$pull: {questionsSkilled: questionID}})
  subUserUpdate({_id: userID}, {$pull: {questionsMastered: questionID}})
  subUserUpdate({_id: userID}, {$addToSet: {questionsIncorrect: questionID}})
  subUserUpdate({_id: userID}, {$pull: {questionsSkipped: questionID}})