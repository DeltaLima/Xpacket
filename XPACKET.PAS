{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  Primaryfile:     X P . P A S                                           ³
 ³                                                                         ³
 ³                                                                         ³
 ³  XP ist ein auf TOP 1.50-Routinen aufgebautes Programm.                 ³
 ³  TOP ist eine Weiterentwicklung des schon bekannten Terminalprogramms   ³
 ³  THP 2.6 von DL1BHO . Es gelten auch hier die gleichen Kriterien wie    ³
 ³  bei THP. Das heiát:                                                    ³
 ³                                                                         ³
 ³  Das Programm ist ausdruecklich PUBLIC DOMAIN, koennen also an jeden    ³
 ³  interessierten Funkamateur zur NICHT-KOMMERZIELLEN NUTZUNG weiterge-   ³
 ³  geben werden.                                                          ³
 ³                                                                         ³
 ³                                                                         ³
 ³  A C H T U N G :                                                        ³
 ³                                                                         ³
 ³   Dieses Programm ist ein reines Hobby-Produkt!                         ³
 ³                                                                         ³
 ³   Fr Fehler, insbesondere fr eventuelle Datenverluste, kann           ³
 ³   KEINERLEI HAFTUNG bernommen werden!                                  ³
 ³                                                                         ³
 ³                                                                         ³
 ³                                                                         ³
 ³                                                                         ³
 ³   Compiliert wird mit TURBO-PASCAL 7.0                                  ³
 ³                                                                         ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
 { XPLOAD nach 101 suchen, um die richtige versi zu erstellen }

PROGRAM Packet_HOSTMODE_Terminal(Input,Output);
{$M 22000,0,655360}
{$F+}
{-$DEFINE extovl}   {**Zum Start in TP aktivieren}
{-$DEFINE code}   {** Aktiv fr Code-Fassung, Deaktiv fr offizielle
                     auch XPACT, XPOVR6}
{-$DEFINE Sound}  {**Wenn aktiv, wird SB-Untersttzung mit
                     compilliert, ist es deaktiv, nicht
                     auch XPACT, XPACT1, XPOVR, XPOVR4, XPOVR6, XPDEFS}
{-$DEFINE no_Netrom} {**Wenn aktiv wird keine NetRom-Unterstuetzung
                        mit compiliert //db1ras}
{-$DEFINE no_Bake}   {**Wenn aktiv, alle Bakenfunktionen deaktiviert //db1ras}

{-$DEFINE ReadOldMemo} {**Wenn aktiv, kann XP auch die Vorgaengerversion der
                        memo.xp lesen (waehrend der Uebergangsphase wichtig),
                        die alte Version wird als memo.<versionsnummer>
                        gesichert, geschrieben wird immer die neue Version
                                                                     //db1ras}

USES    OVERLAY,
        CRT,
        DOS,

{        GRAPH,}

        XPEMS,
        XPXMS,
        XPDEFS,
        XPACT,
        XPACT1,

        XPOVR,
        XPOVR1,
        XPOVR2,
        XPOVR3,
        XPOVR4,
        XPOVR5,
        XPOVR6,
        OVERXMS;


{$O XPOVR}
{$O XPOVR1}
{$O XPOVR2}
{$O XPOVR3}
{$O XPOVR4}
{$O XPOVR5}

Var   i  : Integer;
      spf:dirstr..dirstr;


BEGIN   (****  H A U P T P R O G R A M M  ****)

  Check_Loaded; {Ueberprueft, ob XP schon geladen ist}

  Old_IntMask := Port[$21];

  Inline($FA);
  FillChar(neue_Table,SizeOf(neue_Table),$FF);
  alte_Table := Ptr(PrefixSeg,$18);
  move(alte_Table^[1],neue_Table[1],20);

  TabAdresse := Ptr(PrefixSeg,$34);
  TabAdresse^ := @neue_Table[1];
  TabLaenge := Ptr(PrefixSeg,$32);
  TabLaenge^ := maxTable;
  Inline($FB);

{ SPf := Dir;}
 SysPfad:=UpCaseStr(ParamStr(0));          { Pfad fr Config-Dateien }
  OvrDatei := SysPfad;

{$IFDEF extovl}
OVRDatei := 'XPACKET.OVR';
{$ENDIF}


 While (length(SysPfad) > 0) and (SysPfad[length(SysPfad)] <> BS)
        do delete(SysPfad,length(SysPfad),1);
  if (Length(SysPfad) > 0) and (SysPfad[Length(SysPfad)] <> BS)
    then SysPfad := SysPfad + BS;

  Sys1Pfad := SysPfad;
  OvrInit(OvrDatei);
  if OvrResult <> 0 then

    begin
    Writeln;
    Writeln('Failure with ',OvrDatei,' !');
    PRG_Stoppen(0);
  end;

  ParamZeile := Ptr(PrefixSeg,$80);
  UebergabeAuswert;

  if Nutze_XMS then Init_XMS;
  if Nutze_EMS then Init_EMS;

  if Nutze_XMS and OVRtoXMS then
  begin
    OvrInitXMS;
    i := OvrResult;
    OVRtoEMS:=false;
    if i = 0 then Mstr := EmsStr + OvrDatei + B1 + 'load into XMS'
             else Mstr := EmsStr + OvrDatei + B1 + 'F-Nr.' + GL + int_str(i);
  end;

  if Nutze_EMS and OVRtoEMS then
  begin
    OvrInitEMS;
    i := OvrResult;
    if i = 0 then Mstr := EmsStr + OvrDatei + B1 + 'load into EMS'
             else Mstr := EmsStr + OvrDatei + B1 + 'F-Nr.' + GL + int_str(i);
  end;

   OrigExit := ExitProc;
  ExitProc := @Exit_XP;

  FreeRam := $A0000 - Adr_absolut(Ptr(PrefixSeg,0));

  GetMem(G,SizeOf(G^));
  FillChar(G^,SizeOf(G^),0);

  CheckBreak := false;                { kein Abbruch durch ctrl-C }
  GetCBreak(BreakStatus);             { Break-Status holen und retten }
  SetCBreak(false);                   { Break off }

  CheckSnow := false;
  GetVideoMode;
  StartVideoMode := LastMode;         { derzeitigen VideoMode merken }
  LastModeStore := StartVideoMode;

  if Hercules then maxZ := 25
              else maxZ := WindMax div 256 + 1;

  Cursor_aus;
  TextAttr := StartColor;
  ClrScr;

  GenCrcTab;
  Mstr := ParamStr(0);

  if CRC_PR_EXE then
  begin
    NormVideo;
    ClrScr;
    SetzeCursor(1,25);
    Mstr := ParamStr(0);
    CRC_Datei(Mstr);
    Writeln(Mstr);
    Writeln;
    PRG_Stoppen(0);
  end;

  Var_Init(99); { Erstmal nur globale Variablen initialisieren }

  getdate(Jahr_,Monat_, Tag_, woTag_);
  LastLTCheck:=0;

  Cursor_aus;
  Emblem_zeigen;
  {$IFNDEF Sound}
  writeln('NoSound-Version');   {//db1ras}
  {$ENDIF}
  LastLTCheck:=SizeOf(lokalptr);
  LastLTCheck:=SizeOf(Kanalptr);
  LastLTCheck:=SizeOf(TNC_Typ);
  LastLTCheck:=0;

  ConfigLesen;

{  GetNetRom;}
(*  Konfig.WavOut:=true; {************************ L™SCHEN}*)

{$IFDEF Sound}
  if (konfig.wavout) or (konfig.wavsprach) then
   begin
    FindBlaster;
    assign (SoundFile, 'TEST.WAV');
   end;
{$ENDIF}

{  Mstr := ParamStr(0);
  GetNetRom (Mstr);}

  Infos_Lesen;
  Strings_Lesen;
  Merker_Conn_Lesen;
  Merker_File_Lesen;
  Fenster_Berechnen;
  V24_Init;

  AttributFile_Lesen;
  ESC_Lesen;
  QRG_Lesen;
  REM_Lesen;
  PWD_Lesen;
  HELP_Lesen;

  if (SSAV > 0) then Puffer_lesen;

  max_path_ermitteln;

  Switch_VGA_Mono;
  ColorItensity(HighCol);
  maxZ := WindMax div 256 + 1;
  Cursor_aus;

  show := 0;
  for i := 1 to 4 do StatusOut(0,1,i,Attrib[9],ConstStr(B1,20),1);
  Neu_Bild;
  VorCurEnd;

  M_aus(Attrib[28],^J, 0);

  Ini_Start_Tnc;
  if MhKill then FillChar(MH^,SizeOf(MH^),0);

  K[0]^.TncNummer := 1;

  SwitchChannel(FirstConCh);

  if Exists(Konfig.makverz + AutoExecFile) then
  begin
    MakroInit;
    Makro_aktivieren(konfig.makverz + AutoExecFile);
  end;

  if klingel<>(not quiet) then
   begin
    Klingel:=not Quiet;
    setzeFlags(show);
   end;

 UserAnwesend;

{for i:=1 to maxlink do }   {//db1ras}
{  if (not K[i]^.connected) and (not K[i]^.Mo.MonActive) then }
{    K[i]^.ignore:=false; }



  Repeat  (****  H A U P T S C H L E I F E  ****)
    Check_Keyboard;
    Uhr_aus;


    If Idle then
    begin
      if (Idle_TCount > 0) and (Idle_TMerk <> TimerTick) then
      begin
        Idle_TMerk := TimerTick;
        dec(Idle_TCount);
      end;

      if Idle_Count > 0 then dec(Idle_Count);

      if (Idle_TCount = 0) and ((Idle_Pos and (Idle_Count = 0)) or
                                (not Idle_Pos and (Idle_Count > 0))) then
      begin
        IdleDOS;
        if Idle_Pos then Idle_Count := Idle_Anz;
      end;
    end;

    if not Idle or
       Idle and (Idle_Pos or
       (not Idle_Pos and (Idle_Count = 0) and (Idle_TCount = 0))) then
    begin
      if Idle and not Idle_Pos then Idle_Count := Idle_Anz;
      if polling then TNCs_Pollen;
      set_Hardwarecursor(show);
    end;
  Until QRT;   (*  E N D E  der  H A U P T S C H L E I F E  *)
  TschuessFenster;
  TncIni(1);
  Abschluss_XP;
  Init_HardDrive;
  ExitProc := OrigExit;
End.
