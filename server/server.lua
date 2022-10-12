local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")


vPRISON = Tunnel.getInterface("vrp_prison")
vPLAYER = Tunnel.getInterface("vrp_player")
vSKINSHOP = Tunnel.getInterface("vrp_skinshop")

cRP = {}
Tunnel.bindInterface("policetablet",cRP)
------------------------------------------------------------------------------------------------------------------------
---------------------------- DBTABLET
------------------------------------------------------------------------------------------------------------------------

-- Buscar dados de um policial
vRP._prepare("vRP/get_police_tablet_user","SELECT police_user.id, police_user.id_usuario as passaporte, police_user.firstname, police_user.lastname, police_patente.nome as nome_patente, police_patente.desc_patente, police_patente.number_patente, police_user.url_photo FROM creative.police_user INNER JOIN police_patente ON police_user.id_patente = police_patente.id where police_user.id_usuario = @id;")

-- Buscar dados de prisão por player
vRP._prepare("vRP/get_prison_player","SELECT * FROM police_prison where passaporte_user_prison = @id")

-- Multar/prender player
vRP._prepare("vRP/prison_or_fine_player","INSERT INTO `creative`.`police_prison` (`id_police`, `nome_user_prison`, `prison`, `passaporte_user_prison`, `motivo`, `servicos`, `multa`, `fine_pay`, `fianca`) VALUES (`@id_police`, `@nome_user_prison`,`@prison`, `@passaporte_user_prison`, `@motivo`, `@servicos`, `@multa`, @multa_paga, `@fianca`);")
-- id_police
-- nome_user_prison
-- prisão?
-- passaporte_user_prison
-- motivo
-- servicos
-- multa
-- multa paga?
-- fianca

-- Listar patentes
vRP._prepare("vRP/get_police_pantente","SELECT * FROM police_patente")

-- Listar código penal
vRP._prepare("vRP/get_police_penal_code","SELECT * FROM police_codigo_penal")


permissionTablet = 'police'
-- Busca policial cadastrado no tablet
function cRP.getInfosPolice()
	local data = vRP.query("vRP/get_police_tablet_user",{ id = parseInt(source) })

	if data then
		return data
	end
	-- return { passaporte = data.id_usuario, name = data.firstname .. " " .. data.lastname, patente = data.nome_patente, unidade = "Policia", rg = " <PRIVATE> ", tel = " <PRIVATE> "}
end

-- Busca informações de um player
function cRP.getInfos(data)
    if data then
        local identity = vRP.userIdentity(data)
        local fines = 0
        local consult = cRP.getFines(data)

		for k,v in pairs(consult) do
			fines = parseInt(fines) + parseInt(v.price)
		end
		return {passaporte = parseInt(data),firstname = identity.name,secondname = identity.name2,banco = parseInt(identity.bank),telefone = identity.phone,rg = identity.serial,multa = parseInt(fines), porte = identity.port}
    end
end

-- Busca informações de multa de um player
function cRP.getFines(user)
	local source = source
	if user then
		local data = vRP.query("vRP/get_prison_player",{ id = parseInt(user) })

		local fine = {}
		if data then
			for k,v in pairs(data) do
				local identity = vRP.userIdentity(v.id)
				if identity then
					table.insert(fine,{ officer = tostring(identity.name.." "..identity.name2), multa = parseInt(v.multa) })
				end
			end
			return fine
		end
	end
end

-- Checa a permissão de um policial
function cRP.checkPermission()
    local user_id = parseInt(source)
    if vRP.hasPermission(user_id, 'police') then
		return true
	end

	return false
end

-- Login User
function cRP.login(id)
	return parseInt(id) == parseInt(source)
end

function cRP.fineUser(playerPass, fine, reason)
	local source = source
	local user_id = source

	local identityPlayerFine = vRP.userIdentity(playerPass)

	if user then

		vRP.query("vRP/prison_or_fine_player",{ 
			id_police = parseInt(source),
			nome_user_prison = identityPlayerFine.name,
			prisao = 0,
			passaporte_user_prison = parseInt(playerPass),
			motivo = reason,
			servicos = 0,
			multa = parseInt(fine),
			multa_paga = 0,
			fianca = 0
		})

		vRP.setFines(parseInt(playerPass),parseInt(fine),parseInt(user_id),tostring(reason))
		return true
	end
	return false
end

-- Prende um player
function cRP.prisonUser(user,services,fine,reason)
	local source = source
    local user_id = source
	-- Player to prison
	if user then
		local nplayer = vRP.getUserSource(parseInt(user))
		if nplayer then
			if vPLAYER.getHandcuff(nplayer) then
				vPLAYER.toggleHandcuff(nplayer)
				vRPC.stopAnim(source,false)
			end
		end
		--todo: start prison
		--todo: teleporte player to prison
		
		--todo: colocar multa

		vRP.setFines(parseInt(user),parseInt(fine),parseInt(user_id),tostring(reason))

		local nidentity = vRP.getUserIdentity(parseInt(user_id))
        local identity = vRP.getUserIdentity(parseInt(user))

		vRP.query("vRP/prison_or_fine_player",{ 
			id_police = parseInt(source),
			nome_user_prison = identity.name.." "..identity.name2,
			prisao = 1,
			passaporte_user_prison = parseInt(user),
			motivo = reason,
			servicos = services,
			multa = parseInt(fine),
			multa_paga = 0,
			fianca = 0
		})
		
        if identity then
            TriggerClientEvent("Notify",source,"sucesso","<b>"..identity.name.." "..identity.name2.."</b> enviado para a prisão <b>"..parseInt(services).." serviços</b>.",5000)
			TriggerEvent("webhooks","prender","```ini\n[OFICIAL]: "..user_id.." "..nidentity.name.." "..nidentity.name2.."\n[PRENDEU]: "..parseInt(user).." "..identity.name.." "..identity.name2.."\n[MOTIVO]: "..tostring(text).."\n[MULTA]: "..parseInt(price).."\n[SERVIÇOS]: "..parseInt(services).." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```","Prender")
        end

	end
end

-- Buscar código penal
function cRP.getPenalCode()
	local data = vRP.query("vRP/get_police_penal_code",{ id = parseInt(user) })
	return data
end
