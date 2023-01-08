#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf_custom_attributes>
#include <sdkhooks>
#include <tf2_stocks>
#include <sdktools>

#define PLUGIN_VERSION "1.0.0"
public Plugin myinfo =
{
	name = "[TF2] Custom Weapon Attribute: Headshots Only",
	author = "Kruthal",
	description = "Anything other than headshots makes no damage.",
	version = PLUGIN_VERSION
};


public void OnPluginStart() {
	AddTempEntHook("World Decal", TE_OnWorldDecal);
	AddTempEntHook("Entity Decal", TE_OnWorldDecal);
}

public void OnConfigsExecuted() {
    for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i)) {
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action TE_OnWorldDecal(const char[] te_name, const int[] Players, int numClients, float delay)
{
	float vecOrigin[3];
	int nIndex = TE_ReadNum("m_nIndex");
	char sDecalName[64];

	TE_ReadVector("m_vecOrigin", vecOrigin);
	GetDecalName(nIndex, sDecalName, sizeof(sDecalName));

	int weapon = GetEntPropEnt(Players[0], Prop_Send, "m_hActiveWeapon");
	if(TF2CustAttr_GetInt(weapon, "only headshots")) {
		if(StrContains(sDecalName, "decals/blood") == 0 && StrContains(sDecalName, "_subrect") != -1)
			return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	bool bHeadshot = damagecustom == TF_CUSTOM_HEADSHOT;

	if (TF2CustAttr_GetInt(weapon, "only headshots") && !bHeadshot) {

		// Blood on player clothes is client-side issue and can be fixed by typing 'violence_hblood 0' in console
		// There is no known method to fix this.

		damage = 0.0;
		return Plugin_Changed;
    }
 
	return Plugin_Continue;
}

stock int GetDecalName(int index, char[] sDecalName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("decalprecache");
	
	return ReadStringTable(table, index, sDecalName, maxlen);
}