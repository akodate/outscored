@JSON_REGEX = /^.*\.json$/i
@TEST_REGEX = /^[^\/]+$/i # No /
@QUESTION_REGEX = /^.*\.+.*$/i # has .
@SECTION_REGEX = /.*/ # Placeholder, dynamically generated
@MIDSECTION_REGEX = /.*/ # Placeholder, dynamically generated

@String.prototype.capitalize = () ->
  return this[0].toUpperCase() + this[1..-1].toLowerCase();

# Is JSON?
@isJSONFile = (file) ->
  JSON_REGEX.test(file)

# Returns JSON object
@parseJSONFile = (file) ->
  return JSON.parse(Assets.getText(file))