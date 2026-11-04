'use strict'

const assert = require('node:assert/strict')
const { test } = require('node:test')

const tocTitleForLang = require('./mlm/susecom-2025/helpers/tocTitleForLang')

test('uses the playbook language code', () => {
  assert.equal(tocTitleForLang('en'), 'On this page')
  assert.equal(tocTitleForLang('ja'), 'このページで')
  assert.equal(tocTitleForLang('ko'), '이 페이지에서')
  assert.equal(tocTitleForLang('zh_CN'), '在此页面上')
})

test('falls back to English for an unknown code', () => {
  assert.equal(tocTitleForLang('zh'), 'On this page')
  assert.equal(tocTitleForLang('ja-jp'), 'On this page')
  assert.equal(tocTitleForLang(undefined), 'On this page')
})
