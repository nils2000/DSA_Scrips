-module (weapons).
-include ("used_records.hrl").
-export ([sword/0]).

sword() ->
	Damage = #set_of_dice{
		number_of_dice=1,
		type_of_dice=6,
		modifier=4},
	#weapon{
		name="Sword",
		fragility=2,
		attackmodifier=0,
		parademodifier=0,
		damage=Damage,
		weight=0}.