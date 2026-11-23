/* ============================================================
   gta4inver v2 app.js
   Same data bridge as v1:
     Lua -> window.__luxAction("state"|"toast", data)
     JS  -> mta.triggerEvent("gta4i:ui", action, json)
   ============================================================ */

"use strict";

var state = null;
var selectedId = null;
var filter = "all";
var dragData = null;
var currentStorage = "trunk";
var storageTab = "trunk";

/* ============================ icons ============================ */

var FALLBACK_ICONS = {
    burger: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M6 18c0-7 8-11 18-11s18 4 18 11H6zm0 6h36v3a3 3 0 0 1-3 3H9a3 3 0 0 1-3-3v-3zm3 10h30c0 5-4 9-9 9H18c-5 0-9-4-9-9zm12-16h6v3h-6z" opacity=".95"/></svg>',
    pizza: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 4 4 42c12 4 28 4 40 0L24 4zm-8 22 4-2 4 2-2 4h-4l-2-4zm12 12-4-2 2-4 4 2-2 4z"/></svg>',
    water: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M20 4h8v6h-8zM18 12h12l-1 4h4a3 3 0 0 1 3 3v20a3 3 0 0 1-3 3H15a3 3 0 0 1-3-3V19a3 3 0 0 1 3-3h4l-1-4zm6 10c-3 5-6 8-6 12a6 6 0 0 0 12 0c0-4-3-7-6-12z"/></svg>',
    soda: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M16 6h16v3l-2 2h2a4 4 0 0 1 4 4v25a4 4 0 0 1-4 4H16a4 4 0 0 1-4-4V15a4 4 0 0 1 4-4h2l-2-2V6zm6 13c-2.5 4-5 6.5-5 9.5A5 5 0 0 0 27 29c0-3-2.5-6-5-10z"/></svg>',
    medkit: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M8 12h32a3 3 0 0 1 3 3v22a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V15a3 3 0 0 1 3-3zm14 4v4h-4v6h4v4h4v-4h4v-6h-4v-4h-4zM18 8h12v4H18V8z"/></svg>',
    repairkit: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 6a8 8 0 0 1 7.7 10.2l-3.2-3.2-4.2 4.2 3.2 3.2A8 8 0 0 1 20 19.7L10.5 29a4 4 0 0 1-5.6-5.6L14.3 14A8 8 0 0 1 24 6zm14 30-6-6 2.5-2.5L14 47l-4.4-1.2L11 40l12-12 2.5-2.5L20 20l4-4 4 4 10-10 4 4-10 10 6 6-4 4z"/></svg>',
    phone: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M16 4h16a3 3 0 0 1 3 3v34a3 3 0 0 1-3 3H16a3 3 0 0 1-3-3V7a3 3 0 0 1 3-3zm0 5v26h16V9H16zm8 29a2 2 0 1 0 0 4 2 2 0 0 0 0-4z"/></svg>',
    id_card: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M6 10h36a2 2 0 0 1 2 2v24a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V12a2 2 0 0 1 2-2zm8 7a5 5 0 1 0 0 10 5 5 0 0 0 0-10zm-7 14c0-3 3.5-5 7-5s7 2 7 5v1H7v-1zm16-12h12v4H23v-4zm0 8h10v4H23v-4z"/></svg>',
    radio: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M14 4h20a4 4 0 0 1 4 4v32a4 4 0 0 1-4 4H14a4 4 0 0 1-4-4V8a4 4 0 0 1 4-4zm6 6h8v3h-8v-3zm10 15a2 2 0 1 0-2 2v6h2v-6a2 2 0 0 0 0-2zm-12 0a2 2 0 1 0 2 2v6h-2v-6a2 2 0 0 0 0-2zm-4-8h16v5H14v-5z"/></svg>',
    fuelcan: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M10 10h20l4 4h6a2 2 0 0 1 2 2v24a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V14a4 4 0 0 1 4-4zm10 8-6 8h4l-2 8 8-10h-5l1-6z"/></svg>',
    weapon_pistol: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M4 14h34v6h-8l2 4h-8l-2-4h-6v4H8v-4H4v-6zm24 12h8l4 14h-8l-4-14zm-10 0h6v6h-6v-6z"/></svg>',
    weapon_deagle: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M4 12h38v8h-10l3 5h-9l-3-5h-7v6h-9v-6H4v-8zm20 16h9l5 16h-9l-5-16z"/></svg>',
    weapon_shotgun: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M2 20h40l4 3-4 3H2v-6zm6 8h10v4H8v-4zm12 0h8l3 12h-8l-3-12z"/></svg>',
    weapon_ak: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M2 22h44v4H30l-2 4h-6l2-4H2v-4zm12 6h8v4h-8v-4zm22 0h6l4 12h-6l-4-12z"/></svg>',
    backpack: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M16 8h16c6 0 10 5 10 11v19a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V19c0-6 4-11 10-11zm2 4v3h12v-3H18zm-8 12h28v4H10v-4zm0 8h28v4H10v-4z"/></svg>',
    watch: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M15 4h18l-2 10H17L15 4zm2 26h14l2 14H15l2-14zm7-20a14 14 0 1 0 0 28 14 14 0 0 0 0-28zm0 6a8 8 0 1 1 0 16 8 8 0 0 1 0-16z"/></svg>',
    default: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 6 6 22h4v18h28V22h4L24 6zm6 22h-4v-4h-4v4h-4v4h4v4h4v-4h4v-4z"/></svg>'
};

/* detailed artwork pack (icons.js); flat glyphs remain only as a fallback */
var ICONS = window.LUX_ICONS || FALLBACK_ICONS;

function iconFor(item) { return ICONS[item] || ICONS.default; }

var KIND_COLOR = {
    food: "#5fc06e", drink: "#6fb7e0", heal: "#e05b5b",
    weapon: "#d4af37", tool: "#8fa3bf", item: "#9aa2ad"
};

var KIND_GROUP = {
    food: "food", drink: "food", heal: "medical",
    weapon: "weapon", tool: "tool", item: "misc"
};

/* ============================ helpers ============================ */

function $(id) { return document.getElementById(id); }
function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
        return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
}
function trigger(action, args) {
    if (window.mta && mta.triggerEvent) mta.triggerEvent("gta4i:ui", action, JSON.stringify(args || {}));
}
function fmtW(w) { return (Math.round(w * 10) / 10).toFixed(1); }
function notify(text, ok) {
    var t = document.createElement("div");
    t.className = "toast" + (ok === false ? " err" : "");
    t.textContent = text;
    $("toasts").appendChild(t);
    setTimeout(function () { t.style.opacity = "0"; }, 2500);
    setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 2900);
}

var AUDIO = {};
function sfx(name) {
    try {
        if (!AUDIO[name]) AUDIO[name] = new Audio(name + ".wav");
        var a = AUDIO[name];
        a.currentTime = 0; a.volume = 0.3; a.play();
    } catch (e) { }
}

/* ============================ bridge ============================ */

window.__luxReady = function () { };

window.__luxAction = function (action, data) {
    // MTA's toJSON() always wraps its arguments in a JSON array, so a single
    // payload arrives as [ {...} ] - unwrap it before rendering.
    if (Object.prototype.toString.call(data) === "[object Array]" && data.length === 1) data = data[0];
    if (action === "state") {
        // 2026-11-18: a payload without `items` (inventory not ready yet or an
        // empty character) crashed the whole UI with
        // "Cannot read properties of undefined (reading 'length')".
        // Normalise every collection renderAll() expects.
        if (data && typeof data === "object") {
            if (!Array.isArray(data.items)) data.items = [];
            if (!Array.isArray(data.quickslots)) data.quickslots = [];
            if (!data.capacity || typeof data.capacity !== "object") data.capacity = {};
            if (!data.char || typeof data.char !== "object") data.char = {};
        }
        state = data;
        renderAll();
    }
    else if (action === "toast") notify(data.text || "", data.ok);
};

/* ============================ render ============================ */

function renderAll() {
    if (!state) return;
    // #app ships hidden; the first server payload is what reveals the UI
    var appEl = $("app");
    if (appEl) appEl.classList.remove("hidden");
    var bootEl = $("boot");
    if (bootEl) bootEl.classList.add("hidden");
    var cap = state.capacity || {};
    var ch = state.char || {};

    $("t-cash").textContent = "$" + (ch.cash || 0);
    $("p-name").textContent = ch.name || "-";
    $("p-number").textContent = ch.number ? ("PHONE " + ch.number) : "-";
    $("p-avatar").textContent = initials(ch.name);

    var tags = [];
    if (ch.bank != null) tags.push("BANK $" + ch.bank);
    if (cap.slotsMax > 20) tags.push("BACKPACK");
    $("p-tags").innerHTML = tags.map(function (t) { return '<span class="p-tag">' + esc(t) + "</span>"; }).join("");

    // weight ring: r=52 -> circumference 326.7
    var pct = cap.max ? Math.min(1, (cap.used || 0) / cap.max) : 0;
    var ring = $("ring-fill");
    ring.style.strokeDashoffset = (326.7 * (1 - pct)).toFixed(1);
    ring.style.stroke = pct >= 1 ? "#e05b5b" : pct >= 0.8 ? "#e0913c" : "#d4af37";
    $("ring-num").textContent = fmtW(cap.used || 0);
    $("ring-max").textContent = "/ " + fmtW(cap.max || 0);

    $("m-slots").textContent = (cap.slotsUsed || 0) + "/" + (cap.slotsMax || 0);
    $("m-slots-fill").style.width = Math.min(100, cap.slotsMax ? (cap.slotsUsed / cap.slotsMax) * 100 : 0) + "%";

    renderGrid();
    renderQuick();
    renderStorage();
    renderDetail();
}

function initials(name) {
    var parts = String(name || "?").split(/[_\s]+/);
    return ((parts[0] || "?")[0] || "?").toUpperCase() + ((parts[1] || "")[0] || "").toUpperCase();
}

function itemById(id) {
    if (!state) return null;
    for (var i = 0; i < state.items.length; i++) if (state.items[i].id === id) return state.items[i];
    return null;
}
function slotByPos(pos) {
    if (!state) return null;
    for (var i = 0; i < state.items.length; i++) if (state.items[i].slot === pos) return state.items[i];
    return null;
}
function quickIndexOf(itemName) {
    var qs = state.quickslots || [];
    for (var i = 0; i < qs.length; i++) if (qs[i] === itemName) return i + 1;
    return 0;
}

function renderGrid() {
    var grid = $("grid");
    grid.innerHTML = "";
    var max = (state.capacity && state.capacity.slotsMax) || 20;

    var visible = [];
    if (filter === "all") {
        for (var pos = 0; pos < max; pos++) visible.push(slotByPos(pos) || null);
    } else {
        var matched = [];
        for (var p2 = 0; p2 < max; p2++) {
            var m = slotByPos(p2);
            if (m && KIND_GROUP[m.kind] === filter) matched.push(m);
        }
        var pad = Math.ceil((matched.length + 1) / 6) * 6 - matched.length;
        if (matched.length === 0) pad = 6;
        visible = matched.slice();
        for (var q = 0; q < pad; q++) visible.push(null);
    }
    $("f-count").textContent = (filter === "all" ? state.items.length : state.items.filter(function (i) {
        return KIND_GROUP[i.kind] === filter;
    }).length) + " ITEMS";

    visible.forEach(function (it) {
        var div = document.createElement("div");
        var kindCol = it ? (KIND_COLOR[it.kind] || KIND_COLOR.item) : null;
        div.className = "slot" + (it ? "" : " empty") + (it && it.id === selectedId ? " selected" : "");
        div.dataset.pos = it ? it.slot : -1;
        if (kindCol) div.style.setProperty("--kind", kindCol);

        if (it) {
            var qi = quickIndexOf(it.item);
            div.innerHTML =
                (qi ? '<div class="s-q">F' + (1 + qi) + "</div>" : "") +
                '<div class="s-icon">' + iconFor(it.item) + "</div>" +
                '<div class="s-name">' + esc(it.name) + "</div>" +
                '<div class="s-meta">' + (it.amount > 1 ? "x" + it.amount + " · " : "") + fmtW(it.weight * it.amount) + " kg</div>";
            div.draggable = true;
            div.addEventListener("dragstart", makeDragStart(it, "inv"));
            div.addEventListener("dragend", clearDrag);
            div.addEventListener("click", (function (id) {
                return function () { selectedId = id; sfx("click"); renderAll(); };
            })(it.id));
        }
        div.addEventListener("dragover", dragOver);
        div.addEventListener("dragleave", dragLeave);
        div.addEventListener("drop", makeGridDrop(parseInt(div.dataset.pos, 10)));
        grid.appendChild(div);
    });
}

function renderDetail() {
    var it = selectedId != null ? itemById(selectedId) : null;
    var icon = $("d-icon");
    if (it) {
        icon.className = "d-icon";
        icon.innerHTML = iconFor(it.item);
        icon.style.color = KIND_COLOR[it.kind] || KIND_COLOR.item;
        icon.style.borderColor = (KIND_COLOR[it.kind] || "#d4af37") + "88";
        $("d-kind").textContent = it.kind;
        $("d-name").textContent = it.name;
        $("d-stats").innerHTML =
            stat("AMOUNT", "x" + it.amount) +
            stat("UNIT WEIGHT", fmtW(it.weight) + " kg") +
            stat("TOTAL", fmtW(it.weight * it.amount) + " kg") +
            stat("SLOT", "#" + (it.slot + 1));
        $("a-use").disabled = false;
        $("a-give").disabled = false;
        $("a-drop").disabled = false;
        $("a-split").disabled = it.amount <= 1;
    } else {
        icon.className = "d-icon empty";
        icon.innerHTML = ICONS.default;
        icon.style.color = "";
        icon.style.borderColor = "";
        $("d-kind").textContent = "-";
        $("d-name").textContent = "Select an item";
        $("d-stats").innerHTML = stat("AMOUNT", "-") + stat("TYPE", "-") + stat("AGAIN", "-");
        $("a-use").disabled = true;
        $("a-give").disabled = true;
        $("a-drop").disabled = true;
        $("a-split").disabled = true;
    }
}

function stat(k, v) {
    return '<div class="d-stat"><div class="k">' + k + '</div><div class="v">' + esc(v) + "</div></div>";
}

function renderQuick() {
    var wrap = $("quick-slots");
    wrap.innerHTML = "";
    var qs = state.quickslots || [];
    for (var i = 0; i < 5; i++) {
        var q = document.createElement("div");
        q.className = "qslot";
        var item = qs[i];
        q.innerHTML = (item ? iconFor(item) : "") +
            '<span class="qkey">F' + (2 + i) + "</span>" +
            (item ? '<span class="q-amt">x' + quickAmount(item) + "</span>" : "");
        if (item) {
            q.addEventListener("click", (function (idx) {
                return function (e) {
                    e.stopPropagation();
                    trigger("clearQuick", { index: idx });
                    notify("Quickslot Q" + idx + " cleared");
                };
            })(i + 1));
        }
        q.addEventListener("dragover", dragOver);
        q.addEventListener("dragleave", dragLeave);
        q.addEventListener("drop", makeQuickDrop(i + 1));
        wrap.appendChild(q);
    }
}

function quickAmount(item) {
    if (!state) return 0;
    for (var i = 0; i < state.items.length; i++) {
        if (state.items[i].item === item) return state.items[i].amount;
    }
    return 0;
}

/* ============================ storage ============================ */

function renderStorage() {
    var ctxs = (state && state.contexts) || {};
    var box = $("storage");
    var keys = [];
    if (ctxs.trunk) keys.push("trunk");
    if (ctxs.house) keys.push("house");
    if (!keys.length) { box.classList.add("hidden"); return; }
    box.classList.remove("hidden");

    if (keys.indexOf(storageTab) === -1) storageTab = keys[0];
    currentStorage = ctxs[storageTab];
    var ctx = currentStorage;
    if (!ctx) return;

    var tabs = $("st-tabs");
    tabs.innerHTML = "";
    keys.forEach(function (k) {
        var b = document.createElement("button");
        b.className = "st-tab" + (k === storageTab ? " on" : "");
        b.textContent = k === "trunk" ? "TRUNK" : "HOUSE";
        b.onclick = function () { storageTab = k; renderStorage(); };
        tabs.appendChild(b);
    });

    $("st-cap").textContent = ctx.usedSlots + "/" + ctx.slots + " SLOTS · " + fmtW(ctx.usedWeight) + "/" + fmtW(ctx.weight) + " KG";

    var list = $("st-list");
    list.innerHTML = "";
    if (!ctx.items.length) {
        list.innerHTML = '<div class="st-empty">Empty - drag items here<br>or press STORE on a selected item</div>';
        return;
    }
    ctx.items.forEach(function (it) {
        var row = document.createElement("div");
        row.className = "st-row";
        row.innerHTML =
            '<div class="s-icon" style="color:' + (KIND_COLOR[it.kind] || "#9aa2ad") + '">' + iconFor(it.item) + "</div>" +
            '<div class="st-name">' + esc(it.name) + '</div><div class="st-amt">x' + it.amount + "</div>" +
            '<button class="st-btn">TAKE</button>';
        row.draggable = true;
        row.addEventListener("dragstart", makeDragStart(it, "storage"));
        row.addEventListener("dragend", clearDrag);
        row.addEventListener("click", function (e) {
            if (e.target.classList.contains("st-btn")) {
                e.stopPropagation();
                trigger("storageWithdraw", { ctx: ctx.ctx, item: it.item, amount: 1 });
            }
        });
        list.appendChild(row);
    });
}

/* ============================ drag & drop ============================ */

function makeDragStart(it, source) {
    return function (e) {
        dragData = { id: it.id, item: it.item, source: source, name: it.name };
        e.dataTransfer.setData("text/plain", String(it.id));
        e.target.classList.add("dragging");
    };
}
function dragOver(e) { e.preventDefault(); this.classList.add("drag-over"); }
function dragLeave() { this.classList.remove("drag-over"); }
function clearDrag() {
    this.classList.remove("dragging");
    var els = document.querySelectorAll(".drag-over");
    for (var i = 0; i < els.length; i++) els[i].classList.remove("drag-over");
}

function makeGridDrop(pos) {
    return function (e) {
        e.preventDefault();
        this.classList.remove("drag-over");
        if (!dragData) return;
        if (dragData.source === "inv") {
            if (pos < 0) { dragData = null; return; }
            var it = itemById(dragData.id);
            if (!it) { dragData = null; return; }
            var target = slotByPos(pos);
            if (target && target.id === it.id) { selectedId = it.id; renderAll(); }
            else if (target && target.item === it.item) trigger("merge", { srcId: it.id, dstId: target.id });
            else if (!target) trigger("move", { id: it.id, slot: pos });
            else notify("Slot occupied", false);
        } else if (dragData.source === "storage" && currentStorage) {
            trigger("storageWithdraw", { ctx: currentStorage.ctx, item: dragData.item, amount: 1 });
        }
        dragData = null;
    };
}

function makeQuickDrop(index) {
    return function (e) {
        e.preventDefault();
        this.classList.remove("drag-over");
        if (!dragData || dragData.source !== "inv") { dragData = null; return; }
        trigger("setQuick", { index: index, item: dragData.item });
        notify("Bound " + dragData.name + " to F" + (1 + index));
        dragData = null;
    };
}

/* ============================ filters ============================ */

document.querySelectorAll("#filters .chip").forEach(function (b) {
    b.addEventListener("click", function () {
        document.querySelectorAll("#filters .chip").forEach(function (x) { x.classList.remove("on"); });
        b.classList.add("on");
        filter = b.dataset.f;
        sfx("click");
        renderGrid();
    });
});

/* ============================ actions ============================ */

$("a-use").onclick = function () { if (selectedId != null) trigger("use", { id: selectedId }); };
$("a-drop").onclick = function () { if (selectedId != null) trigger("drop", { id: selectedId }); };
$("a-give").onclick = function () { if (selectedId != null) trigger("give", { id: selectedId }); };
$("a-split").onclick = function () {
    var it = selectedId != null ? itemById(selectedId) : null;
    if (!it || it.amount <= 1) return;
    $("modal-sub").textContent = it.name + " (x" + it.amount + ") - how many to split off?";
    $("modal-amount").value = Math.max(1, Math.floor(it.amount / 2));
    $("modal").classList.remove("hidden");
    $("modal-amount").focus();
};
$("modal-cancel").onclick = function () { $("modal").classList.add("hidden"); };
$("modal-ok").onclick = function () {
    var amt = parseInt($("modal-amount").value, 10);
    if (amt >= 1 && selectedId != null) trigger("split", { id: selectedId, amount: amt });
    $("modal").classList.add("hidden");
};
$("m-minus").onclick = function () { var v = parseInt($("modal-amount").value, 10) || 1; if (v > 1) $("modal-amount").value = v - 1; };
$("m-plus").onclick = function () { $("modal-amount").value = (parseInt($("modal-amount").value, 10) || 0) + 1; };
$("modal-amount").addEventListener("keydown", function (e) {
    if (e.key === "Enter") $("modal-ok").click();
    if (e.key === "Escape") $("modal-cancel").click();
});
$("btn-close").onclick = function () { trigger("close", {}); };
$("btn-phone").onclick = function () { trigger("openPhone", {}); };

/* close on Escape */
document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") trigger("close", {});
});

/* ============================ mock storage drag target ============================ */
$("storage").addEventListener("dragover", function (e) {
    e.preventDefault();
    if (dragData && dragData.source === "inv" && currentStorage) this.classList.add("drag-over");
});
$("storage").addEventListener("dragleave", function () { this.classList.remove("drag-over"); });
$("storage").addEventListener("drop", function (e) {
    e.preventDefault();
    this.classList.remove("drag-over");
    if (!dragData || !currentStorage || dragData.source !== "inv") { dragData = null; return; }
    trigger("storageDeposit", { ctx: currentStorage.ctx, item: dragData.item, amount: 1 });
    dragData = null;
});
