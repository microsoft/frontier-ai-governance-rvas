(() => {
  "use strict";

  document.documentElement.classList.add("js");

  const records = [...document.querySelectorAll(".session-record")];
  const filterButtons = [...document.querySelectorAll("[data-filter]")];
  const toolFilterButtons = [
    ...document.querySelectorAll("[data-tool-filter]"),
  ];
  const phaseMarkers = [...document.querySelectorAll("[data-phase-marker]")];
  const searchInput = document.querySelector("[data-session-search]");
  const resultsCount = document.querySelector("[data-results-count]");
  const emptyState = document.querySelector("[data-empty-state]");
  const serviceMapRows = [...document.querySelectorAll("[data-service-row]")];
  const serviceMapSearch = document.querySelector("[data-service-map-search]");
  const serviceMapCount = document.querySelector("[data-service-map-count]");
  const serviceMapEmpty = document.querySelector("[data-service-map-empty]");
  const navToggle = document.querySelector("[data-nav-toggle]");
  const primaryNav = document.querySelector("[data-primary-nav]");
  const jumpSearchButtons = [...document.querySelectorAll("[data-jump-search]")];
  const deckDialog = document.querySelector("[data-deck-dialog]");
  const deckLauncher = document.querySelector("[data-deck-open]");
  const deckClose = document.querySelector("[data-deck-close]");
  const deckFrame = document.querySelector("[data-deck-frame]");
  const diagramImages = [
    ...document.querySelectorAll(".session-diagram img"),
  ];
  const codeTabs = [...document.querySelectorAll("[data-code-tabs]")];
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const shellCookieName = "rvas-command-shell";

  let activePhase = "all";
  let activeTool = "all";
  let searchTerm = "";
  let activeShell = "powershell";

  const normalize = (value) =>
    value.toLocaleLowerCase().replace(/\s+/g, " ").trim();

  const readShellPreference = () => {
    const prefix = `${shellCookieName}=`;
    const value = document.cookie
      .split(";")
      .map((part) => part.trim())
      .find((part) => part.startsWith(prefix))
      ?.slice(prefix.length);
    try {
      const shell = value ? decodeURIComponent(value) : "";
      return ["powershell", "bash"].includes(shell) ? shell : "powershell";
    } catch {
      return "powershell";
    }
  };

  const writeShellPreference = (shell) => {
    const secure = window.location.protocol === "https:" ? "; Secure" : "";
    document.cookie = `${shellCookieName}=${encodeURIComponent(shell)}; Max-Age=31536000; Path=/; SameSite=Lax${secure}`;
  };

  const selectShell = (shell, { persist = true } = {}) => {
    activeShell = shell;
    codeTabs.forEach((group) => {
      group.querySelectorAll("[data-shell-tab]").forEach((tab) => {
        const selected = tab.dataset.shellTab === activeShell;
        tab.setAttribute("aria-selected", String(selected));
        tab.tabIndex = selected ? 0 : -1;
      });
      group.querySelectorAll("[data-shell-panel]").forEach((panel) => {
        panel.hidden = panel.dataset.shellPanel !== activeShell;
      });
    });

    if (persist) {
      writeShellPreference(activeShell);
    }
  };

  const updateResults = () => {
    let visibleCount = 0;
    const visiblePhases = new Set();

    records.forEach((record) => {
      const matchesPhase =
        activePhase === "all" || record.dataset.phase === activePhase;
      const services = (record.dataset.services ?? "").split(/\s+/);
      const matchesTool =
        activeTool === "all" || services.includes(activeTool);
      const haystack = normalize(
        `${record.dataset.search ?? ""} ${record.textContent ?? ""}`,
      );
      const matchesSearch = !searchTerm || haystack.includes(searchTerm);
      const isVisible = matchesPhase && matchesTool && matchesSearch;

      record.hidden = !isVisible;
      if (isVisible) {
        visibleCount += 1;
        visiblePhases.add(record.dataset.phase);
      }
    });

    phaseMarkers.forEach((marker) => {
      marker.hidden = !visiblePhases.has(marker.dataset.phaseMarker);
    });

    if (resultsCount) {
      resultsCount.textContent = `${visibleCount} ${
        visibleCount === 1 ? "session" : "sessions"
      } shown`;
    }
    if (emptyState) {
      emptyState.hidden = visibleCount !== 0;
    }
  };

  const selectPhase = (phase) => {
    activePhase = phase;
    filterButtons.forEach((button) => {
      button.setAttribute(
        "aria-pressed",
        String(button.dataset.filter === activePhase),
      );
    });
    updateResults();
  };

  const persistTool = () => {
    const url = new URL(window.location.pathname, window.location.origin);
    if (activeTool === "all") {
      url.searchParams.delete("tool");
    } else {
      url.searchParams.set("tool", activeTool);
    }
    url.hash = "program";
    window.history.replaceState(null, "", url);
  };

  const selectTool = (tool, { persist = true } = {}) => {
    activeTool = tool;
    toolFilterButtons.forEach((button) => {
      button.setAttribute(
        "aria-pressed",
        String(button.dataset.toolFilter === activeTool),
      );
    });
    updateResults();
    if (persist) {
      persistTool();
    }
  };

  const restoreTool = () => {
    if (toolFilterButtons.length === 0) {
      return;
    }
    const requested = new URL(window.location.href).searchParams.get("tool");
    const available = toolFilterButtons.some(
      (button) => button.dataset.toolFilter === requested,
    );
    selectTool(available ? requested : "all", { persist: false });
    if (requested) {
      persistTool();
    }
  };

  const updateServiceMap = () => {
    if (serviceMapRows.length === 0) {
      return;
    }
    const term = normalize(serviceMapSearch?.value ?? "");
    let visibleCount = 0;
    serviceMapRows.forEach((row) => {
      const haystack = normalize(
        `${row.dataset.search ?? ""} ${row.textContent ?? ""}`,
      );
      const visible = !term || haystack.includes(term);
      row.hidden = !visible;
      if (visible) {
        visibleCount += 1;
      }
    });
    if (serviceMapCount) {
      serviceMapCount.textContent = `${visibleCount} ${
        visibleCount === 1 ? "service" : "services"
      } shown`;
    }
    if (serviceMapEmpty) {
      serviceMapEmpty.hidden = visibleCount !== 0;
    }
  };

  const setNavOpen = (isOpen) => {
    if (!navToggle || !primaryNav) {
      return;
    }

    navToggle.setAttribute("aria-expanded", String(isOpen));
    navToggle.setAttribute(
      "aria-label",
      isOpen ? "Close navigation" : "Open navigation",
    );
    primaryNav.classList.toggle("is-open", isOpen);
  };

  filterButtons.forEach((button) => {
    button.addEventListener("click", () => {
      selectPhase(button.dataset.filter ?? "all");
    });
  });

  toolFilterButtons.forEach((button) => {
    button.addEventListener("click", () => {
      selectTool(button.dataset.toolFilter ?? "all");
    });
  });

  searchInput?.addEventListener("input", (event) => {
    searchTerm = normalize(event.currentTarget.value);
    updateResults();
  });

  serviceMapSearch?.addEventListener("input", updateServiceMap);

  navToggle?.addEventListener("click", () => {
    setNavOpen(navToggle.getAttribute("aria-expanded") !== "true");
  });

  primaryNav?.addEventListener("click", (event) => {
    if (event.target.closest("a")) {
      setNavOpen(false);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      setNavOpen(false);
    }
  });

  jumpSearchButtons.forEach((button) => {
    button.addEventListener("click", () => {
      document.querySelector("#program")?.scrollIntoView({
        behavior: reducedMotion.matches ? "auto" : "smooth",
      });
      window.setTimeout(() => searchInput?.focus(), reducedMotion.matches ? 0 : 300);
    });
  });

  codeTabs.forEach((group) => {
    group.addEventListener("click", (event) => {
      const tab = event.target.closest("[data-shell-tab]");
      if (tab) {
        selectShell(tab.dataset.shellTab);
      }
    });

    group.addEventListener("keydown", (event) => {
      const tab = event.target.closest("[data-shell-tab]");
      if (!tab || !["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) {
        return;
      }

      event.preventDefault();
      const tabs = [...group.querySelectorAll("[data-shell-tab]")];
      const currentIndex = tabs.indexOf(tab);
      const nextIndex =
        event.key === "Home"
          ? 0
          : event.key === "End"
            ? tabs.length - 1
            : (currentIndex + (event.key === "ArrowRight" ? 1 : -1) + tabs.length) %
              tabs.length;
      const nextTab = tabs[nextIndex];
      selectShell(nextTab.dataset.shellTab);
      nextTab.focus();
    });
  });

  const openDeck = () => {
    if (!(deckDialog instanceof HTMLDialogElement)) {
      return;
    }

    if (deckFrame instanceof HTMLIFrameElement && !deckFrame.src) {
      deckFrame.src = deckFrame.dataset.src ?? "deck.html";
    }

    if (typeof deckDialog.showModal === "function") {
      deckDialog.showModal();
    } else {
      deckDialog.setAttribute("open", "");
    }
  };

  const closeDeck = () => {
    if (!(deckDialog instanceof HTMLDialogElement)) {
      return;
    }

    if (typeof deckDialog.close === "function") {
      deckDialog.close();
    } else {
      deckDialog.removeAttribute("open");
      deckLauncher?.focus();
    }
  };

  deckLauncher?.addEventListener("click", openDeck);
  deckClose?.addEventListener("click", closeDeck);
  deckDialog?.addEventListener("click", (event) => {
    if (event.target === deckDialog) {
      closeDeck();
    }
  });
  deckDialog?.addEventListener("close", () => deckLauncher?.focus());

  const enableDiagramZoom = () => {
    if (
      diagramImages.length === 0 ||
      !("HTMLDialogElement" in window) ||
      typeof HTMLDialogElement.prototype.showModal !== "function"
    ) {
      return;
    }

    const dialog = document.createElement("dialog");
    dialog.className = "diagram-dialog";
    dialog.setAttribute("aria-labelledby", "diagram-dialog-title");
    dialog.innerHTML = `
      <div class="diagram-dialog__shell">
        <header class="diagram-dialog__header">
          <div>
            <h2 id="diagram-dialog-title">Diagram detail</h2>
            <p data-diagram-caption></p>
          </div>
          <div class="diagram-dialog__actions">
            <a href="#" download data-diagram-download>Download</a>
            <button type="button" aria-label="Close diagram" data-diagram-close>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="m6 6 12 12M18 6 6 18"></path>
              </svg>
            </button>
          </div>
        </header>
        <div
          class="diagram-dialog__viewport"
          tabindex="0"
          aria-label="Diagram preview"
          data-diagram-viewport
        >
          <div class="diagram-dialog__canvas" data-diagram-canvas>
            <img alt="" data-diagram-image>
          </div>
        </div>
      </div>
    `;

    const modalImage = dialog.querySelector("[data-diagram-image]");
    const caption = dialog.querySelector("[data-diagram-caption]");
    const downloadLink = dialog.querySelector("[data-diagram-download]");
    const closeButton = dialog.querySelector("[data-diagram-close]");
    const viewport = dialog.querySelector("[data-diagram-viewport]");
    const canvas = dialog.querySelector("[data-diagram-canvas]");
    let activeTrigger = null;

    const closeDiagram = () => {
      if (dialog.open) {
        dialog.close();
      }
    };

    diagramImages.forEach((image, index) => {
      const description = image.alt.trim() || `Diagram ${index + 1}`;
      const trigger = document.createElement("button");
      const hint = document.createElement("span");

      trigger.type = "button";
      trigger.className = "session-diagram__trigger";
      trigger.setAttribute("aria-haspopup", "dialog");
      trigger.setAttribute("aria-label", `Open diagram preview: ${description}`);

      hint.className = "session-diagram__hint";
      hint.innerHTML = `
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <circle cx="10.5" cy="10.5" r="5.5"></circle>
          <path d="m15 15 4 4M10.5 8v5M8 10.5h5"></path>
        </svg>
        <span>Open preview</span>
      `;

      image.before(trigger);
      trigger.append(image, hint);
      trigger.addEventListener("click", () => {
        activeTrigger = trigger;
        const imageSource = image.currentSrc || image.src;
        const fileName = imageSource.split("/").pop()?.split("?")[0] || "diagram";
        modalImage.src = imageSource;
        modalImage.alt = description;
        downloadLink.href = imageSource;
        downloadLink.download = fileName;
        caption.textContent = image.alt;
        caption.hidden = !image.alt;
        document.documentElement.classList.add("has-open-dialog");
        dialog.showModal();
        viewport.scrollTo({ top: 0, left: 0 });
        viewport.focus();
      });
    });

    closeButton.addEventListener("click", closeDiagram);
    dialog.addEventListener("click", (event) => {
      if (event.target === dialog || event.target === canvas) {
        closeDiagram();
      }
    });
    dialog.addEventListener("close", () => {
      document.documentElement.classList.remove("has-open-dialog");
      modalImage.removeAttribute("src");
      downloadLink.removeAttribute("href");
      downloadLink.removeAttribute("download");
      activeTrigger?.focus();
      activeTrigger = null;
    });

    document.body.append(dialog);
  };

  enableDiagramZoom();
  selectShell(readShellPreference(), { persist: false });
  restoreTool();
  updateResults();
  updateServiceMap();
})();
