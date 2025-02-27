'use strict'

const extractModuleFromURL = (url) => url.split('/')[3] || null

const findModule = (nav, module) =>
  (nav.url && extractModuleFromURL(nav.url) === module) ||
  (Array.isArray(nav.items) && nav.items.some((item) => findModule(item, module)))

module.exports = (navList, module) => navList.filter((nav) => findModule(nav, module))
