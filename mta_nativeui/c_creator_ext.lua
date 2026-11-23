-- Small helper exported to ng-characters so the GTA V creator can keep its
-- NativeUI rows in sync with typed names while the third-party core stays
-- otherwise untouched. The Beerware notice in c_MTA-V-Native-UI.lua applies.

function setNativeItemText(menuElement, itemElement, text)
    assert(isElement(menuElement), "Bad argument @ setNativeItemText [expected native-menu at argument 1]")
    assert(getElementType(menuElement) == "native-menu", "Bad argument @ setNativeItemText [expected native-menu at argument 1]")
    assert(isElement(itemElement), "Bad argument @ setNativeItemText [expected native-item at argument 2]")

    local menu = menus[menuElement]
    if not menu then return false end
    for i, v in ipairs(menu.items) do
        if v.element == itemElement then
            v.text = tostring(text or "")
            return true
        end
    end
    return false
end

-- Used by the saved-character selector to follow NativeUI keyboard highlight.
function getNativeMenuActiveIndex(menuElement)
    assert(isElement(menuElement), "Bad argument @ getNativeMenuActiveIndex [expected native-menu at argument 1]")
    assert(getElementType(menuElement) == "native-menu", "Bad argument @ getNativeMenuActiveIndex [expected native-menu at argument 1]")
    local menu = menus[menuElement]
    if not menu then return 0 end
    return tonumber(menu.activeItem) or 0
end
