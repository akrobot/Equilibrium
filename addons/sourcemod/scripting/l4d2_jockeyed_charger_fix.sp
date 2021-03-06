/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <sourcemod>
#include <dhooks>

#define CLEAP_ONTOUCH_OFFSET    215

new Handle:hCLeap_OnTouch;

public Plugin:myinfo =
{
	name = "L4D2 Jockeyed Charger Fix",
	author = "Visor",
	description = "Prevent jockeys and chargers from capping the same target simultaneously",
	version = "1.3",
	url = "https://github.com/Attano/smplugins"
}

public OnPluginStart()
{
	hCLeap_OnTouch = DHookCreate(CLEAP_ONTOUCH_OFFSET, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CLeap_OnTouch);
	DHookAddParam(hCLeap_OnTouch, HookParamType_CBaseEntity);
	DHookAddEntityListener(ListenType_Created, OnEntityCreated);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "ability_leap"))
	{
		DHookEntity(hCLeap_OnTouch, false, entity); 
	}
}

public MRESReturn:CLeap_OnTouch(ability, Handle:hParams)
{
	new jockey = GetEntPropEnt(ability, Prop_Send, "m_owner");
	new survivor = DHookGetParam(hParams, 1);
	if (IsValidJockey(jockey)/* probably redundant */ && IsSurvivor(survivor))
	{
		if (IsValidCharger(GetCarrier(survivor)) || IsValidCharger(GetPummelQueueAttacker(survivor)) || IsValidCharger(GetPummelAttacker(survivor)))
		{
			return MRES_Supercede;
		}
	}
	return MRES_Ignored;
}

bool:IsSurvivor(client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

bool:IsValidJockey(client)
{
	return (client > 0 
		&& client <= MaxClients 
		&& IsClientInGame(client) 
		&& GetClientTeam(client) == 3 
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == 5);
}

bool:IsValidCharger(client)
{
	return (client > 0 
		&& client <= MaxClients 
		&& IsClientInGame(client) 
		&& GetClientTeam(client) == 3 
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == 6);
}

GetCarrier(survivor)
{
	return GetEntDataEnt2(survivor, 10860);
}

GetPummelQueueAttacker(survivor)
{
	return GetEntDataEnt2(survivor, 15988);
}

GetPummelAttacker(survivor)
{
	return GetEntDataEnt2(survivor, 15976);
}