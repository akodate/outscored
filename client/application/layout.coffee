Deps.autorun ->

  if Meteor.userId()
    if subUser()
      Meteor.call( "subTransfer", subUser(), (error, id) ->
        if (error)
          alert error.reason
      )

  else
    console.log "Switched to sub-user"
    if SubUser.find().count() == 0
      SubUser.insert({})