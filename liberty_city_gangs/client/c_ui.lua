--[[
    liberty_city_gangs / client/c_ui.lua
    Basic luxury DX panel (foundation). Extend for full GTA V RP UI/UX.
]]

LCG = LCG or {}
LCG.UI = LCG.UI or {}

local sw, sh = guiGetScreenSize()
local open = false
local tab = 1
local tabs = { "overview", "members", "treasury", "warehouse", "territory", "vehicles" }

local function color(c, a)
    return tocolor(c[1], c[2], c[3], a or c[4] or 255)
end

local function fName(f)
    if not f or not f.name then return "-" end
    local l = LCG.client.lang or "ar"
    return f.name[l] or f.name.en or f.name.ar or f.key or "-"
end

function LCG.UI.onState(payload) end
function LCG.UI.onTreasuryLogs(rows) end
function LCG.UI.onWarehouse(rows) end

function LCG.UI.toggle()
    open = not open
    LCG.client.uiOpen = open
    showCursor(open)
    if open then LCG.requestState() end
end

function LCG.UI.close()
    open = false
    LCG.client.uiOpen = false
    showCursor(false)
end

addEventHandler("onClientKey", root, function(btn, press)
    if not press then return end
    if btn == "backspace" or btn == "escape" then
        if open then LCG.UI.close() cancelEvent() end
    end
end)

local function drawButton(x,y,w,h,text,active)
    local theme = LCG.theme
    dxDrawRectangle(x,y,w,h, active and color(theme.goldSoft,90) or color(theme.panel2,230))
    dxDrawRectangle(x, y+h-2, w, 2, color(theme.gold, active and 255 or 90))
    dxDrawText(text, x, y, x+w, y+h, color(theme.text), 1.0, "default-bold", "center", "center")
end

local function inRect(mx,my,x,y,w,h) return mx>=x and mx<=x+w and my>=y and my<=y+h end

addEventHandler("onClientClick", root, function(btn, state, mx, my)
    if btn ~= "left" or state ~= "up" or not open then return end
    local pw, ph = math.floor(sw*0.62), math.floor(sh*0.62)
    local px, py = math.floor((sw-pw)/2), math.floor((sh-ph)/2)
    local tx, ty = px + 20, py + 70
    local tw, th, gap = 120, 30, 8
    for i, name in ipairs(tabs) do
        local bx = tx + (i-1)*(tw+gap)
        if inRect(mx,my,bx,ty,tw,th) then
            tab = i
            if name == "warehouse" then triggerServerEvent("lcg:warehouse:list", resourceRoot) end
            if name == "treasury" then triggerServerEvent("lcg:treasury:logs", resourceRoot) end
            if name == "members" then triggerServerEvent("lcg:member:list", resourceRoot) end
            return
        end
    end
    -- quick actions (foundation)
    local ax, ay = px + pw - 220, py + ph - 50
    if tab == 2 and inRect(mx,my,ax,ay,90,30) then
        triggerServerEvent("lcg:member:list", resourceRoot)
    elseif tab == 3 and inRect(mx,my,ax,ay,90,30) then
        triggerServerEvent("lcg:treasury:deposit", resourceRoot, 1000)
    elseif tab == 3 and inRect(mx,my,ax-100,ay,90,30) then
        triggerServerEvent("lcg:treasury:withdraw", resourceRoot, 1000)
    elseif tab == 4 and inRect(mx,my,ax,ay,90,30) then
        triggerServerEvent("lcg:warehouse:deposit", resourceRoot, "water", 1)
    elseif tab == 4 and inRect(mx,my,ax-100,ay,90,30) then
        triggerServerEvent("lcg:warehouse:withdraw", resourceRoot, "water", 1)
    elseif tab == 5 and inRect(mx,my,ax,ay,90,30) then
        triggerServerEvent("lcg:territory:claim", resourceRoot, nil)
    end
end)

addEventHandler("onClientRender", root, function()
    if not open then return end
    local theme = LCG.theme
    local st = LCG.client.state or {}
    local member = st.member
    local faction = st.faction

    local pw, ph = math.floor(sw*0.62), math.floor(sh*0.62)
    local px, py = math.floor((sw-pw)/2), math.floor((sh-ph)/2)
    dxDrawRectangle(px, py, pw, ph, color(theme.bg))
    dxDrawRectangle(px, py, pw, 44, color(theme.panel))
    dxDrawRectangle(px, py+44, pw, 2, color(theme.gold))
    dxDrawText(LCG.t("نظام العصابات والمافيا", "Mafia & Gangs", "Máfia e Gangues"), px+18, py, px+pw, py+44, color(theme.gold), 1.3, "default-bold", "left", "center")
    dxDrawText(LCG.t("اغلاق: ESC/Backspace", "Close: ESC/Backspace", "Fechar: ESC/Backspace"), px, py, px+pw-16, py+44, color(theme.dim), 1.0, "default", "right", "center")

    local tx, ty = px + 20, py + 70
    local tw, th, gap = 120, 30, 8
    local labels = {
        overview = LCG.t("نظرة عامة","Overview","Visão"),
        members = LCG.t("الأعضاء","Members","Membros"),
        treasury = LCG.t("الخزينة","Treasury","Tesouro"),
        warehouse = LCG.t("المستودع","Warehouse","Armazém"),
        territory = LCG.t("المناطق","Territories","Territórios"),
        vehicles = LCG.t("السيارات","Vehicles","Veículos"),
    }
    for i, name in ipairs(tabs) do
        drawButton(tx + (i-1)*(tw+gap), ty, tw, th, labels[name] or name, tab == i)
    end

    local cx, cy = px + 24, ty + 50
    local cw, ch = pw - 48, ph - (ty - py) - 90
    dxDrawRectangle(cx, cy, cw, ch, color(theme.panel, 220))
    dxDrawRectangle(cx, cy, cw, 2, color(theme.line, 180))

    if not member or not faction then
        dxDrawText(LCG.t("أنت لست عضواً في أي فاكشن.", "You are not in any faction.", "Você não está em uma facção."), cx, cy, cx+cw, cy+ch, color(theme.dim), 1.2, "default-bold", "center", "center")
        return
    end

    local y = cy + 14
    local function line(txt, col)
        dxDrawText(txt, cx + 16, y, cx + cw - 16, y + 22, col or color(theme.text), 1.0, "default-bold", "left", "top")
        y = y + 24
    end

    local current = tabs[tab]
    if current == "overview" then
        line(LCG.t("الفاكشن: ", "Faction: ", "Facção: ") .. fName(faction), color(theme.gold))
        line(LCG.t("الرتبة: ", "Rank: ", "Rank: ") .. tostring(member.rank or "-"))
        line(LCG.t("الخزينة: $", "Treasury: $", "Tesouro: $") .. tostring(st.treasury or 0))
        line(LCG.t("النشاط: ", "Activity: ", "Atividade: ") .. tostring(faction.activity or "-"))
        line(LCG.t("أوامر: /gang, /lcgclaim, /lcgpark, /lcglock, /lcgactivity", "Commands: /gang, /lcgclaim, /lcgpark, /lcglock, /lcgactivity", "Comandos: /gang, /lcgclaim, /lcgpark, /lcglock, /lcgactivity"), color(theme.dim))
        line(LCG.t("ملاحظة: هذه نسخة تأسيسية وتحتاج تحقق داخل اللعبة.", "Note: foundation build, requires in-game verification.", "Nota: versão base, requer verificação no jogo."), color(theme.warn))
    elseif current == "members" then
        line(LCG.t("قائمة الأعضاء", "Members list", "Lista de membros"), color(theme.gold))
        local list = st.members or {}
        for i, m in ipairs(list) do
            if i > 14 then break end
            line("char#" .. tostring(m.char_id) .. "  |  rank " .. tostring(m.rank) .. "  |  joined " .. tostring(m.joined_at or "-"), color(theme.text))
        end
        if #list == 0 then line(LCG.t("لا يوجد بيانات بعد. اضغط تحديث.", "No data yet. Click refresh.", "Sem dados."), color(theme.dim)) end
    elseif current == "treasury" then
        line(LCG.t("رصيد الخزينة: $", "Treasury balance: $", "Saldo: $") .. tostring(st.treasury or 0), color(theme.gold))
        line(LCG.t("إيداع/سحب تجريبي: +$1000 / -$1000 (حسب الصلاحيات)", "Test deposit/withdraw: +$1000 / -$1000 (permission-based)", "Depósito/saque teste: +$1000 / -$1000"), color(theme.dim))
        local logs = LCG.client.treasuryLogs or {}
        for i, r in ipairs(logs) do
            if i > 10 then break end
            line(tostring(r.created_at or "") .. " | " .. tostring(r.action) .. " | " .. tostring(r.amount) .. " | bal " .. tostring(r.balance), color(theme.text))
        end
    elseif current == "warehouse" then
        line(LCG.t("مستودع الفاكشن (أساس)", "Faction warehouse (foundation)", "Armazém da facção (base)"), color(theme.gold))
        line(LCG.t("إيداع/سحب تجريبي: water x1 (عناصر مسموحة فقط)", "Test deposit/withdraw: water x1 (allowed items only)", "Depósito/saque teste: water x1"), color(theme.dim))
        local rows = LCG.client.warehouse or {}
        if #rows == 0 then line(LCG.t("المستودع فارغ", "Warehouse empty", "Armazém vazio"), color(theme.dim)) end
        for i, r in ipairs(rows) do
            if i > 14 then break end
            line(tostring(r.item) .. "  x" .. tostring(r.amount), color(theme.text))
        end
    elseif current == "territory" then
        line(LCG.t("مناطق النفوذ (أساس)", "Territories (foundation)", "Territórios (base)"), color(theme.gold))
        line(LCG.t("استخدم /lcgclaim داخل المنطقة للسيطرة (حسب الشروط/الصلاحيات)", "Use /lcgclaim inside a territory (rules/permissions apply)", "Use /lcgclaim dentro do território"), color(theme.dim))
        local rows = st.territories or {}
        for i, r in ipairs(rows) do
            if i > 12 then break end
            local owner = tonumber(r.owner_faction or r.owner or 0) or 0
            line("#" .. tostring(r.id) .. "  owner=" .. tostring(owner), color(theme.text))
        end
    elseif current == "vehicles" then
        line(LCG.t("أسطول الفاكشن", "Faction fleet", "Frota da facção"), color(theme.gold))
        line(LCG.t("الأوامر: /lcglock لقفل/فتح، /lcgpark لحفظ الحالة (داخل المركبة)", "Commands: /lcglock toggle, /lcgpark save state", "Comandos: /lcglock, /lcgpark"), color(theme.dim))
        local f = LCG.getFaction and LCG.getFaction(member.faction_id) or nil
        if f and f.vehicles then
            for i, v in ipairs(f.vehicles) do
                if i > 12 then break end
                line(tostring(v.name or v.model) .. " (" .. tostring(v.model) .. ")", color(theme.text))
            end
        else
            line(LCG.t("لا توجد بيانات مركبات", "No vehicle data", "Sem dados"), color(theme.dim))
        end
    end

    -- footer actions
    local ax, ay = px + pw - 220, py + ph - 50
    if tab == 2 then drawButton(ax, ay, 90, 30, LCG.t("تحديث","Refresh","Atualizar"), false) end
    if tab == 3 then
        drawButton(ax-100, ay, 90, 30, "-$1000", false)
        drawButton(ax, ay, 90, 30, "+$1000", false)
    end
    if tab == 4 then
        drawButton(ax-100, ay, 90, 30, LCG.t("سحب","Take","Retirar"), false)
        drawButton(ax, ay, 90, 30, LCG.t("إيداع","Put","Depositar"), false)
    end
    if tab == 5 then
        drawButton(ax, ay, 90, 30, LCG.t("سيطرة","Claim","Tomar"), false)
    end
end)
