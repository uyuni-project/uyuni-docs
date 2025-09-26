/* 'use strict'

const get_lang = (url) => {
  if (!url) return 'en';
  const parts = url.split('/').filter(Boolean); // remove empty strings
  // Look for known language codes in the path
  const knownLangs = ['en', 'de', 'fr', 'es', 'ja', 'pt_br', 'zh', 'zh_cn', 'ko'];
  const match = parts.find(p => knownLangs.includes(p.toLowerCase()));
  return match ? match.toLowerCase() : 'en';
};

const langToHreflangMapping = {
  "en": "en-US",
  "de": "de-DE",
  "fr": "fr-FR",
  "es": "es-ES",
  "ja": "ja-JP",
  "pt_br": "pt-BR",
  "zh": "zh-CN",
  "zh_cn": "zh-CN",
  "ko": "ko-KR",
};

module.exports = (pageurl, type, nav) => {
  if (nav.page.layout === '404') return null;
  const lang = get_lang(pageurl);
  if (type === 'hreflang') {
    return langToHreflangMapping[lang] || 'en-US';
  } else {
    return lang;
  }
}; */