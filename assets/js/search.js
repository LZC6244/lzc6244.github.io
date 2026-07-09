(function() {
  'use strict';

  var searchIndex = null;
  var searchTimer = null;
  var searchInput = document.getElementById('search-input');
  if (!searchInput) return;

  var MAX_QUERY_LEN = 100;
  var headerCharCount = document.getElementById('search-char-count');
  var overlayCharCount = null;

  var searchResults = document.getElementById('search-results');
  var searchIndexUrl = searchInput.dataset.searchUrl;

  var PAGE_SIZE = 8;
  var currentResults = [];
  var currentQuery = '';
  var currentPage = 0;
  var isLoading = false;
  var allLoaded = false;
  var closeBtn = document.getElementById('search-overlay-close');
  var _openOverlayGuard = false;
  var _mouseDownOnSearch = false;
  var _mousedownOnBg = false;
  var _scrollY = 0;

  // 搜索索引按 URL 去重
  function deduplicateIndex(arr) {
    var seen = {};
    return arr.filter(function(item) {
      var key = item.url;
      if (seen[key]) return false;
      seen[key] = true;
      return true;
    });
  }

  var _panelScrollBound = false;

  // 获取/创建结果内面板
  function getResultsPanel() {
    var panel = searchResults.querySelector('.search-results-panel');
    if (!panel) {
      panel = document.createElement('div');
      panel.className = 'search-results-panel';
      searchResults.appendChild(panel);
    }
    if (!_panelScrollBound) {
      _panelScrollBound = true;
      panel.addEventListener('scroll', function() {
        if (isLoading || allLoaded) return;
        if (this.scrollTop + this.clientHeight >= this.scrollHeight - 30) {
          loadMore();
        }
      });
    }
    return panel;
  }

  // 清除面板内容（带动画）
  function clearPanelSmooth() {
    var panel = getResultsPanel();
    if (panel._clearTimer) {
      clearTimeout(panel._clearTimer);
    }
    panel.style.transition = 'opacity 0.15s ease';
    panel.style.opacity = '0';
    panel._clearTimer = setTimeout(function() {
      panel.innerHTML = '';
      panel.style.opacity = '';
      panel.style.transition = '';
      panel._clearTimer = null;
    }, 160);
  }

  // 创建弹窗内搜索栏（与主搜索框联动）
  function ensureSearchBar() {
    var bar = searchResults.querySelector('.search-overlay-input');
    if (bar) return bar;

    bar = document.createElement('div');
    bar.className = 'search-overlay-input';

    var input = document.createElement('input');
    input.type = 'text';
    input.placeholder = '搜索文章…';
    input.maxLength = MAX_QUERY_LEN;

    var inputWrap = document.createElement('div');
    inputWrap.style.cssText = 'flex:1;position:relative;display:flex';
    inputWrap.appendChild(input);

    overlayCharCount = document.createElement('span');
    overlayCharCount.className = 'search-overlay-char-count';
    overlayCharCount.textContent = '0/' + MAX_QUERY_LEN;
    inputWrap.appendChild(overlayCharCount);

    bar.appendChild(inputWrap);

    var count = document.createElement('span');
    count.className = 'search-overlay-count';
    bar.appendChild(count);

    // 插入到面板前面
    var panel = searchResults.querySelector('.search-results-panel');
    if (panel) {
      searchResults.insertBefore(bar, panel);
    } else {
      searchResults.appendChild(bar);
    }

    // 弹窗内输入变化 → 同步到主搜索框 → 触发搜索
    var timer = null;
    input.addEventListener('input', function() {
      searchInput.value = this.value;
      updateCharCount(this.value.length);
      clearTimeout(timer);
      var query = this.value.trim();
      if (query === '') {
        clearPanelSmooth();
        currentPage = 0;
        allLoaded = false;
        return;
      }
      timer = setTimeout(function() {
        if (searchIndex === null) {
          fetch(searchIndexUrl)
            .then(function(res) { return res.json(); })
            .then(function(data) {
              searchIndex = deduplicateIndex(data);
              performSearch(query);
            })
            .catch(function() {
              getResultsPanel().innerHTML = '<div class="search-error">无法加载搜索索引</div>';
              openOverlay();
            });
        } else {
          performSearch(query);
        }
      }, 200);
    });

    return bar;
  }

  // 打开全屏弹窗
  function openOverlay() {
    // 已打开时跳过，避免 body 为 fixed 时 window.scrollY=0 覆盖已保存的滚动位置
    if (searchResults.classList.contains('open')) return;
    searchResults.classList.add('open');
    if (closeBtn) closeBtn.classList.add('open');
    // 锁定背景页面滚动
    _scrollY = window.scrollY;
    var scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.position = 'fixed';
    document.body.style.top = '-' + _scrollY + 'px';
    document.body.style.width = '100%';
    if (scrollBarWidth > 0) {
      document.body.style.paddingRight = scrollBarWidth + 'px';
    }
    // 确保弹窗内搜索栏存在
    ensureSearchBar();
    // 同步值并聚焦弹窗内搜索框
    var overlayInput = searchResults.querySelector('.search-overlay-input input');
    if (overlayInput) {
      overlayInput.value = searchInput.value;
      overlayInput.focus();
      overlayInput.setSelectionRange(overlayInput.value.length, overlayInput.value.length);
      updateCharCount(overlayInput.value.length);
    }
    // 标记打开时间，防止焦点触发弹窗后的误关闭
    _openOverlayGuard = true;
    setTimeout(function() { _openOverlayGuard = false; }, 300);
  }

  // 关闭全屏弹窗
  function closeOverlay() {
    if (!searchResults.classList.contains('open')) return;
    searchResults.classList.remove('open');
    if (closeBtn) closeBtn.classList.remove('open');
    // 解锁背景页面滚动
    document.body.style.position = '';
    document.body.style.top = '';
    document.body.style.width = '';
    document.body.style.paddingRight = '';
    window.scrollTo({ top: _scrollY, behavior: 'instant' });
    // 取消当前焦点，防止浏览器 scroll-into-view 导致页面滑动
    if (document.activeElement && document.activeElement !== document.body) {
      document.activeElement.blur();
    }
  }

  // 点击遮罩背景关闭（仅当鼠标按下也在遮罩上时才关闭，避免选中文字误触）
  searchResults.addEventListener('mousedown', function(e) {
    _mousedownOnBg = (e.target === searchResults);
  });
  searchResults.addEventListener('click', function(e) {
    if (e.target === searchResults && _mousedownOnBg && !_openOverlayGuard) {
      // 有选中文字时不关闭
      var sel = window.getSelection();
      if (sel && sel.toString().trim().length > 0) return;
      closeOverlay();
    }
  });

  // 关闭按钮
  if (closeBtn) {
    closeBtn.addEventListener('click', closeOverlay);
  }

  // ESC 键关闭搜索弹窗
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && searchResults.classList.contains('open')) {
      closeOverlay();
    }
  });

  // 预加载搜索索引，点击搜索框时立即可用
  fetch(searchIndexUrl)
    .then(function(res) { return res.json(); })
    .then(function(data) { searchIndex = deduplicateIndex(data); })
    .catch(function() {});

  function escapeRegex(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // 判断是否为纯英文关键词（需要单词边界匹配）
  function isWholeWord(k) {
    return /^[a-zA-Z0-9]+$/.test(k);
  }

  // 英文单词边界匹配，中文子串匹配
  function keywordMatches(text, keyword) {
    if (isWholeWord(keyword)) {
      return new RegExp('\\b' + escapeRegex(keyword) + '\\b', 'i').test(text);
    }
    return text.indexOf(keyword.toLowerCase()) !== -1;
  }

  function highlightMatch(text, query) {
    if (!text || !query) return text;
    var keywords = query.split(/\s+/).filter(function(k) { return k.length > 0; });
    if (keywords.length === 0) return text;
    var patterns = keywords.map(function(k) {
      var esc = escapeRegex(k);
      return isWholeWord(k) ? '\\b' + esc + '\\b' : esc;
    });
    var regex = new RegExp('(' + patterns.join('|') + ')', 'gi');
    return text.replace(regex, '<em>$1</em>');
  }

  function getSnippet(text, query, maxLen) {
    maxLen = maxLen || 200;

    // 去掉首尾空白
    text = text.replace(/^\s+/, '').replace(/\s+$/, '');

    var keywords = query.split(/\s+/).filter(function(k) { return k.length > 0; });
    if (keywords.length === 0) return text.substring(0, maxLen);

    // 找出所有关键词的所有命中位置（英文单词边界，中文子串）
    var lowerText = text.toLowerCase();
    var allMatches = [];
    keywords.forEach(function(k) {
      if (isWholeWord(k)) {
        // 英文：单词边界匹配
        var re = new RegExp('\\b' + escapeRegex(k) + '\\b', 'gi');
        var m;
        while ((m = re.exec(text)) !== null) {
          allMatches.push({ idx: m.index, len: k.length });
        }
      } else {
        // 中文：子串匹配
        var lowerK = k.toLowerCase();
        var idx = -1;
        while ((idx = lowerText.indexOf(lowerK, idx + 1)) !== -1) {
          allMatches.push({ idx: idx, len: k.length });
        }
      }
    });

    if (allMatches.length === 0) return text.substring(0, maxLen);

    // 按位置排序
    allMatches.sort(function(a, b) { return a.idx - b.idx; });

    var first = allMatches[0];
    var last = allMatches[allMatches.length - 1];
    var span = last.idx + last.len - first.idx;

    // 如果所有命中的跨度 ≤ maxLen，覆盖全部命中（关键词依然靠前）
    if (span <= maxLen) {
      var before = Math.floor((maxLen - span) * 0.15);
      var start = Math.max(0, first.idx - before);
      var end = Math.min(text.length, last.idx + last.len + (maxLen - span - before));
    } else {
      // 命中也太分散，以第一个为准（15%在前）
      var before = Math.floor((maxLen - first.len) * 0.15);
      var start = Math.max(0, first.idx - before);
      var end = Math.min(text.length, first.idx + first.len + (maxLen - before - first.len));
    }

    var snippet = '';
    if (start > 0) snippet += '…';
    snippet += text.substring(start, end);
    if (end < text.length) snippet += '…';

    return highlightMatch(snippet, query);
  }

  // 生成中文二元组（用于模糊匹配）
  function chineseBigrams(str) {
    var result = [];
    for (var i = 0; i < str.length - 1; i++) {
      var pair = str.substring(i, i + 2);
      if (/[\u4e00-\u9fff]/.test(pair[0]) && /[\u4e00-\u9fff]/.test(pair[1])) {
        result.push(pair);
      }
    }
    return result;
  }

  function performSearch(query) {
    var results = [];
    var rawKeywords = query.split(/\s+/).filter(function(k) { return k.length > 0; });
    if (rawKeywords.length === 0) return;

    // 判断是否为连续中文（无空格），需要分词处理
    var needsFuzzy = rawKeywords.some(function(k) {
      return /[\u4e00-\u9fff]{3,}/.test(k);
    });

    searchIndex.forEach(function(post) {
      var title = post.title || '';
      var content = post.content || '';
      var searchText = (title + ' ' + content).toLowerCase();

      // 标准匹配：英文单词边界，中文子串
      var exactMatch = rawKeywords.every(function(k) {
        return keywordMatches(searchText, k);
      });

      if (exactMatch) {
        results.push(makeResult(post, title, content, query));
        return;
      }

      // 中文模糊匹配：如果含连续中文，用二元组评分
      if (needsFuzzy) {
        var totalBigrams = 0;
        var matchedBigrams = 0;
        rawKeywords.forEach(function(k) {
          if (/[\u4e00-\u9fff]{3,}/.test(k)) {
            var bigrams = chineseBigrams(k);
            bigrams.forEach(function(b) {
              totalBigrams++;
              if (searchText.indexOf(b.toLowerCase()) !== -1) matchedBigrams++;
            });
          }
        });
        if (totalBigrams > 0 && matchedBigrams / totalBigrams > 0.4) {
          results.push(makeResult(post, title, content, query));
        }
      }
    });

    currentQuery = query;
    currentPage = 0;
    allLoaded = false;

    // 结果去重（防止搜索索引有重复）
    var seen = {};
    results = results.filter(function(r) {
      var key = r.url;
      if (seen[key]) return false;
      seen[key] = true;
      return true;
    });
    currentResults = results;

    // 创建/更新弹窗内搜索栏
    var bar = ensureSearchBar();
    var barInput = bar.querySelector('input');
    if (barInput) barInput.value = query;
    var barCount = bar.querySelector('.search-overlay-count');
    if (barCount) barCount.textContent = '文章数: ' + results.length;

    // 重置面板（取消可能正在进行的清除动画）
    var panel = getResultsPanel();
    if (panel._clearTimer) {
      clearTimeout(panel._clearTimer);
      panel._clearTimer = null;
    }
    panel.style.opacity = '';
    panel.style.transition = '';
    panel.innerHTML = '';
    openOverlay();
    loadMore();
  }

  function makeResult(post, title, content, query) {
    return {
      title: title,
      url: post.url,
      snippet: getSnippet(content, query),
      titleHighlighted: highlightMatch(title, query),
      date: post.date,
      cats: post.categories || []
    };
  }

  function loadMore() {
    if (isLoading || allLoaded) return;
    isLoading = true;

    var results = currentResults;
    var start = currentPage * PAGE_SIZE;
    var end = Math.min(start + PAGE_SIZE, results.length);

    if (currentPage === 0) {
      var loadingEl = document.createElement('div');
      loadingEl.className = 'search-loading';
      loadingEl.textContent = '加载中...';
      getResultsPanel().appendChild(loadingEl);
    }

    var panel = getResultsPanel();

    requestAnimationFrame(function() {
      var loadEl = panel.querySelector('.search-loading');
      if (loadEl) loadEl.parentNode.removeChild(loadEl);

      if (start >= results.length) {
        allLoaded = true;
        if (currentPage === 0) {
          getResultsPanel().innerHTML = '<div class="search-no-result">未找到匹配结果</div>';
        }
        isLoading = false;
        return;
      }

      var items = results.slice(start, end);
      var fragment = document.createDocumentFragment();

      items.forEach(function(r) {
        var tagsHtml = '';
        if (r.cats && r.cats.length > 0) {
          tagsHtml = r.cats.slice(0, 2).map(function(t) {
            return '<span class="search-result-tag">' + t + '</span>';
          }).join('');
        }
        
        var date = r.date || '';
        var el = document.createElement('a');
        el.className = 'search-result-item';
        el.href = r.url;
        el.innerHTML = '<span class="search-result-title">' + (r.titleHighlighted || r.title) + '</span>' +
                '<span class="search-result-meta">' +
                  (date ? '<span class="search-result-date">' + date + '</span>' : '') +
                  tagsHtml +
                '</span>' +
                '<span class="search-result-snippet">' + r.snippet + '</span>';
        fragment.appendChild(el);
      });

      getResultsPanel().appendChild(fragment);

      currentPage++;
      isLoading = false;

      if (currentPage * PAGE_SIZE >= results.length) {
        allLoaded = true;
        var endEl = document.createElement('div');
        endEl.className = 'search-loading search-loading-end';
        endEl.textContent = '— 已加载全部 ' + results.length + ' 篇 —';
        getResultsPanel().appendChild(endEl);
      } else if (panel.scrollHeight <= panel.clientHeight) {
        // 内容未填满面板，自动加载下一页
        loadMore();
      }
    });
  }

  // 鼠标按下时标记并阻止默认行为（防止 focus 立即打开弹窗导致文字选择时页面滑动）
  searchInput.addEventListener('mousedown', function(e) {
    _mouseDownOnSearch = true;
    e.preventDefault();
  });

  // 鼠标释放后打开弹窗（click 是 mouseup 后的最后事件，此时遮罩不会干扰）
  searchInput.addEventListener('click', function() {
    _mouseDownOnSearch = false;
    openOverlay();
    // 如果已有内容，在弹窗内触发搜索
    var query = this.value.trim();
    if (query !== '') {
      clearTimeout(searchTimer);
      searchTimer = setTimeout(function() {
        if (searchIndex === null) {
          fetch(searchIndexUrl)
            .then(function(res) { return res.json(); })
            .then(function(data) {
              searchIndex = deduplicateIndex(data);
              performSearch(query);
            })
            .catch(function() {
              getResultsPanel().innerHTML = '<div class="search-error">无法加载搜索索引</div>';
            });
        } else {
          performSearch(query);
        }
      }, 200);
    }
  });

  // 键盘 Tab/Enter 聚焦时弹出弹窗（mousedown 已 preventDefault，鼠标点击由 click 处理）
  searchInput.addEventListener('focus', function() {
    if (_mouseDownOnSearch) return;
    openOverlay();
  });

  // 更新字符计数器
  function updateCharCount(len) {
    var text = len + '/' + MAX_QUERY_LEN;
    if (headerCharCount) headerCharCount.textContent = text;
    if (overlayCharCount) overlayCharCount.textContent = text;
  }

  searchInput.addEventListener('input', function() {
    var query = this.value.trim();
    updateCharCount(this.value.length);
    clearTimeout(searchTimer);

    if (query === '') {
      clearPanelSmooth();
      currentPage = 0;
      allLoaded = false;
      return;
    }

    searchTimer = setTimeout(function() {
      if (searchIndex === null) {
        fetch(searchIndexUrl)
          .then(function(res) { return res.json(); })
          .then(function(data) {
            searchIndex = deduplicateIndex(data);
            performSearch(query);
          })
          .catch(function() {
            getResultsPanel().innerHTML = '<div class="search-error">无法加载搜索索引</div>';
            openOverlay();
          });
      } else {
        performSearch(query);
      }
    }, 200);
  });

  document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
      // 弹窗未打开时不做任何操作
      if (!searchResults.classList.contains('open')) return;
      // 有选中文字时不关闭（鼠标在弹窗外释放）
      var sel = window.getSelection();
      if (sel && sel.toString().trim().length > 0) return;
      closeOverlay();
      getResultsPanel().innerHTML = '';
    }
  });
})();
