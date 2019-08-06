-module (kampf).
-include ("used_records.hrl").
-compile(export_all).

-export ([
	attackewert/1,
	standardheld/0,
	schwert/0,
	wuerfelsatz/3,
	initialisiere_kampfrunde/2,
	beginne_kampfrunde/3
	]).

wuerfelsatz(Anzahl,Typ,Modifikator) ->
	#wuerfelsatz{
		anzahl_wuerfel=Anzahl,
		wuerfel_typ=Typ,
		modifikator=Modifikator
	}.

schwert() ->
	Trefferwuerfel = wuerfelsatz(1,6,4),
	#waffe{
		name="Schwert",
		bruchfaktor=2,
		attacke=0,
		parade=0,
		trefferpunkte=Trefferwuerfel,
		gewicht=0
	}.

standardheld() ->
	Waffe = schwert(),
	#{
		name=>"Alrik",
		mut=>10,
		klugheit=>10,
		charisma=>10,
		geschicklichkeit=>10,
		koerperkraft=>10,
		stufe=>1,
		lebenspunkte=>30,
		astralpunkte=>0,
		karmapunkte=>0,
		abenteuerpunkte=>0,
		attacke=>10,
		parade=>8,
		waffe=>Waffe,
		ruestungsschutz=>4,
		schonangegriffen=>true,
		schonverteidigt=>true
		}.

lebenspunkte(Held) ->
	maps:get(lebenspunkte,Held).

mutiger_held() ->
	(standardheld())#{mut := 13}.

attackewert(Held) ->
	maps:get(attacke,Held) + (maps:get(waffe,Held))#waffe.attacke.

paradewert(Held) ->
	maps:get(parade,Held) + (maps:get(waffe,Held))#waffe.parade.

schaden(Held) ->
	Staerke = maps:get(koerperkraft,Held),
	if
		Staerke < 8 ->
			Modifikator = Staerke - 8;
		Staerke > 12 ->
			Modifikator = Staerke - 12;
		true ->
			Modifikator = 0
		end,
	Waffe = maps:get(waffe,Held),
	Waffenschaden = Waffe#waffe.trefferpunkte,
	Schaden = wuerfelwurf(Waffenschaden),
	Schaden + Modifikator.


probe() ->
	rand:uniform(20).

wuerfelwurf(Wuerfelsatz,0,Ergebnis) ->
	Ergebnis + Wuerfelsatz#wuerfelsatz.modifikator;

wuerfelwurf(Wuerfelsatz,N,Ergebnis) ->
	Wurf = rand:uniform(Wuerfelsatz#wuerfelsatz.wuerfel_typ),
	wuerfelwurf(Wuerfelsatz,N-1,Ergebnis + Wurf).

wuerfelwurf(Wuerfelsatz) ->
	wuerfelwurf(Wuerfelsatz,Wuerfelsatz#wuerfelsatz.anzahl_wuerfel,0).

entziehe_trefferpunkte(Held,Schaden) ->
	Held#{lebenspunkte := (maps:get(lebenspunkte,Held) - Schaden)}.

ist_bewusstlos(Held) ->
	maps:get(lebenspunkte,Held) < 5.

sortiere_nach_mut(Helden) ->
	lists:sort((fun(A,B) -> (maps:get(mut,A) > maps:get(mut,B)) end), Helden).

initialisiere_kampfrunde(Helden) ->
	initialisiere_kampfrunde(Helden,[]).

initialisiere_kampfrunde([],Helden) ->
	Helden;

initialisiere_kampfrunde(Nicht_initialisiert,Helden) ->
	[He|Rest_Gruppe] = Nicht_initialisiert,
	H1 = He#{schonangegriffen=>false},
	H2 = H1#{schonverteidigt=>false},
	Vorbereitete_Helden = [H2|Helden],
	initialisiere_kampfrunde(Rest_Gruppe,Vorbereitete_Helden).

kampf([],B,Leichen) ->
	{B,Leichen};

kampf(A,[],Leichen) ->
	{A,Leichen};

kampf(A,B,Leichen) ->
	Af = lists:flatten(A),
	Bf = lists:flatten(B),
	NeuA = initialisiere_kampfrunde(Af),
	NeuB = initialisiere_kampfrunde(Bf),
	beginne_kampfrunde(NeuA,NeuB,Leichen).

beginne_kampfrunde(A,B,Leichen) when is_list(A) and is_list(B)->
	%exit("Test"),
	GruppeA = sortiere_nach_mut(A),
	GruppeB = sortiere_nach_mut(B),
	kampfrunde(GruppeA,[],GruppeB,[],Leichen).



kampfrunde([],A,[],B,Leichen) ->
	%exit([A,B]),
	kampf(A,B,Leichen);

kampfrunde(A,A_fertig,[],[],Leichen) ->
	{A ++ A_fertig,Leichen};

kampfrunde([],[],B,B_fertig,Leichen) ->
	{B ++ B_fertig,Leichen};

kampfrunde(A,A_fertig,[],B_fertig,Leichen) ->
	[Kaempfer_A|Rest_A] = A,
	[Kaempfer_B|Rest_B] = B_fertig,
	{Fertig_A,Fertig_B,Leiche} = schlagabtausch(Kaempfer_A,Kaempfer_B),
	kampfrunde(Rest_A,A_fertig ++ [Fertig_A],[],Rest_B ++ [Fertig_B],lists:flatten([Leiche|Leichen]));

kampfrunde([],A_fertig,B,B_fertig,Leichen) ->
	kampfrunde(B,B_fertig,[],A_fertig,Leichen);

kampfrunde(A,A_fertig,B,B_fertig,Leichen) ->
	[Kaempfer_A|Rest_A] = A,
	[Kaempfer_B|Rest_B] = B,
	{Fertig_A,Fertig_B,Leiche} = schlagabtausch(Kaempfer_A,Kaempfer_B),
	kampfrunde(Rest_A,A_fertig ++ [Fertig_A],Rest_B,B_fertig ++ [Fertig_B],lists:flatten([Leiche|Leichen])).

schlagabtausch(Kaempfer_A,Kaempfer_B) ->
	LebenA = lebenspunkte(Kaempfer_A),
	LebenB = lebenspunkte(Kaempfer_B),
	SchonAlle = (maps:get(schonangegriffen,Kaempfer_A) and (maps:get(schonangegriffen,Kaempfer_B))),
	SchonA = maps:get(schonangegriffen,Kaempfer_A),
	SchonB = maps:get(schonangegriffen,Kaempfer_B),
	MutA = maps:get(mut,Kaempfer_A),
	MutB = maps:get(mut,Kaempfer_B),
	ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B).

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when LebenA < 5 ->
	{[],[Kaempfer_B],[Kaempfer_A]};

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when LebenB < 5 ->
	{[Kaempfer_A],[],[Kaempfer_B]};


ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when SchonAlle ->
	{[Kaempfer_A],[Kaempfer_B],[]};

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when SchonB ->
			{A,B} = angriff(Kaempfer_A,Kaempfer_B),
			schlagabtausch(A,B);

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when SchonA ->
			{B,A} = angriff(Kaempfer_B,Kaempfer_A),
			schlagabtausch(A,B);

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) when MutA > MutB ->
	{A,B} = angriff(Kaempfer_A,Kaempfer_B),
	schlagabtausch(A,B);

ergebnisSchlagabtausch(LebenA,LebenB,SchonAlle,SchonA,SchonB,MutA,MutB,Kaempfer_A,Kaempfer_B) ->
	{B,A} = angriff(Kaempfer_B,Kaempfer_A),
	schlagabtausch(A,B).


angriff(Kaempfer_A,Kaempfer_B) ->
	A = Kaempfer_A#{schonangegriffen := true},
	Wurf = probe(),
	Attackewert = attackewert(A),
	if
		Attackewert < Wurf -> 
		 	{A,Kaempfer_B};
		true -> 
			B = trifft(A,Kaempfer_B),
			{A,B}
	end.

trifft(Kaempfer_A,Kaempfer_B) ->
	SchonV = maps:get(schonverteidigt,Kaempfer_B),
	if
		SchonV ->
			B = schadet(Kaempfer_A,Kaempfer_B),
			B;
		true ->
			K_B = Kaempfer_B#{schonverteidigt := true},
			Wurf = probe(),
			Paradewert = paradewert(K_B),
			if
				Paradewert =< Wurf ->
					K_B ; %bruchfaktor
				true ->
					B = schadet(Kaempfer_A,K_B),
					B
			end
	end.

schadet(Kaempfer_A,Kaempfer_B) ->
	TP = schaden(Kaempfer_A),
	Schaden = TP - maps:get(ruestungsschutz,Kaempfer_B),
	if
		Schaden > 0 ->
			B = entziehe_trefferpunkte(Kaempfer_B,Schaden),
			B;
		true ->
			Kaempfer_B
		end.
