if Meteor.isClient
  Template.projectImageItem.events = "click .open-modal": (e, t) ->
    e.preventDefault()
    $("#completeModal").modal "show"
    return

Template.completeModal.events

  "click .modal-stop": (event, ui) ->
    Router.go('home')
    outscoredUpdate({testsEntered: false})
    searchText = ''
    runSearch(searchText)

Template.completeModal.helpers

  complete: ->
    if Localization.findOne().region == 'JP'
      return "Complete!!!"
    else
      return "Complete!!!"

  heading: ->
    if Localization.findOne().region == 'JP'
      return "このセクションの問題を全部マスターしました！"
    else
      return "You've mastered all the questions in this section!"

  stop: ->
    if Localization.findOne().region == 'JP'
      return "メインメニュー"
    else
      return "Main Menu"

  continue: ->
    if Localization.findOne().region == 'JP'
      return "復習を続ける"
    else
      return "Continue Reviewing"