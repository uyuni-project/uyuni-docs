'use strict'

// Each language is its own Antora site. The playbook sets page-lang to the
// config code (ja, ko, zh_CN), which becomes page.attributes.lang and the
// html lang attribute. Language is not a segment of page.url.
const tocTitles = {
  en: 'On this page',
  ja: 'このページで',
  ko: '이 페이지에서',
  zh_CN: '在此页面上',
}

module.exports = (lang) => tocTitles[lang] || tocTitles.en
