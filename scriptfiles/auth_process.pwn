loginDialog(playerid, response, const inputtext[], client)
{
    if(!response)
        {
            SendClientMessage(playerid, COLOR_RED, "And telah dikeluarkan dari server.");
            DelayedKick(playerid); 
        }
        else
        {
            new hashed_pass[65];
			SHA256_PassHash(inputtext, Player[playerid][Salt], hashed_pass, 65);
            if (strcmp(hashed_pass, Player[playerid][Password]) == 0)
			{
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Masuk", "Selamat bermain! baca peraturan main terlebih dahulu ya.", "Okay", "");
                Player[playerid][Online] = true;

                ResetPlayerMoney(playerid);
                GivePlayerMoney(playerid, Player[playerid][Money]);
                _ProsesUpdatePlayerData(client, playerid);
                
                //TODO: nanti disini bakalan ada tampilan untuk milih karakter dulu, nanti karakter id nya di passing pas spawn info
				SetSpawnInfo(playerid, NO_TEAM, 34, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos], 0, 0, 0, 0, 0, 0);
				_SpawnPlayer(playerid);
			}
            else
            {
                SendClientMessage(playerid, COLOR_RED, "Login gagal, pastikan password yang dimasukan benar.");
                showLoginDialog(playerid);
            }
        }
    return 1;
}

registerDialog(playerid, response, const inputtext[], _:client)
{
    if (!response) return Kick(playerid);
    if (strlen(inputtext) < 5) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registrasi", "Password minimal 5 karakter\nMasukan kembali password kamu dibawah sini", "Daftar", "Keluar");
    for (new i = 0; i < 16; i++) Player[playerid][Salt][i] = random(94) + 33;
	SHA256_PassHash(inputtext, Player[playerid][Salt], Player[playerid][Password], 65);
    
    _ProsesUpdatePlayerData(client, playerid);
    showLoginDialog(playerid);

    return 1;
}

_ProsesUpdatePlayerData(_:client, playerid){
    //register process
    new const getPlayerIdx[50] = "auth/%d/%s";
	new formatMsg[23];
	format(formatMsg, sizeof(formatMsg), getPlayerIdx, playerid, Player[playerid][Username]);
    RequestJSON(
        client,
        formatMsg,
        HTTP_METHOD_POST,
        "UpdatePlayerData",
        JsonObject(
            "username", JsonString(Player[playerid][Username]),
            "password", JsonString(Player[playerid][Password]),
            "salt", JsonString(Player[playerid][Salt]),
            "kills", JsonInt(Player[playerid][Kills]),
            "deaths", JsonInt(Player[playerid][Deaths]),
            "x_pos", JsonFloat(Player[playerid][X_Pos]),
            "y_pos", JsonFloat(Player[playerid][Y_Pos]),
            "z_pos", JsonFloat(Player[playerid][Z_Pos]),
            "a_pos", JsonFloat(Player[playerid][A_Pos]),
            "interior", JsonInt(Player[playerid][Interior]),
            "online", JsonInt(Player[playerid][Online]),
            "money", JsonInt(Player[playerid][Money])
        ),
        .headers = RequestHeaders()
    );
}

stock showLoginDialog(playerid){
    new string[125];
    format(string, sizeof string, "Selamat datang kembali %s", Player[playerid][Username]);
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Masuk ke akun", string, "Masuk", "Keluar");
    return 0;
}

stock showRegisterDialog(playerid){
    new string[125];
    format(string, sizeof string, "Selamat datang %s, kamu bisa registrasi dengan memasukan password di bawah ini:", Player[playerid][Username]);
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registrasi", string, "Daftar", "Keluar");
    return 0;
}

forward UpdatePlayerData(Request:id, E_HTTP_STATUS:status, Node:node);
public UpdatePlayerData(Request:id, E_HTTP_STATUS:status, Node:node) {
    new playerid;
    new bool:data_ok;
    
    new Node:result;

    JsonGetInt(node, "player_id", playerid);
    JsonGetBool(node, "data_ok", data_ok);

    if (data_ok){
        JsonGetObject(node, "data", result);
        
        JsonGetInt(result, "username", Player[playerid][Username]);
        JsonGetInt(result, "password", Player[playerid][Password]);
        JsonGetInt(result, "salt", Player[playerid][Salt]);
        JsonGetInt(result, "kills", Player[playerid][Kills]);
        JsonGetInt(result, "deaths", Player[playerid][Deaths]);
        JsonGetFloat(result, "x_pos", Player[playerid][X_Pos]);
        JsonGetFloat(result, "y_pos", Player[playerid][Y_Pos]);
        JsonGetFloat(result, "z_pos", Player[playerid][Z_Pos]);
        JsonGetFloat(result, "a_pos", Player[playerid][A_Pos]);
        JsonGetInt(result, "interior", Player[playerid][Interior]);
        JsonGetInt(result, "money", Player[playerid][Money]);
        JsonGetInt(result, "online", Player[playerid][Online]);
    }
}

forward OnLoadPlayerData(Request:id, E_HTTP_STATUS:status, Node:node);
public OnLoadPlayerData(Request:id, E_HTTP_STATUS:status, Node:node) {
    new playerid;
    new bool:data_ok;
    new Node:result;
    
    new password[65];

    JsonGetInt(node, "player_id", playerid);
    JsonGetBool(node, "data_ok", data_ok);

    if (data_ok){
        JsonGetObject(node, "data", result);
        
        JsonGetString(result, "username", Player[playerid][Username]);
        JsonGetString(result, "password", Player[playerid][Password]);
        JsonGetString(result, "salt", Player[playerid][Salt]);
        JsonGetInt(result, "kills", Player[playerid][Kills]);
        JsonGetInt(result, "deaths", Player[playerid][Deaths]);
        JsonGetFloat(result, "x_pos", Player[playerid][X_Pos]);
        JsonGetFloat(result, "y_pos", Player[playerid][Y_Pos]);
        JsonGetFloat(result, "z_pos", Player[playerid][Z_Pos]);
        JsonGetFloat(result, "a_pos", Player[playerid][A_Pos]);
        JsonGetInt(result, "interior", Player[playerid][Interior]);
        JsonGetInt(result, "money", Player[playerid][Money]);
        JsonGetInt(result, "online", Player[playerid][Online]);
        showLoginDialog(playerid);
    } else {
        showRegisterDialog(playerid);
    }
}