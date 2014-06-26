@QuestionResults = new Meteor.Collection(null)

Template.sectionPage.created = () ->

  outscoredUpdate({currentQuestionNum: 1})
  outscoredUpdate({clickedChoice: false})
  outscoredUpdate({isTextCovered: false})
  outscoredUpdate({grayedOut: false})
  outscoredUpdate({noChoicesIn: false})
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
      else if answer.match(/^.$/)
        selection = processSelection(choice)
        if selection == answer
          correctClick(event)
        else
          incorrectClick(event)
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

  choice: ->
    choice = @.replace(/^\w*<br>*/, '')
    return choice

  totalQuestions: ->
    return QuestionResults.find().count()

  isCorrect: ->
    return outscoredFind('isCorrect')

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
  currentQuestion = QuestionResults.findOne(result: true)
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
  QuestionResults.update({}, {$set: {result: false}}, {multi: true})
  QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})
  shuffleChoices()
  outscoredUpdate({clickedChoice: false})

@processSelection = (choice) ->
  if choice.match(/^\d/)
    choice.match(/^\d/)[0]
  else if choice.match(/（(\d)/)
    choice.match(/（(\d)/)[1]
  else if choice.match(/[①②③④]/)
    selection = choice.match(/[①②③④]/)[0]
    switch selection
      when '①' then '1'
      when '②' then '2'
      when '③' then '3'
      when '④' then '4'
      else selection

@correctClick = (event) ->
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
  $('.correct').show()
  $('.correct').css
    color: 'white'
  $('.correct').animate
    color: 'lime',
    1500
  Meteor.setTimeout questionOut, 1000

@incorrectClick = (event) ->
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
  outscoredUpdate({isCorrect: false})
  $('.incorrect').show()
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