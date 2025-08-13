(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
  typeof define === 'function' && define.amd ? define(['exports'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.antoraSearch = {}));
})(this, (function (exports) { 'use strict';

  // -------------------------------------------------
  // Helpers: highlighting + meta description fetch
  // -------------------------------------------------
  function buildHighlightedText (text, positions, snippetLength) {
    const t = String(text || '');
    const textLength = t.length;
    const validPositions = (positions || [])
      .filter((p) => p && p.length > 0 && p.start >= 0 && p.start + p.length <= textLength);

    if (validPositions.length === 0) {
      const end = snippetLength >= textLength ? textLength : snippetLength;
      return [{ type: 'text', text: t.slice(0, end) + (end < textLength ? '...' : '') }];
    }

    const ordered = validPositions.slice().sort((a, b) => a.start - b.start);
    const first = ordered[0];
    const range = { start: 0, end: textLength };

    if (snippetLength && textLength > snippetLength) {
      const firstStart = first.start;
      const firstEnd = firstStart + first.length;

      range.start = firstStart - snippetLength < 0 ? 0 : t.lastIndexOf(' ', firstStart - snippetLength);
      range.end = firstEnd + snippetLength > textLength ? textLength : t.indexOf(' ', firstEnd + snippetLength);
      if (range.start === -1 || range.start == null) range.start = 0;
      if (range.end === -1 || range.end == null) range.end = textLength;
    }

    const nodes = [];
    if (first.start > range.start) {
      nodes.push({ type: 'text', text: (range.start > 0 ? '...' : '') + t.slice(range.start, first.start) });
    }

    let lastEnd = first.start;
    const within = ordered.filter((p) => p.start >= range.start && p.start + p.length <= range.end);

    for (const p of within) {
      const start = p.start;
      const end = start + p.length;
      if (lastEnd < start) nodes.push({ type: 'text', text: t.slice(lastEnd, start) });
      nodes.push({ type: 'mark', text: t.slice(start, end) });
      lastEnd = end;
    }

    if (lastEnd < range.end) {
      nodes.push({ type: 'text', text: t.slice(lastEnd, range.end) + (range.end < textLength ? '...' : '') });
    }
    return nodes;
  }

  function findTermPosition (lunr, term, text) {
    const str = String(text || '').toLowerCase();
    const needle = String(term || '').toLowerCase();
    const len = str.length;
    if (!needle) return { start: 0, length: 0 };

    for (let sliceEnd = 0, sliceStart = 0; sliceEnd <= len; sliceEnd++) {
      const ch = str.charAt(sliceEnd);
      const sliceLength = sliceEnd - sliceStart;
      if ((ch && ch.match(lunr.tokenizer.separator)) || sliceEnd === len) {
        if (sliceLength > 0) {
          const value = str.slice(sliceStart, sliceEnd);
          const idx = value.indexOf(needle);
          if (idx !== -1) return { start: sliceStart + idx, length: needle.length };
        }
        sliceStart = sliceEnd + 1;
      }
    }
    return { start: 0, length: 0 };
  }

  function getTermPosition (text, terms) {
    const positions = (terms || [])
      .map((term) => findTermPosition(globalThis.lunr, term, text))
      .filter((p) => p.length > 0)
      .sort((a, b) => a.start - b.start);
    return positions.length ? positions : [];
  }

  // Async meta description fetch with simple in-memory cache
  const __descCache = new Map();
  async function fetchMetaDescription (url) {
    try {
      const normalized = url.replace(/#.*$/, '');
      if (__descCache.has(normalized)) return __descCache.get(normalized);
      const p = (async () => {
        try {
          const res = await fetch(normalized, { credentials: 'same-origin' });
          if (!res.ok) return null;
          const html = await res.text();
          const m = html.match(/<meta\s+name=["']description["']\s+content=["']([^"']+)["']/i);
          return m ? m[1] : null;
        } catch { return null; }
      })();
      __descCache.set(normalized, p);
      return p;
    } catch { return null; }
  }

  function getTextTermsFromMetadata (metadata) {
    const terms = [];
    if (!metadata) return terms;
    for (const term in metadata) if (Object.prototype.hasOwnProperty.call(metadata, term)) {
      const fields = metadata[term];
      if (fields && Object.prototype.hasOwnProperty.call(fields, 'text')) terms.push(term);
    }
    return terms;
  }

  function pickDescription (doc) {
    const direct = doc && typeof doc.description === 'string' && doc.description.trim();
    if (direct) return doc.description.trim();
    const attr = doc && doc.attributes && typeof doc.attributes.description === 'string' && doc.attributes.description.trim();
    if (attr) return doc.attributes.description.trim();
    return '';
  }

  // -------------------------------------------------
  // Boot / DOM
  // -------------------------------------------------
  const cfgEl = document.getElementById('search-ui-script');
  const cfg = (cfgEl && cfgEl.dataset) || {};
  const snippetLength = parseInt(cfg.snippetLength || 100, 10);
  const siteRootPath = cfg.siteRootPath || '';

  appendStylesheet(cfg.stylesheet);
  const searchInput = document.getElementById('search-input');
  const searchResultContainer = document.createElement('div');
  searchResultContainer.classList.add('search-result-dropdown-menu');
  if (searchInput && searchInput.parentNode) searchInput.parentNode.appendChild(searchResultContainer);
  const facetFilterInput = document.querySelector('#search-field input[type=checkbox][data-facet-filter]');

  function appendStylesheet (href) {
    if (!href) return;
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
  }

  // -------------------------------------------------
  // Highlight integration
  // -------------------------------------------------
  function highlightPageTitle (title, terms) {
    const positions = getTermPosition(title, terms);
    return buildHighlightedText(title, positions, snippetLength);
  }

  function highlightSectionTitle (sectionTitle, terms) {
    if (!sectionTitle) return [];
    const text = sectionTitle.text;
    const positions = getTermPosition(text, terms);
    return buildHighlightedText(text, positions, snippetLength);
  }

  function highlightText (doc, terms) {
    const desc = pickDescription(doc);
    const src = desc || doc.text || '';
    const positions = getTermPosition(src, terms);
    return buildHighlightedText(src, positions, snippetLength);
  }

  function highlightHit (searchMetadata, sectionTitle, doc) {
    const terms = {};
    for (const term in searchMetadata) {
      const fields = searchMetadata[term];
      for (const field in fields) {
        terms[field] = [...(terms[field] || []), term];
      }
    }
    return {
      pageTitleNodes: highlightPageTitle(doc.title, terms.title || []),
      sectionTitleNodes: highlightSectionTitle(sectionTitle, terms.title || []),
      pageContentNodes: highlightText(doc, terms.text || []),
    };
  }

  // -------------------------------------------------
  // Rendering
  // -------------------------------------------------
  function createSearchResult (result, store, searchResultDataset) {
    let currentComponent;
    result.forEach(function (item) {
      const ids = item.ref.split('-');
      const docId = ids[0];
      const doc = store.documents[docId];
      let sectionTitle;
      if (ids.length > 1) {
        const titleId = ids[1];
        sectionTitle = (doc.titles || []).filter(function (x) { return String(x.id) === titleId; })[0];
      }
      const metadata = item.matchData.metadata;
      const highlightingResult = highlightHit(metadata, sectionTitle, doc);
      const textTerms = getTextTermsFromMetadata(metadata);
      const componentVersion = store.componentVersions[doc.component + '/' + doc.version];
      if (componentVersion !== undefined && currentComponent !== componentVersion) {
        const hdr = document.createElement('div');
        hdr.classList.add('search-result-component-header');
        const title = componentVersion.title;
        const displayVersion = componentVersion.displayVersion;
        hdr.appendChild(document.createTextNode(title + (doc.version && displayVersion ? ' ' + displayVersion : '')));
        searchResultDataset.appendChild(hdr);
        currentComponent = componentVersion;
      }
      searchResultDataset.appendChild(createSearchResultItem(doc, sectionTitle, item, highlightingResult, textTerms));
    });
  }

  function createSearchResultItem (doc, sectionTitle, item, highlightingResult, textTerms) {
    const breadcrumbs = doc.breadcrumbs || [];
    const chapterTitleText = breadcrumbs.length > 0 ? breadcrumbs[0] : '';
    const sectionTitleText = sectionTitle ? sectionTitle.text : doc.title;

    const documentTitle = document.createElement('div');
    documentTitle.classList.add('search-result-document-title');

    const chapterTitleEl = document.createElement('div');
    chapterTitleEl.classList.add('chapter-title');
    chapterTitleEl.textContent = chapterTitleText;

    const sectionTitleEl = document.createElement('div');
    sectionTitleEl.classList.add('section-title');
    sectionTitleEl.textContent = sectionTitleText;

    documentTitle.appendChild(chapterTitleEl);
    documentTitle.appendChild(sectionTitleEl);

    const documentHit = document.createElement('div');
    documentHit.classList.add('search-result-document-hit');

    const documentHitLink = document.createElement('a');
    documentHitLink.href = siteRootPath + doc.url + (sectionTitle ? '#' + sectionTitle.hash : '');
    documentHit.appendChild(documentHitLink);

    // initial (fast) render: use description if present in store, else body text
    highlightingResult.pageContentNodes.forEach(function (node) {
      let el;
      if (node.type === 'text') {
        el = document.createTextNode(node.text);
      } else {
        el = document.createElement('mark');
        el.classList.add('search-result-highlight');
        el.textContent = node.text;
      }
      documentHitLink.appendChild(el);
    });

    // async upgrade: replace snippet with <meta name="description"> if not present in store
    (async () => {
      const immediateDesc = pickDescription(doc);
      if (immediateDesc) return; // already using description
      const meta = await fetchMetaDescription(documentHitLink.href);
      if (!meta) return;
      const positions = getTermPosition(meta, textTerms || []);
      const nodes = buildHighlightedText(meta, positions, snippetLength);
      documentHitLink.textContent = '';
      nodes.forEach((node) => {
        let el;
        if (node.type === 'text') {
          el = document.createTextNode(node.text);
        } else {
          el = document.createElement('mark');
          el.classList.add('search-result-highlight');
          el.textContent = node.text;
        }
        documentHitLink.appendChild(el);
      });
    })();

    const searchResultItem = document.createElement('div');
    searchResultItem.classList.add('search-result-item');
    searchResultItem.appendChild(documentTitle);
    searchResultItem.appendChild(documentHit);

    searchResultItem.addEventListener('mousedown', function (e) { e.preventDefault(); });

    return searchResultItem;
  }

  function createNoResult (text) {
    const item = document.createElement('div');
    item.classList.add('search-result-item');
    const hit = document.createElement('div');
    hit.classList.add('search-result-document-hit');
    const msg = document.createElement('strong');
    msg.textContent = 'No results found for query "' + text + '"';
    hit.appendChild(msg);
    item.appendChild(hit);
    return item;
  }

  function clearSearchResults (reset) {
    if (reset === true && searchInput) searchInput.value = '';
    searchResultContainer.innerHTML = '';
  }

  function filter (result, documents) {
    const facetFilter = facetFilterInput && facetFilterInput.checked && facetFilterInput.dataset.facetFilter;
    if (facetFilter) {
      const pair = facetFilter.split(':');
      const field = pair[0], value = pair[1];
      return result.filter((item) => {
        const ids = item.ref.split('-');
        const docId = ids[0];
        const doc = documents[docId];
        return field in doc && doc[field] === value;
      });
    }
    return result;
  }

  function search (index, documents, queryString) {
    let query;
    let result = filter(
      index.query(function (lunrQuery) {
        const parser = new globalThis.lunr.QueryParser(queryString, lunrQuery);
        parser.parse();
        query = lunrQuery;
      }),
      documents
    );
    if (result.length > 0) return result;

    result = filter(
      index.query(function (lunrQuery) {
        lunrQuery.clauses = query.clauses.map((clause) => {
          if (clause.presence !== globalThis.lunr.Query.presence.PROHIBITED) {
            clause.term = clause.term + '*';
            clause.wildcard = globalThis.lunr.Query.wildcard.TRAILING;
            clause.usePipeline = false;
          }
          return clause;
        });
      }),
      documents
    );
    if (result.length > 0) return result;

    result = filter(
      index.query(function (lunrQuery) {
        lunrQuery.clauses = query.clauses.map((clause) => {
          if (clause.presence !== globalThis.lunr.Query.presence.PROHIBITED) {
            clause.term = '*' + clause.term + '*';
            clause.wildcard = globalThis.lunr.Query.wildcard.LEADING | globalThis.lunr.Query.wildcard.TRAILING;
            clause.usePipeline = false;
          }
          return clause;
        });
      }),
      documents
    );
    return result;
  }

  function searchIndex (index, store, text) {
    clearSearchResults(false);
    if (!text || text.trim() === '') return;
    const result = search(index, store.documents, text);
    const dataset = document.createElement('div');
    dataset.classList.add('search-result-dataset');
    searchResultContainer.appendChild(dataset);
    if (result.length > 0) {
      createSearchResult(result, store, dataset);
    } else {
      dataset.appendChild(createNoResult(text));
    }
  }

  function confineEvent (e) { e.stopPropagation(); }

  function debounce (func, wait, immediate) {
    let timeout;
    return function () {
      const context = this, args = arguments;
      const later = function () { timeout = null; if (!immediate) func.apply(context, args); };
      const callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  function enableSearchInput (enabled) {
    if (facetFilterInput) facetFilterInput.disabled = !enabled;
    if (searchInput) {
      searchInput.disabled = !enabled;
      searchInput.title = enabled ? '' : 'Loading index...';
    }
  }

  function isClosed () { return searchResultContainer.childElementCount === 0; }

  function executeSearch (index) {
    const debug = 'URLSearchParams' in globalThis && new URLSearchParams(globalThis.location.search).has('lunr-debug');
    const query = (searchInput && searchInput.value) || '';
    try {
      if (!query) return clearSearchResults();
      searchIndex(index.index, index.store, query);
    } catch (err) {
      if (err instanceof globalThis.lunr.QueryParseError) {
        if (debug) console.debug('Invalid search query: ' + query + ' (' + err.message + ')');
      } else {
        console.error('Something went wrong while searching', err);
      }
    }
  }

  function toggleFilter (e, index) {
    if (searchInput) searchInput.focus();
    if (!isClosed()) executeSearch(index);
  }

  // -------------------------------------------------
  // initSearch (called by search-index.js)
  // -------------------------------------------------
  function initSearch (lunr, data) {
    const start = performance.now();
    const index = { index: lunr.Index.load(data.index), store: data.store };
    enableSearchInput(true);
    if (searchInput) {
      searchInput.dispatchEvent(new CustomEvent('loadedindex', { detail: { took: performance.now() - start } }));
      searchInput.addEventListener('keydown', debounce(function (e) {
        if (e.key === 'Escape' || e.key === 'Esc') return clearSearchResults(true);
        executeSearch(index);
      }, 100));
      searchInput.addEventListener('click', confineEvent);
    }
    searchResultContainer.addEventListener('click', confineEvent);
    if (facetFilterInput) {
      facetFilterInput.parentElement.addEventListener('click', confineEvent);
      facetFilterInput.addEventListener('change', (e) => toggleFilter(e, index));
    }
    document.documentElement.addEventListener('click', clearSearchResults);
  }

  // Disable input until index is ready
  enableSearchInput(false);

  // UMD export
  exports.initSearch = initSearch;
  Object.defineProperty(exports, '__esModule', { value: true });
}));
