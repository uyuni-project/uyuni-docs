'use strict'

// The site build copies en/modules into translations/<lang>/modules, and that
// copy is the path Antora records. A pull request has to change the English
// source. Anything under ja, ko, or zh_CN is dropped.
const translatedTree = /\/translations\/(?:ja|ko|zh_CN)(?:\/|$)/

module.exports = (url) => {
  if (typeof url !== 'string' || url === '') return ''
  if (translatedTree.test(url)) return ''
  const rewritten = url.replace('/translations/en/', '/en/')
  if (rewritten.includes('/translations/')) return ''
  if (!rewritten.includes('/en/modules/')) return ''
  return rewritten
}
