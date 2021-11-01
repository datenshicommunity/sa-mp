
/*
 ██████╗░░█████╗░████████╗███████╗███╗░░██╗░██████╗██╗░░██╗██╗░░░░░░░██████╗░█████╗░███╗░░░███╗██████╗░
 ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝████╗░██║██╔════╝██║░░██║██║░░░░░░██╔════╝██╔══██╗████╗░████║██╔══██╗
 ██║░░██║███████║░░░██║░░░█████╗░░██╔██╗██║╚█████╗░███████║██║█████╗╚█████╗░███████║██╔████╔██║██████╔╝
 ██║░░██║██╔══██║░░░██║░░░██╔══╝░░██║╚████║░╚═══██╗██╔══██║██║╚════╝░╚═══██╗██╔══██║██║╚██╔╝██║██╔═══╝░
 ██████╔╝██║░░██║░░░██║░░░███████╗██║░╚███║██████╔╝██║░░██║██║░░░░░░██████╔╝██║░░██║██║░╚═╝░██║██║░░░░░
 ╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚══╝╚═════╝░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░░░
*/
/*
	Owner & Founder : Tr0ke
	Base script by: Gobay
	Copyright 2021
*/
#include <a_samp>
#include <core>
#include <float>
#include <zcmd>
#include <streamer>
#include <zcmd>
#include <requests>
#include <string>

//definition file
#include "../scriptfiles/def.pwn"

//enum file
#include "../scriptfiles/enum.pwn"

#include "../scriptfiles/auth_process.pwn"
#include "../scriptfiles/cmd/playercmd/generalcmd.pwn"

#pragma tabsize 0

//request api function
new RequestsClient:client;

main()
{
	print("\n----------------------------------");
	print("  Bare Script\n");
	print("----------------------------------\n");

	client = RequestsClient("http://localhost:1010/api/");
}

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~SA-MP: ~r~Bare Script",5000,5);
	static const empty_player[E_PLAYERS];
	Player[playerid] = empty_player;
	
	GetPlayerName(playerid, Player[playerid][Username], MAX_PLAYER_NAME);
	
	Player[playerid][X_Pos] = DEFAULT_X_POS;
	Player[playerid][Y_Pos] = DEFAULT_Y_POS;
	Player[playerid][Z_Pos] = DEFAULT_Z_POS;
	Player[playerid][A_Pos] = DEFAULT_A_POS;
	Player[playerid][Interior] = 0;
	Player[playerid][Money] = INITIAL_MONEY;

	//Load player data
	new const getPlayerIdx[50] = "auth/%d/%s";
	new formatMsg[23];
	format(formatMsg, sizeof(formatMsg), getPlayerIdx, playerid, Player[playerid][Username]);
	RequestJSON(
        client,
        formatMsg,
        HTTP_METHOD_GET,
        "OnLoadPlayerData",
        .headers = RequestHeaders()
    );
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid,Player[playerid][Interior]);
	TogglePlayerClock(playerid,0);
	SetPlayerPos(playerid,Player[playerid][X_Pos],Player[playerid][Y_Pos],Player[playerid][Z_Pos]);
	SetPlayerFacingAngle(playerid, Player[playerid][A_Pos]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
   	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	TogglePlayerSpectating(playerid, true);
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("Bare");
	ShowPlayerMarkers(1);
	ShowNameTags(1);
	//AllowAdminTeleport(1);

	AddPlayerClass(265,1958.3783,1343.1572,15.3746,270.1425,0,0,0,0,-1,-1);

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid){
		case DIALOG_UNUSED: return 1;

		case DIALOG_LOGIN:{
			loginDialog(playerid, response, inputtext, _:client);
		}

		case DIALOG_REGISTER:{
			registerDialog(playerid, response, inputtext, _:client);
		}
	}
    return 0;
}

public OnPlayerDisconnect(playerid, reason){
	new szString[64];
	new interior,
		money;
	
	GetPlayerPos(playerid, Player[playerid][X_Pos],Player[playerid][Y_Pos],Player[playerid][Z_Pos]);
	GetPlayerFacingAngle(playerid, Player[playerid][A_Pos]);
	money = GetPlayerMoney(playerid);
	interior = GetPlayerInterior(playerid);

	Player[playerid][Money] = money;
	Player[playerid][Interior] = interior;
	Player[playerid][Online] = false;

	_ProsesUpdatePlayerData(_:client, playerid);
    new szDisconnectReason[3][] =
    {
        "Timeout/Crash",
        "Quit",
        "Kick/Ban"
    };
	format(szString, sizeof szString, "%s left the server (%s).", Player[playerid][Username], szDisconnectReason[reason]);
    SendClientMessageToAll(0xC4C4C4FF, szString);
}

forward _SpawnPlayer(playerid);
public _SpawnPlayer(playerid){
	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);
}

forward _KickPlayerDelayed(playerid);
public _KickPlayerDelayed(playerid)
{
	Kick(playerid);
	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}