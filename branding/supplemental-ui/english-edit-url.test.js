'use strict'

const assert = require('node:assert/strict')
const { test } = require('node:test')

const helpers = [
  require('./mlm/susecom-2025/helpers/englishEditUrl'),
  require('./uyuni/uyuni-2023/helpers/englishEditUrl'),
]

const sample = 'https://github.com/uyuni-project/uyuni-docs/edit/manager-5.2/translations/en/modules/administration/pages/monitoring.adoc'

for (const englishEditUrl of helpers) {
  test('rewrites the generated English copy to the source file', () => {
    assert.equal(
      englishEditUrl(sample),
      'https://github.com/uyuni-project/uyuni-docs/edit/manager-5.2/en/modules/administration/pages/monitoring.adoc'
    )
  })

  test('keeps a URL that already points at the English source', () => {
    const direct = 'https://github.com/uyuni-project/uyuni-docs/edit/master/en/modules/ROOT/pages/index.adoc'
    assert.equal(englishEditUrl(direct), direct)
  })

  test('drops translated trees', () => {
    for (const lang of ['ja', 'ko', 'zh_CN']) {
      const url = sample.replace('/translations/en/', `/translations/${lang}/`)
      assert.equal(englishEditUrl(url), '')
    }
  })

  test('drops empty values and paths that are not a page module', () => {
    assert.equal(englishEditUrl(''), '')
    assert.equal(englishEditUrl(undefined), '')
    assert.equal(
      englishEditUrl('https://github.com/uyuni-project/uyuni-docs/edit/master/translations/en/antora.yml'),
      ''
    )
  })
}
