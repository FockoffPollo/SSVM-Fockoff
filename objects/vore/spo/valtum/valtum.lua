-- Paer of an all-in-one lua! OV, digest, CV, digestcv, disposal, disposalcv, idle anims and commentary! UB can easily be included as well!
-- Trimmed down from the template, so this one is missing compatability with unused types.

function init(virtural)
-- Makes detection area around the predatores.
  if not virtual then
    self.detectArea = config.getParameter("detectArea")
  end
-- Imports the lines from the predatores object file.
  chatOptions = config.getParameter("chatOptions", {})
  gulpLines = config.getParameter("gulpLines", {})
  rubLines = config.getParameter("rubLines", {})
-- Imports type of predator from the object file.
  config_vore = config.getParameter( "vore", config_vore );
  fatal = config_vore["fatal"];
  dirty = config_vore["dirty"];
  spo_type = config_vore["type"];
-- Chat related
  ohSnap = false
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
  soundPlaying = false
end

local function play_sound( sfx, loops )
	loops = loops or 0;
	animator.playSound( sfx..spo_type, loops );
end

local function digest_end()
	animator.stopAllSounds( "fullov" );
	play_sound( "fulloutro" );
	play_sound( "digest" );	  
	digestState = digestState + 1
end

local function set_anim( anim )
	animator.setAnimationState( "bodyState", anim );
end

function update(dt)
  -- Uses the previously made detection area to say the IdleFull or IdleEmpty lines when a player is closeby.
  local players = world.entityQuery( object.position(), 7, {
      includedTypes = {"player"},
      boundMode = "CollisionArea"
    })
  local chatIdleEmpty = config.getParameter("chatIdleEmpty", {})
  local chatIdleFull = config.getParameter("chatIdleFull", {})
  -- Only displays the lines if more than 0 players are in, and ohSnap is false (to prevent spam).
	if #players > 0 and not ohSnap then
      -- Displays the empty lines if the predator is empty, else full.
	  if world.loungeableOccupied(entity.id()) == false then
        -- But only if it isnt already displaying a line.
	    if #chatIdleEmpty > 0 then
		  object.say(chatIdleEmpty[math.random(1, #chatIdleEmpty)])
		end
	  else
	    if #chatIdleFull > 0 then
		  object.say(chatIdleFull[math.random(1, #chatIdleFull)])
		end
	  end
	  ohSnap = true
    -- Sets ohSnap to false when no players are within the dection area.
	elseif #players == 0 and ohSnap then
	  ohSnap = false
	end
-- Randomly displays the "Player inside Pred" lines
	if world.loungeableOccupied(entity.id()) and math.random(150) == 1 then
	  if #chatOptions > 0 then
        object.say(chatOptions[math.random(1, #chatOptions)])
      end
    end
  -- Animations that happens while the predator is empty (hungry).
  if world.loungeableOccupied(entity.id()) == false then
	
	--Lock animation to keep the waste while player is still inside.	
	if digestState == 3 then -- Make sure to change this if you remove states from below.
	  set_anim( "idle" )
	  soundPlaying = false
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
		animator.stopAllSounds( "fullov" );
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

	if preyPercentHealth <= 100 and digestState == 0 then
	  set_anim( "full" )
	  digestState = digestState + 1
	elseif preyPercentHealth <= 25 and digestState == 1 and dirty == true then -- Uses disposal anim instead of digest anim if disposal object. Adjust health % based on anim length.
	  set_anim( "disposal" )
	  digest_end()
	elseif preyPercentHealth <= 10 and digestState == 1 then
	  set_anim( "digest" )
	  digest_end()
	elseif preyPercentHealth <= 10 and digestState == 2 and dirty == true then
	  set_anim( "erase" )
	  digestState = digestState + 1
	elseif preyPercentHealth <= 7 and digestState == 2 then
	  set_anim( "burp" )
	  animator.playSound( "burp" );
	  digestState = digestState + 1
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
  
  -- Unless the predator is full it will activate this code.
  if world.loungeableOccupied(entity.id()) == false then
-- Swallows the prey, playing the gulp sound and displaying a line. Also sets the player to be "prey".
    if #gulpLines > 0 then
      object.say(gulpLines[math.random(1, #gulpLines)])
	  prey = args.sourceId
    end
-- If the interaction is done by someone NOT flagged as this predators prey then the RubLines are displayed.
  elseif world.loungeableOccupied(entity.id()) and prey ~= args.sourceId then
    if #rubLines > 0 then
      object.say(rubLines[math.random(1, #rubLines)])
	end
  end
end