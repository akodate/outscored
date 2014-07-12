Template._loginButtonsLoggedInDropdownActions.helpers

  signOut: ->
    if Localization.findOne().region == 'JP'
      return "ログアウト"
    else
      return "Log out"


Template._loginButtonsLoggedOutDropdown.helpers

  signIn: ->
    if Localization.findOne().region == 'JP'
      return "ログイン"
    else
      return "Log in"

Template._loginButtonsLoggedOutSingleLoginButton.helpers

  beforeCapitalizedName: ->
    if Localization.findOne().region == 'JP'
      return ""
    else
      return "Log in with "

  afterCapitalizedName: ->
    if Localization.findOne().region == 'JP'
      return "でログイン"
    else
      return ""