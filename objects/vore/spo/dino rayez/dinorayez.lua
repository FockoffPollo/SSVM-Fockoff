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

local function play_sound( sfx, loops ) -- Loops sounds
	loops = loops or 0;
	animator.playSound( sfx..spo_type, loops );
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
	if digestState == 3 then
	  animator.setAnimationState("bodyState", "disposalidle")
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
		if eatingTimer >= 16 then
		  animLock = true
		  eatingTimer = 0
		  releaseLock = true
		  animator.stopAllSounds( "fullov" );
		  soundPlaying = false
		  animator.setAnimationState("bodyState", "release")
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
  elseif world.loungeableOccupied(entity.id()) == true and eatingTimer <= 16 then
    -- Swallow animation
	if soundLock == false then
	  animator.playSound("swallow")
      soundLock = true
	end
	  
	animator.setAnimationState("bodyState", "swallow")
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
	    animator.setAnimationState("bodyState", "full")
		digestState = digestState + 1
	  elseif preyPercentHealth <= 50 and digestState == 1 then 
		animator.setAnimationState("bodyState", "shrink")			  
		digestState = digestState + 1
	  elseif preyPercentHealth <= 20 and digestState == 2 then
		animator.setAnimationState("bodyState", "disposal")
		animator.stopAllSounds( "fullov" );
		play_sound( "fulloutro" );
		play_sound( "digest" );
		digestState = digestState + 1
	  end
	else
	  animator.setAnimationState("bodyState", "full")
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