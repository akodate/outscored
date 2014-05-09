test_data = JSON.parse(Assets.getText('ACT Practice Test/Advanced Algebra/Advanced Algebra.json'))
console.log(JSON.stringify(test_data).substr(0,100))
console.log('Test found.')
console.log(process.cwd())





test = new Glob('**/**/*.json', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) ->
  return 'Matches: ' + match.toString()
)
console.log('Values returned: ' + test)
console.log('Type is: ' + typeof test)
console.log(test[75])