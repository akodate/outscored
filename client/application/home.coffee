@Outscored = new Meteor.Collection(null)
@SubUser = new Meteor.Collection(null)
@Results = new Meteor.Collection(null)
@SectionResults = new Meteor.Collection(null)
@Localization = new Meteor.Collection(null)

Template.home.rendered = () ->

  # unless window.matchMedia("(max-width: 370px)").matches || window.matchMedia("(max-height: 400px)").matches
  #   window.alert "Please access outsco.red from a mobile device"
  #   window.stop()
  #   throw new Error "Mobile-only"

  if Outscored.find().count() == 0
    Outscored.insert({})
  outscoredUpdate({clickedTest: false, clickedSection: false, testsEntered: false})
  if SubUser.find().count() == 0
    SubUser.insert({})

  renderSetup()
  setDivHeights()
  searchArrowSetup()
  sectionsIn()

Template.header.events

  "click .navbar-brand": (event, ui) ->
    outscoredUpdate({testsEntered: false})
    if $('.search-box')[0]
      searchText = $('.search-box')[0].value
    else
      searchText = ''
    runSearch(searchText)

Template.home.events

  "keyup .search-box": (event, ui) ->
    outscoredUpdate({testsEntered: false})
    $(".search-arrow").animate
      opacity: 0.25
    searchText = $('.search-box')[0].value
    runSearch(searchText)

    # SectionResults.remove({})
    # Results.update({}, {$set: {result: false}}, {multi: true})
    # if @search
    #   Results.update({name: {$regex: @search, $options: "i" }}, {$set: {result: true}}, {multi: true})

  "click .search-result": (event, ui) ->
    showClickedTest()
    showTestSections()
    resetScroll()
    unless outscoredFind('clickedTest')
      outscoredUpdate({clickedTest: true})
      clickHighlight(event)

  "click .section-result": (event, ui) ->
    # Find section by clicked title and go to section page, use test to subscribe to questions
    sectionResult = SectionResults.findOne({name: event.target.innerText})
    console.log sectionResult
    test = Results.findOne({result: true})
    unless outscoredFind('clickedSection')
      outscoredUpdate({clickedSection: true})
      clickHighlight(event)
    if Meteor.userId() || subUser()
      sectionViewCount(sectionResult.original)
      testViewCount(test._id)
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
    searchText = $('.search-box')[0].value
    Meteor.setTimeout (() ->
      runSearch(searchText)
    ), 30



Template.home.helpers

  # Set flag image filename
  flag: ->
    localization = Localization.findOne()
    if localization
      region = localization.region
      return region.toLowerCase()
    else
      return 'us'

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
    console.log Localization.findOne().region
    if Localization.findOne().region == 'JP'
      return Results.find({result: true, name: /^\W/}, {sort: {name: 1}}).fetch()
    else
      return Results.find({result: true, name: /^\w/}, {sort: {name: 1}}).fetch()

  # Section results
  sections: ->
    sections = SectionResults.find({}, {sort: {name: 1}}).fetch()



# Helpers

@outscoredUpdate = (objects) ->
  Outscored.update({}, {$set: objects})

@outscoredFind = (field) ->
  Outscored.findOne()[field]

@subUser = () ->
  SubUser.findOne()

@subUserUpdate = (query, fields) ->
  SubUser.update(query, fields)

@setDivHeights = () ->
  $('#main').css('height', ($('.sheet')[0].offsetHeight - $('#main')[0].offsetTop) + 72)
  $('.result-box').css('height', ($('#main')[0].offsetHeight - $('.result-box')[0].offsetTop))

@setLocalization = () ->
  Localization.remove({})
  Localization.insert(region: 'US')
  internationalCSS('US')

@renderSetup = () ->
  # Clear data
  $('.search-results').hide()
  Results.remove({})
  SectionResults.remove({})

  # Fill data
  Tests.find().forEach( (doc) ->
    Results.insert(doc)
  )
  Results.update({}, {$set: {result: true}}, {multi: true})

@sectionsIn = () ->
  if $('.not-animated-section')[0] # jQuery found a test
    outscoredUpdate({testsEntered: true})
    if Meteor.userId() || subUser()
      colorTest($('.not-animated-section')[0])
  $($('.not-animated-section')[0]).removeClass('not-animated-section').addClass('animated bounceInUp').show() # Animate the first remaining test
  # Execute while jQuery hasn't found a test yet or tests can still be found
  if !outscoredFind('testsEntered') || $('.not-animated-section')[0]
    Meteor.setTimeout sectionsIn, 30

@colorTest = (testElement) ->
  testText = testElement.innerText.replace(/^\s+|\s+$/g, "")
  # console.log "Test text: " + testText
  currentTestID = Results.findOne(name: testText)._id
  user = Meteor.user() || subUser()
  if user.testsMastered && currentTestID in user.testsMastered
    $(testElement).addClass('mastered-test')
  else if user.testsSkilled && currentTestID in user.testsSkilled
    $(testElement).addClass('skilled-test')
  else if user.testsExperienced && currentTestID in user.testsExperienced
    $(testElement).addClass('experienced-test')
  else if user.testsAnswered && currentTestID in user.testsAnswered
    $(testElement).addClass('answered-test')

@searchArrowSetup = () ->
  arrow = $('.search-arrow')

  point = () ->
    arrow.removeClass('slideInLeft')
    arrow.addClass('shake')
  #   arrow[0].style.webkitAnimationDuration = '5s'
  #   arrow[0].style.mozAnimationDuration = '5s'
  #   arrow[0].style.oanimationDuration = '5s'
  #   arrow[0].style.animationDuration = '5s'

  # arrow[0].addEventListener('webkitAnimationEnd', point)
  # arrow[0].addEventListener('mozAnimationEnd', point)
  # arrow[0].addEventListener('MSAnimationEnd', point)
  # arrow[0].addEventListener('oanimationend', point)
  # arrow[0].addEventListener('animationend', point)

@runSearch = (searchText) ->
  outscoredUpdate({clickedSection: false})
  SectionResults.remove({})
  Results.update({}, {$set: {result: true}}, {multi: true})
  sectionsIn()
  if searchText
    for result in $(".search-result")
      if result.innerText.match(new RegExp('^' + searchText, 'i'))
        scrollResults(result)
        return
    for result in $(".search-result")
      if result.innerText.match(new RegExp(searchText, 'i'))
        scrollResults(result)
        return

@scrollResults = (result) ->
  $(".result-box").animate
    scrollTop: result.offsetTop - 160,
    300

@showClickedTest = () ->
  # Set only clicked test to 'result: true'
  $('.search-results').show()
  Results.update({}, {$set: {result: false}}, {multi: true})
  Results.update({name: event.target.innerText}, {$set: {result: true}})

@clickHighlight = (event) ->
  $(event.target).css
    backgroundColor: 'white'
  $(event.target).animate
    backgroundColor: 'black',
    1500

@showTestSections = () ->
  # Find children of clicked test and display them by their dir name
  testResult = Results.findOne(result: true)
  SectionResults.remove({})
  TestSections.find({_id: {$in: testResult.children}}).fetch()
  TestSections.find({_id: {$in: testResult.children}}).forEach( (doc) ->
    doc.name = (/[^\/]+$/.exec(doc.filePath))[0] ||= ''
    SectionResults.insert(doc)
    if Meteor.userId() || subUser()
      Meteor.setTimeout (() ->
        colorSection(doc)
      ), 30
  )

@colorSection = (section) ->
  for sectionElement in $('.section-result')
    if sectionElement.innerText == section.name
      user = Meteor.user() || subUser()
      if user.sectionsMastered && section.original in user.sectionsMastered
        $(sectionElement).addClass('mastered-section')
      else if user.sectionsSkilled && section.original in user.sectionsSkilled
        $(sectionElement).addClass('skilled-section')
      else if user.sectionsExperienced && section.original in user.sectionsExperienced
        $(sectionElement).addClass('experienced-section')
      else if user.sectionsAnswered && section.original in user.sectionsAnswered
        $(sectionElement).addClass('answered-section')

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

@setLocalization()




# Meteor methods
  # Question side:

@testViewCount = (testID) ->
  Meteor.call( "testViewCount", testID, (error, id) ->
    if (error)
      alert error.reason
  )
  testViewed(testID)

@sectionViewCount = (sectionID) ->
  Meteor.call( "sectionViewCount", sectionID, (error, id) ->
    if (error)
      alert error.reason
  )
  sectionViewed(sectionID)

  # User side:

@testViewed = (testID) ->
  if Meteor.userId()
    Meteor.call( "testViewed", testID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subTestViewed(testID)

@sectionViewed = (sectionID) ->
  if Meteor.userId()
    Meteor.call( "sectionViewed", sectionID, (error, id) ->
      if (error)
        alert error.reason
    )
  else if subUser()
    subSectionViewed(sectionID)




# Sub-user methods

@subTestViewed = (testID) ->
  userID = subUser()._id
  console.log testID + " test viewed, current user is: " + userID
  subUserUpdate({_id: userID}, {$addToSet: {testsViewed: testID}})

@subSectionViewed = (sectionID) ->
  userID = subUser()._id
  console.log sectionID + " section viewed, current user is: " + userID
  subUserUpdate({_id: userID}, {$addToSet: {sectionsViewed: sectionID}})