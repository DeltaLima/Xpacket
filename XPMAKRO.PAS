{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P M A K R O . P A S                                                  ³
 ³                                                                         ³
 ³ Routinen fr die Abarbeitung der Makrofunktionen.                       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure MakroZeile_holen;
Var   w : Word;
Begin
  if ResetTxt(G^.MakroFile) = 0 then
  begin
    for w := 1 to G^.MakroZaehl do Readln(G^.MakroFile);
    if not Eof(G^.MakroFile) then
    begin
      Readln(G^.MakroFile,G^.MakroZeile);
      KillEndBlanks(G^.MakroZeile);
      inc(G^.MakroZaehl);
      G^.MakroFileEnd := Eof(G^.MakroFile);
    end else MakroInit;
    FiResult := CloseTxt(G^.MakroFile);
  end else MakroInit;
End;


Procedure Makro_aktivieren (* Zeile : Str60 *);
Begin
  if pos(BS,Zeile) = 0 then Zeile := Konfig.MakVerz + Zeile;
  if pos(Pkt,Zeile) = 0 then Zeile := Zeile + KeyExt;
  Assign(G^.MakroFile,Zeile);
  if ResetTxt(G^.MakroFile) = 0 then
  begin
    FiResult := CloseTxt(G^.MakroFile);
    G^.Makro := true;
    G^.MakroZeile := '';
  end else
  begin
    MakroInit;
    InfoOut(show,1,1,InfoZeile(27) + B1 + Zeile);
  end;
End;


Procedure MakroInit;
Begin
  G^.MakroZeile := '';
  G^.Makro := false;
  G^.MakroFileEnd := false;
  G^.MakroZaehl := 0;
End;


Procedure Makro_Erlernen (* SK : Sondertaste; VC : Char *);
Begin
  if not(KeyCheck and (SK = _Alt3)) then
  begin
    if SK = _Andere then
    begin
      if not G^.MakroReturn then Writeln(G^.MakroFile);
      G^.MakroReturn := true;
      if VC in [^A..^Z] then
      begin
        Writeln(G^.MakroFile,S_ch + B1 + CTRL + chr(ord(VC)+64));
        G^.MakroZeile := '';
      end else G^.MakroZeile := G^.MakroZeile + VC;
    end else
    begin
      if not G^.MakroReturn then Writeln(G^.MakroFile);
      G^.MakroReturn := true;
      if G^.MakroZeile > '' then
      begin
        if not G^.MakroReturn then Writeln(G^.MakroFile);
        Writeln(G^.MakroFile,G^.MakroZeile);
        G^.MakroZeile := '';
        G^.MakroReturn := true;
      end;
      Writeln(G^.MakroFile,'* ',Key[SK].Ta);
    end;
  end;
End;


Procedure Makro_Open_LearnFile;
var     Hstr : String[80];
        KC   : Sondertaste;
        VC   : Char;
        Flag : Boolean;
        i    : Byte;
Begin
  if not G^.MakroLearn then
  begin
    Flag := false;
    Hstr := Konfig.MakVerz + MakDatei + KeyExt;
    G^.Fstr[7] := InfoZeile(187);
    G^.Fstr[10] := B1 + InfoZeile(168);
    Fenster(15);
    GetString(Hstr,Attrib[3],60,2,14,KC,2,Ins);
    if KC <> _Esc then
    begin
      Assign(G^.MakroFile,Hstr);
      if ResetTxt(G^.MakroFile) = 0 then
      begin
        FiResult := CloseTxt(G^.MakroFile);
        for i := 9 to 15 do G^.Fstr[i] := '';
        G^.Fstr[11] := B1 + Hstr + DP + InfoZeile(156);
        G^.Fstr[13] := B1 + InfoZeile(188);
        Fenster(15);
        SetzeCursor(length(G^.Fstr[13]) + 1,13);
        Alarm;
        _ReadKey(KC,VC);
        Cursor_aus;
        VC := UpCase(VC);
        if (VC in YesMenge) or (KC = _Ret) then
        begin
          if RewriteTxt(G^.MakroFile) = 0 then Flag := true
                                          else Triller;
        end else if KC <> _Esc then
        begin
          if AppendTxt(G^.MakroFile) = 0 then Flag := true
                                         else Triller;
        end;
      end else
      begin
        if RewriteTxt(G^.MakroFile) = 0 then Flag := true
                                        else Triller;
      end;

      if Flag then
      begin
        G^.MakroZeile := '';
        G^.MakroLearn := true;
        G^.MakroReturn := true;
      end;
    end;
  end else
  begin
    G^.MakroLearn := false;
    if G^.MakroZeile > '' then Writeln(G^.MakroFile,G^.MakroZeile);
    FiResult := CloseTxt(G^.MakroFile);
    G^.MakroZeile := '';
  end;
  ClrFenster;
  SetzeFlags(show);
  Neu_Bild;
End;
