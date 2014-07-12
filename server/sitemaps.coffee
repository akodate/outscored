sitemaps.add "/sitemap.xml", ->

  console.log "Sitemap."

# path: ':testName/:sectionName&:testID&:secID&:testSecID'
# Router.go('sectionPage', {testName: test.name, sectionName: section.name, testSecID: section._id, secID: section.original, testID: test._id})

  @SectionResults = new Meteor.Collection(null)
  out = []

  for test in Tests.find().fetch()
    getTestSections(test)
    sections = SectionResults.find().fetch()
    for section in sections
      if section.name.charCodeAt(0) < 127
        testName = test.name.replace(/[^a-z0-9]+/gi,'-')
        sectionName = section.name.replace(/[^a-z0-9]+/gi,'-')
      else
        testName = test.name
        sectionName = section.name
      out.push
        page: testName + '/' + sectionName + '/' + test._id + '/' + section.original + '/' + section._id
        lastmod: '2014-07-12'
      console.log _.last(out).page

  return out

@getTestSections = (test) ->
  SectionResults.remove({})
  TestSections.find({_id: {$in: test.children}}).forEach( (doc) ->
    doc.name = (/[^\/]+$/.exec(doc.filePath))[0] ||= ''
    SectionResults.insert(doc)
  )