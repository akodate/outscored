Template.correct.rendered = () ->

  $('.correct').css
    color: 'white'
  $('.correct').animate
    color: 'lime',
    500

Template.correct.helpers

  correct: ->
    if Localization.findOne().region == 'JP'
      return "正解です！"
    else
      return "Correct!"




Template.skilled.rendered = () ->

  $('.skilled').css
    color: 'white'
  $('.skilled').animate
    color: 'rgb(0,128,128)',
    500

Template.skilled.helpers

  skilled: ->
    if Localization.findOne().region == 'JP'
      return "また正解です！！"
    else
      return "Skilled!!"




Template.mastered.rendered = () ->

  $('.mastered').css
    color: 'white'
  $('.mastered').animate
    color: 'rgb(0,255,255)',
    500

Template.mastered.helpers

  mastered: ->
    if Localization.findOne().region == 'JP'
      return "覚えました！！！"
    else
      return "MASTERED!!!"




Template.incorrect.rendered = () ->

  $('.incorrect').css
    color: 'white'
  $('.incorrect').animate
    color: 'red',
    1500

Template.incorrect.helpers

  incorrect: ->
    if Localization.findOne().region == 'JP'
      return "が正解でした..."
    else
      return "...is the correct answer"