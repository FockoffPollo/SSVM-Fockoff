require "/scripts/vore/npcprey.lua"

function init()

	oldInit()
	
	if storage.names == nil then
		storage.names = {}
		storage.freq = {}
	end
	
	myProfile				= {}					
	myProfile["bribe"]		= {}
	myProfile["consumed"]	= {}
	myProfile["death"] 		= {}
	myProfile["idle"] 		= {}
	myProfile["interact"]	= {}
	myProfile["release"]	= {}
	
	myProfile["bribe"][1]		= {	"Is this your way of enforcing rent? Fine.",
									"Your scare tactics are futile... Oh shit your serious! Ok I'll pay sheesh..."
	}
	myProfile["consumed"][1]	= {	"Hey! What was that for!",
									"Who the hell just eats their tennatns!",
									"Are you serious!? Oh come on!" ,
									"What the hell is this!"
	}
	myProfile["death"][1] 		= {	"..."
	}
	myProfile["idle"][1] 		= {	"Spit me you you ^red;*REDACTED*^reset;",
									"Screw you, you gluttenous freak!",
									"Ugh! It's absolutely disgusting in here!",
									"Only Rayez is allowed to eat me and get away with it!",
									"Is this some kind of twisted prank?",
									"The only thing that could make this worse is more acid. Dont get any Ideas!",
									"Let me out or I'll determine your bodies resonant freaquency and play a jaunty horn solo that boils your miserable organs inside out!"
	}
	myProfile["interact"][1]	= {	"Oh... Its you...",
									"You better not do what I think your about to do.",
									"What are you looking at me like that for?",
									"Dont even think about it."
	}
	myProfile["release"][1] 	= {	"Oh finally!",
									"Could be worse.",
									"How long was I in there for jeez.",
									"Had you fun?"
	}	
	myProfile["bribe"][2]		= {	"Yeah yeah I get the drill... You want me to pay rent."
	}
	myProfile["consumed"][2]	= {	"Ah shit, Here we go again.",
									"Oh give me a break.",
									"Not again! Dammit!",
									"Is this your way of saying hi or somthing?",
									"I'm not even suprised at this point.",
									"Ugh. Really."
	}
	myProfile["death"][2] 		= {	"..."
	}
	myProfile["idle"][2] 		= {	"Welp time to get comfy.",
									"How long am I going to be in here this time?",
									"You... Uh... Really like having me in here don't you.",
									"Did Rayez eat you again? Is this your attempt at revenge?",
									"You just couldn't leave me well enough alone. Could you?"
	}
	myProfile["interact"][2]	= {	"Not you again!",
									"So one time I encountered this really hungry looking. Wait a minute.",
									"Have you learnt you lesson yet?",
									"Could you not do that *Thing* again?"
	}
	myProfile["release"][2] 	= {	"You know what? That wasn't so bad.",
									"Your intent was not to digest me? Odd.",
									"I'm gonna be honest with you here. I'm pretty used to this kind of stuff.",
									"Your gut was surprisingly comfy. God Dammit why did I say that!?"
	}
	
	myProfile["bribe"][3]		= {	"... can I pay you so I can stay in here longer?",
	}
	myProfile["consumed"][3]	= {	"Perfect! An excuse to sleep on the job!",
									"Well... Time to get comfortable.",
									"Finally! I haven't slept in 4 days.",
									"I guess you really like me?"
	}
	myProfile["death"][3] 		= {	"..."
	}
	myProfile["idle"][3] 		= {	"Your gut reminds me of a good friend of mine. Have you met him by any chance?",
									"Zzzzz... Augh! What did I miss?",
									"You wouldn't happen to have a watch? What's the time?",
									"Your probably wondering how I can stay in here for so long without getting gurgled. Nanomachines son...",
									"Good night.",
									"Its what's on the inside that counts. Hehe.",
									"I guess your my personal *Bodyguard* now!"
	}
	myProfile["interact"][3]	= {	"Look who it is. My second favourite living sleeping bag.",
									"Have you met Rayez? You know the big friendly dragon?",
									"Would you like to spend the night with Rayez and I?",
									"I'm feeling pretty tired. You know what to do...",
							        "I got a great idea to jump those nasty cultists, And it involves your gut."
	}
	myProfile["release"][3] 	= {	"See you again, Sometime soon.",
									"Did I miss anything while I was in there?",
									"Excuse me while I go clean my attire.",
									"Definitely going to need a shower after that."
	}
	
	initHook()
	
end
