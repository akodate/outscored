@QuestionResults = new Meteor.Collection(null)

Template.sectionPage.created = () ->

  window.outscored.currentQuestionNum = 1
  QuestionResults.remove({})
  sectionSetup()



Template.sectionPage.rendered = () ->

  sectionStyleSetup()
  shuffleChoices()

Template.sectionPage.events
  "click .previous-question": (event, ui) ->
    window.outscored.currentQuestionNum -= 1
    $('.next-question').show()
    if window.outscored.currentQuestionNum <= 1
      $('.previous-question').hide()
    cycleQuestion()

  "click .next-question": (event, ui) ->
    window.outscored.currentQuestionNum += 1
    $('.previous-question').show()
    if window.outscored.currentQuestionNum >= QuestionResults.find().count()
      $('.next-question').hide()
    cycleQuestion()

  "click .choice": (event, ui) ->
    thisQuestion = QuestionResults.findOne({result: true})
    if thisQuestion.answer.match('^' + event.target.innerText + '$')
      correctAnswer(event)
    else
      incorrectAnswer(event)


Template.question.rendered = () ->
  console.log "Question template rendered."
  choicesIn = () ->
    $($('.not-animated')[0]).removeClass('not-animated')
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
  QuestionResults.update(order: window.outscored.currentQuestionNum, {$set: {result: true}})

@sectionStyleSetup = () ->
  $('.previous-question').hide()
  $('.navbar-fixed-bottom').css('position', 'relative')
  $('.navbar-fixed-bottom').css('position', 'absolute')

@shuffleChoices = () ->
  currentQuestion = QuestionResults.find(result: true).fetch()
  shuffledChoices = _.shuffle(currentQuestion[0]['choices'])
  QuestionResults.update(result: true, {$set: {choices: shuffledChoices}})

@cycleQuestion = () ->
  QuestionResults.update({}, {$set: {result: false}}, {multi: true})
  QuestionResults.update(order: window.outscored.currentQuestionNum, {$set: {result: true}})
  shuffleChoices()

@correctAnswer = (event) ->
  $(event.target).css
    backgroundColor: 'blue'
  $(event.target).animate
    backgroundColor: 'black',
    1500

@incorrectAnswer = (event) ->
  $(event.target).css
    backgroundColor: 'red'
  $(event.target).animate
    backgroundColor: 'black',
    1500