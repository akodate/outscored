@Results = new Meteor.Collection(null)

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
    search = event.target.value
    Results.update({}, {$set: {result: false}}, {multi: true})
    Results.update({name: {$regex: "^" + search, $options: "i" }}, {$set: {result: true}}, {multi: true})
    console.log search

Template.home.helpers
  results: ->
    console.log "LOG THIS"
    tests = Results.find({result: true}, {sort: {name: 1}, limit: 5} ).fetch()
    return tests
