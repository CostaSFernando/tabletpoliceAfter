-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("policetablet",cRP)
vSERVER = Tunnel.getInterface("policetablet")
vSKINSHOP = Tunnel.getInterface("vrp_skinshop")


local isOpen = false
local oldcustom = {}

RegisterCommand("tabletpolice",function(source,args)
	if vSERVER.checkPermission() then
		isOpen = not isOpen
		if isOpen then
			SetNuiFocus(true,true)
		else
			SetNuiFocus(false)
		end
		SendNUIMessage({ showNui = isOpen })
	end
end)

--login
RegisterNUICallback("login",function(data, cb)
	if vSERVER.checkPermission() then
		return cb(json.encode({vSERVER.login(data.pass)}))
	end
end)

-- dados usuario logado
RegisterNUICallback("findplayer",function(data, cb)
	if vSERVER.checkPermission() then
		local infosCurrentUser = vSERVER.getInfos(data.pass);
		cb(infosCurrentUser)
	end
	return;
end)

RegisterNUICallback("prisonPlayer",function(data)
	if vSERVER.checkPermission() then
		vSERVER.prisonUser(data.prisonPlayerPass, data.services, data.fine, date.reason)
	end
end)

RegisterNUICallback("finePlayer",function(data)
	if vSERVER.checkPermission() then
		return vSERVER.fineUser(data.playerPass, data.fine, data.reason)
	end
end)

RegisterNUICallback("getPenalCode",function(data, cb)
	if vSERVER.checkPermission() then
		return cb(vSERVER.getPenalCode())
	end
end)

RegisterNUICallback("currentUser",function(data, cb)
	if vSERVER.checkPermission() then
		local infosCurrentUser = vSERVER.getInfosPolice(data.pass);
		return cb(infosCurrentUser)
	end
end)
