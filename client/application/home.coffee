@Results = new Meteor.Collection(null)
@SectionResults = new Meteor.Collection(null)

Template.home.rendered = () ->

  unless @rendered == true
    Tests.find().forEach( (doc) ->
      Results.insert(doc)
      console.log "Doing this??"
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
    @search = event.target.value
    SectionResults.remove({})
    Results.update({}, {$set: {result: false}}, {multi: true})
    if @search
      Results.update({name: {$regex: @search, $options: "i" }}, {$set: {result: true}}, {multi: true})
  "click .search-result": (event, ui) ->
    console.log event.target.innerText
    Results.update({}, {$set: {result: false}}, {multi: true})
    Results.update({name: event.target.innerText}, {$set: {result: true}})

    test = Results.findOne(result: true)
    SectionResults.remove({})
    TestSections.find({_id: {$in: test.children}}).fetch()
    TestSections.find({_id: {$in: test.children}}).forEach( (doc) ->
      SectionResults.insert({doc, name: (/[^\/]+$/.exec(doc.filePath))})
      console.log "Executing...."
    )

Template.home.helpers
  results: ->
    console.log "LOG THIS"
    tests = Results.find({result: true}, {sort: {name: 1}, limit: 5}).fetch()
    return tests
  sections: ->
    console.log "Sections..."
    sections = SectionResults.find({}, {sort: {name: 1}}).fetch()
