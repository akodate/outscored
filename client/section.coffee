@QuestionResults = new Meteor.Collection(null)
@currentQuestionNum = 1

Template.sectionPage.rendered = () ->
  $('.previous-question').hide()
  $('.navbar-fixed-bottom').css('position', 'relative')
  $('.navbar-fixed-bottom').css('position', 'absolute')

Template.sectionPage.events
  "click .previous-question": (event, ui) ->
    currentQuestionNum -= 1
    $('.next-question').show()
    if currentQuestionNum <= 1
      $('.previous-question').hide()
    QuestionResults.update({}, {$set: {result: false}}, {multi: true})
    QuestionResults.update(order: currentQuestionNum, {$set: {result: true}})

  "click .next-question": (event, ui) ->
    currentQuestionNum += 1
    $('.previous-question').show()
    if currentQuestionNum >= QuestionResults.find().count()
      $('.next-question').hide()
    QuestionResults.update({}, {$set: {result: false}}, {multi: true})
    QuestionResults.update(order: currentQuestionNum, {$set: {result: true}})

  "click .choice": (event, ui) ->
    thisQuestion = QuestionResults.findOne({result: true})
    if thisQuestion.answer.match(event.target.innerText)
      console.log "CORRECT"
    else
      console.log "INCORRECT"

Template.sectionPage.helpers
  questions: ->
    QuestionResults.remove({})
    # Get IDs of original questions from test questions
    originals = []
    TestQuestions.find({}, {sort: {order: 1}}).forEach (doc) ->
      console.log "Order: " + doc.order
      originals.push(doc.original)
    # Fill client-side questions collection with originals, assign order and active tag
    for original, i in originals
      thisID = QuestionResults.insert(Questions.findOne(_id: original))
      QuestionResults.update(thisID, {$set: {order: (i + 1), result: false}})
    QuestionResults.update(order: currentQuestionNum, {$set: {result: true}})
    return QuestionResults.find(result: true)

  sectionName: ->
    return TestSections.findOne().filePath

Template.question.helpers
  choice: ->
    choice = @.replace(/^\w*<br>*/, '')
    return choice