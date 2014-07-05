Deps.autorun ->

  if Meteor.userId()
    if subUser()
      Meteor.call( "subTransfer", subUser(), (error, id) ->
        if (error)
          alert error.reason
      )
    SubUser.remove({})

  else if SubUser.find().count() == 0
    console.log "Switched to sub-user"
    sessionSub = SessionAmplify.get('subUser')
    console.log sessionSub
    if sessionSub
      SubUser.insert(sessionSub)
    else
      SubUser.insert({})

  if !_.isEqual(SessionAmplify.get('subUser'), subUser())
    SessionAmplify.set('subUser', subUser())
    console.log "Sub-user data saved to session"
    console.log SessionAmplify.get('subUser')

# $(window).bind "beforeunload", (event) ->
#   if !Meteor.userId()
#     "You will lose your progress if you are not logged in."