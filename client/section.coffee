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
      choice = choice.replace(/^\s+|\s+$/g, "")
      answer = thisQuestion.answer.replace(/^\s+|\s+$/g, "")
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




Template.sectionPage.helpers

  questions: ->
    return QuestionResults.find(result: true)

  sectionName: ->
    return TestSections.findOne().filePath



Template.question.helpers

  questionHeading: ->
    if Localization.findOne().region == 'JP'
      return "問題"
    else
      return "Question"

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

  correct: ->
    if Localization.findOne().region == 'JP'
      return "正解です！"
    else
      return "Correct!"

  incorrect: ->
    if Localization.findOne().region == 'JP'
      return "が正解でした..."
    else
      return "...is the correct answer"

  isCorrect: ->
    return outscoredFind('isCorrect')

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
  for original, i in originals
    thisID = QuestionResults.insert(Questions.findOne(_id: original))
    QuestionResults.update(thisID, {$set: {order: (i + 1), result: false}})
  QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})

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
  resetQuestion()
  QuestionResults.update({}, {$set: {result: false}}, {multi: true})
  QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})
  shuffleChoices()
  outscoredUpdate({clickedChoice: false})

@resetQuestion = () ->
  outscoredUpdate({isCorrect: false})
  outscoredUpdate({isIncorrect: false})
  outscoredUpdate({isSkilled: false})
  outscoredUpdate({isMastered: false})

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
    backgroundColor: 'black',
    1500

@correctAnswer = () ->
  outscoredUpdate({isCorrect: true})
  $('.correct').css
    color: 'white'
  $('.correct').animate
    color: 'lime',
    1500
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
    backgroundColor: 'black',
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
  if Meteor.userId()
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

@testStatus = (testID) ->
  Meteor.call( "testStatus", testID, (error, id) ->
    if (error)
      alert error.reason
  )

@sectionStatus = (sectionID) ->
  Meteor.call( "sectionStatus", sectionID, (error, id) ->
    if (error)
      alert error.reason
  )

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

@questionViewed = (questionID) ->
  Meteor.call( "questionViewed", questionID, (error, id) ->
    if (error)
      alert error.reason
  )

@questionCorrect = (questionID) ->
  Meteor.call( "questionCorrect", questionID, (error, id) ->
    if (error)
      alert error.reason
  )

@questionIncorrect = (questionID) ->
  Meteor.call( "questionIncorrect", questionID, (error, id) ->
    if (error)
      alert error.reason
  )