

--made by furzy

armas = {
	{"FALL", 2646},
	{"G36", 2644},
	{"GLOCK18", 2726},
	{"GLOCKG25", 1730},
	{"MP5", 1882},
	{"AWP", 1769},
	{"M4A1CCOSD",2727},	
}


weapsIDs = {356, 346, 347, 358, 353}
for i,weapID in pairs(weapsIDs)do
  txd = engineLoadTXD("models/None.txd",weapID)
  engineImportTXD(txd,weapID)
  dff = engineLoadDFF("models/None.dff",weapID)
  engineReplaceModel(dff,weapID)
end

for i,weaponData in pairs(armas) do
  file = weaponData[1]:gsub(' ','')
	if fileExists("models/"..file..".txd") and fileExists("models/"..file..".dff")then
	  txd = engineLoadTXD("models/"..file..".txd",weaponData[2])
	  engineImportTXD(txd,weaponData[2])
	  dff = engineLoadDFF("models/"..file..".dff",weaponData[2])
	  engineReplaceModel(dff,weaponData[2])
	else
	  outputChatBox("ERROR: models/"..file)
	end
end

function playerJoined()
    local Variavel_1 = isWorldSoundEnabled ( 5 )
    setWorldSoundEnabled ( 5, false )
    setWorldSoundEnabled ( 3, false )
    setWorldSoundEnabled ( 42, false )
end
addEvent("playerJoined",true)
addEventHandler("playerJoined",getRootElement(),playerJoined)

function PlaySound(ID)
  wpn1 = getElementData(source,"cweapon")
  x,y,z = getPedWeaponMuzzlePosition(source)
  for _,weap in pairs(armas)do
      soundName = weap[1]:gsub(' ','')
      if wpn1 == weap[1] then
	  if not fileExists("Sounds/Primary/"..soundName..".wav")then return end
	  sound = playSound3D("Sounds/Primary/"..soundName..".wav",x,y,z, false)
	  setSoundMaxDistance(sound,200)
	end
  end
end
addEventHandler("onClientPlayerWeaponFire",root,PlaySound)