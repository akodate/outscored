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
        correctAnswer(event)
      else
        incorrectAnswer(event)
      $('.question-area').hide()
      $('.answer-area').show()
      # nextQuestion()


Template.question.rendered = () ->
  console.log "Question template rendered."
  choicesIn = () ->
    $($('.not-animated-choice')[0]).removeClass('not-animated-choice')
      .addClass('animated bounceInLeft').show()
  choicesIn()
  setInterval choicesIn, 300

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

@correctAnswer = (event) ->
  $(event.target).css
    backgroundColor: 'lime'
  $(event.target).animate
    backgroundColor: 'black',
    1500
  outscoredUpdate({isCorrect: true})

@incorrectAnswer = (event) ->
  $(event.target).css
    backgroundColor: 'red'
  $(event.target).animate
    backgroundColor: 'black',
    1500
  outscoredUpdate({isCorrect: false})