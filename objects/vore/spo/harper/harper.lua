local anim_state = "ov";
local anim = "";
local fatal = false;
local victim = nil;
local health = 1.0;
local state = 0;
--[[
-- 0: idle
-- 1: swallow
-- 2: full
-- 3: digest
--]]

local function play_anim( anim )
	animator.setAnimationState( "bodyState", anim_state.."_"..anim );
end

local function play_sound( sfx, loops )
	loops = loops or 0;
	animator.playSound( sfx..anim_state, loops );
end

local function anim_is( anim )
	anim = anim_state.."_"..anim;
	
	return anim == animator.animationState( "bodyState" );
end

local function update_empty( dt )
	animator.stopAllSounds( "fullov" );
	animator.stopAllSounds( "fullcv" );
	if state == 2 then
		play_sound( "fulloutro" );
		animator.playSound( "slip" );
	end
	state = 0;
	play_anim( "idle" );
end

local function update_full( dt )
	-- anim swap
	if state == 0 then -- idle to swallow
		state = 1;
		play_anim( "swallow" );

		animator.playSound( "swallow" );
		play_sound( "fullintro" );
	elseif state == 1 and anim_is( "full" ) then -- swallow to full
		state = 2;

		play_sound( "full", -1 );
	elseif fatal == false then
		-- nothing
	elseif state == 2 and health < 0.2 then -- full to digest
		state = 3;
		play_anim( "digest" );

		animator.stopAllSounds( "fullov" );
		animator.stopAllSounds( "fullcv" );
		play_sound( "fulloutro" );
		play_sound( "digest" );
		if anim_state == "ov" then
			animator.playSound( "burp" );
		end
	end

	-- anim loop
	if state == 0 then -- idle
	elseif state == 1 then -- swallow
	elseif state == 2 and fatal == false then -- full endo
	elseif state == 2 then -- full fatal
		local h = world.entityHealth( victim );
		health = h[1] / h[2];
	elseif state == 3 then -- digest
	end
end

function init( )
	local config_vore = {
		["fatal"] = false,
		["type"] = "ov"
	};
	config_vore = config.getParameter( "vore", config_vore );

	fatal = config_vore["fatal"];
	anim_state = config_vore["type"];
end

function update( dt )
	if world.loungeableOccupied( entity.id( ) ) then
		if victim ~= nil then
			update_full( dt );
			return;
		end
	end

	update_empty( dt );
end

function onInteraction( args )
	if not world.loungeableOccupied( entity.id( ) ) then
		victim = args.sourceId;
	end
end
