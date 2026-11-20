/* ============================================================
   gta4inver app.js - premium inventory UI logic
   Data comes from Lua via window.__luxAction("state", payload)
   Actions go to Lua via mta.triggerEvent("gta4i:ui", action, json)
   ============================================================ */

"use strict";

var state = null;
var selectedId = null;

/* ============================ icons ============================ */

var ICONS = {
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

function iconFor(item) {
    return ICONS[item] || ICONS.default;
}

/* ============================ helpers ============================ */

function $(id) { return document.getElementById(id); }

function notify(text, ok) {
    var t = document.createElement("div");
    t.className = "toast" + (ok === false ? " err" : "");
    t.textContent = text;
    $("toasts").appendChild(t);
    setTimeout(function () { t.classList.add("out"); }, 2600);
    setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 3000);
}

function trigger(action, args) {
    if (window.mta && mta.triggerEvent) {
        mta.triggerEvent("gta4i:ui", action, JSON.stringify(args || {}));
    }
}

function fmtW(w) { return (Math.round(w * 10) / 10).toFixed(1); }

/* ============================ state ============================ */

window.__luxReady = function () { /* page ready - Lua may inject state now */ };

window.__luxAction = function (action, data) {
    if (action === "state") { state = data; renderAll(); }
    else if (action === "toast") { notify(data.text || "", data.ok); }
};

/* ============================ render ============================ */

function renderAll() {
    if (!state) return;
    var cap = state.capacity || {};

    $("h-name").textContent = (state.char && state.char.name) || "-";
    $("h-number").textContent = "PHONE " + ((state.char && state.char.number) || "-");
    $("h-cash").textContent = "$" + ((state.char && state.char.cash) || 0);

    var slotsTxt = (cap.slotsUsed || 0) + "/" + (cap.slotsMax || 0);
    $("cap-slots-txt").textContent = slotsTxt;
    $("cap-weight-txt").textContent = fmtW(cap.used || 0) + "/" + fmtW(cap.max || 0) + " kg";

    var sp = (cap.slotsMax ? cap.slotsUsed / cap.slotsMax : 0) * 100;
    var wp = (cap.max ? cap.used / cap.max : 0) * 100;
    setBar("cap-slots", sp);
    setBar("cap-weight", wp);

    renderGrid();
    renderQuick();
    renderStorage();
    renderDetail();
    $("btn-phone").textContent = "\u260E PHONE";
}

function setBar(id, pct) {
    var el = $(id);
    el.style.width = Math.min(100, Math.max(0, pct)) + "%";
    el.className = "bar-fill" + (pct >= 100 ? " full" : pct >= 80 ? " warn" : "");
}

function itemById(id) {
    if (!state) return null;
    for (var i = 0; i < state.items.length; i++) {
        if (state.items[i].id === id) return state.items[i];
    }
    return null;
}

function slotByPos(pos) {
    if (!state) return null;
    for (var i = 0; i < state.items.length; i++) {
        if (state.items[i].slot === pos) return state.items[i];
    }
    return null;
}

function inQuick(itemName) {
    var qs = state.quickslots || [];
    for (var i = 0; i < qs.length; i++) {
        if (qs[i] === itemName) return i + 1;
    }
    return 0;
}

function renderGrid() {
    var grid = $("grid");
    grid.innerHTML = "";
    var max = (state.capacity && state.capacity.slotsMax) || 20;

    var bySlot = {};
    for (var i = 0; i < state.items.length; i++) {
        bySlot[state.items[i].slot] = state.items[i];
    }

    for (var pos = 0; pos < max; pos++) {
        var it = bySlot[pos];
        var div = document.createElement("div");
        div.className = "slot" + (it ? "" : " empty") + (it && it.id === selectedId ? " selected" : "");
        div.dataset.pos = pos;
        div.dataset.id = it ? it.id : "";

        if (it) {
            div.innerHTML =
                '<div class="s-icon">' + iconFor(it.item) + "</div>" +
                '<div class="s-name">' + escapeHtml(it.name) + "</div>" +
                (it.amount > 1 ? '<div class="s-amount">x' + it.amount + "</div>" : "") +
                '<div class="s-weight">' + fmtW(it.weight * it.amount) + " kg</div>" +
                (inQuick(it.item) ? '<div class="s-q">Q' + inQuick(it.item) + "</div>" : "");
        }

        if (it) {
            div.draggable = true;
            div.addEventListener("dragstart", makeDragStart(it, "inv"));
            div.addEventListener("dragend", clearDragOver);
            div.addEventListener("click", function (e) { selectItem(parseInt(this.dataset.id, 10)); });
        }
        div.addEventListener("dragover", dragOver);
        div.addEventListener("dragleave", dragLeave);
        div.addEventListener("drop", makeGridDrop(pos));
        grid.appendChild(div);
    }
}

function selectItem(id) {
    selectedId = id;
    playSound("click");
    renderAll();
}

function renderDetail() {
    var it = selectedId != null ? itemById(selectedId) : null;
    var icon = $("d-icon");
    if (it) {
        icon.className = "d-icon";
        icon.innerHTML = iconFor(it.item);
        $("d-name").textContent = it.name;
        $("d-kind").textContent = it.kind + " - " + fmtW(it.weight) + " kg each";
        $("d-info").innerHTML =
            "Amount: <b>x" + it.amount + "</b> &nbsp;|&nbsp; Total: <b>" + fmtW(it.weight * it.amount) + " kg</b><br>" +
            "Slot: <b>" + (it.slot + 1) + "</b> &nbsp;|&nbsp; Stack ID: <b>#" + it.id + "</b>";
        $("a-use").disabled = false;
        $("a-drop").disabled = false;
        $("a-give").disabled = false;
        $("a-split").disabled = it.amount <= 1;
    } else {
        icon.className = "d-icon empty";
        icon.innerHTML = ICONS.default;
        $("d-name").textContent = "Select an item";
        $("d-kind").textContent = "-";
        $("d-info").innerHTML = "Click an item in the grid to manage it.<br>Drag &amp; drop to rearrange, merge or store.";
        $("a-use").disabled = true;
        $("a-drop").disabled = true;
        $("a-give").disabled = true;
        $("a-split").disabled = true;
    }
    renderQuick();
}

function renderQuick() {
    var wrap = $("quick-slots");
    wrap.innerHTML = "";
    var qs = state.quickslots || [];
    for (var i = 0; i < 5; i++) {
        var q = document.createElement("div");
        q.className = "qslot";
        q.dataset.index = i + 1;
        var item = qs[i];
        if (item) {
            q.innerHTML =
                '<div class="s-icon">' + iconFor(item) + "</div>" +
                '<div class="s-amount">Q' + (i + 1) + "</div>";
            q.addEventListener("click", (function (nm, idx) {
                return function (e) {
                    e.stopPropagation();
                    trigger("clearQuick", { index: idx });
                    notify("Quickslot " + idx + " cleared");
                };
            })(item, i + 1));
        } else {
            q.innerHTML = '<div class="s-name" style="color:#9aa2ad;font-size:9px;">Q' + (i + 1) + "</div>";
        }
        q.addEventListener("dragover", dragOver);
        q.addEventListener("dragleave", dragLeave);
        q.addEventListener("drop", makeQuickDrop(i + 1));
        wrap.appendChild(q);
    }
}

/* ============================ storage ============================ */

function renderStorage() {
    var ctxs = (state && state.contexts) || {};
    var trunk = ctxs.trunk, house = ctxs.house;
    var box = $("storage");
    if (!trunk && !house) { box.classList.add("hidden"); return; }
    box.classList.remove("hidden");

    var ctx = trunk || house;
    $("st-title").textContent =
        (trunk ? "VEHICLE TRUNK" : "HOUSE STORAGE") +
        (house && trunk ? "  (HOUSE)" : "");

    $("st-weight-txt").textContent = fmtW(ctx.usedWeight) + "/" + fmtW(ctx.weight) + " kg (" + ctx.usedSlots + "/" + ctx.slots + " slots)";
    setBar("st-weight", ctx.weight ? (ctx.usedWeight / ctx.weight) * 100 : 0);

    var list = $("st-list");
    list.innerHTML = "";
    if (!ctx.items.length) {
        list.innerHTML = '<div class="st-empty">Storage is empty - drag items here or click STORE</div>';
    }
    ctx.items.forEach(function (it) {
        var row = document.createElement("div");
        row.className = "st-item";
        row.innerHTML =
            '<div class="s-icon">' + iconFor(it.item) + "</div>" +
            '<div class="st-name">' + escapeHtml(it.name) + "</div>" +
            '<div class="st-amount">x' + it.amount + "</div>" +
            '<button class="st-btn">TAKE</button>';
        row.draggable = true;
        row.addEventListener("dragstart", makeDragStart(it, "storage"));
        row.addEventListener("dragend", clearDragOver);
        row.querySelector(".st-btn").addEventListener("click", function (e) {
            e.stopPropagation();
            trigger("storageWithdraw", { ctx: ctx.ctx, item: it.item, amount: 1 });
        });
        list.appendChild(row);
    });
}

/* ============================ drag & drop ============================ */

var dragData = null;

function makeDragStart(it, source) {
    return function (e) {
        dragData = { id: it.id, item: it.item, source: source };
        e.dataTransfer.setData("text/plain", String(it.id));
        e.target.classList.add("dragging");
    };
}

function dragOver(e) {
    e.preventDefault();
    this.classList.add("drag-over");
}
function dragLeave() { this.classList.remove("drag-over"); }
function clearDragOver() {
    this.classList.remove("dragging");
    var els = document.querySelectorAll(".drag-over");
    for (var i = 0; i < els.length; i++) els[i].classList.remove("drag-over");
}

function makeGridDrop(pos) {
    return function (e) {
        e.preventDefault();
        this.classList.remove("drag-over");
        if (!dragData) return;
        var target = slotByPos(pos);
        if (dragData.source === "inv") {
            var it = itemById(dragData.id);
            if (!it) return;
            if (target && target.id !== it.id && target.item === it.item) {
                trigger("merge", { srcId: it.id, dstId: target.id });
            } else if (target && target.id === it.id) {
                selectItem(it.id);
            } else if (!target && it.slot !== pos) {
                trigger("move", { id: it.id, slot: pos });
            } else if (target && target.id !== it.id) {
                notify("Slot occupied", false);
            }
        } else if (dragData.source === "storage") {
            // storage -> grid handled via withdraw buttons; dropping does 1
            var ctxs = state.contexts || {};
            var ctx = ctxs.trunk || ctxs.house;
            if (ctx) trigger("storageWithdraw", { ctx: ctx.ctx, item: dragData.item, amount: 1 });
        }
        dragData = null;
    };
}

function makeQuickDrop(index) {
    return function (e) {
        e.preventDefault();
        this.classList.remove("drag-over");
        if (!dragData || dragData.source !== "inv") return;
        trigger("setQuick", { index: index, item: dragData.item });
        notify("Bound to quickslot " + index);
        dragData = null;
    };
}

/* ============================ buttons ============================ */

function bindActions() {
    $("a-use").onclick = function () { if (selectedId != null) trigger("use", { id: selectedId }); };
    $("a-drop").onclick = function () { if (selectedId != null) trigger("drop", { id: selectedId }); };
    $("a-give").onclick = function () { if (selectedId != null) trigger("give", { id: selectedId }); };
    $("a-split").onclick = function () {
        var it = selectedId != null ? itemById(selectedId) : null;
        if (!it || it.amount <= 1) return;
        $("modal-sub").textContent = it.name + " (x" + it.amount + ") - how many to split?";
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
    $("modal-amount").addEventListener("keydown", function (e) {
        if (e.key === "Enter") $("modal-ok").click();
        if (e.key === "Escape") $("modal-cancel").click();
    });
    $("btn-close").onclick = function () { trigger("close", {}); };
    $("btn-phone").onclick = function () { trigger("openPhone", {}); };
}

function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
        return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
}

/* ============================ audio ============================ */

var AUDIO = {};
function playSound(name) {
    try {
        if (!AUDIO[name]) AUDIO[name] = new Audio(name + ".wav");
        var a = AUDIO[name];
        a.currentTime = 0;
        a.volume = 0.35;
        a.play();
    } catch (e) { /* audio optional */ }
}

bindActions();
