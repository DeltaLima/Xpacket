{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P A U T O .  P A S                                                   ³
 ³                                                                         ³
 ³ Routinen fr die Abarbeitung der automatischen CMD-Dateien.             ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Auto_Init (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    {
    Werte fr CSelf:
    ----------------
    1 = Auto startet zu einer bestimmten Zeit.
    2 = Auto startet alle X Minuten.
    3 = Bedingung 1 oder 2 sind erfllt.
    4 = Auto befindet sich im Wartestadium und wartet X Minuten ab.
    5 = Auto erwartet den Empfang der Abfragezeile (einfache Prfung)
    6 = Auto erwartet den Empfang der Abfragezeile (strenge Prfung,
                        die Abfragezeile muá mit Return beendet sein).
    7 = Bedingung 5 oder 6 sind erfllt.
    8 = Auto hat Gleichheit zwischen Auto1Zeile und eintreffender
        Zeile festgestellt.
    9 = Das Terminal ist momentan im Backscrollmode und eine ESC-Zeile
        aus dem Autofile kann deswegen nicht bedient werden. Erst wenn
        der Backscroll verlassen wird, wird die ESC-Zeile bearbeitet.
   10 = kurze Ruhephase fr Auto.
    }

    Cself := 0;
    AutoZeile := '';
    Auto1Zeile := '';
    AutoTime := '';
    AutoWait := 0;
    AutoChMerk := 0;
    AutoZaehl := 0;
    AutoJump := 0;
    AutoZyCount := 0;
    AutoToCount := 0;
    AutoToConst := 0;
    AutoToAnz := 0;
    AutoToMax := 0;
    AutoToAnzJmp := 0;
    AutoArt := 0;
    AutoJmpPtr := 1;
    FillChar(AutoJmpRet,SizeOf(AutoJmpRet),0);
    if AutoZyConst > 0 then CSelf := 2;
    SetzeFlags(Kanal);
  end;
End;


Procedure Autozeile_Holen (* Kanal : Byte *);
Var  Hstr   : String[80];
     w      : Word;
     Flag,
     EFlag,
     TxFlag : Boolean;
Begin
  with K[Kanal]^ do
  begin
    Flag := false;
    EFlag := false;
    Hstr := Konfig.MakVerz + AutoDatei + SFillStr(3,'0',int_str(Kanal));
    Assign(G^.AutoFile,Hstr);
    if ResetTxt(G^.AutoFile) = 0 then
    begin
      for w := 1 to AutoZaehl do Readln(G^.AutoFile);
      if not Eof(G^.AutoFile) then
      begin
        TxFlag := false;
        CSelf := 11;
        Repeat
          inc(AutoZaehl);
          Readln(G^.AutoFile,AutoZeile);
          KillEndBlanks(AutoZeile);

          if pos('* ',AutoZeile) = 1 then
          begin
            CSelf := 9;
            if BackScroll(show) then dec(AutoZaehl)
                                else Auswert_CMD(Kanal,AutoZeile);
            EFlag := true;
          end else

          if pos('? ',AutoZeile) = 1 then
          begin
            AutoZeile := UpCaseStr(RestStr(AutoZeile));
            AutoToCount := AutoToConst;
            CSelf := 5;
            EFlag := true;
          end else

          if pos('?G ',AutoZeile) = 1 then
          begin
            AutoZeile := RestStr(AutoZeile);
            AutoJump := AutoJmpZnNr(Kanal,CutStr(AutoZeile));
            Auto1Zeile := UpCaseStr(RestStr(AutoZeile));
          end else

          if pos('?L ',AutoZeile) = 1 then
          begin
            Auto1Zeile := UpCaseStr(RestStr(AutoZeile));
            AutoArt := 1;
          end else

          begin
            AutoZeile := Line_convert(Kanal,1,AutoZeile);
            NodeConnect(Kanal,UpCaseStr(AutoZeile));
            EigFlag := Echo in [1,3,5,7];
            S_PAC(Kanal,NU,false,AutoZeile + M1);
            EigFlag := false;
            TxFlag := true;
          end;
        Until EFlag or Eof(G^.AutoFile);
        if TxFlag then S_PAC(Kanal,NU,true,'');
      end else Flag := true;
      FiResult := CloseTxt(G^.AutoFile);
    end;
    if Flag then Auto_Init(Kanal)
            else SetzeFlags(Kanal);
  end;
End;


Procedure Auto_Aktivieren (* Kanal : Byte; Zeile : Str60 *);
Var    Hstr : String[80];
Begin
  with K[Kanal]^ do
  begin
    Zeile := UpCaseStr(RestStr(Zeile));

    if CSelf = 0 then
    begin
      Hstr := Konfig.MakVerz + AutoDatei + SFillStr(3,'0',int_str(Kanal));

      if Exists(Hstr) then
      begin
        Hstr := CutStr(Zeile);

        if (length(Zeile) = 5) and (pos(DP,Zeile) = 3) then
        begin
          AutoTime := Zeile;
          CSelf := 1;
          InfoOut(Kanal,0,1,InfoZeile(294) + B1 + AutoTime);
        end else

        if Hstr = 'Z' then
        begin
          AutoZyConst := Word(str_int(RestStr(Zeile)));
          if AutoZyConst > 0 then
          begin
            CSelf := 2;
            AutoZyCount := 0;
            InfoOut(Kanal,0,1,InfoZeile(275) + B1 + RestStr(Zeile) + B1 + 'min');
          end;
        end else
        begin
          Autozeile_Holen(Kanal);
          AutoToAnz := AutoToMax;
        end;
      end else InfoOut(Kanal,1,1,InfoZeile(293) + B1 + Hstr);
    end else
    begin
      Hstr := CutStr(Zeile);

      if Hstr = 'A' then
      begin
        AutoToMax := Word(str_int(ParmStr(2,B1,Zeile)));
        AutoToAnzJmp := AutoJmpZnNr(Kanal,ParmStr(3,B1,Zeile));
        AutoToAnz := AutoToMax;
      end else

      if Hstr = 'E' then
      begin
        AutoZeile := '';
        CSelf := 9;
      end else

      if Hstr = 'G' then
      begin
        AutoJmpRet[AutoJmpPtr] := AutoZaehl;
        inc(AutoJmpPtr);
        if AutoJmpPtr > maxAutoJmpPtr then AutoJmpPtr := 1;
        AutoZaehl := AutoJmpZnNr(Kanal,RestStr(Zeile));
        CSelf := 3;
      end else

      if Hstr = 'J' then
      begin
        AutoZaehl := AutoJmpZnNr(Kanal,RestStr(Zeile));
        CSelf := 3;
      end else

      if Hstr = 'K' then
      begin
        Auto1Zeile := '';
      end else

      if Hstr = 'L' then
      begin
        if AutoArt = 2 then
        begin
          AutoJmpRet[AutoJmpPtr] := AutoZaehl;
          inc(AutoJmpPtr);
          if AutoJmpPtr > maxAutoJmpPtr then AutoJmpPtr := 1;
          AutoZaehl := AutoJmpZnNr(Kanal,RestStr(Zeile));
          AutoArt := 0;
        end;
        CSelf := 3;
      end else

      if Hstr = 'R' then
      begin
        dec(AutoJmpPtr);
        if AutoJmpPtr = 0 then AutoJmpPtr := maxAutoJmpPtr;
        AutoZaehl := AutoJmpRet[AutoJmpPtr];
        CSelf := 3;
      end else

      if Hstr = 'S' then
      begin
        InfoOut(Kanal,0,1,AutoZeile);
      end else

      if Hstr = 'T' then
      begin
        AutoToConst := Word(str_int(RestStr(Zeile)));
      end else

      if Hstr = 'W' then
      begin
        AutoWait := Word(str_int(RestStr(Zeile)));
        if AutoWait > 0 then CSelf := 4;
      end else

      if Hstr = 'Y' then
      begin
        dec(AutoJmpPtr);
        if AutoJmpPtr = 0 then AutoJmpPtr := 1;
        AutoJmpRet[AutoJmpPtr] := 0;
        CSelf := 3;
      end else

      if Hstr = '+' then
      begin
        AutoChMerk := show;
        SwitchChannel(Kanal);
      end else

      if Hstr = '-' then
      begin
        SwitchChannel(AutoChMerk);
      end else
      begin
        AutoZyConst := 0;
        Auto_Init(Kanal);
        InfoOut(Kanal,0,1,InfoZeile(274));
      end;
    end;
    SetzeFlags(Kanal);
  end;
End;


Function  AutoJmpZnNr (* Kanal : Byte; Zeile : Str40) : Word *);
Var   w    : Word;
      Hstr : String[80];
      Flag : Boolean;
Begin
  w := 0;
  Flag := false;
  Zeile := UpCaseStr(Zeile);

  Hstr := Konfig.MakVerz + AutoDatei + SFillStr(3,'0',int_str(Kanal));
  Assign(G^.TFile,Hstr);
  if ResetTxt(G^.TFile) = 0 then
  begin
    While not (Flag or Eof(G^.TFile)) do
    begin
      inc(w);
      Readln(G^.TFile,Hstr);
      Flag := UpCaseStr(CutStr(Hstr)) = (DP + Zeile);
    end;

    if Flag then AutoJmpZnNr := w
            else AutoJmpZnNr := 0;

    FiResult := CloseTxt(G^.TFile);
  end else AutoJmpZnNr := 0;
End;
