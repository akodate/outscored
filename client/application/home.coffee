@Results = new Meteor.Collection(null)
@SectionResults = new Meteor.Collection(null)

Template.home.rendered = () ->

  SectionResults.remove({})

  unless @rendered == true
    Tests.find().forEach( (doc) ->
      Results.insert(doc)
      @rendered = true
    )

  arrow = $('.search-arrow')

  point = () ->
    arrow.removeClass('slideInLeft')
    arrow.addClass('shake')
    arrow[0].style.webkitAnimationDuration = '5s'

  arrow[0].addEventListener('webkitAnimationEnd', point)
  arrow[0].addEventListener('mozAnimationEnd', point)
  arrow[0].addEventListener('MSAnimationEnd', point)
  arrow[0].addEventListener('oanimationend', point)
  arrow[0].addEventListener('animationend', point)

Template.home.events

  "keyup .search-box": (event, ui) ->
    $('.search-arrow').animate
      opacity: 0.25
    @search = event.target.value
    SectionResults.remove({})
    Results.update({}, {$set: {result: false}}, {multi: true})
    if @search
      Results.update({name: {$regex: @search, $options: "i" }}, {$set: {result: true}}, {multi: true})
  "click .search-result": (event, ui) ->
    console.log event.target.innerText
    Results.update({}, {$set: {result: false}}, {multi: true})
    Results.update({name: event.target.innerText}, {$set: {result: true}})

    testResult = Results.findOne(result: true)
    SectionResults.remove({})
    TestSections.find({_id: {$in: testResult.children}}).fetch()
    TestSections.find({_id: {$in: testResult.children}}).forEach( (doc) ->
      doc.name = (/[^\/]+$/.exec(doc.filePath))
      SectionResults.insert(doc)
      console.log "Executing...."
    )
    $('.search-box').focus()
  "click .section-result": (event, ui) ->
    console.log event.target.innerText
    sectionResult = SectionResults.findOne({name: event.target.innerText})
    console.log sectionResult.name
    console.log sectionResult.original
    Router.go('sectionPage', {testSecID: sectionResult._id, secID: sectionResult.original})

Template.home.helpers
  results: ->
    console.log "LOG THIS"
    tests = Results.find({result: true}, {sort: {name: 1}, limit: 5}).fetch()
    # Assign order to results
    if tests.length > 0
      for test, i in tests
        tests[i].styleLeft = i * 30 + 20
        tests[i].styleTop = i * 75 + 340
    return tests
  sections: ->
    console.log "Sections..."
    sections = SectionResults.find({}, {sort: {name: 1}}).fetch()
