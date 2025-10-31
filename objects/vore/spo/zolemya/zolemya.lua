-- An all-in-one lua! OV, digest, CV, digestcv, disposal, disposalcv, idle anims and commentary! UB can easily be included as well!
-- Trimmed down from the template, so this one is missing compatability with unused types.

function init(virtural)
-- Imports type of predator from the object file.
  config_vore = config.getParameter( "vore", config_vore );
  fatal = config_vore["fatal"];
  dirty = config_vore["dirty"];
  spo_type = config_vore["type"];
-- Animation related
  animLock = false
  soundLock = false
  releaseLock = false
  idleTimer = 0
  eatingTimer = 0
  releaseTimer = 0
-- Health related
  preyMaxHealth = 0
  preyCurrentHealth = 0
  preyPercentHealth = 0
  digestState = 0
  animPlaying = false
  soundPlaying = false
end

local function play_sound( sfx, loops )
	loops = loops or 0;
	animator.playSound( sfx..spo_type, loops );
end

local function stop_sounds()
	animator.stopAllSounds( "fullov" );
	animator.stopAllSounds( "fullcv" );
end

local function digest_end()
	stop_sounds()
	play_sound( "fulloutro" );
	play_sound( "digest" );	  
	digestState = digestState + 1
end

local function set_anim( anim )
	if spo_type == "ov" then
	  animator.setAnimationState( "bodyState", anim );
	else
	  animator.setAnimationState( "bodyState", anim.."_"..spo_type );
	end
end

function update(dt)
  -- Uses the previously made detection area to say the IdleFull or IdleEmpty lines when a player is closeby.
  local players = world.entityQuery( object.position(), 7, {
      includedTypes = {"player"},
      boundMode = "CollisionArea"
    })
  -- Animations that happens while the predator is empty (hungry).
  if world.loungeableOccupied(entity.id()) == false then
	
	--Lock animation to keep the waste while player is still inside.	
	if digestState == 2 then -- Make sure to change this if you remove states from below.
	  set_anim( "idle" )
	  eatingTimer = 0
	  animLock = true
	end
	
	-- Resets the digestState checker.
	digestState = 0
	  
	-- Resets the predator to the idle state
    if animLock == false then
	  animator.setAnimationState("bodyState", "idle")
	  idleTimer = 0
      releaseLock = false
      releaseTimer = 0
	  -- If player leaves after being eaten, it plays the release animation.
	  if eatingTimer >= 16 then -- Adjust eating timer based on swallow anim duration.
		animLock = true
		eatingTimer = 0
		releaseLock = true
		stop_sounds()
		soundPlaying = false
		set_anim( "release" )
		play_sound( "fulloutro" );
		animator.playSound( "slip" );
	  end
	end
	
	if idleTimer >= 30 or releaseTimer >= 16 then
	  animLock = false
	end
	  
	-- Counts time being idle and empty.
	idleTimer = idleTimer + 1
	  
	if releaseLock == true then
	  releaseTimer = releaseTimer + 1
	end
  elseif world.loungeableOccupied(entity.id()) == true and eatingTimer <= 16 then -- Adjust eating timer based on swallow anim duration.
  
    -- Swallow animation and sounds.
	
	if soundLock == false then
	  animator.playSound("swallow") -- I recommend using a diff swallow sound effect per SPO. Bigger ones should have a hefty swallow.
	  
	  if spo_type == "cv" then
		play_sound( "fullintro" ); -- Plays into sound for only CV since I think OV works better without.
	  end
	  
      soundLock = true
	end
	  
	set_anim( "swallow" )
	eatingTimer = eatingTimer + 0.4
	  
  else
    
	-- Math to find player percent health
	preyCurrentHealth = world.entityHealth(prey)[1] * 100
	preyMaxHealth = world.entityHealth(prey)[2]
	preyPercentHealth = math.floor(preyCurrentHealth / preyMaxHealth)
	
	-- Animations that happens while the predator is full (digesting).
	
	soundLock = false
	
	if soundPlaying == false then
		play_sound( "full", -1 );
		soundPlaying = true
	end
	
	-- Changes player state based on their current percent health

	if fatal == true then
	  if preyPercentHealth <= 100 and digestState == 0 then
		set_anim( "full" )
		digestState = digestState + 1
	  elseif preyPercentHealth <= 10 and digestState == 1 then
		set_anim( "digest" )
		digest_end()
	  end
	else
		set_anim( "full" )
	end
  end
end
  
function onInteraction(args)

  if not prey then
    prey = nil
  end

  -- Makes sure only the pred only checks the health of the prey inside.
  if world.loungeableOccupied(entity.id()) == false then
    prey = args.sourceId
  end
end