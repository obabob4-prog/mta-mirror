--== Script feito por:
--== ● Caio ●
--== Discord: Caio#8888
--===================================================
--== Qualquer problema procure pelo meu discord.
--===================================================

addEvent('alarmSound', true)
addEventHandler('alarmSound', root, function (x, y, z)
    local alarm = playSound3D('alarm.mp3', x, y, z)
    setSoundVolume(alarm, 0.5)
    setSoundMaxDistance(alarm, 30)
end)