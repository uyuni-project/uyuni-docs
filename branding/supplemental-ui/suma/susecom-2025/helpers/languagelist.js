'use strict'

const modules = new Set()
const extractModuleFromURL = (url) => url.split('/')[3] || null

const languagesList = [
  { id: 'en', image: 'engFlag.svg', class: 'english', label: 'English' },
  { id: 'zh', image: 'china.svg', class: 'china', label: '中文' },
  { id: 'ko', image: 'koFlag.svg', class: 'korea', label: '한국어' },
  { id: 'ja', image: 'jaFlag.svg', class: 'japan', label: '日本語' },
]

const getModules = (navigation) => {
  if (navigation.url) {
    modules.add(extractModuleFromURL(navigation.url))
  } else if (Array.isArray(navigation.items)) {
    navigation.items.forEach((item) => getModules(item))
  }
}

module.exports = (navigation, uiRootPath) => {
  let finalResponse = []
  if (Array.isArray(navigation)) {
    navigation.forEach((nav) => getModules(nav))
    const res = languagesList.filter((lang) => modules.has(lang.id))
    finalResponse = res.map((item) => {
      return {
        ...item,
        uiRootPath,
      }
    })
  }
  return finalResponse
}
