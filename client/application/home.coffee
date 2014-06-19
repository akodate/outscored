@Results = new Meteor.Collection(null)
@SectionResults = new Meteor.Collection(null)
@Localization = new Meteor.Collection(null)

Template.home.rendered = () ->

  # unless window.matchMedia("(max-width: 370px)").matches || window.matchMedia("(max-height: 400px)").matches
  #   window.alert "Please access outsco.red from a mobile device"
  #   window.stop()
  #   throw new Error "Mobile-only"

  setDivHeights()
  renderSetup()
  searchArrowSetup()



Template.home.events

  "keyup .search-box": (event, ui) ->
    $(".search-arrow").animate
      opacity: 0.25
    @search = event.target.value

    SectionResults.remove({})
    Results.update({}, {$set: {result: true}}, {multi: true})
    if @search
      for result in $(".search-result")
        if result.innerText.match(new RegExp('^' + @search, 'i'))
          $(".result-box").animate
            scrollTop: result.offsetTop - 160
          , 300
          return
      for result in $(".search-result")
        if result.innerText.match(new RegExp(@search, 'i'))
          $(".result-box").animate
            scrollTop: result.offsetTop - 160
          , 300
          return
      console.log @search

    # SectionResults.remove({})
    # Results.update({}, {$set: {result: false}}, {multi: true})
    # if @search
    #   Results.update({name: {$regex: @search, $options: "i" }}, {$set: {result: true}}, {multi: true})

  "click .search-result": (event, ui) ->

    showClickedTest(event, ui)
    showTestSections()
    resetScroll()

  "click .section-result": (event, ui) ->
    # Find section by clicked title and go to section page
    console.log event.target.innerText
    sectionResult = SectionResults.findOne({name: event.target.innerText})
    test = Results.findOne({result: true})
    console.log test.name
    console.log test._id
    console.log sectionResult.name
    console.log sectionResult.original

    Router.go('sectionPage', {testSecID: sectionResult._id, secID: sectionResult.original, testID: test._id})

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

  # Creates empty space at the bottom as needed so scroll works properly
  resultBottom: ->
    if Results.find({result: true}).count() > 1
      return ''
    else
      return 'none'

  # Test results
  results: ->
    tests = Results.find({result: true}, {sort: {name: 1}, limit: 1000}).fetch()
    return tests

  # Section results
  sections: ->
    console.log "Sections..."
    sections = SectionResults.find({}, {sort: {name: 1}}).fetch()



# Helpers

@setDivHeights = () ->
  $('#main').css('height', ($('.sheet')[0].offsetHeight - $('#main')[0].offsetTop) + 45)
  $('.result-box').css('height', ($('#main')[0].offsetHeight - $('.result-box')[0].offsetTop))

@renderSetup = () ->
  console.log "Rendered..."
  # Clear data
  $('.search-results').hide()
  Results.remove({})
  SectionResults.remove({})
  Localization.remove({})

  # Fill data
  Localization.insert(region: 'US')
  internationalCSS('US')
  Tests.find().forEach( (doc) ->
    Results.insert(doc)
  )
  Results.update({}, {$set: {result: true}}, {multi: true})

@searchArrowSetup = () ->
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

@showClickedTest = (event, ui) ->
  # Set only clicked test to 'result: true'
  $('.search-results').show()
  console.log event.target.innerText
  Results.update({}, {$set: {result: false}}, {multi: true})
  Results.update({name: event.target.innerText}, {$set: {result: true}})

@showTestSections = () ->
  # Find children of clicked test and display them by their dir name
  testResult = Results.findOne(result: true)
  SectionResults.remove({})
  TestSections.find({_id: {$in: testResult.children}}).fetch()
  TestSections.find({_id: {$in: testResult.children}}).forEach( (doc) ->
    doc.name = (/[^\/]+$/.exec(doc.filePath))
    SectionResults.insert(doc)
    console.log "Executing...."
  )

@resetScroll = () ->
  $('.result-box').scrollTop(0)
  if window.matchMedia("(min-width: 1000px)").matches || window.matchMedia("(min-height: 1000px)").matches
    $('.search-box').focus()

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