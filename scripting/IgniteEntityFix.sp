/**
* IgniteEntity Sound Fix by Root
*
* Description:
*   Fixes looping fire sound even if ignited entity is dead or invalid.
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

#include <sdktools>

// ====[ CONSTANTS ]========================================================
#define PLUGIN_NAME     "IgniteEntity Sound Fix"
#define PLUGIN_VERSION  "1.0"

#define FIRE_LOOP_SOUND "ambient/fire/fire_small_loop2.wav"

// ====[ PLUGIN ]===========================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Fixes looping fire sound even if ignited entity is dead or invalid",
	version     = PLUGIN_VERSION,
	url         = "http://dodsplugins.com/"
}


/* OnPluginStart()
 *
 * When the plugin starts up.
 * ------------------------------------------------------------------------- */
public OnPluginStart()
{
	// Create version CVar to track servers which is running this plugin
	CreateConVar("sm_iesoundfix_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// Hook fire sound
	AddNormalSoundHook(NormalSHook:FireLoopSound);
}

/* NormalSHook:FireLoopSound()
 *
 * Called when a sound is going to be emitted to one or more clients.
 * ------------------------------------------------------------------------- */
public Action:FireLoopSound(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH],
							&entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	// Whether or not fire sound was emitted
	if (StrEqual(sample, FIRE_LOOP_SOUND, false))
	{
		// Loop through all players on a server
		for (new client = 1; client <= MaxClients; client++)
		{
			// Check for valid players, which is also NOT ignited at the moment
			if (IsClientInGame(client) && IsPlayerAlive(client) &&
			GetEntPropEnt(client, Prop_Send, "m_hEffectEntity") < 1)
			{
				// For each other create timer and check whether or not its about to burn
				CreateTimer(0.1, Timer_EmitFireSound, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}

		// Dont emit normal fire sound
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

/* Timer_EmitFireSound()
 *
 * Checks whether or not client is ignited.
 * ------------------------------------------------------------------------- */
public Action:Timer_EmitFireSound(Handle:timer, any:client)
{
	// To check whether or not client is ignited, check its m_hEffectEntity netprop value
	// If its more than 0 (it also may be -1) - then client is burning
	if (IsClientInGame(client) && IsPlayerAlive(client) &&
	GetEntPropEnt(client, Prop_Send, "m_hEffectEntity") > 0)
	{
		// Return the client's origin vector
		decl Float:origin[3];
		GetClientAbsOrigin(client, origin);

		// Emit ambient(!) sound from this player
		EmitAmbientSound(FIRE_LOOP_SOUND, origin, client);
	}
}