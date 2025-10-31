-- Part of an all-in-one lua! OV, digest, CV, digestcv, disposal, disposalcv, idle anims and commentary! UB can easily be included as well!
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
-- Chat related
  ohSnap = false
-- Animation related
  animLock = false
  soundLock = false
  releaseLock = false
  idleTimer = 0
  eatingTimer = 0
  releaseTimer = 0
  animTimer = 0
  animPlaying = false
  soundPlaying = false
end

local function play_sound( sfx, loops )
	loops = loops or 0;
	animator.playSound( sfx, loops );
end

local function stop_sounds()
	animator.stopAllSounds( "fullov" );
	soundPlaying = false
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

	-- Resets the predator to the idle state
    if animLock == false then
	  animator.setAnimationState("bodyState", "idle")
	  idleTimer = 0
      releaseLock = false
      releaseTimer = 0
	  -- If player leaves after being eaten, it plays the release animation.
	  if eatingTimer >= 15 then -- Adjust eating timer based on swallow anim duration.
		animLock = true
		eatingTimer = 0
		releaseLock = true
		stop_sounds()
		set_anim( "release" )
		play_sound( "fulloutroov" );
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
  elseif world.loungeableOccupied(entity.id()) == true and eatingTimer <= 15 then -- Adjust eating timer based on swallow anim duration.
  
    -- Swallow animation and sounds.
	
	if soundLock == false then
	  animator.playSound("swallow") -- I recommend using a diff swallow sound effect per SPO. Bigger ones should have a hefty swallow.
	  
      soundLock = true
	end
	  
	set_anim( "swallow" )
	eatingTimer = eatingTimer + 0.4
	  
  else
    
	-- Animations that happens while the predator is full.
	
	soundLock = false
	
	if soundPlaying == false then
		play_sound( "fullov", -1 );
		soundPlaying = true
	end
	
	if animPlaying == true then
	  animTimer = animTimer + 1
	end
	if animTimer >= 16 then
	  animPlaying = false
	end
	
	-- Changes player state based on their current percent health

	if animPlaying == false then 
	  if math.random(200) == 1 then  -- Random in belly anim
		animator.setAnimationState("bodyState", "safeburp")
		animator.playSound("burp")
		animTimer = 0
	    animPlaying = true
	  else
		set_anim( "full" )
	  end
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