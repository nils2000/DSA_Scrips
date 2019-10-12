-module (creatures).
-include ("used_records.hrl").
-export ([
		common_hero/0,
		bold_hero/0
		]).

common_hero() ->
	Weapon = weapons:sword(),
	#hero{
		name="Alrik",
		courage=10,
		cleverness=10,
		charisma=10,
		dexterity=10,
		strength=10,
		level=1,
		lifepoints=30,
		astralpoints=0,
		karmapoints=0,
		experience=0,
		attack=10,
		parade=8,
		weapon=Weapon,
		armor=4,
		has_attacked=true,
		has_defended=true
		}.

bold_hero() ->
	Hero = common_hero(),
=======
-module (creatures).
-include ("used_records.hrl").
-export ([
		common_hero/0,
		bold_hero/0,
		wounded_creature/2
		]).

common_hero() ->
	Weapon = weapons:sword(),
	#hero{
		name="Alrik",
		courage=10,
		cleverness=10,
		charisma=10,
		dexterity=10,
		strength=10,
		level=1,
		lifepoints=30,
		astralpoints=0,
		karmapoints=0,
		experience=0,
		attack=10,
		parade=8,
		weapon=Weapon,
		armor=4,
		has_attacked=true,
		has_defended=true
		}.

bold_hero() ->
	Hero = common_hero(),
	Hero#hero{courage = 13}.
