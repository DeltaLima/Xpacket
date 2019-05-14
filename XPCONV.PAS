{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P C O N V .  P A S                                                   ³
 ³                                                                         ³
 ³ Routinen fr den Conversmode.                                           ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Conv_Tx_All (* Kanal : Byte *);
Var  i    : Byte;
Begin
  with K[Kanal]^ do
  begin
    for i := 1 to VorZeilen - VorCmdZeilen do if stTX[i] then
    begin
      ConversTX(Kanal,false,false,VorWrite[Kanal]^[i] + M1);
      inc(Conv.Count);
    end;
    ConversTX(Kanal,true,false,'');
    Conv.Count := 0;
  end;
End;


Procedure ConversTX (* Kanal : Byte; All,Head : Boolean; Zeile : String *);
Const   ML = 8;
        MZ = 71;

Var   i,i1    : Byte;
      Flag    : Boolean;
      CallStr : String[20];
      Bstr,
      Hstr    : String;

  Procedure Send_Blanks(Kanal : Byte);
  Begin
    with K[Kanal]^ do
    begin
      if not Flag and (Conv.LLen = 0) then
      begin
        if Kanal = ConvHilfsPort then _aus(Attrib[18],Kanal,ConstStr(B1,ML))
                                 else S_PAC(Kanal,NU,false,ConstStr(B1,ML));
      end;
      Flag := false;
    end;
  End;

Begin
  with K[Kanal]^ do if Conv.Active then
  begin
    CallStr := ConversCall(Kanal);

    for i := 1 to maxLink do with K[i]^ do
    begin
      if (i <> Kanal) and Conv.Active and (Zeile > '') and
         (K[Kanal]^.Conv.Chan = Conv.Chan) then
      begin
        Flag := false;
        if (K[Kanal]^.Conv.Count = 0) and
           ((K[Kanal]^.Call <> Conv.LCall) or not Conv.NoCHead or Head) then
        begin
          if i = ConvHilfsPort then _aus(Attrib[18],i,CallStr)
                               else S_PAC(i,NU,false,CallStr);
          Flag := true;
        end;

        Bstr := Line_convert(i,1,Zeile);
        KillStartBlanks(Bstr);
        KillEndBlanks(Bstr);
        While pos(M1,Bstr) > 0 do Bstr[pos(M1,Bstr)] := B1;

        While Bstr > '' do
        begin
          if (length(Bstr) + Conv.LLen) > MZ then
          begin
            Hstr := copy(Bstr,1,MZ-Conv.LLen);
            KillEndBlanks(Hstr);
            if ((length(Hstr)+Conv.LLen) = MZ) and
               (copy(Bstr,MZ-Conv.LLen+1,1) <> B1) and
               (pos(B1,Hstr) > 0) then
            begin
              i1 := length(Hstr);
              While Hstr[i1] <> B1 do dec(i1);
              Send_Blanks(i);
              if i = ConvHilfsPort
                then _aus(Attrib[18],i,copy(Bstr,1,i1-1) + M1)
                else S_PAC(i,NU,false,copy(Bstr,1,i1-1) + M1);
              Conv.LLen := 0;
              delete(Bstr,1,i1);
              KillStartBlanks(Bstr);
            end else
            begin
              Send_Blanks(i);
              if i = ConvHilfsPort
                then _aus(Attrib[18],i,Hstr + M1)
                else S_PAC(i,NU,false,Hstr + M1);
              Conv.LLen := 0;
              delete(Bstr,1,length(Hstr));
              KillStartBlanks(Bstr);
            end;
          end else
          begin
            Send_Blanks(i);
            if i = ConvHilfsPort
                then _aus(Attrib[18],i,Bstr)
                else S_PAC(i,NU,false,Bstr);
            Conv.LLen := Conv.LLen + length(Bstr);
            Bstr := '';
          end;
        end;
      end;

      if All then
      begin
        if i = ConvHilfsPort then
        begin
          if not RxLRet then _aus(Attrib[18],i,M1);
          if Conv.Ret then _aus(Attrib[18],i,M1);
        end else
        begin
          if not TxLRet then S_PAC(i,NU,false,M1);
          if Conv.Ret then S_PAC(i,NU,false,M1);
          S_PAC(i,NU,true,'');
        end;
        Conv.LLen := 0;
      end;

      Conv.LCall := K[Kanal]^.Call;
    end;
  end;
End;


Procedure ConversUser (* Kanal : Byte *);
Var    i    : Byte;
       Hstr : String;
       Bstr : String[20];
Begin
  S_PAC(Kanal,NU,false,Plus + InfoZeile(314) + M1);
  Hstr := '';
  for i := 1 to maxLink do with K[i]^ do
  begin
    if Conv.Active then
    begin
      if i = ConvHilfsPort then Bstr := OwnCall + '=SYSOP'
                           else Bstr := Call;
      Bstr := '(' + int_str(Conv.Chan) + ')-' + Bstr + B1;
      if length(Hstr) > 65 then
      begin
        KillEndBlanks(Hstr);
        S_PAC(Kanal,NU,false,Hstr + M1);
        Hstr := '';
      end;
      Hstr := Hstr + Bstr;
    end;
  end;
  KillEndBlanks(Hstr);
  S_PAC(Kanal,NU,true,Hstr + M2);
End;


Procedure ConversRemote (* Kanal : Byte; Zeile : String *);
Var   i,ic,afu    : Byte;
      CoFlag,
      Flag : Boolean;
      Rstr : String[2];
      Cstr,
      Vstr,
      Hstr,
      Bstr : String[6];

  Procedure CHeader(Kanal : Byte);
  Begin
    with K[Kanal]^ do
    begin
      Cstr := OwnCall;
      Strip(Cstr);
      if Conv.Ret then Rstr := M2
                  else Rstr := M1;
    end;
  End;

Begin
  with K[Kanal]^ do
  begin
    delete(Zeile,1,1);
    Vstr := UpCaseStr(CutStr(Zeile));
    Zeile := RestStr(Zeile);

    if (Vstr = 'Q') or (Vstr = 'D') then
    begin
      ConversTX(Kanal,true,true,Plus + InfoZeile(244) + M1);
      ConversIni(Kanal,false);
      if Vstr = 'D' then S_PAC(Kanal,CM,true,'D')
                    else Send_Prompt(Kanal,FF);
    end else

    if Vstr = 'C' then
    begin
      CHeader(Kanal);
      i := Byte(str_int(Zeile));
      if i in [1..99] then
      begin
       CoFlag:=false;
       ic:=0;
       Afu:=Conv.AfuStatus;
       while not CoFlag do
        begin
        inc(ic);
         if ic=maxlink then CoFlag:=true;
         if (K[ic]^.Conv.Active) and (K[ic]^.Conv.Chan = i) then
          begin
           CoFlag:=true;
           Afu:=K[ic]^.Conv.AfuStatus;
          end;
        end;
       if Afu=Conv.AfuStatus then
       begin
        S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                            InfoZeile(248) + B1 + int_str(i) + Rstr);
        ConversTX(Kanal,true,true,Plus + InfoZeile(247) + B1 + int_str(i) + M1);
        Conv.Chan := i;
        ConversTX(Kanal,true,true,Plus + InfoZeile(245) + M1);
       end else
       begin
        S_Pac(kanal,nu,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +InfoZeile(442)+m1);
       end;
      end else
      begin
        S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                            InfoZeile(249) + B1 + int_str(Conv.Chan) + Rstr);
      end;
    end else

    if Vstr = 'R' then
    begin
      Conv.Ret := not Conv.Ret;
      CHeader(Kanal);
      if Conv.Ret
       then S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr)+'*'+B1+Plus+InfoZeile(312) + M2)
       else S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr)+'*'+B1+Plus+InfoZeile(313) + M1)
    end else

    if Vstr = 'S' then
    begin
      Hstr := UpCaseStr(CutStr(Zeile));
      Strip(Hstr);
      Zeile := RestStr(Zeile);
      if Zeile > '' then
      begin
        i := 0;
        Repeat
          inc(i);
          if i = ConvHilfsPort then Bstr := K[i]^.OwnCall
                               else Bstr := K[i]^.Call;
          Strip(Bstr);
          Flag := (i <> Kanal) and K[i]^.Conv.Active and
                  (Hstr = Bstr) and (K[i]^.Conv.Chan = Conv.Chan);
        Until Flag or (i = maxLink);
        if Flag then
        begin
         if K[i]^.Conv.AfuStatus = Conv.AfuStatus then
         begin
          Hstr := Call;
          Strip(Hstr);
          if i = ConvHilfsPort then
          begin
            _aus(Attrib[18],i,EFillStr(6,B1,Hstr) + '*' + B1 + Zeile + M1);
            if K[i]^.Conv.Ret then _aus(Attrib[18],i,M1);
            CHeader(Kanal);
            S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                                InfoZeile(242) + B1 + Hstr + Rstr);
          end else
          begin
            S_PAC(i,NU,false,EFillStr(6,B1,Hstr) + '*' + B1 + Zeile + M1);
            if K[i]^.Conv.Ret then S_PAC(i,NU,false,M1);
            S_PAC(i,NU,true,'');
            CHeader(Kanal);
            S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                                InfoZeile(242) + B1 + Hstr + Rstr);
          end;
         end else
          S_Pac(Kanal, NU, true, EFillStr(6,B1,Cstr) + '*' + B1 + Plus +infozeile(442));
        end else
        begin
          CHeader(Kanal);
          S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                              InfoZeile(50) + B1 + Hstr + Rstr);
        end;
      end;
    end else

    if (Vstr = 'H') or (Vstr = '?') then
    begin
      WishBuf := true;
      Send_Hilfe(Kanal,G^.OHelp[17]);
      S_PAC(Kanal,NU,true,'');
    end else

    if Vstr = 'U' then
    begin
      ConversUser(Kanal);
    end else

    if Vstr = 'V' then
    begin
      CHeader(Kanal);
      Conv.NoCHead := not Conv.NoCHead;
      if Conv.NoCHead
       then S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr)+'*'+B1+Plus+InfoZeile(220) + Rstr)
       else S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr)+'*'+B1+Plus+InfoZeile(219) + Rstr);
    end else

    begin
      CHeader(Kanal);
      S_PAC(Kanal,NU,true,EFillStr(6,B1,Cstr) + '*' + B1 + Plus +
                          InfoZeile(280) + B1 + '/' + Vstr + Rstr);
    end;

    Conv.LCall := '';
  end;
End;


Function ConversIni (* Kanal : Byte; INI : Boolean *);
var ic, AfuCSt : Byte;
coflag:boolean;
Begin
 COFlag:=False;
  with K[Kanal]^ do
  begin
    if INI then
    begin
    if TNC[TNCNummer]^.AfuPort then AfuCSt:=1 else AfuCSt:=2;

{if (kanal=25) or (kanal=24) then AfucSt:=1; NUR FšR TESTS!!}

    if Conv.AfuStatus=0 then Conv.AfuStatus:=AfuCSt;

 

     ic:=0;
     COFlag:=false;

     while not coflag do
      begin
      inc(ic);
      if ic=MaxLink then COFlag:=True;
       if (K[ic]^.Conv.Active) and (K[ic]^.Conv.Chan=Conv.Chan) then
        begin
         AfuCSt:=K[ic]^.Conv.AfuStatus;
         COFlag:=true;
        end;
      end;

     COFlag:=False;

     if Conv.AfuStatus=AfuCSt then
     begin
      Kanal_Benutz := true;
      COFlag:=true;
      with Conv do
      begin
        Active := true;
        Ret := false;
        NoCHead := false;
        LCall := '';
      end;
     end else Conv.Fehler:=InfoZeile(442); {Conv.AfuStatus}
    end else
    begin
      FillChar(Conv,SizeOf(Conv),0);
      Kanal_Benutz := false;
      COFlag:=true;
    end;
  end;
  ConversIni:=COFlag;
End;


Procedure ConversAuswert (* Kanal,Nr : Byte *);
Const  SYSOP = '(Sysop)';
Var   i : Byte;
Begin
  with K[Kanal]^ do
  begin
    if ConvHilfsPort > 0 then
    begin
      i := ConvHilfsPort;
      ConversTX(i,true,true,Plus + InfoZeile(244) + B1 + SYSOP + M1);
      S_PAC(i,CM,true,'I ' + K[i]^.OwnCall);
      ConversIni(i,false);
      ConvHilfsPort := 0;
      InfoOut(Kanal,0,T,InfoZeile(258));
    end else
    begin
      i := KanalFrei(0);
      if Nr in [1..99] then
      begin
        if i <> 0 then
        begin
          ConvHilfsPort := i;
          S_PAC(i,CM,true,'I ' + PhantasieCall);
          K[i]^.Conv.Chan := Nr;
          ConversIni(i,true);
          InfoOut(show,0,T,InfoZeile(259) + B1 + '(Port' + B1 + int_str(i) + ')');
          ConversTX(i,true,true,Plus + InfoZeile(245) + B1 + SYSOP + M1);
        end else InfoOut(Kanal,T,T,InfoZeile(94));
      end else InfoOut(Kanal,T,T,InfoZeile(281));
    end;
  end;
End;


Function ConversCall (* (Kanal : Byte)  : Str20 *);
Var   Hstr : String[6];
Begin
  with K[Kanal]^ do
  begin
    if Kanal = ConvHilfsPort then Hstr := OwnCall
                             else Hstr := Call;
    Strip(Hstr);
    ConversCall := EFillStr(6,B1,Hstr) + DP + B1;
  end;
End;


Procedure ConversQuit (* Kanal : Byte *);
Begin
  ConversTX(Kanal,true,true,Plus + InfoZeile(244) + M1);
  ConversIni(Kanal,false);
End;
