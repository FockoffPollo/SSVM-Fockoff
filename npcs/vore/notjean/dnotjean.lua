require "/scripts/vore/npcvore.lua"

capacity	= 2
isDigest	= true
effect 		= "npcdigestvore"

playerLines = {		""
}

function initHook()

	index = npc.getItemSlot("legs").parameters.colorIndex

	legs[2] = {
		name = "notjeanlegsbelly1",
		parameters = {
					colorIndex = index
	}}
	chest[2] = {
		name = "notjeanchest1",
		parameters = {
					colorIndex = index
	}}
	
	legs[3] = {
		name = "notjeanlegsbelly2",
		parameters = {
					colorIndex = index
	}}
	chest[3] = {
		name = "notjeanchestbelly2",
		parameters = {
					colorIndex = index
	}}

end

function feedHook()
	world.spawnProjectile( "npcanimchomp" , world.entityPosition( tempTarget ), entity.id(), {0, 0}, false)
	world.spawnProjectile( "swallowprojectile" , world.entityPosition( tempTarget ), entity.id(), {0, 0}, false)
end

function requestHook(args)
	world.spawnProjectile( "npcanimchomp" , world.entityPosition( victim[#victim] ), entity.id(), {0, 0}, false)
	world.spawnProjectile( "swallowprojectile" , world.entityPosition( victim[#victim] ), entity.id(), {0, 0}, false)
end

function updateHook()

	if containsPlayer() and math.random(700) == 1 and ( playerTimer < duration or request[1] == true or request[2] == true ) then
		sayline( playerLines )
	end

end

