/* ============================================================
   luxury_phone app.js - iFruit OS logic
   Lua -> window.__luxAction(action, data)
   JS -> mta.triggerEvent("lxp:ui", action, json)
   ============================================================ */

"use strict";

var state = {
    phone: null,      // ngp:showPhone payload
    settings: {},     // per-character settings
    bank: null,       // lxp:bankData
    vehicles: null,   // lxp:vehicles
    photos: [],
    thread: null,     // active chat number
    callActive: false,
};

/* ============================ icons ============================ */

var I = {
    contacts: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M10 8h24a4 4 0 0 1 4 4v24a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4V12a4 4 0 0 1 4-4zm12 8a5 5 0 1 0 0 10 5 5 0 0 0 0-10zm-9 20c0-4 4-7 9-7s9 3 9 7v1H13v-1z"/></svg>',
    messages: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M6 8h36a3 3 0 0 1 3 3v22a3 3 0 0 1-3 3H20l-9 8v-8H6a3 3 0 0 1-3-3V11a3 3 0 0 1 3-3zm6 9h24v3H12v-3zm0 7h18v3H12v-3z"/></svg>',
    calls: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M16 6c2 0 4 1 5 3l3 6c1 2 0 4-1 5l-4 3c2 5 6 9 11 11l3-4c1-2 3-2 5-1l6 3c2 1 3 3 3 5 0 5-5 9-10 9C20 46 2 28 2 11c0-3 1-5 2-6 1-1 2-1 3-1h9z" transform="translate(6 0)"/></svg>',
    bank: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 4 44 14v4H4v-4L24 4zM8 22h6v14H8V22zm13 0h6v14h-6V22zm13 0h6v14h-6V22zM4 40h40v4H4v-4z"/></svg>',
    gps: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 4a14 14 0 0 1 14 14c0 10-14 26-14 26S10 28 10 18A14 14 0 0 1 24 4zm0 8a6 6 0 1 0 0 12 6 6 0 0 0 0-12z"/></svg>',
    vehicles: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M10 20l3-8a4 4 0 0 1 3.7-2.5h14.6A4 4 0 0 1 35 12l3 8h2a3 3 0 0 1 3 3v9a2 2 0 0 1-2 2h-2v2a3 3 0 0 1-6 0v-2H15v2a3 3 0 0 1-6 0v-2H7a2 2 0 0 1-2-2v-9a3 3 0 0 1 3-3h2zm6 0h16l-2-6H18l-2 6zm0 10a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm16 0a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/></svg>',
    settings: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 16a8 8 0 1 0 0 16 8 8 0 0 0 0-16zm0 5a3 3 0 1 1 0 6 3 3 0 0 1 0-6zm-4-17h8l1.4 6.2 3.6 1.5 5.4-3.2 5.6 5.6-3.2 5.4 1.5 3.6L48 24v8h-6.2l-1.5 3.6 3.2 5.4-5.6 5.6-5.4-3.2-3.6 1.5L28 52h-8l-1.4-6.2-3.6-1.5-5.4 3.2-5.6-5.6 3.2-5.4-1.5-3.6L0 32v-8h6.2l1.5-3.6-3.2-5.4 5.6-5.6 5.4 3.2 3.6-1.5L20 4z" transform="scale(0.92)"/></svg>',
    camera: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M16 10h16l3 5h7a3 3 0 0 1 3 3v21a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V18a3 3 0 0 1 3-3h7l3-5zm8 8a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm0 5a5 5 0 1 1 0 10 5 5 0 0 1 0-10z"/></svg>',
    ads: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M38 6v30L26 30H12a4 4 0 0 1-4-4V16a4 4 0 0 1 4-4h14l12-6zM12 34h4v6a2 2 0 0 1-4 0v-6z"/></svg>',
    services: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 4a6 6 0 0 1 6 6c0 2-1 4-2.5 5L24 34l-3.5-19A6 6 0 0 1 18 10a6 6 0 0 1 6-6zm0 34 4 4-4 4-4-4 4-4z"/></svg>',
    inventory: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M6 10h36a2 2 0 0 1 2 2v24a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V12a2 2 0 0 1 2-2zm4 8h28v3H10v-3zm0 7h18v3H10v-3zm0 7h10v3H10v-3z"/></svg>',
    clock: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M24 4a20 20 0 1 1 0 40 20 20 0 0 1 0-40zm2 9h-4v13l10 6 2-3.4-8-4.8V13z"/></svg>',
    exit: '<svg viewBox="0 0 48 48"><path fill="currentColor" d="M18 6h18a4 4 0 0 1 4 4v28a4 4 0 0 1-4 4H18a4 4 0 0 1-4-4v-6h4v6h18V10H18v6h-4v-6a4 4 0 0 1 4-4zm2 14h12v4H20v4l-8-6 8-6v4z"/></svg>'
};

/* ============================ helpers ============================ */

function $(id) { return document.getElementById(id); }

function trigger(action, args) {
    if (window.mta && mta.triggerEvent) {
        mta.triggerEvent("lxp:ui", action, JSON.stringify(args || {}));
    }
}

function sfx() { trigger("click", {}); }

function toast(text, ok) {
    var t = $("phone-toast");
    t.className = "phone-toast" + (ok === false ? " err" : "");
    t.textContent = text;
    clearTimeout(t._to);
    t._to = setTimeout(function () { t.classList.add("out"); }, 2400);
    setTimeout(function () { t.classList.add("hidden"); }, 2800);
}

function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
        return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
}

function fmtCash(n) { return "$" + (n || 0).toLocaleString("en-US"); }

/* ============================ clock ============================ */

setInterval(function () {
    var d = new Date();
    var hh = d.getHours(), mm = d.getMinutes();
    var t = (hh < 10 ? "0" : "") + hh + ":" + (mm < 10 ? "0" : "") + mm;
    $("sb-time").textContent = t;
    $("lk-time").textContent = t;
    var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"];
    var mon = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    $("lk-date").textContent = days[d.getDay()] + " - " + mon[d.getMonth()] + " " + d.getDate();
}, 1000);

/* ============================ panes ============================ */

var currentApp = null;

function showPane(id) {
    var panes = document.querySelectorAll(".pane");
    for (var i = 0; i < panes.length; i++) panes[i].classList.remove("active");
    $(id).classList.add("active");
    $("home-bar").classList.toggle("hidden", id !== "home");
}

function goHome() { currentApp = null; showPane("home"); sfx(); }

$("lockscreen").addEventListener("click", function () { showPane("home"); sfx(); });
$("app-back").addEventListener("click", function () { goHome(); });
$("home-bar").addEventListener("click", goHome);
$("inc-decline").addEventListener("click", function () {
    $("incoming").classList.add("hidden");
    state.callActive = false;
    trigger("hangup", {});
    sfx();
});

/* ============================ app registry ============================ */

var APPS = [
    { id: "contacts",  label: "Contacts",  icon: I.contacts,  c1: "#2a2e36", c2: "#171a20" },
    { id: "messages",  label: "Messages",  icon: I.messages,  c1: "#2a2e36", c2: "#171a20", badge: true },
    { id: "calls",     label: "Calls",     icon: I.calls,     c1: "#2a2e36", c2: "#171a20" },
    { id: "bank",      label: "Bank",      icon: I.bank,      c1: "#2a2e36", c2: "#171a20", badgeTxt: "$" },
    { id: "gps",       label: "GPS",       icon: I.gps,       c1: "#2a2e36", c2: "#171a20" },
    { id: "vehicles",  label: "Vehicles",  icon: I.vehicles,  c1: "#2a2e36", c2: "#171a20" },
    { id: "services",  label: "Services",  icon: I.services,  c1: "#2a2e36", c2: "#171a20" },
    { id: "ads",       label: "Ads",       icon: I.ads,       c1: "#2a2e36", c2: "#171a20" },
    { id: "camera",    label: "Camera",    icon: I.camera,    c1: "#2a2e36", c2: "#171a20" },
    { id: "inventory", label: "Backpack",  icon: I.inventory, c1: "#2a2e36", c2: "#171a20" },
    { id: "settings",  label: "Settings",  icon: I.settings,  c1: "#2a2e36", c2: "#171a20" },
    { id: "exit",      label: "Exit",      icon: I.exit,      c1: "#2a2e36", c2: "#171a20" },
];

var DOCK = ["calls", "messages", "camera", "settings"];

function tileHtml(app, label) {
    return '<div class="tile-icon"><svg viewBox="0 0 48 48">' + app.icon.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</svg></div>" +
        (label ? '<div class="tile-label">' + esc(app.label) + "</div>" : "");
}

function renderHome() {
    var grid = $("app-grid");
    grid.innerHTML = "";
    var unread = state.phone && state.phone.unread ? state.phone.unread : 0;

    APPS.forEach(function (app, i) {
        var tile = document.createElement("div");
        tile.className = "app-tile";
        tile.style.animationDelay = (i * 28) + "ms";
        tile.innerHTML = tileHtml(app, true);
        if (app.id === "messages" && unread > 0) {
            tile.innerHTML += '<div class="badge">' + unread + "</div>";
        }
        tile.addEventListener("click", function () { openApp(app.id); });
        grid.appendChild(tile);
    });

    var dock = $("dock");
    dock.innerHTML = "";
    DOCK.forEach(function (id) {
        var app = APPS.filter(function (a) { return a.id === id; })[0];
        var tile = document.createElement("div");
        tile.className = "app-tile";
        tile.innerHTML = tileHtml(app, false);
        tile.addEventListener("click", function () { openApp(id); });
        dock.appendChild(tile);
    });
}

function openApp(id) {
    sfx();
    if (id === "exit") { trigger("close", {}); return; }
    if (id === "inventory") { trigger("openInventory", {}); return; }

    currentApp = id;
    $("app-title").textContent = APPS.filter(function (a) { return a.id === id; })[0].label.toUpperCase();
    var c = $("app-content");
    c.innerHTML = "";
    showPane("appview");

    if (id === "contacts") renderContacts(c);
    else if (id === "messages") renderMessages(c);
    else if (id === "calls") renderCalls(c);
    else if (id === "bank") renderBank(c);
    else if (id === "gps") renderGps(c);
    else if (id === "vehicles") { renderVehicles(c); trigger("vehicles", {}); }
    else if (id === "services") renderServices(c);
    else if (id === "ads") renderAds(c);
    else if (id === "camera") renderCamera(c);
    else if (id === "settings") renderSettings(c);
}

/* ============================ contacts ============================ */

function renderContacts(c) {
    var add = document.createElement("div");
    add.className = "card";
    add.innerHTML =
        '<div class="row"><input id="ct-name" class="field" placeholder="Name" style="flex:1">' +
        '<input id="ct-num" class="field" placeholder="Number" style="flex:1;width:90px"></div>' +
        '<button class="btn" style="width:100%;margin-top:8px">ADD CONTACT</button>';
    add.querySelector(".btn").addEventListener("click", function () {
        var n = $("ct-name").value.trim(), num = $("ct-num").value.trim();
        if (!n || !num) { toast("Name and number required", false); return; }
        trigger("addContact", { name: n, number: num });
        setTimeout(openContactsRefresh, 400);
    });
    c.appendChild(add);

    var list = (state.phone && state.phone.contacts) || [];
    if (!list.length) {
        c.innerHTML += '<div class="empty-note">No contacts yet.<br>Add one above - numbers are 6-digit LS numbers.</div>';
        return;
    }
    list.forEach(function (ct, i) {
        var row = document.createElement("div");
        row.className = "list-row";
        row.style.animationDelay = (i * 30) + "ms";
        row.innerHTML =
            '<div class="lr-icon">' + I.contacts.replace(/^<svg[^>]*>|<\/svg>$/g, function (m) { return m; }) + "</div>" +
            '<div class="lr-main"><div class="lr-name">' + esc(ct.name) + '</div><div class="lr-sub">' + esc(ct.number) + "</div></div>" +
            '<div class="lr-acts">' +
            '<button class="lr-btn" title="SMS">' + I.messages.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</button>" +
            '<button class="lr-btn gold" title="Call">' + I.calls.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</button>" +
            '<button class="lr-btn danger" title="Delete">&#10005;</button></div>';
        var btns = row.querySelectorAll(".lr-btn");
        btns[0].addEventListener("click", function (e) { e.stopPropagation(); state.thread = { number: ct.number, name: ct.name }; openApp("messages"); });
        btns[1].addEventListener("click", function (e) { e.stopPropagation(); trigger("call", { number: ct.number }); });
        btns[2].addEventListener("click", function (e) { e.stopPropagation(); trigger("deleteContact", { number: ct.number }); setTimeout(openContactsRefresh, 350); });
        c.appendChild(row);
    });
}
function openContactsRefresh() { openApp("contacts"); }

/* ============================ messages ============================ */

function renderMessages(c) {
    var list = (state.phone && state.phone.messages) || [];
    var myNum = state.phone ? String(state.phone.number) : "";
    var contacts = (state.phone && state.phone.contacts) || [];

    function contactName(number) {
        for (var i = 0; i < contacts.length; i++) {
            if (String(contacts[i].number) === String(number)) return contacts[i].name;
        }
        return number;
    }

    if (state.thread) {
        renderThread(c, myNum);
        return;
    }

    // group into threads by other party
    var threads = {};
    var order = [];
    list.forEach(function (m) {
        var other = String(m.sender) === myNum ? String(m.receiver) : String(m.sender);
        if (!threads[other]) { threads[other] = { last: m, count: 0 }; order.push(other); }
        threads[other].last = m;
        threads[other].count++;
    });

    if (!order.length) {
        c.innerHTML = '<div class="empty-note">No messages yet.<br>Open Contacts and tap the SMS button,<br>or use the Calls app.</div>';
        return;
    }

    order.forEach(function (num, i) {
        var t = threads[num];
        var row = document.createElement("div");
        row.className = "list-row";
        row.style.animationDelay = (i * 30) + "ms";
        row.innerHTML =
            '<div class="lr-icon">' + I.messages.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</div>" +
            '<div class="lr-main"><div class="lr-name">' + esc(contactName(num)) + '</div><div class="lr-sub">' + esc(t.last.text).slice(0, 40) + "</div></div>" +
            '<div class="lr-sub">' + esc(t.last.time || "") + "</div>";
        row.addEventListener("click", function () {
            state.thread = { number: num, name: contactName(num) };
            openApp("messages");
        });
        c.appendChild(row);
    });

    var newBtn = document.createElement("button");
    newBtn.className = "btn dark";
    newBtn.textContent = "NEW SMS - TYPE A NUMBER";
    newBtn.addEventListener("click", function () {
        state.thread = { number: "", name: "New SMS" };
        openApp("messages");
    });
    c.appendChild(newBtn);
}

function renderThread(c, myNum) {
    var head = document.createElement("div");
    head.className = "card";
    head.innerHTML =
        '<div class="row"><b class="card-title">' + esc(state.thread.name || state.thread.number) + "</b></div>" +
        '<div class="row" style="margin-top:8px"><input id="th-num" class="field" placeholder="Number (6 digits)" value="' + esc(state.thread.number) + '" style="flex:1">' +
        '<button id="th-start" class="btn" style="padding:9px 12px">OPEN</button></div>';
    c.appendChild(head);
    $("th-start").addEventListener("click", function () {
        state.thread.number = $("th-num").value.trim();
        toast("Now chatting with " + (state.thread.number || "-"));
    });

    var list = (state.phone && state.phone.messages) || [];
    var msgs = list.filter(function (m) {
        var other = String(m.sender) === myNum ? String(m.receiver) : String(m.sender);
        return other === String(state.thread.number);
    }).slice(0, 20).reverse();

    if (msgs.length) {
        var bubble;
        msgs.forEach(function (m) {
            var mine = String(m.sender) === myNum;
            bubble = document.createElement("div");
            bubble.className = "chat-bubble " + (mine ? "chat-out" : "chat-in");
            bubble.innerHTML = esc(m.text) + '<div class="chat-time">' + esc(m.time || "") + "</div>";
            c.appendChild(bubble);
        });
    } else {
        c.innerHTML += '<div class="empty-note">No messages with this number yet.</div>';
    }

    var inputRow = document.createElement("div");
    inputRow.className = "chat-input-row";
    inputRow.innerHTML =
        '<input id="sms-text" class="field" placeholder="Message..." style="flex:1" maxlength="160">' +
        '<button id="sms-send" class="btn" style="padding:11px 16px">SEND</button>';
    c.appendChild(inputRow);
    $("sms-send").addEventListener("click", sendSmsLocal);
    $("sms-text").addEventListener("keydown", function (e) { if (e.key === "Enter") sendSmsLocal(); });
}

function sendSmsLocal() {
    var text = $("sms-text").value.trim();
    var num = String(state.thread.number || "").trim();
    if (!text || !num) { toast("Number and message required", false); return; }
    trigger("sendSms", { number: num, text: text });
    $("sms-text").value = "";
    setTimeout(function () {
        state.phone = null; // force refresh from server on next open
        trigger("markRead", {});
        openApp("messages");
    }, 450);
}

/* ============================ calls ============================ */

function renderCalls(c) {
    var myNum = state.phone ? String(state.phone.number) : "";
    var dial = document.createElement("div");
    dial.className = "card";
    dial.innerHTML =
        '<div class="card-sub">Your number: <b class="card-gold">' + esc(myNum) + "</b></div>" +
        '<div class="row" style="margin-top:10px"><input id="dial-num" class="field" placeholder="Number to call" style="flex:1">' +
        '<button id="dial-go" class="btn" style="padding:11px 16px">CALL</button></div>' +
        '<div class="card-sub" style="margin-top:8px">Voice works through proximity chat while the call is active. Use DECLINE or /hangup to end.</div>';
    c.appendChild(dial);
    $("dial-go").addEventListener("click", function () {
        var n = $("dial-num").value.trim();
        if (!n) { toast("Enter a number", false); return; }
        trigger("call", { number: n });
        toast("Calling " + n + "...");
    });

    var contacts = (state.phone && state.phone.contacts) || [];
    if (contacts.length) {
        var t = document.createElement("div");
        t.className = "card-sub";
        t.style.marginTop = "6px";
        t.textContent = "QUICK CALL - CONTACTS";
        c.appendChild(t);
        contacts.forEach(function (ct, i) {
            var row = document.createElement("div");
            row.className = "list-row";
            row.style.animationDelay = (i * 25) + "ms";
            row.innerHTML =
                '<div class="lr-icon">' + I.calls.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</div>" +
                '<div class="lr-main"><div class="lr-name">' + esc(ct.name) + '</div><div class="lr-sub">' + esc(ct.number) + "</div></div>" +
                '<div class="lr-acts"><button class="lr-btn gold">' + I.calls.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</button></div>";
            row.querySelector(".lr-btn").addEventListener("click", function (e) {
                e.stopPropagation();
                trigger("call", { number: ct.number });
                toast("Calling " + ct.name + "...");
            });
            c.appendChild(row);
        });
    }
}

/* ============================ bank ============================ */

function renderBank(c) {
    if (state.bank) { paintBank(c, state.bank); return; }
    trigger("bankData", {});
    c.innerHTML = '<div class="empty-note">Loading account...</div>';
    setTimeout(function () { if (currentApp === "bank" && state.bank) paintBank($("app-content"), state.bank); }, 500);
}

function paintBank(c, bank) {
    var top = document.createElement("div");
    top.className = "card big";
    top.innerHTML =
        '<div class="card-sub">MAZE BANK - LS</div>' +
        '<div class="num card-green">' + fmtCash(bank.bank) + "</div>" +
        '<div class="card-sub">Cash on hand: <b class="card-gold">' + fmtCash(bank.cash) + "</b></div>";
    c.appendChild(top);

    var tr = document.createElement("div");
    tr.className = "card";
    tr.innerHTML =
        '<div class="card-title">TRANSFER MONEY</div>' +
        '<input id="tr-name" class="field" placeholder="Player name" style="margin-top:9px">' +
        '<input id="tr-amount" class="field" type="number" placeholder="Amount $" style="margin-top:7px">' +
        '<button id="tr-go" class="btn" style="width:100%;margin-top:9px">SEND TRANSFER</button>';
    c.appendChild(tr);
    $("tr-go").addEventListener("click", function () {
        var n = $("tr-name").value.trim(), a = parseInt($("tr-amount").value, 10);
        if (!n || !a || a <= 0) { toast("Player and amount required", false); return; }
        trigger("transfer", { name: n, amount: a });
    });

    var hist = document.createElement("div");
    hist.className = "card";
    hist.innerHTML = '<div class="card-title">RECENT ACTIVITY</div>';
    (bank.transactions || []).forEach(function (t) {
        var row = document.createElement("div");
        row.className = "row";
        row.style.marginTop = "8px";
        var isInc = String(t.ttype) === "income";
        row.innerHTML =
            '<div class="grow"><div class="card-sub" style="margin:0">' + esc((t.note || "").slice(0, 34)) + '<br><span style="opacity:.6">' + esc(t.time || "") + "</span></div></div>" +
            '<div class="' + (isInc ? "card-green" : "card-gold") + '">' + (isInc ? "+" : "-") + fmtCash(Math.abs(t.amount || 0)) + "</div>";
        hist.appendChild(row);
    });
    if (!(bank.transactions || []).length) {
        var e = document.createElement("div");
        e.className = "empty-note";
        e.textContent = "No transactions yet.";
        hist.appendChild(e);
    }
    c.appendChild(hist);
}

/* ============================ gps ============================ */

var LANDMARKS = [
    { name: "Spawn Point",        x: -66.99,  y: -1113.86, z: 729.0 },
    { name: "City Hospital",      x: 296.11,  y: -1130.44, z: 731.0 },
    { name: "LSPD Station",       x: 323.11,  y: -995.83,  z: 731.0 },
    { name: "Vehicle Dealer",     x: 180.2,   y: -966.3,   z: 728.8 },
    { name: "Gas Station (West)", x: -716.3,  y: -830.8,   z: 724.2 },
    { name: "Gas Station (Central)", x: 0.3,  y: -1436.2,  z: 734.4 },
    { name: "Gas Station (South)",   x: -123.8, y: -1464.8, z: 735.6 },
    { name: "Gas Station (East)",    x: -812.0, y: -956.9,  z: 721.0 },
    { name: "ATM - City Bank",    x: 133.6,   y: -1131.6,  z: 730.2 },
    { name: "24/7 Downtown",      x: 452.2,   y: -1111.8,  z: 735.7 },
    { name: "Burger Shot",        x: 422.8,   y: -1570.7,  z: 732.4 },
    { name: "Binco Clothing",     x: 511.7,   y: -662.4,   z: 727.0 },
];

function renderGps(c) {
    var info = document.createElement("div");
    info.className = "card";
    info.innerHTML = '<div class="card-title">GPS NAVIGATOR</div><div class="card-sub">Pick a destination - a gold blip is placed on your radar.</div>';
    c.appendChild(info);
    LANDMARKS.forEach(function (l, i) {
        var row = document.createElement("div");
        row.className = "list-row";
        row.style.animationDelay = (i * 22) + "ms";
        row.innerHTML =
            '<div class="lr-icon">' + I.gps.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</div>" +
            '<div class="lr-main"><div class="lr-name">' + esc(l.name) + '</div><div class="lr-sub">' + l.x.toFixed(0) + ", " + l.y.toFixed(0) + "</div></div>" +
            '<div class="lr-acts"><button class="lr-btn gold">SET</button></div>';
        row.querySelector(".lr-btn").addEventListener("click", function (e) {
            e.stopPropagation();
            trigger("waypoint", { x: l.x, y: l.y, z: l.z, name: l.name });
            toast("Route: " + l.name);
        });
        c.appendChild(row);
    });
}

/* ============================ vehicles ============================ */

function renderVehicles(c) {
    if (state.vehicles) { paintVehicles(c, state.vehicles); return; }
    trigger("vehicles", {});
    c.innerHTML = '<div class="empty-note">Loading your vehicles...</div>';
    setTimeout(function () { if (currentApp === "vehicles" && state.vehicles) paintVehicles($("app-content"), state.vehicles); }, 500);
}

function paintVehicles(c, data) {
    var list = data.vehicles || [];
    if (!list.length) {
        c.innerHTML = '<div class="empty-note">You do not own any vehicles yet.<br>Visit the dealer to buy one.</div>';
        return;
    }
    list.forEach(function (v, i) {
        var row = document.createElement("div");
        row.className = "list-row";
        row.style.animationDelay = (i * 30) + "ms";
        row.innerHTML =
            '<div class="lr-icon">' + I.vehicles.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</div>" +
            '<div class="lr-main"><div class="lr-name">' + esc(v.name) + ' <span style="color:#d4af37;font-size:10px">' + esc(v.plate) + "</span></div>" +
            '<div class="lr-sub">Fuel ' + v.fuel + "% - Condition " + v.health + "% - " + (v.locked ? "LOCKED" : "UNLOCKED") + "</div></div>" +
            '<div class="lr-acts">' +
            '<button class="lr-btn" title="Lock/Unlock">' + (v.locked ? "&#128274;" : "&#128275;") + "</button>" +
            '<button class="lr-btn gold" title="GPS">' + I.gps.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</button></div>";
        var btns = row.querySelectorAll(".lr-btn");
        btns[0].addEventListener("click", function (e) {
            e.stopPropagation();
            trigger("vehAction", { id: v.id, do_action: v.locked ? "unlock" : "lock" });
        });
        btns[1].addEventListener("click", function (e) {
            e.stopPropagation();
            trigger("vehAction", { id: v.id, do_action: "find" });
        });
        c.appendChild(row);
    });
}

/* ============================ services ============================ */

var SERVICES = [
    { id: "mechanic", label: "MECHANIC", sub: "Vehicle repair - broadcasts to mechanics on duty", icon: I.vehicles },
    { id: "taxi",     label: "TAXI",     sub: "Ride request - $100 fee, refunded if no driver", icon: I.vehicles },
    { id: "police",   label: "POLICE",   sub: "Emergency - LSPD response", icon: I.services },
    { id: "medic",    label: "EMS",      sub: "Medical emergency - medics respond", icon: I.services },
];

function renderServices(c) {
    var info = document.createElement("div");
    info.className = "card";
    info.innerHTML = '<div class="card-title">CITY SERVICES</div><div class="card-sub">Your position is shared as a GPS blip for 5 minutes. One call per minute.</div>';
    c.appendChild(info);
    SERVICES.forEach(function (s, i) {
        var btn = document.createElement("div");
        btn.className = "svc-btn";
        btn.style.animationDelay = (i * 40) + "ms";
        btn.innerHTML =
            '<div class="svc-ic">' + s.icon.replace(/^<svg[^>]*>|<\/svg>$/g, "") + "</div>" +
            '<div class="grow"><div class="svc-name">' + s.label + '</div><div class="svc-sub">' + s.sub + "</div></div>";
        btn.addEventListener("click", function () {
            trigger("service", { service: s.id });
            toast("Calling " + s.label + "...");
        });
        c.appendChild(btn);
    });
}

/* ============================ ads ============================ */

function renderAds(c) {
    var box = document.createElement("div");
    box.className = "card";
    box.innerHTML =
        '<div class="card-title">SERVER ADVERTISEMENT</div>' +
        '<div class="card-sub">Broadcast to every player in Los Santos. Cost: <b class="card-gold">$200</b> cash.</div>' +
        '<textarea id="ad-text" class="field" rows="3" maxlength="120" placeholder="e.g. Selling Sultan, cheap - call 555..." style="margin-top:9px;resize:none"></textarea>' +
        '<button id="ad-go" class="btn" style="width:100%;margin-top:9px">PUBLISH ($200)</button>';
    c.appendChild(box);
    $("ad-go").addEventListener("click", function () {
        var t = $("ad-text").value.trim();
        if (!t) { toast("Write your ad first", false); return; }
        trigger("sendAd", { text: t });
        $("ad-text").value = "";
    });
}

/* ============================ camera ============================ */

function renderCamera(c) {
    var cap = document.createElement("div");
    cap.className = "card big";
    cap.innerHTML =
        '<div class="card-title">LS CAMERA</div>' +
        '<div class="card-sub">Captures a real photo of your current view.</div>' +
        '<button id="cam-go" class="btn" style="width:60%;margin-top:12px">CAPTURE</button>';
    c.appendChild(cap);
    $("cam-go").addEventListener("click", function () { trigger("photo", {}); });

    var g = document.createElement("div");
    g.className = "card";
    g.innerHTML = '<div class="card-title">GALLERY</div><div id="cam-grid" class="photo-grid" style="margin-top:9px"></div>';
    c.appendChild(g);
    paintGallery();
}

function paintGallery() {
    var grid = $("cam-grid");
    if (!grid) return;
    grid.innerHTML = "";
    if (!state.photos.length) {
        grid.innerHTML = '<div class="empty-note" style="grid-column:1/3">No photos yet - capture one!</div>';
        return;
    }
    state.photos.forEach(function (src) {
        var d = document.createElement("div");
        d.className = "photo";
        d.style.backgroundImage = "url('" + src + "')";
        grid.appendChild(d);
    });
}

/* ============================ settings ============================ */

function renderSettings(c) {
    var s = state.settings || {};

    var name = document.createElement("div");
    name.className = "set-row";
    name.innerHTML =
        '<div><div class="set-label">PHONE NAME</div><div class="set-hint">Shown on the status bar</div></div>' +
        '<input id="s-name" class="field" style="width:110px" maxlength="16" value="' + esc(s.phoneName || "iFruit") + '">';
    c.appendChild(name);

    var wall = document.createElement("div");
    wall.className = "set-row";
    wall.innerHTML =
        '<div><div class="set-label">WALLPAPER</div><div class="set-hint">Tap to preview</div></div>' +
        '<div class="wall-prev"><div class="wp wp1" data-w="1"></div><div class="wp wp2" data-w="2"></div><div class="wp wp3" data-w="3"></div></div>';
    c.appendChild(wall);

    var ring = document.createElement("div");
    ring.className = "set-row";
    ring.innerHTML =
        '<div><div class="set-label">RINGTONE</div><div class="set-hint">Incoming call sound</div></div>' +
        '<div class="seg" id="s-ring"><button data-r="call">Call</button><button data-r="message">Message</button></div>';
    c.appendChild(ring);

    var vol = document.createElement("div");
    vol.className = "set-row";
    vol.innerHTML =
        '<div><div class="set-label">VOLUME</div><div class="set-hint">UI sounds</div></div>' +
        '<input id="s-vol" type="range" min="0" max="100" value="' + (s.volume != null ? s.volume : 60) + '">';
    c.appendChild(vol);

    var bri = document.createElement("div");
    bri.className = "set-row";
    bri.innerHTML =
        '<div><div class="set-label">BRIGHTNESS</div><div class="set-hint">Screen dimming</div></div>' +
        '<input id="s-bri" type="range" min="40" max="100" value="' + (s.brightness != null ? s.brightness : 100) + '">';
    c.appendChild(bri);

    var save = document.createElement("button");
    save.className = "btn";
    save.textContent = "SAVE SETTINGS";
    save.addEventListener("click", function () {
        var data = {
            wallpaper: parseInt(currentWall, 10) || 1,
            ringtone: currentRing,
            volume: parseInt($("s-vol").value, 10),
            brightness: parseInt($("s-bri").value, 10),
            phoneName: $("s-name").value.trim() || "iFruit",
        };
        trigger("saveSettings", data);
        toast("Settings saved");
    });
    c.appendChild(save);

    applySettingsToControls(s);
}

var currentWall = 1;
var currentRing = "call";

function applySettingsToControls(s) {
    currentWall = s.wallpaper || 1;
    currentRing = s.ringtone || "call";
    document.querySelectorAll(".wall-prev .wp").forEach(function (w) {
        w.classList.toggle("on", parseInt(w.dataset.w, 10) === currentWall);
        w.onclick = function () {
            currentWall = parseInt(w.dataset.w, 10);
            document.querySelectorAll(".wall-prev .wp").forEach(function (x) { x.classList.remove("on"); });
            w.classList.add("on");
            applyWallpaper(currentWall);
            sfx();
        };
    });
    document.querySelectorAll("#s-ring button").forEach(function (b) {
        b.classList.toggle("on", b.dataset.r === currentRing);
        b.onclick = function () {
            currentRing = b.dataset.r;
            document.querySelectorAll("#s-ring button").forEach(function (x) { x.classList.remove("on"); });
            b.classList.add("on");
            sfx();
        };
    });
    var vb = $("s-vol");
    if (vb) vb.addEventListener("input", function () {
        state.settings.volume = parseInt(vb.value, 10);
        sfx();
    });
    var br = $("s-bri");
    if (br) br.addEventListener("input", function () {
        $("brightness").style.opacity = ((100 - parseInt(br.value, 10)) / 100) * 0.55;
    });
    var bri0 = $("s-bri");
    if (bri0) $("brightness").style.opacity = ((100 - (s.brightness != null ? s.brightness : 100)) / 100) * 0.55;
}

function applyWallpaper(n) {
    var s = $("screen");
    s.classList.remove("w1", "w2", "w3");
    s.classList.add("w" + Math.min(3, Math.max(1, n)));
}

/* ============================ Lua bridge ============================ */

window.__luxReady = function () { renderHome(); };

window.__luxAction = function (action, data) {
    // MTA's toJSON() always wraps its arguments in a JSON array, so a single
    // payload arrives as [ {...} ] - unwrap it before rendering.
    if (Object.prototype.toString.call(data) === "[object Array]" && data.length === 1) data = data[0];
    if (action === "phone") {
        state.phone = data;
        renderHome();
        if (currentApp) openApp(currentApp); // refresh open app
        if (state.callActive) $("incoming").classList.add("hidden");
    } else if (action === "settings") {
        state.settings = data || {};
        applyWallpaper(state.settings.wallpaper || 1);
        $("sb-name").textContent = state.settings.phoneName || "iFruit";
        var bri = state.settings.brightness != null ? state.settings.brightness : 100;
        $("brightness").style.opacity = ((100 - bri) / 100) * 0.55;
        if (currentApp === "settings" && $("s-name")) applySettingsToControls(state.settings);
    } else if (action === "incoming") {
        state.callActive = true;
        $("inc-number").textContent = data.number || "-";
        $("incoming").classList.remove("hidden");
    } else if (action === "callEnded") {
        state.callActive = false;
        $("incoming").classList.add("hidden");
        toast("Call ended");
    } else if (action === "sms") {
        toast("SMS from " + (data.from || "?") + ": " + (data.text || ""));
        if (state.phone) {
            state.phone.messages.unshift({ sender: data.from, text: data.text, time: "now", read: 0 });
            renderHome();
        }
    } else if (action === "toast") {
        toast(data.text || "", data.ok);
    } else if (action === "bank") {
        state.bank = data;
        if (currentApp === "bank") { $("app-content").innerHTML = ""; paintBank($("app-content"), data); }
    } else if (action === "vehicles") {
        state.vehicles = data;
        if (currentApp === "vehicles") { $("app-content").innerHTML = ""; paintVehicles($("app-content"), data); }
    } else if (action === "photo") {
        state.photos.unshift(data.data);
        if (state.photos.length > 6) state.photos.pop();
        paintGallery();
        toast("Photo saved to gallery");
    }
};
