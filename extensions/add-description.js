// extensions/add-description.js
module.exports.register = function (registry) {
  const getDesc = (page) => {
    const raw =
      (page.asciidoc && page.asciidoc.attributes && page.asciidoc.attributes.description) ||
      (page.attributes && page.attributes.description) || ''
    const clean = String(raw || '').trim()
    return clean || null
  }

  // Run after attributes are resolved, before search index builds
  registry.on('pageBuilt', (page) => {
    const desc = getDesc(page)
    if (!desc) return
    page.description = desc                 // nice-to-have
    page.attributes = page.attributes || {}
    page.attributes.description = desc      // <-- this one matters for Lunr
  })
}