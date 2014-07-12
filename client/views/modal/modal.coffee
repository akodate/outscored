if Meteor.isClient
  Template.projectImageItem.events = "click .open-modal": (e, t) ->
    e.preventDefault()
    $("#projectImageModal").modal "show"
    return