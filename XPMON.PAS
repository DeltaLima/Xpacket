{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P M O N . P A S                                                      ³
 ³                                                                         ³
 ³ Routinen fr das Monitoren auf einem QSO-Kanal                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Stat_MonitorCalls (* Kanal : Byte *);
Var  Ch : Char;
Begin
  with K[Kanal]^ do
  begin
    with Mo do
    begin
      if MonActive then
      begin
        if MonBeide then Ch := #29 else Ch := #26;
        StatusOut(Kanal,2,2,Attrib[25],EFillStr(19,B1,CutStr(MonStr[1]) +
                                    Ch + RestStr(RestStr(MonStr[1]))),1);
      end else StatusOut(Kanal,14,1,Attrib[9],ConstStr(B1,19),1);
    end;
    StatusOut(Kanal,4,1,Attrib[9],EFillStr(9,B1,OwnCall),1);
    Status2;
  end;
End;


Procedure Calls_Monitoren (* Kanal : Byte; Zeile : Str80 *);
Const  ArtMax = 11;

Var    i,i1,
       X,Y,
       Art,
       aktiv : Byte;
       Flag,
       ZFlag,
       DisAbr,
       Beide,
       HCall,
       EHCall,
       Strict,
       Signal,
       IFr,UFr  : Boolean;
       Hstr     : String[19];
       KC       : Sondertaste;
       VC       : Char;

  Procedure InitKanal(Kanal : Byte);
  Begin
    with K[Kanal]^.Mo do
    begin
      DisAbr := MonDisAbr;
      Beide  := MonBeide;
      Strict := MonStrict;
      HCall  := MonHCall;
      EHCall := MonEHCall;
      Signal := MonSignal;
      IFr    := MonIFr;
      UFr    := MonUFr;
    end;
  End;

  Procedure Ins_Auswert(Istr : Str20);
  Var Flag : Boolean;
  Begin
    Flag := pos(B1,Zeile) = 0;
    DisAbr := not Flag;
    Beide := true;
    HCall := true;
    EHCall := true;
    Strict := not Flag;
    Signal := true;
    IFr := true;
    UFr := false;
  End;

Begin
  with K[Kanal]^ do
  begin
    InitKanal(Kanal);
    KillEndBlanks(Zeile);
    ZFlag := Zeile > '';

    if not Mo.MonActive then
    begin
      if (Zeile > '') then Ins_Auswert(Zeile);
    end else
    begin
      Zeile := CutStr(Mo.MonStr[1]) + B1 + CutStr(Mo.MonStr[2]);
      KillEndBlanks(Zeile);
    end;

    for i := 9 to 15 do G^.Fstx[i] := 2;
    G^.Fstr[7]  := InfoZeile(304);
    G^.Fstr[9]  := InfoZeile(305);
    G^.Fstr[10] := InfoZeile(306);
    G^.Fstr[11] := InfoZeile(307);
    G^.Fstr[12] := InfoZeile(308) + B1 + Zeile;
    G^.Fstr[13] := InfoZeile(309);
    G^.Fstr[14] := InfoZeile(310);
    G^.Fstr[15] := InfoZeile(311);

    Flag := false;

    if ZFlag and not Mo.MonActive then Art := 8 else
     if not ZFlag and Mo.MonActive then Art := 10 else
      if not ZFlag then Art := 11
                   else Art := 1;

    Repeat
      for i := 9 to 15 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][hM+1] := B1;
        G^.Fstr[i][vM] := B1;
        G^.Fstr[i][hM] := B1;
      end;

      if Art in [1..7] then
      begin
        X := vM;
        Y := Art + 8;
      end else
      begin
        X := hM;
        Y := Art + 1;
      end;

      G^.Fstr[Y][X] := A_ch;
      if HardCur then SetzeCursor(X+1,Y);

      if DisAbr then  G^.Fstr[9][vM+1] := X_ch;
      if Beide  then G^.Fstr[10][vM+1] := X_ch;
      if HCall  then G^.Fstr[11][vM+1] := X_ch;
      if EHCall then G^.Fstr[12][vM+1] := X_ch;
      if Strict then G^.Fstr[13][vM+1] := X_ch;
      if IFr    then G^.Fstr[14][vM+1] := X_ch;
      if Signal then G^.Fstr[15][vM+1] := X_ch;
      if Zeile > '' then G^.Fstr[12][hM+1] := X_ch;

      aktiv := 0;
      if Zeile > '' then
      begin
        for i := 1 to maxLink do with K[i]^.Mo do
        begin
          if MonActive and (i <> Kanal) and
            ((Zeile = (CutStr(MonStr[1]) + B1 + CutStr(MonStr[2]))) or
             (Zeile = (CutStr(MonStr[2]) + B1 + CutStr(MonStr[1])))) then
          aktiv := i;
        end;
      end;

      if aktiv > 0 then
      begin
        delete(G^.Fstr[13],hM,2);
        insert(SFillStr(2,B1,int_str(aktiv)),G^.Fstr[13],hM);
      end;

      Fenster(15);

      _ReadKey(KC,VC);
       Case KC of
         _Esc : Flag := true;
         _Ret :;

          _F1 : Art := 1;
          _F2 : Art := 2;
          _F3 : Art := 3;
          _F4 : Art := 4;
          _F5 : Art := 5;
          _F6 : Art := 6;
          _F7 : Art := 7;
         _Back: Art := 8;
         _End : Art := 9;
         _Del : Art := 10;
         _Ins : Art := 11;

        _AltH : XP_Help(G^.OHelp[10]);

          _Up : if Art > 1  then dec(Art)
                            else Alarm;

          _Dn : if Art < ArtMax then inc(Art)
                                else Alarm;
       _Right : if Art < ArtMax  then
                begin
                  Art := Art + 7;
                  if Art > ArtMax then Art := ArtMax;
                end else Alarm;

        _Left : if Art > 1 then
                begin
                  if Art <= 7 then Art := 1
                              else Art := Art - 7;
                end else Alarm;


      _Andere : case VC of
                  B1:;
                  else Alarm;
                end;

          else Alarm;
       End;

      if (KC in [_F1.._F7,_Ret,_End,_Back,_Del,_Ins]) or
         ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : DisAbr := not DisAbr;
        2 : Beide := not Beide;
        3 : HCall := not HCall;
        4 : begin
              EHCall := not EHCall;
              if EHCall then HCall := true;
            end;
        5 : Strict := not Strict;
        6 : begin
              IFr := not IFr;
              UFr := not IFr;
              if UFr then
              begin
                DisAbr := false;
                Strict := false;
              end;
            end;
        7 : Signal := not Signal;
        8 : begin
              if Zeile > '' then with Mo do
              begin
                Init_Call_Monitoren(Kanal,Zeile);
                MonDisAbr := DisAbr;
                MonBeide := Beide;
                MonHCall := HCall;
                MonEHCall := EHCall;
                MonStrict := Strict;
                MonSignal := Signal;
                MonIFr := IFr;
                MonUFr := UFr;
                Flag := true;
              end else Alarm;
            end;
        9 : begin
              if Mo.MonActive then for i := 1 to 2 do with Mo do
              begin
                MonFrameNr[i] := 0;
                MonFirst[i] := true;
                MonLast := '';
                for i1 := 0 to 7 do MonCtrl[i][i1] := 0;
              end else Alarm;
            end;
        10: begin
              Cancel_Call_Monitoren(Kanal);
              Flag := true;
            end;
        11: begin
              Hstr := Zeile;
              GetString(Hstr,Attrib[3],19,length(InfoZeile(308))+3,12,KC,0,Ins);
              if KC <> _Esc then
              begin
                Zeile := UpcaseStr(Hstr);
                KillEndBlanks(Zeile);
                G^.Fstr[12] := InfoZeile(308) + B1 + Zeile;
                if not ZFlag and not Mo.MonActive then Ins_Auswert(Zeile);
              end;
            end;
      end;
    Until Flag;

    Stat_MonitorCalls(Kanal);
  end;
  ClrFenster;
  Neu_Bild;
  
End;


Procedure Init_Call_monitoren (* Kanal : Byte; Zeile : Str80 *);
Var   i,i1 : Byte;
Begin
  with K[Kanal]^ do
  begin
    with Mo do
    begin
      KillEndBlanks(Zeile);

      MonStr[1] := CutStr(Zeile) + zu + RestStr(Zeile);
      KillEndBlanks(MonStr[1]);

      MonStr[2] := RestStr(Zeile) + zu + CutStr(Zeile);
      KillEndBlanks(MonStr[2]);

      for i := 1 to 2 do
      begin
        MonFrameNr[i] := 0;
        MonFirst[i] := true;
        for i1 := 0 to 7 do MonCtrl[i][i1] := 0;
      end;
      MonLast := '';
      MonActive := true;
    end;
    Mon_Anz := 0;
    for i := 1 to maxLink do if K[i]^.Mo.MonActive then inc(Mon_Anz);
    S_PAC(Kanal,CM,true,'I ' + PhantasieCall);
    Kanal_benutz := true;
    Stat_MonitorCalls(Kanal);
  end;
End;


Procedure Cancel_Call_monitoren (* Kanal : Byte *);
Var  i,i1 : Byte;
Begin
  with K[Kanal]^ do
  begin
    with Mo do
    begin
      MonActive := false;
      MonDisAbr := false;
      MonBeide := false;
      MonHCall := false;
      MonEHCall := false;
      MonStrict := false;
      MonSignal := false;
      for i := 1 to 2 do
      begin
        MonNow[i] := false;
        MonStr[i] := '';
        MonFrameNr[i] := 0;
        MonFirst[i] := false;
        for i1 := 0 to 7 do MonCtrl[i][i1] := 0;
      end;
      MonLast := '';
    end;
    if Mon_Anz > 0 then dec(Mon_Anz);
    S_PAC(Kanal,CM,true,'I '+ OwnCall);
    Kanal_benutz := false;
    TxComp := false;
    RxComp := false;
    SetzeFlags(Kanal);
    StatusOut(Kanal,2,2,Attrib[14],EFillStr(19,B1,' '),1);
    Stat_MonitorCalls(Kanal);
  end;
End;


Procedure FreeMonitorKanal (* Var KA : Byte; Zeile : Str80 *);
Var  Flag : Boolean;
     i    : Byte;
Begin
  Flag := false;
  i := 1;
  While (i <= maxLink) and not Flag do with K[i]^.Mo do
  begin
    if MonActive and (MonStr[1] = Zeile) then Flag := true
                                         else inc(i);
  end;
  if Flag then KA := i else KA := KanalFrei(0);
End;
