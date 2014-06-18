@Results = new Meteor.Collection(null)
@SectionResults = new Meteor.Collection(null)
@Localization = new Meteor.Collection(null)

Template.home.rendered = () ->

  # unless window.matchMedia("(max-width: 370px)").matches || window.matchMedia("(max-height: 400px)").matches
  #   window.alert "Please access outsco.red from a mobile device"
  #   window.stop()
  #   throw new Error "Mobile-only"

  # Set-up
  $('.search-results').hide()
  Results.remove({})
  SectionResults.remove({})

  unless @rendered == true
    Localization.insert(region: 'US')
    internationalCSS('US')
    Tests.find().forEach( (doc) ->
      Results.insert(doc)
      @rendered = true
    )

  # Search arrow animation
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
    # Set search matches to 'result: true'
    $('.search-arrow').animate
      opacity: 0.25
    @search = event.target.value
    SectionResults.remove({})
    Results.update({}, {$set: {result: false}}, {multi: true})
    if @search
      Results.update({name: {$regex: @search, $options: "i" }}, {$set: {result: true}}, {multi: true})

  # "click .search-result": (event, ui) ->
  #   # Set only clicked test to 'result: true'
  #   $('.search-results').show()
  #   console.log event.target.innerText
  #   Results.update({}, {$set: {result: false}}, {multi: true})
  #   Results.update({name: event.target.innerText}, {$set: {result: true}})
  #   # Find children of clicked test and display them by their dir name
  #   testResult = Results.findOne(result: true)
  #   SectionResults.remove({})
  #   TestSections.find({_id: {$in: testResult.children}}).fetch()
  #   TestSections.find({_id: {$in: testResult.children}}).forEach( (doc) ->
  #     doc.name = (/[^\/]+$/.exec(doc.filePath))
  #     SectionResults.insert(doc)
  #     console.log "Executing...."
  #   )
  #   $('.search-box').focus()

  "click .section-result": (event, ui) ->
    # Find section by clicked title and go to section page
    console.log event.target.innerText
    sectionResult = SectionResults.findOne({name: event.target.innerText})
    console.log sectionResult.name
    console.log sectionResult.original

    Router.go('sectionPage', {testSecID: sectionResult._id, secID: sectionResult.original})

  "click #localization": (event, ui) ->
    # Get 2-letter region from localization dropdown text
    if event.target.innerText == ''
      regionSelect = event.target.parentElement.innerText[0..1]
    else
      regionSelect = event.target.innerText[0..1]
    # Set language-specific CSS styles
    if regionSelect
      internationalCSS(regionSelect)
    # Update localization region
    Localization.update({}, {$set: {region: regionSelect}}, {multi: true})

  "click a[href*=#]": (event, ui) ->
    event.preventDefault()
    if location.pathname.replace(/^\//, "") is event.target.pathname.replace(/^\//, "") || location.hostname is event.target.hostname
      target = $(event.target.hash)
      target = (if target.length then target else $("[name=" + event.target.hash.slice(1) + "]"))
      if target.length
        $(".result-box").animate
          scrollTop: target.offset().top
        , 1000
        false
    console.log "CLICKED"


Template.home.helpers

  # Set flag image filename
  flag: ->
    localization = Localization.findOne()
    if localization
      region = localization.region
      return region.toLowerCase()

  # Set search heading text
  searchHeading: ->
    localization = Localization.findOne()
    if localization
      region = localization.region
      switch region
        when 'JP' then '今日は何を学ぶ？'
        else 'What will you study?'

  # Set search placeholder text
  searchPlaceholder: ->
    localization = Localization.findOne()
    if localization
      if window.matchMedia("(max-width: 370px)").matches
        region = localization.region
        switch region
          when 'JP' then 'ここで検索！'
          else 'Search here!'
      else
        switch region
          when 'JP' then 'ここで検索！'
          else 'Search by test, subject, or job!'

  # Test results
  results: ->
    tests = Results.find({result: true}, {sort: {name: 1}, limit: 1000}).fetch()
    return tests

  # Section results
  sections: ->
    console.log "Sections..."
    sections = SectionResults.find({}, {sort: {name: 1}}).fetch()



# Helpers

@internationalCSS = (regionSelect) ->
  # Login dropdown styling
  loginDropdown = $(".login, .login-button, #login-buttons-logout")
  loginDropdownMenu = $("#login-dropdown-list > .dropdown-menu")
  if window.matchMedia("(max-width: 370px)").matches
    switch regionSelect
      when 'JP'
        loginDropdown.css("font-size", "16px")
        loginDropdown.css("font-family", "Belgrano")
        loginDropdownMenu.css("left", "-70px")
      else
        loginDropdown.css("font-size", "20px")
        loginDropdown.css("font-family", "La Belle Aurore")
        loginDropdownMenu.css("left", "-93px")