//! Gives the MULEbot an access that nothing else does.

#define ACCESS_MULEBOT 290

/mob/living/simple_animal/bot/mulebot/Initialize()
	. = ..()
	access_card.access += ACCESS_MULEBOT
