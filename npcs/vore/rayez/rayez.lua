require "/scripts/vore/npcvore.lua"

effect 		= "npchealvore"
playerLines = {}

--Player is idle in the belly after forcibly ate
playerLines["forceidle"] = {
	"Hey take it easy, I really dont want to hurt you.",
	"I just need to heal you for a bit and ill let you out. I promise!",
	"Relax... I just want to help.",
	"No need to panic you'll be fine.",
	"Please... Calm down, You're not going to die in there.",
	"I cant stand seeing folk as injured as you.",
	"No need to worry Its perfectly safe in there.",
	"Stop squirming! It's making me naucious!",
	"Hold still, The sooner your healed, The sooner youll be out.",
}

--Player is idle in the belly after requesting to be eaten
playerLines["requestidle"] = {
	"Comfortable enough for you?",
	"Feeling better yet?",
	"If you start to feel drowsy, Just let me know. Its a side effect of the healing.",
	"Enjoying yourself? I know I am!",
	"Feel free to take a nap in there.",
	"Stay as long as you want, Its not like Im going anywhere.",
	"Want me to swallow a pillow and blanket for you?",
	"I consider this a win-win situation, You get a nice place to rest and I get a tasty snack."
	
}

--Player forcibly to be eaten
playerLines["forceeat"] = {
		"Ahaha! Gotcha!",
		"Look I dont want to hurt you, Quite the opposite actually!",
		"This wont hurt a bit! You have nothing to worry about.",
		"Relax, you'll be fine!",
		"Ahhh... That hits the spot.",
		"I promise I wont hurt you ok?",
		"No need to worry. You're safe with me."
}

--Player requests to be eaten
playerLines["requesteat"] = {
	"Oh of course!",
	"Thanks for the donation friend.",
	"Ahhh... Enjoy your stay.",
	"Yeah sure come on in!"
}

--Player is forcibly ate and released after timeout
playerLines["exit"] = {
	"I think you've had enough.",
	"You might want to take a nap after that.",
	"At least you were more cooperative than most.",
	"Hey, You okay? Sorry about that."
}

--Player is forcibly ate and released after request
playerLines["escape"] = {
	"Okay okay, Jeez...",
	"Look I get it you have things you need to do.",
	"Yeah... Sorry about that.",
	"Hey, You okay? Sorry about that.",
	"You know anyone who actually enjoys this kind of stuff?",
	"HEY! GET BACK HERE!"
}

--Player requested to be ate and requested release
playerLines["release"] = {
	"We should definately do this more often.",
	"See you around friend!",
	"Thanks for that. I really needed it.",
	"Lets keep this a secret between you and I Ok?",
	"I could really get used to this."
}

function initHook()

	if storage.ci == nil then
		ci = npc.getItemSlot("legs").parameters.colorIndex
		storage.ci = ci
	else
		ci = storage.ci
	end
	
	if storage.de == nil then
		de = npc.getItemSlot("chest").parameters.colorIndex
		storage.de = de
	else
		de = storage.de
	end
	
	chest[2] = {
		name = "Rayezbelly",
		parameters = {
					colorIndex = de
	}}
	

end

--For some reason, I cannot get the "exit" lines to play, it always defaults to "release". If it can be fixed, let me know.
function digestHook(id, time, dead)
	sayLine( playerLines["exit"] )
end

function releaseHook(input, time)
	if request[1] then
		sayLine( playerLines["release"] )
	else
		sayLine( playerLines["escape"] )
	end
end

function feedHook()
	sayLine( playerLines["forceeat"] )
	world.spawnProjectile( "npcanimchomp" , world.entityPosition( tempTarget ), entity.id(), {0, 0}, false)
	world.spawnProjectile( "swallowprojectile" , world.entityPosition( tempTarget ), entity.id(), {0, 0}, false)

end

function requestHook(args)
	sayLine( playerLines["requesteat"] )
	world.spawnProjectile( "npcanimchomp" , world.entityPosition( victim[#victim] ), entity.id(), {0, 0}, false)
	world.spawnProjectile( "swallowprojectile" , world.entityPosition( victim[#victim] ), entity.id(), {0, 0}, false)
end

function updateHook(input)
	if containsPlayer() and math.random(700) == 1 then
		if request[1] then
			sayLine( playerLines["requestidle"] )
		else
			sayLine( playerLines["forceidle"] )
		end
	end
end