@QuestionResults = new Meteor.Collection(null)

Template.sectionPage.created = () ->

  outscoredUpdate({currentQuestionNum: 1})
  outscoredUpdate({clickedSection: false})
  QuestionResults.remove({})
  sectionSetup()



Template.sectionPage.rendered = () ->

  sectionStyleSetup()
  shuffleChoices()

Template.sectionPage.events
  "click .previous-question": (event, ui) ->
    current = outscoredFind('currentQuestionNum')
    outscoredUpdate({currentQuestionNum: current - 1})
    $('.next-question').show()
    if outscoredFind('currentQuestionNum') <= 1
      $('.previous-question').hide()
    cycleQuestion()

  "click .next-question": (event, ui) ->
    current = outscoredFind('currentQuestionNum')
    outscoredUpdate({currentQuestionNum: current + 1})
    $('.previous-question').show()
    if outscoredFind('currentQuestionNum') >= QuestionResults.find().count()
      $('.next-question').hide()
    cycleQuestion()

  "click .choice": (event, ui) ->
    if outscoredFind('clickedSection') == false
      thisQuestion = QuestionResults.findOne({result: true})
      outscoredUpdate({clickedSection: true})
      if thisQuestion.answer.match('^' + event.target.innerText + '$')
        correctClick(event)
        fadeInAnswer()
        Meteor.setTimeout (() ->
          correctAnswer event
        ), 500
      else
        incorrectClick(event)
        displayX()
        Meteor.setTimeout (() ->
          fadeInAnswer()
          Meteor.setTimeout (() ->
            incorrectAnswer event
          ), 500
        ), 500
      $('.question-area').hide()
      $('.answer-area').show()
      # nextQuestion()


Template.question.rendered = () ->

  choicesIn = () ->
    $($('.not-animated-choice')[0]).removeClass('not-animated-choice')
      .addClass('animated bounceInLeft').show()
  choicesIn()
  Meteor.setInterval choicesIn, 300



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
    console.log "EXPLANATION: " + explanation
    return explanation.replace(/<(?:.|\n)*?>/gm, '')




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

@cycleQuestion = () ->
  QuestionResults.update({}, {$set: {result: false}}, {multi: true})
  QuestionResults.update(order: outscoredFind('currentQuestionNum'), {$set: {result: true}})
  shuffleChoices()
  outscoredUpdate({clickedSection: false})

@correctClick = (event) ->
  $(event.target).css
    backgroundColor: 'lime'
  $(event.target).animate
    backgroundColor: 'black',
    1500

@correctAnswer = (event) ->
  outscoredUpdate({isCorrect: true})
  $('.correct').show()
  $('.correct').css
    color: 'white'
  $('.correct').animate
    color: 'lime',
    1500
  Meteor.setTimeout fadeInExplanation, 500

@incorrectClick = (event) ->
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

@incorrectAnswer = (event) ->
  outscoredUpdate({isCorrect: false})
  $('.incorrect').show()
  $('.incorrect').css
    color: 'white'
  $('.incorrect').animate
    color: 'red',
    1500
  Meteor.setTimeout fadeInExplanation, 500

@fadeInAnswer = () ->
  $('.answer').show()
  $('.answer').css
    backgroundColor: 'white'
  $('.answer').animate
    backgroundColor: 'black',
    1500

@fadeInExplanation = () ->
  $('.explanation').show()
  $('.explanation').css
    color: 'transparent'
  $('.explanation').animate
    color: 'white',
    1500
