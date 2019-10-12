<<<<<<< HEAD
-module (weapons).
-include ("used_records.hrl").
-export ([sword/0]).

damage(Number,Type,Modifier) ->
	#set_of_dice{
		number_of_dice = Number,
		type_of_dice = Type,
		modifier = Modifier}.

weapon(Name,Fragility,Attackmod,Parademod,Damage,Weight) ->
	#weapon{
		name = Name,
		fragility = Fragility,
		attackmodifier = Attackmod,
		parademodifier = Parademod,
		damage = Damage,
		weight = Weight
	}.

sword() ->
	weapon("sword",2,0,0,damage(1,6,4),80).

knife() ->
	weapon("knife",5,0,-5,damage(1,6,0),10).

dagger() ->
	weapon("dagger",3,0,-4,damage(1,6,1),20).

heavy_dagger() ->
	weapon("heavy dagger",3,0,-2,damage(1,6,2),35).

short_sword() ->
	weapon("short sword",2,0,0,damage(1,6,2),60).

club() ->
	weapon("club",6,-1,-3,damage(1,6,2),80).

hatchet() ->
	weapon("hatchet",4,0,-4,damage(1,6,3)60).

=======
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
>>>>>>> 6c4c6a24ff4b2b1da0a8c17b99b3deaf01f0f70a
