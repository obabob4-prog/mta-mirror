addEvent('copyKey.salario', true)
addEventHandler('copyKey.salario', root, function (key)
    setClipboard('/ativarkey '..key)
end)