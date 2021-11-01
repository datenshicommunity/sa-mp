enum E_PLAYERS{
    Idx,
	Username[MAX_PLAYER_NAME],
	Password[65],
	Salt[17],
	Kills,
	Deaths,
	Float: X_Pos,
	Float: Y_Pos,
	Float: Z_Pos,
	Float: A_Pos,
	Interior,
	bool: Online,
    Money
}
new Player[MAX_PLAYERS][E_PLAYERS];