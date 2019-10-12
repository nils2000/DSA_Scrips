-module (combat).
-include ("used_records.hrl").
-compile(export_all).

%-export ([
%	]).


resolve({round_over,Done_FighterA,CorpsesA,Done_FighterB,CorpsesB}) ->
	resolve({Done_FighterA,CorpsesA},{Done_FighterB,CorpsesB});

resolve({all_dead,[],CorpsesA,[],CorpsesB}) ->
	logger:notice("How did that happen ? All unable to fight !"),
	logger:notice(CorpsesA ++ CorpsesB);

resolve({b_won,[],CorpsesA,FighterB,CorpsesB}) ->
	logger:notice("Second group won. Still standing:"),
	logger:notice(FighterB),
	logger:notice("On the ground:"),
	logger:notice(CorpsesA ++ CorpsesB);

resolve({a_won,FighterA,CorpsesA,[],CorpsesB}) ->
	logger:notice("First group won. Still standing:"),
	logger:notice(FighterA),
	logger:notice("On the ground:"),
	logger:notice(CorpsesA ++ CorpsesB).

resolve(FighterA,FighterB) when is_list(FighterA) ->
	resolve({FighterA,[]},{FighterB,[]});

resolve({FighterA,CorpsesA},{FighterB,CorpsesB}) ->
	resolve(six_seconds({FighterA,CorpsesA},{FighterB,CorpsesB})).

%%%%%%%%fight
%simple setup:
%two groups fight against each other
%each group is a tupel {fighterList,corpseList}

six_seconds({FighterA,CorpsesA},{FighterB,CorpsesB}) ->
	InitializedA = initialize_combat_round(FighterA),
	InitializedB = initialize_combat_round(FighterB),
	six_seconds({InitializedA,[],CorpsesA},{InitializedB,[],CorpsesB});

six_seconds({[],[],CorpsesA},{[],[],CorpsesB}) ->
	{all_dead,[],CorpsesA,[],CorpsesB};

six_seconds({[],[],CorpsesA},{FighterB,FighterB_Done,CorpsesB}) ->
	{b_won,[],CorpsesA,FighterB++FighterB_Done,CorpsesB};

six_seconds({FighterA,FighterA_Done,CorpsesA},{[],[],CorpsesB}) ->
	{a_won,FighterA++FighterA_Done,CorpsesA,[],CorpsesB};

six_seconds({[],Done_FighterA,CorpsesA},{[],Done_FighterB,CorpsesB}) ->
	{round_over,Done_FighterA,CorpsesA,Done_FighterB,CorpsesB};

%%from each group of fighters still standing:
%take one
%let them fight against each other
%corpses are removed from the fightergroups

six_seconds({FighterA,Done_FighterA,CorpsesA},{FighterB,Done_FighterB,CorpsesB}) ->
	%logger:notice("Fight:"),
	{F_A,F_B} = next_pair(FighterA,Done_FighterA,FighterB,Done_FighterB),
	%logger:notice(name(F_A) ++ "against" ++ name(F_B)),
	Fighters_A = lists:delete(F_A,FighterA),
	Fighters_B = lists:delete(F_B,FighterB),
	Done_Fighters_A = lists:delete(F_A,Done_FighterA),
	Done_Fighters_B = lists:delete(F_B,Done_FighterB),
	{FiA_List,CA_L,FiB_List,CB_L} = one_on_one(F_A,F_B),
	six_seconds({Fighters_A,Done_Fighters_A ++ FiA_List,CorpsesA ++ CA_L},{Fighters_B,Done_Fighters_B ++ FiB_List,CorpsesB ++ CB_L}).

%attack stategy is to pair fighting pairs as equaly as possible
%(later we could try to see what happens if all fighters of th group attack
%	the same target)

next_pair(L1_1,L1_2,L2_1,L2_2) ->
	[A|_] = L1_1 ++ L1_2,
	[B|_] = L2_1 ++ L2_2,
	{A,B}.


%%%%%%%%each round: initialize combatants,
%each round: initialize combatants,

initialize_combatant(Fighter) when is_record(Fighter,hero) ->
	Fighter#hero{has_attacked=false,has_defended=false}.

initialize_combat_round(List_of_combatants) when is_list(List_of_combatants) ->
	initialize_combat_round(List_of_combatants,[]).

initialize_combat_round([],List_of_initialized) ->
	List_of_initialized;

initialize_combat_round(List_of_uninitialized,List_of_initialized) ->
	[Hero|Rest] = List_of_uninitialized,
	initialize_combat_round(Rest,[initialize_combatant(Hero)|List_of_initialized]).




%one-on-one:
%-if either one is unconcious fight is over,

one_on_one(FighterA,FighterB) when FighterA#hero.lifepoints < 5 ->
	{[],[FighterA],[FighterB],[]};

one_on_one(FighterA,FighterB) when FighterB#hero.lifepoints < 5 ->
	{[FighterA],[],[],[FighterB]};

%only one attack per round
one_on_one(FighterA,FighterB) when FighterB#hero.has_attacked and FighterA#hero.has_attacked ->
	{[FighterA],[],[FighterB],[]};

%one-on-one:
%-if either one is unconcious fight is over,
one_on_one(FighterA,FighterB) when FighterA#hero.lifepoints < 5 ->
	{[],[FighterB],[FighterA]};

one_on_one(FighterA,FighterB) when FighterB#hero.lifepoints < 5 ->
	{[FighterA],[],[FighterB]};

%only one attack per round
one_on_one(FighterA,FighterB) when FighterB#hero.has_attacked and FighterA#hero.has_attacked ->
	{[FighterA],[FighterB],[]};


one_on_one(FighterA,FighterB) when FighterB#hero.has_attacked ->
	{A,B} = attack(FighterA,FighterB),
	one_on_one(A,B);

one_on_one(FighterA,FighterB) when FighterA#hero.has_attacked ->
	{B,A} = attack(FighterB,FighterA),
	one_on_one(A,B);
%(most couragous first):
one_on_one(FighterA,FighterB) when FighterA#hero.courage > FighterB#hero.courage ->
	{A,B} = attack(FighterA,FighterB),
	one_on_one(A,B);

one_on_one(FighterA,FighterB) ->
	{B,A} = attack(FighterB,FighterA),
	one_on_one(A,B).

attack(FighterA,FighterB) ->
	A = FighterA#hero{has_attacked = true},
	Attack_roll = roll_d20(),
	Attack_value = attackvalue(A),

	%logger:notice(name(A) ++ " attacks, rolls " ++ integer_to_list(Attack_roll)),

	logger:notice(name(A) ++ " attacks, rolls " ++ integer_to_list(Attack_roll)),

	if
	 	Attack_roll > Attack_value ->
	 		{A,FighterB};
	 	true ->
	 		%logger:notice("Attack succeded"),
	 		logger:notice("Attack succeded"),
	 		B = defend(FighterB,FighterA),
	 		{A,B}
	 end.

%defend (-only one Defence per round for each fighter)
defend(Defender,Attacker) ->
	D = Defender#hero{has_defended=true},
	Defence_roll = roll_d20(),
	Defence_value = paradevalue(Defender),
	%logger:notice(name(D) ++ " defends, rolls " ++ integer_to_list(Defence_roll)),
	logger:notice(name(D) ++ " defends, rolls " ++ integer_to_list(Defence_roll)),
	if
		Defence_value >= Defence_roll ->
			D;
		%do damage
		true ->
			hit(Attacker,D)
	end.

% ---- helper functions -----

name(Hero) ->
	Hero#hero.name.

lifepoints(Hero) ->
	Hero#hero.lifepoints.

attackvalue(Hero) ->
	Hero#hero.attack + (Hero#hero.weapon)#weapon.attackmodifier.

paradevalue(Hero) ->
	Hero#hero.parade + (Hero#hero.weapon)#weapon.parademodifier.

strength(Hero) ->
	Hero#hero.strength.

wounded_hero(Hero,Damage) ->
	Hero#hero{lifepoints = lifepoints(Hero) - Damage}.

weapon(Hero) ->
	Hero#hero.weapon.

set_of_dice(Number,Type,Modifier) ->
	#set_of_dice{
		number_of_dice=Number,
		type_of_dice=Type,
		modifier=Modifier
	}.

roll_d20() ->
	rand:uniform(20).

roll_dice(Dice) ->
	roll_dice(Dice,Dice#set_of_dice.number_of_dice, 0).

roll_dice(Dice,0,Result) ->
	Result + Dice#set_of_dice.modifier;

roll_dice(Dice,Number,Result) ->
	Res = rand:uniform(Dice#set_of_dice.type_of_dice),
	roll_dice(Dice,Number-1,Result+Res).

roll_damage_for(Hero) ->
	Strength = strength(Hero),
	if
		Strength < 8 ->
			Modifier = Strength - 8;
		Strength > 12 ->
			Modifier = Strength - 12;
		true ->
			Modifier = 0
		end,
	Weapon = weapon(Hero),
	Damage_dice = Weapon#weapon.damage,
	Damage = roll_dice(Damage_dice),
	Damage + Modifier.

hit(Attacker,Defender) ->
	Damage = roll_damage_for(Attacker),
	wounded_hero(Defender,Damage).

simple_test_group_one() ->
	CH = creatures:common_hero(),
	[CH#hero{name="A1"},CH#hero{name="B1"}].

simple_test_group_two() ->
	CH = creatures:common_hero(),
	[CH#hero{name="A2"},CH#hero{name="B2"}].
