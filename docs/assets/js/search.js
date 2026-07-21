/* =====================================================================
   AI GOVERNANCE PLATFORM GLOBAL SEARCH — command-palette modal over the site content.
   Client-side only. Lazy-loads assets/data/search-index.json on first
   open. Bound to the nav #searchBtn and Ctrl/Cmd-K (and "/").
   Hidden in kiosk/curated-set view. Depends on FP (core.js) for esc/qp.
   ===================================================================== */
(function () {
  "use strict";

  var FP = window.FP || {};
  var esc =
    (FP && FP.esc) ||
    function (s) {
      return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
        return {
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        }[c];
      });
    };

  var INDEX_URL = "assets/data/search-index.json";
  var MAX_RESULTS = 30;

  var docs = null; // loaded index
  var loading = null; // in-flight fetch promise
  var els = null; // cached DOM refs
  var results = []; // current result docs
  var activeIndex = -1;

  /* ── Kiosk guard ─────────────────────────────────────────────────── */
  function isKiosk() {
    if (FP && typeof FP.isKiosk === "function") return FP.isKiosk();
    var p = new URLSearchParams(window.location.search);
    return !!(p.get("ids") || p.get("set"));
  }

  /* ── Index loading ───────────────────────────────────────────────── */
  function loadIndex() {
    if (docs) return Promise.resolve(docs);
    if (loading) return loading;
    loading = fetch(INDEX_URL, { cache: "no-cache" })
      .then(function (res) {
        if (!res.ok) throw new Error("HTTP " + res.status);
        return res.json();
      })
      .then(function (data) {
        docs = (data && data.docs) || [];
        docs.forEach(function (d) {
          d._haystack = (
            (d.title || "") +
            " " +
            (d.section || "") +
            " " +
            (d.text || "")
          ).toLowerCase();
        });
        return docs;
      })
      .catch(function (err) {
        loading = null; // allow retry
        throw err;
      });
    return loading;
  }

  /* ── Ranking ─────────────────────────────────────────────────────── */
  function scoreDoc(doc, tokens) {
    var title = (doc.title || "").toLowerCase();
    var section = (doc.section || "").toLowerCase();
    var body = doc._haystack || "";
    var score = 0;
    for (var i = 0; i < tokens.length; i++) {
      var t = tokens[i];
      if (body.indexOf(t) === -1) return 0; // every token must appear
      if (title.indexOf(t) !== -1) score += 12;
      if (section.indexOf(t) !== -1) score += 6;
      var idx = body.indexOf(t);
      var occ = 0;
      while (idx !== -1) {
        occ++;
        idx = body.indexOf(t, idx + t.length);
      }
      score += Math.min(occ, 5);
    }
    return score;
  }

  function search(query) {
    var q = query.trim().toLowerCase();
    if (!q) return [];
    var tokens = q.split(/\s+/).filter(Boolean);
    if (!tokens.length) return [];
    var scored = [];
    for (var i = 0; i < docs.length; i++) {
      var s = scoreDoc(docs[i], tokens);
      if (s > 0) scored.push({ doc: docs[i], score: s });
    }
    scored.sort(function (a, b) {
      return b.score - a.score;
    });
    return scored.slice(0, MAX_RESULTS).map(function (x) {
      return x.doc;
    });
  }

  /* ── Snippet with highlight ──────────────────────────────────────── */
  function snippet(doc, query) {
    var text = doc.text || "";
    if (!text) return "";
    var tokens = query.trim().toLowerCase().split(/\s+/).filter(Boolean);
    var lower = text.toLowerCase();
    var pos = -1;
    for (var i = 0; i < tokens.length; i++) {
      var p = lower.indexOf(tokens[i]);
      if (p !== -1 && (pos === -1 || p < pos)) pos = p;
    }
    if (pos === -1) pos = 0;
    var start = Math.max(0, pos - 60);
    var end = Math.min(text.length, pos + 140);
    var frag = (start > 0 ? "…" : "") + text.slice(start, end) + (end < text.length ? "…" : "");
    var out = esc(frag);
    tokens.forEach(function (t) {
      if (!t) return;
      var re = new RegExp("(" + t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
      out = out.replace(re, "<mark>$1</mark>");
    });
    return out;
  }

  /* ── DOM ─────────────────────────────────────────────────────────── */
  function build() {
    if (els) return els;
    var overlay = document.createElement("div");
    overlay.className = "search-overlay";
    overlay.id = "searchOverlay";
    overlay.hidden = true;
    overlay.setAttribute("role", "dialog");
    overlay.setAttribute("aria-modal", "true");
    overlay.setAttribute("aria-label", "Search the site");
    overlay.innerHTML =
      '<div class="search-modal" role="document">' +
      '  <div class="search-box">' +
      '    <svg class="search-box-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.35-4.35"/></svg>' +
      '    <input type="text" class="search-input" id="searchInput" placeholder="Search all content…" autocomplete="off" spellcheck="false" aria-label="Search query" aria-controls="searchResults" role="combobox" aria-expanded="true" aria-autocomplete="list" />' +
      '    <kbd class="search-esc">Esc</kbd>' +
      "  </div>" +
      '  <ul class="search-results" id="searchResults" role="listbox" aria-label="Search results"></ul>' +
      '  <div class="search-status" id="searchStatus" aria-live="polite"></div>' +
      "</div>";
    document.body.appendChild(overlay);

    els = {
      overlay: overlay,
      modal: overlay.querySelector(".search-modal"),
      input: overlay.querySelector("#searchInput"),
      list: overlay.querySelector("#searchResults"),
      status: overlay.querySelector("#searchStatus"),
    };

    overlay.addEventListener("mousedown", function (e) {
      if (e.target === overlay) close();
    });
    els.input.addEventListener("input", function () {
      render(els.input.value);
    });
    els.input.addEventListener("keydown", onInputKey);
    return els;
  }

  function open() {
    var e = build();
    if (!e.overlay.hidden) return;
    e.overlay.hidden = false;
    document.documentElement.classList.add("search-open");
    e.status.textContent = "Loading index…";
    loadIndex()
      .then(function () {
        e.status.textContent = "";
        render(e.input.value);
      })
      .catch(function () {
        e.status.textContent = "Could not load the search index.";
      });
    // Focus after paint so the modal is visible.
    requestAnimationFrame(function () {
      e.input.focus();
      e.input.select();
    });
  }

  function close() {
    if (!els || els.overlay.hidden) return;
    els.overlay.hidden = true;
    document.documentElement.classList.remove("search-open");
    activeIndex = -1;
    var trigger = document.getElementById("searchBtn");
    if (trigger) trigger.focus();
  }

  function render(query) {
    if (!docs) return;
    results = search(query || "");
    activeIndex = results.length ? 0 : -1;
    var q = (query || "").trim();
    if (!q) {
      els.list.innerHTML = "";
      els.status.textContent = "";
      return;
    }
    if (!results.length) {
      els.list.innerHTML = "";
      els.status.textContent = "No results for “" + query + "”.";
      return;
    }
    els.status.textContent =
      results.length + (results.length === 1 ? " result" : " results");
    els.list.innerHTML = results
      .map(function (doc, i) {
        var sub = doc.section
          ? '<span class="search-result-sub">' + esc(doc.section) + "</span>"
          : "";
        return (
          '<li class="search-result" role="option" id="searchOpt' +
          i +
          '" data-i="' +
          i +
          '"' +
          (i === activeIndex ? ' aria-selected="true"' : "") +
          ">" +
          '<a href="' +
          esc(doc.url) +
          '" tabindex="-1">' +
          '<span class="search-result-title">' +
          esc(doc.title) +
          "</span>" +
          sub +
          '<span class="search-result-snippet">' +
          snippet(doc, query) +
          "</span>" +
          "</a></li>"
        );
      })
      .join("");
    els.input.setAttribute(
      "aria-activedescendant",
      activeIndex >= 0 ? "searchOpt" + activeIndex : ""
    );

    Array.prototype.forEach.call(
      els.list.querySelectorAll(".search-result"),
      function (li) {
        li.addEventListener("mouseenter", function () {
          setActive(parseInt(li.getAttribute("data-i"), 10));
        });
        li.addEventListener("click", function (ev) {
          ev.preventDefault();
          go(parseInt(li.getAttribute("data-i"), 10));
        });
      }
    );
  }

  function setActive(i) {
    if (i < 0 || i >= results.length) return;
    var prev = els.list.querySelector('.search-result[aria-selected="true"]');
    if (prev) prev.removeAttribute("aria-selected");
    activeIndex = i;
    var el = els.list.querySelector('.search-result[data-i="' + i + '"]');
    if (el) {
      el.setAttribute("aria-selected", "true");
      el.scrollIntoView({ block: "nearest" });
      els.input.setAttribute("aria-activedescendant", "searchOpt" + i);
    }
  }

  function go(i) {
    var doc = results[i];
    if (doc) window.location.href = doc.url;
  }

  function onInputKey(e) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActive(Math.min(activeIndex + 1, results.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActive(Math.max(activeIndex - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      if (activeIndex >= 0) go(activeIndex);
    } else if (e.key === "Escape") {
      e.preventDefault();
      close();
    }
  }

  /* ── Boot ────────────────────────────────────────────────────────── */
  function boot() {
    if (isKiosk()) {
      var hide = document.getElementById("searchBtn");
      if (hide) hide.hidden = true;
      return;
    }
    var btn = document.getElementById("searchBtn");
    if (btn && !btn.dataset.searchBound) {
      btn.dataset.searchBound = "1";
      btn.hidden = false;
      btn.addEventListener("click", open);
    }
    document.addEventListener("keydown", function (e) {
      var mod = e.metaKey || e.ctrlKey;
      if (mod && (e.key === "k" || e.key === "K")) {
        e.preventDefault();
        open();
        return;
      }
      var open_ = els && !els.overlay.hidden;
      if (e.key === "/" && !open_ && !isTypingTarget(e.target)) {
        e.preventDefault();
        open();
      }
    });
  }

  function isTypingTarget(t) {
    if (!t) return false;
    var tag = (t.tagName || "").toLowerCase();
    return tag === "input" || tag === "textarea" || t.isContentEditable;
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }

  window.RVASSearch = { open: open, close: close };
})();
