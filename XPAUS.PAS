{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P A U S .  P A S                                                     ≥
 ≥                                                                         ≥
 ≥ Routinen fÅr diverse Ausgaben. (Bildschirm, Morsezeichen ... usw.)      ≥
 ≥ Desweiteren Speicherung der Backsrolltexte.                             ≥
 ≥                                                                         ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}


Procedure Scroll (* Art : str2; Aufruf,Y1,Y2 : Byte *);  (* Video-Ram scrollen *)
Var       i  : Byte;
Begin
  if not ((Aufruf = 0) and BackScroll(show)) then
  begin
    if Art = Up then    { AufwÑrts scrollen }
    begin
      if ScrollVor or not NowFenster or ((Y2 = maxZ) and (show > 0)) then
         move(Bild^[Y1*160+1],Bild^[((Y1-1)*160)+1],(Y2-Y1)*160) else
      begin
        for i := 0 to 2 do  { nur links und rechts vom Fenster wird gescrollt }
        begin
          move(Bild^[(Y1+i)*160+1],Bild^[((Y1-1+i)*160)+1],(XL-1)*2);
          move(Bild^[(Y1+i)*160+1+2*(XR-1)],Bild^[((Y1-1+i)*160)+1+2*(XR-1)],(81-XR)*2);
        end;  { Unter dem Fenster werden wieder alle Zeilen komplett gescrollt }
        if Y2-Y1-3 > 0 then
         move(Bild^[(Y1+3)*160+1],Bild^[((Y1+2)*160)+1],(Y2-Y1-3)*160);
      end;                                                   { AbwÑrts scrollen }
    end else move(Bild^[((Y1-1)*160)+1],Bild^[(Y1)*160+1],(Y2-Y1)*160);
    ScrollVor := false;
  end;
End;


Procedure _aus (* Attr,Kanal : Byte; Zeile : String *);
Var  i,X2M   : Byte;
     ch      : Char;
     Aktuell : Boolean;
     Hstr    : String[80];
     hstr2   : string;

Begin
  Aktuell := (Kanal = show) and not BackScroll(Kanal);

  with K[Kanal]^ do
  Begin
    While pos(^J,Zeile) > 0 do delete(Zeile,pos(^J,Zeile),1);

{    if kanal>0 then
     while pos(chr(9), zeile) do
      begin
       i:=pos(chr(9), zeile);
      end;}  {while}

    Hstr := '';
    X2M := X2;
      if Save and not RX_Save then Write_SFile(Kanal,Zeile);
      if Drucker then Write_Drucker(Kanal,Zeile);
     Zeile := Line_Convert(Kanal,2,Zeile);

    if (pos(^G,Zeile) > 0) and
       not(Ignore or RX_Save or EigFlag or RemFlag or FileFlag or Mo.MonActive) and
       TNC_ReadOut and CtrlBeep then Beep(G^.CTRL_G_Freq,G^.CTRL_G_Time);

    if Rx_Beep and Aktuell and Klingel then
    begin
      LockIntFlag(0);
      Beep(G^.RxPiepFreq,G^.RxPiepTime);
      LockIntFlag(1);
    end;

    for i := 1 to ord(Zeile[0]) do
    begin
      ch := Zeile[i];
      if ch = #0 then ch := #255;
      if RxLRet then
      begin
        if (X2 > 80) and (ch = M1) then ch := ^J;
        Write_Notstr(Kanal,M1);
        Write_Notstr(Kanal,chr(ChAttr(Attr)));

        if Aktuell then
        begin
          if Hstr > '' then
            if BiosOut then WriteBios(Kanal,X2M,QEnd,Attr,0,Hstr)
                       else WritePage(Kanal,X2M,QEnd,Attr,0,Hstr);
          Scroll(Up,0,QBeg,QEnd);
          WriteRam(1,QEnd,Attr,0,G^.Leer);
        end;

        if (NeueZeilen < N999) then inc(NeueZeilen);

        Hstr := '';
        X2M := 1;
        X2 := 1;
      end;

      RxLRet := false;

      if ch = M1 then RxLRet := true else
      if ch <> ^J then
      begin
        Write_Notstr(Kanal,ch);
        Hstr := Hstr + ch;
        inc(X2);
        if X2 > 80 then RxLRet := true;
      end;
    end; (* for i := ... *)

    Write_Notiz(Kanal);
    if (Hstr > '') and Aktuell then
            if BiosOut then WriteBios(Kanal,X2M,QEnd,Attr,0,Hstr)
                       else WritePage(Kanal,X2M,QEnd,Attr,0,Hstr);
  End;
End;

Function CallInBox(Box, Such:str9) : boolean;
var cib:boolean;
    ci:byte;
begin
 cib:=false;
{ for ci:=1 to maxMailFrames do
  begin
   if (Mail[ci].BoxCall=Box) and (UpcaseStr(Such)=Mail[ci].ZielCall) then Cib:=true;
  end;}
  CallInBox:=cib;
end;

Procedure M_aus (* Attr : Byte; Zeile : String ; Kanal : Byte *);
Var  mfs,mfsc,i,j,ij,mc,X2M : Byte;
     ch         : Char;
     Hstr       : String[80];
     MFlaggi,
     Flag,
     Output,
     PlenOn,
     Aktuell    : Boolean;
     MailFrErk  : Boolean;
     MailZeile  : String;
     MailFlag   : Boolean;
     MailFTemp  : string;
     OCall      : str20;
     MailCalls  : string;

     HCall,hcall2, Box:str9;


Begin
  MailFrErk:=false;
  MailFlag:=false;

  Aktuell := show = 0;
  MailZeile:='';
  ij:=0;i:=0;mc:=0;
  mfs:=0;
  Output := ((K[show]^.UnStat < maxZ) or Aktuell) and not Backscroll(0);


  with K[0]^ do
  Begin
    if Save then Write_SFile(0,Zeile);
    if Drucker then Write_Drucker(0,Zeile);
    Zeile := Line_Convert(0,2,Zeile);

    Hstr := '';
    X2M := X2;
    Flag := false;

    for i := 1 to ord(Zeile[0]) do
    begin
      ch := Zeile[i];
      if ch = #0 then ch := #255;

      if RxLRet then
      begin                        {or (ch = ^J)}
        if (X2 > 80) and ((ch = M1)) or (ch = ^J) then Flag := true;
        Write_Notstr(0,M1);
        Write_Notstr(0,chr(ChAttr(Attr)));

        if Output then
        begin
          if Hstr > '' then WritePage(0,X2M,maxZ,Attr,1,Hstr);
          if Aktuell then Scroll(Up,0,UnStat+1,maxZ)
                     else Scroll(Up,1,K[show]^.UnStat+1,maxZ);
          WriteRam(1,maxZ,Attr,1,G^.Leer);
        end;

        if (NeueZeilen < N999) then inc(NeueZeilen);

        Hstr := '';
        X2 := 1;
        X2M := 1;
      end;

      RxLRet := false;
{          ch=^J or }
      if (ch = ^J) or (ch = M1) then
      begin
        if not Flag then RxLRet := true;
        if ZeigeRet and (ch = M1) then
        begin
          RxLRet := true;
          Write_Notstr(0,^J);
          Hstr := Hstr + ^J;
          inc(X2);
        end;
      end else if not Flag then
      begin
        Write_Notstr(0,ch);
        Hstr := Hstr + ch;
        inc(X2);
        if X2 > 80 then RxLRet := true;
      end;

      Flag := false;
    end;

    Write_Notiz(0);
    if (Hstr > '') and Output then WritePage(0,X2M,maxZ,Attr,1,Hstr);
  end;
End;


Procedure Write_Notiz;    (* Kanal : Integer *)
var    l    : Byte;
       i    : Word;
       i1   : Integer;
       Hstr : string;
Begin
  with K[Kanal]^ do
  begin
    l := ord(NZeile[0]);
    if use_EMS then EMS_Seite_einblenden(Kanal,Scr);
    if use_Vdisk then Open_Scroll(Kanal);
    if NotPos + l > (maxNotCh-1) then
    begin
      i1 := NotPos + l - (maxNotCh-1);
      if use_Vdisk then
      begin
        Hstr := copy(NZeile,1,(maxNotCh-1)-NotPos);
        BlockWrite(ScrollFile,Hstr[1],length(Hstr),i);
        delete(NZeile,1,(maxNotCh-1)-NotPos);
        Seek(ScrollFile,Pos_im_Scr);
        BlockWrite(ScrollFile,NZeile[1],length(NZeile),i);
      end else
      if use_XMS then
      begin
        Data_to_XMS(@NZeile[1],XMS_Handle,Pos_im_Scr+NotPos,(maxNotCh-1)-NotPos);
        Data_to_XMS(@NZeile[(maxNotCh-1)-NotPos+1],XMS_Handle,Pos_im_Scr,i1);
        NotPos := i1;
      end else
      begin
        move(NZeile[1],NotCh[Kanal]^[NotPos],(maxNotCh-1)-NotPos);
        move(NZeile[(maxNotCh-1)-NotPos+1],NotCh[Kanal]^[0],i1);
        NotPos := i1;
      end;
    end else
    begin
      if use_Vdisk then
      begin
        BlockWrite(ScrollFile,NZeile[1],l,i);
      end else if use_XMS then
      begin
        Data_to_XMS(@NZeile[1],XMS_Handle,Pos_im_Scr+NotPos,l);
        NotPos := NotPos + l;
      end else
      begin
        move(NZeile[1],NotCh[Kanal]^[NotPos],l);
        NotPos := NotPos + l;
      end;
    end;
    if use_Vdisk then Close_Scroll(Kanal);
    NZeile := '';
  end; { with }
End;

Procedure Write_Notstr (* Kanal : Byte; ch : char *);
Begin
  with K[Kanal]^ do
  begin
    if length(NZeile) >= 255 then Write_Notiz(Kanal);
    NZeile := NZeile + ch;
  end;
End;

Procedure Write_BoxStr (* Kanal,Art : Byte *);
var  HStr, Zstr      : String[40];
     Ach       : Char;
     i,lp      : Byte;
     Result    : Word;
     Nr        : LongInt;
     FBBAuswert,
     RubHeader,
     RunHeader,
     Checks,
     Lists     : Boolean;
Begin
  Checks := false;
  Lists := false;
  RubHeader := false;
  RunHeader := false;
  lp := 1;
  FillChar(G^.MlStr,SizeOf(G^.MlStr),0);
  Zstr := '';
  Ach := 'U';

  with K[Kanal]^ do
  begin
    if Art = 0 then
    begin
      if SCon[2] then   (* BBOX *)
      begin
        i := pos(') ',BoxStr);
        if (i > 0) and (i < 8) and (pos('(',BoxStr) <> 1) then BoxStr[i] := B1;

        i := pos('R ',BoxStr);
        if (i > 0) and (i < 8) and (str_int(copy(BoxStr,1,i-1)) > 0) then
        begin
          BoxStr[i] := B1;
          BoxStr[i+1] := 'r';
        end;

        i := pos('F ',BoxStr);
        if (i > 0) and (i < 8) and (str_int(copy(BoxStr,1,i-1)) > 0) then
        begin
          BoxStr[i] := B1;
          BoxStr[i+1] := 'f';
        end;

        i := pos('E ',BoxStr);
        if (i > 0) and (i < 8) and (str_int(copy(BoxStr,1,i-1)) > 0) then
        begin
          BoxStr[i] := B1;
          BoxStr[i+1] := 'e';
        end;
      end;

      for i := 1 to maxBlBox do
      begin
        G^.MlStr[i] := ParmStr(i,B1,BoxStr);
        if length(G^.MlStr[i]) > 0 then lp := i;
      end;
      Nr := LongInt(str_int(G^.MlStr[1]));

      if Nr > 0 then  (* Hier war die erste Sequenz eine Nummer *)
      begin

        {Check-Befehl auswerten}
        if SCon[1] or SCon[2] or SCon[14] then   (* DBOX oder BBOX oder TBOX im Connect *)
        begin
          if (G^.MlStr[3] = '>') and (copy(G^.MlStr[5],3,1) = Pkt ) and
             (copy(G^.MlStr[5],6,1) = Pkt ) then
          begin
            Checks := true;
            Ach := 'C';
            Rubrik := copy(G^.MlStr[4],1,8);
            i := pos(Pkt ,Rubrik);
            if i > 0 then Rubrik := copy(Rubrik,1,i-1);
            Rubrik := EFillStr(8,B1,Rubrik);
          end else if (copy(G^.MlStr[3],3,1) = Pkt ) and (copy(G^.MlStr[3],6,1) = Pkt ) and
                      (str_int(G^.MlStr[5]) > 0) then
                   begin
                     Lists := true;
                     Ach := 'L';
                   end;
        end;

        if SCon[3] then  (* FBOX *)
        begin {(pos('@',BoxStr) in [23..26])}
          FBBAuswert:=false;
          if FBBStreng then
          begin
          if (pos('/',BoxStr) in [42..46]) and
             (LongInt(str_int(copy(BoxStr,pos('/',Boxstr)+1,4))) > 0) and
             (LongInt(str_int(copy(BoxStr,pos('/',Boxstr)-4,4))) > 0)
            and ((LongInt(str_int(copy(BoxStr,13,5))) > 0)
             or (LongInt(str_int(copy(BoxStr,11,5))) > 0)) then FBBAuswert:=true;
          end else
           begin
            Hstr:=copy(BoxStr,1,6);
            KillEndBlanks(HSTR);
            nr:=str_int(hstr);
            if ( nr > 0) and (pos('@',BoxStr) > 6) then FBBAuswert:=true;
           end;
          if FBBAuswert then
          begin
            Checks := true;
            Ach := 'C';
            if pos('@',BoxStr)>0 then
             begin
              Rubrik := EFillStr(8,B1,copy(BoxStr,pos('@',BoxStr)-7,6));
              killStartBlanks(Rubrik);
             end
             else Rubrik := EFillStr(8,B1,' ')
          end;
        end;

        if SCon[4] then  (* WBOX *)
        begin
          if (pos('@',BoxStr) = 22) and
             (LongInt(str_int(G^.MlStr[2])) > 0) then
          begin
            Checks := true;
            Ach := 'C';
            Rubrik := EFillStr(8,B1,copy(BoxStr,14,8));
          end;
        end;

        if SCon[5] then  (* EBOX *)  (* Die EBOX ist nur eine lokale Box *)
        begin
          Zstr := UpCaseStr(G^.MlStr[8]);
          if (Word(str_int(G^.MlStr[2])) > 0) and
             (Word(str_int(G^.MlStr[7])) > 0) and
             ((Zstr = 'T') or (Zstr = 'D')) then
          begin
            Lists := true;
            Rubrik := ConstStr(B1,8);
            Ach := 'L';
          end;
        end;
      end else

      begin
        if SCon[1] or SCon[2] then   (* DBox + BBox *)
        begin
          if ((pos(G^.BinEL,BoxStr) = 1) or (pos(G^.TxtEL,BoxStr) = 1)) and
              (LongInt(str_int(G^.MlStr[3])) > 0) then
          begin
            BoxStr := EFillStr(45,B1,RunRub + G^.MlStr[2]) +
                      SFillStr(8,B1,G^.MlStr[3]) + B1 + OneByte + B1 +
                      copy(G^.MlStr[5],1,6) +
                      copy(G^.MlStr[5],9,2) + B1 +
                      copy(G^.MlStr[6],1,5) + B1 +
                      G^.MlStr[1];
            Ach := 'R';
            Lists := true;
          end else

          if ((pos(G^.BinEL,BoxStr) = 1) or (pos(G^.TxtEL,BoxStr) = 1)) and
              (LongInt(str_int(G^.MlStr[2])) > 0) then
          begin
            BoxStr := EFillStr(45,B1,G^.MlStr[5]) +
                      SFillStr(8,B1,G^.MlStr[2]) + B1 + OneByte + B1 +
                      EFillStr(15,B1,G^.MlStr[4]) +
                      G^.MlStr[1];
            Ach := 'R';
            Lists := true;
          end else

          if  (pos(G^.DirEL,BoxStr) = 1) and
              (copy(G^.MlStr[2],length(G^.MlStr[2]),1) = BS ) and
              (pos(Pkt ,G^.MlStr[4]) = 3) and
              (pos(DP,G^.MlStr[5]) = 3) then
          begin
            BoxStr := EFillStr(74,B1,RunRub + G^.MlStr[2]) + CutStr(BoxStr);
            Ach := 'V';
            Lists := true;
          end else

          if (copy(BoxStr,length(G^.MlStr[1]),1) = BS ) and
             (pos('Datei',G^.MlStr[3]) = 1) and
             (G^.MlStr[5] = OneByte) and
             (pos('Unterverzeichnis',G^.MlStr[7]) = 1) then
          begin
            BoxStr := EFillStr(40,B1,RunRub + CutStr(BoxStr)) +
                      SFillStr(3,B1,int_str(str_int(G^.MlStr[2]))) + B1 + Files + B1 +
                      SFillStr(8,B1,G^.MlStr[4]) + B1 + OneByte +
                      SFillStr(4,B1,int_str(str_int(G^.MlStr[6]))) + B1 + DIRs;
            Ach := 'V';
            Lists := true;
          end else

          if (copy(BoxStr,3,1) = Pkt ) and
             (copy(BoxStr,6,1) = Pkt ) and
             (copy(BoxStr,11,2) = '  ') and
             (pos(':\',G^.MlStr[2]) = 2) and
             (pos(B1,G^.MlStr[2]) = 0) then
          begin
            BoxStr := RestStr(BoxStr);
            Ach := 'V';
            Lists := true;
          end else

          if pos(G^.RunElFile,BoxStr) = 1 then
          begin
            { Dateien im Unterverzeichnis: D:\DISKTOOL\*.* }
            RunRub := G^.MlStr[lp];
            While (RunRub[0] > #0) and (RunRub[Ord(RunRub[0])] <> BS )
               do RunRub[0] := Chr(Ord(RunRub[0])-1);
            Rubrik := ConstStr(B1,8);
            RubHeader := true;
            RunHeader := true;
          end else

          if pos(G^.RunElDir,BoxStr) = 1 then
          begin
            { Unterverzeichnisse von: D:\*.* }
            RunRub := G^.MlStr[lp];
            While (RunRub[0] > #0) and (RunRub[Ord(RunRub[0])] <> BS )
               do RunRub[0] := Chr(Ord(RunRub[0])-1);
            Rubrik := ConstStr(B1,8);
            RubHeader := true;
            RunHeader := true;
          end else

          if pos(G^.RunElTree,BoxStr) = 1 then
          begin
            { Verzeichnisbaum fuer EL-Laufwerk/EL-Pfad: D:\EL\ }
            RunRub := G^.MlStr[lp];
            Rubrik := ConstStr(B1,8);
            RubHeader := true;
            RunHeader := true;
          end;
        end;

        { Check-Liste erkennen //db1ras }
        {     # Call     File     Nr.  Datum   @MBX   Bytes #LT Titel }
        {     # Absender Rubrik   Nr. Datum    @BBS   Bytes #LT Titel }
        {     ^                                ^            ^ wird geprueft }
        If (SCon[1] Or SCon[2]) And   { * DBOX * oder * BBOX * }
           (Length(BoxStr)>54) And (BoxStr[5]='#') And
           (BoxStr[38]='@') And (BoxStr[51]='#') Then Begin
           RubHeader := true;
           Rubrik := '';
        End;

        if SCon[1] then   (* DBox *)
        begin
          if (pos(G^.InfoDieBox,BoxStr) = 1) or (pos(G^.UserDieBox,BoxStr) = 1) or
             (pos(G^.RubrikStr,BoxStr)  = 1) then
          begin
            RubHeader := true;
            Rubrik := EFillStr(8,B1,RestStr(BoxStr));
          end;
        end;

        { Inhaltsverzeichnis fuer DF8MT @DB0GV: }
        { Inhaltsverzeichnis fuer COMPUTER/IBM: }
        if SCon[2] then  (* BBOX *)
        begin
          if pos(G^.InfoBayBox,BoxStr) = 1 then
          begin
            RubHeader := true;
            Zstr := G^.MlStr[3];
            While pos('/',Zstr) > 0 do delete(Zstr,1,pos('/',Zstr));
            While pos(DP,Zstr) > 0 do delete(Zstr,pos(DP ,Zstr),1);
            Rubrik := EFillStr(8,B1,Zstr);
          end;
        end;

        if SCon[5] then   (* EBOX *)
        begin
          if (pos(G^.EzFileStr,BoxStr) = 1) or (pos(G^.EzMsgStr,BoxStr) = 1) then
          begin
            RubHeader := true;
            Rubrik := ConstStr(B1,8);
          end;
        end;

        if SCon[14] then   (* TBOX *)
        begin
          Zstr := RestStr(BoxStr);
          if (pos(G^.InfoTnc3Box,BoxStr) = 1) and (Zstr[length(Zstr)] = DP) then
          begin
            delete(Zstr,length(Zstr),1);
            RubHeader := true;
            Rubrik := EFillStr(8,B1,Zstr);
          end;
        end;

        if RubHeader then
        begin
          if RunHeader then
            BoxStr := GPkt + B1 + Call + B1 + GPkt + B1 + copy(Datum,1,8)
                      + B1 + copy(Uhrzeit,1,5) + B1 + GPkt + B1  + RunRub
          else If Rubrik='' Then
            {Check-Liste //db1ras}
            BoxStr := GPkt + B1 + Call + B1 + GPkt + B1 + copy(Datum,1,8)
                      + B1 + copy(Uhrzeit,1,5) + B1 + GPkt + B1
                      + 'Check'
          else
            BoxStr := GPkt + B1 + Call + B1 + GPkt + B1 + copy(Datum,1,8)
                      + B1 + copy(Uhrzeit,1,5) + B1 + GPkt + B1
                      + G^.RubrikStr + Rubrik;

          KillEndBlanks(BoxStr);
          BoxStr := BoxStr + B1;
          if Ord(BoxStr[0]) > 80 then BoxStr[0] := Chr(80);
          BoxStr := EFillStr(79,GPkt,BoxStr) + B2;
          BoxStr[81] := Chr(Attrib[20]);
          Ach := 'R';
        end;
      end;
    end;

    if (Art = 1) or Checks or Lists or RubHeader then
    begin
      if length(BoxStr) < 80 then
           BoxStr := EFillStr(80,B1,BoxStr) + Chr(Attrib[18]);
      BoxStr := BoxStr + Ach + Chr(SysArt) + Rubrik;
      Seek(DBox,FSize);
      BlockWrite(DBox,BoxStr[1],1,Result);
      FSize := FilePos(DBox);
      inc(NewChkLst);
    end;
    FillChar(BoxStr,SizeOf(BoxStr),0);
  end;
 End;

Procedure Morse (* Kanal : Byte; Zeile : str80 *);
var    i,i1,i2 : Byte;
       VC      : char;
Begin
  for i := 1 to length(Zeile) do
  begin
    VC := UpCase(Zeile[i]);
    i1 := 1;
    LockIntFlag(0);
    While (i1 < maxMorAnz) and (Mchs[i1].Ze <> VC) do inc(i1);
    if Mchs[i1].Ze = VC then
    begin
      for i2 := 1 to length(Mchs[i1].Co) do
      begin
        case Mchs[i1].Co[i2] of
          Pkt  : Beep(G^.Tonhoehe,MPause);
          '-' : Beep(G^.Tonhoehe,3 * MPause);
        end;
        Verzoegern(MPause);
      end;
      Verzoegern(2 * MPause);
    end else
    if VC = B1 then Verzoegern(7 * MPause) else
    begin
      Sound_((G^.Tonhoehe div 3) * 2, Mpause div 14);
      Verzoegern(MPause);
    end;
    LockIntFlag(1);
  end;
End;

Function CompRate (Compri, DeCompri : Byte) : Byte;
var cra1:real;
begin
 if Compri=0 then Compri:=1;
 if DeCompri=0 then DeCompri:=1;
 cra1:=100 / Decompri;
 cra1:=cra1 * Compri;
 CompRate:=Round(Cra1);
end;



{ACHTUNG: FÅr offizielle Version nur zwischen den Marken einklammern!!!}
function CCoding (kanal : Byte; zeile:string) : string;
var i,j,l,x,y,z:byte;
hstr:string;
codcall:string;
const teiler=8;

begin
{FÅr offizielle Version hier Klammer AUF - bzw. Def-Schalter abwÅrgen}
{$IFDEF code}


codcall:=k[kanal]^.call;
strip(codcall);
if (codcall='KA1SH') or (codcall='DAB365') or (codcall='DKA777')
  or (codcall='DCW763') or (codcall='CW1MOB') then
  begin
  hstr:=zeile;
  zeile:='';

  for i:=1 to length(hstr) do Zeile:=zeile+hstr[length(hstr)-i+1];

  for i:=1 to length(zeile) do zeile[i]:=chr(ord(Zeile[i]) xor codierung[i]);
x:=length(zeile);
hstr:=zeile;
if x>teiler-1 then
 begin
  z:=x;
  y:=1;
  while z>teiler do
   begin
    inc(y);
    z:=x div y;
   end;
   x:=z div 2+1;
   i:=2; l:=1;
   while i<253 do
    begin
     if z=i then begin
      dec(x);
      l:=0;
     end;
     inc(i,2);
    end;

   zeile:='';
   {z=anzahl zeichen/gruppe, y=anzahl gruppen, x=mitte}
   for j:=1 to y do
    begin
    if length(hstr)>=z then
    begin
     for i:=1 to x do
      begin
       zeile:=zeile+hstr[z-i+1];
      end;
     for i:=1 to x-l do
      begin
       zeile:=zeile+hstr[i];
      end;
      delete(hstr,1,z);
     end;
    end;
     zeile:=hstr+zeile;
 end;



  end;
 {FÅr offizielle Version hier Klammer zu!}
{$ENDIF}

ccoding:=zeile;
end;



Function Compress (* Zeile : String, Kanal : Byte) : String *);
Var   Hs2, Hstr : String;
      t    : Word;
      s    : Word;
      i    : Byte;
      a    : Integer;
      b,c  : Byte;
      ch,ch2 : Char;
      long : Boolean;
      lang1,
      lang2,
      rate,
      diff : byte;
      s1:string;
Begin
 lang2:=length(zeile);
  hstr:='';

  FillChar(Hstr,SizeOf(Hstr),0);
  a := 7;
  b := 1;
  long := false;
  diff:=1;
  if K[Kanal]^.KompressUpd then
   begin
    Zeile:='';
    for i:=1 to 127 do
     Zeile:=Zeile+chr(K[Kanal]^.Kompression[i]);
   end;


 i := 0;
  While (i < length(Zeile)) and not long do
  begin
    inc(i);
    t := HTable[ord(Zeile[i])].Tab;
    s := $8000;
    C := 0;

    While (C < HTable[ord(Zeile[i])].Len) and not long do
    begin
      inc(C);
      if t and s = s then Hstr[b] := Chr(ord(Hstr[b]) + 1 shl a);
      s := s shr 1;
      dec(a);
      if a < 0 then
      begin
        a := 7;
        inc(b);
        if b > 254 then long := true;
      end;
    end;
    Hstr[0] := chr(b);
    {if hstr[length(hstr)]=#0 then hstr[0]:=chr(b-1);}
  end;



 {****************************** codierung *********}
{$IFDEF code}
   hstr:=ccoding(kanal, hstr);
{$ENDIF}

{*************************************}


 { if not K[Kanal]^.KompressUpd then
   begin}
    if (length(Hstr) > length(Zeile)) or long then
     begin
      Hstr := Zeile[0] + ccoding(kanal, Zeile);
      ch := #255;
      diff:=2;
     end else ch := Chr(length(Hstr));



     Hstr := ch + Hstr;
     ch2:=ch;
  {  end;}



   if (K[Kanal]^.CompC) and (not K[kanal]^.KompressUpd) then
   begin
    Hs2:='';
    for i := 3 to length(Hstr) do
     begin
      Hstr[i] := Chr(Ord(Hstr[i]) xor K[Kanal]^.Kompression[i]);
     end;
   end;

  if K[Kanal]^.KompressUpd then
   begin
    Hs2:='';
    for i := 3 to length(Hstr) do
     begin
      Hstr[i] := Chr(Ord(Hstr[i]) xor Comp_Key_Tab [I]);
     end;
    K[Kanal]^.KompressUpd:=false;
    k[kanal]^.FileSendWait:=k[kanal]^.fileSendWaitS;
   end;
  TestCom:=hstr;
  Compress:=Hstr;
  lang1:=length(hstr)-diff;
  rate:=CompRate(Lang1, Lang2);
  if rate>=100 then rate:=k[kanal]^.tXKompRate;
  k[kanal]^.tXKompRate:=rate;
  SetzeFlags(kanal);
End;

{$IFDEF code}
function CDECoding (kanal : Byte; zeile:string) : string;
var i,j,l,x,y,z:byte;
hstr:string;
codcall:string;
const teiler=8;
begin
codcall:=k[kanal]^.call;
strip(codcall);
if (codcall='KA1SH') or (codcall='DAB365') or (codcall='DKA777')
  or (codcall='DCW763') or (codcall='CW1MOB') then
  begin
    if not k[kanal]^.mo.monactive then
      begin
        hstr:=zeile;

x:=length(zeile);
if x>teiler-1 then
 begin
 zeile:='';
  z:=x;
  y:=1;
  while z>teiler do
   begin
    inc(y);
    z:=x div y;
   end;
   x:=x-(z*y);
   codcall:='';
   codcall:=copy(hstr,1,x);
   delete(hstr,1,x);
   hstr:=hstr+codcall;
   x:=z div 2+1;
   i:=2;
   l:=1;
   while i<253 do
    begin
     if z=i then
     begin
      dec(x);
      l:=0;
     end;
     inc(i,2);
    end;

   for j:=1 to y do
    begin
    if length(hstr)>=z then
    begin
     for i:=x-l downto 1 do
      begin
       zeile:=zeile+hstr[z-i+1];
      end;
     for i:=x downto 1 do
      begin
       zeile:=zeile+hstr[i];
      end;
      delete(hstr,1,z);
     end;

    end;
    hstr:=zeile+hstr;
end;

zeile:=hstr;
         for i:=1 to length(hstr) do zeile[i]:=chr(ord(Zeile[i]) xor codierung[i]);


        hstr:='';
         for i:=1 to length(zeile) do hstr:=hstr+zeile[length(zeile)-i+1];

        {hstr:=Zeile[1]+hstr;}

        zeile:=hstr;
      end;
  end;

cdecoding:=zeile;
end;

{$ENDIF}

Function DeCompress (* Zeile : String, Kanal : Byte) : String *);
Var   Hstr, Hstr2  : String;
      b,i,i1,l : Byte;
      a     : Integer;
      t,t2  : Word;
      Bit   : LongInt;
      ch    : Char;
      lang1,
      rate,
      lang2 : Byte;
      s2:string;

Begin
 lang1:=length(zeile)-1;


 Hstr:='';
 Hstr2:='';

 if kanal=0 then delete(Zeile, Length(Zeile),1);
 if K[Kanal]^.KompressUpd then
   begin
    for i := 3 to length(Zeile) do
     begin
      Zeile[i] := Chr(Ord(Zeile[i]) xor Comp_Key_Tab[I]);
     end;

   end else Hstr2:=Zeile;

 if (K[Kanal]^.CompC) and (not K[kanal]^.KompressUpd) then
   begin
    for i := 3 to length(Zeile) do
     begin
      Zeile[i] := Chr(Ord(Zeile[i]) xor K[Kanal]^.Kompression[I]);
     end;

   end else Hstr2:=Zeile;


  HStr:=''; i:=0;
  ch := Zeile[1];
  delete(Zeile,1,1);
  if ch = #255 then
   begin
    delete(Zeile,1,1);
    if lang1>0 then dec(lang1);
   end;

  {******************** DEcodierung ****************}
{$IFDEF code}
  zeile:=CDEcoding(kanal, zeile);
{$ENDIF}

  if (ch < #255) and (Zeile[0] > #0) then
  begin
    Hstr := '';
    l := 0;
    Bit := 0;

    for i := 1 to length(Zeile) do
    begin
      Bit := (Bit shl 8) or ord(Zeile[i]);
      l := Byte(l + 8);

      a := 0;

      Repeat
        b := HTable[a].Len;
        if l >= b then
        begin
          t  := HTable[a].Tab;
          t2 := Word(Bit shr (l-b)) shl (16-b);

          if t = t2 then
          begin
            Hstr := Hstr + chr(a);
            l := l - b;
            a := -1;
          end;
        end;
        inc(a);
      Until (a > 257) or (l < 3);
    end;
  end else Hstr := Zeile;

  if K[Kanal]^.KompressUpd then
   begin
    for i:=1 to length(Zeile) do
     begin
      inc(K[Kanal]^.CompCUpdZahl);
      K[Kanal]^.Kompression[K[Kanal]^.CompCUpdZahl]:=ord(Zeile[i]);
      if K[Kanal]^.CompCUpdZahl=127 then
       begin
        k[kanal]^.KompressUpd:=false;
        k[kanal]^.FileSendWait:=k[kanal]^.fileSendWaitS;
        For i1:=1 to 127 do
          k[kanal]^.Kompression[i1+127]:=k[kanal]^.Kompression[i1] xor Comp_Key_Tab[I1];
          k[kanal]^.Kompression[255]:=k[kanal]^.Kompression[1];
       end;
(*       if (K[Kanal]^.CompC) and (K[Kanal]^.Mo.MonActive) then
        begin
   {i!!!}      for i1:=1 to 255 do K[Kanal]^.Kompression[i1]:=238;
        end; *)
     end;

    zeile:='';
    Hstr:='';
   end;



  DeCompress := Hstr;
  lang2:=length(hstr);
  rate:=CompRate(Lang1, Lang2);
  if rate>=100 then rate:=k[kanal]^.RXKompRate;
  k[kanal]^.RXKompRate:=rate;
  setzeflags(kanal);
End;


Function SPCompress (* Zeile : String, Kanal : Byte) : String *);
Var   Hs2, Hstr : String;
      t    : Word;
      s    : Word;
      i    : Byte;
      a    : Integer;
      b,c  : Byte;
      ch,ch2 : Char;
      long : Boolean;
      lang1,
      lang2,
      rate,
      diff : byte;
Begin
 lang2:=length(zeile);
  FillChar(Hstr,SizeOf(Hstr),0);
  a := 7;
  b := 1;
  long := false;
  diff:=1;

 i := 0;
  While (i < length(Zeile)) and not long do
  begin
    inc(i);
    t := HTable[ord(Zeile[i])].Tab;
    s := $8000;
    C := 0;

    While (C < HTable[ord(Zeile[i])].Len) and not long do
    begin
      inc(C);
      if t and s = s then Hstr[b] := Chr(ord(Hstr[b]) + 1 shl a);
      s := s shr 1;
      dec(a);
      if a < 0 then
      begin
        a := 7;
        inc(b);
        if b > 254 then long := true;
      end;
    end;
     Hstr[0] := chr(b);
   {  if hstr[length(hstr)]=#0 then Hstr[0] := chr(b-1);}
   {mit dem fehlt das return einer zeile nach dekomp!}
  end;

    if (length(Hstr) > length(Zeile)) or long then
     begin
      Hstr := Zeile;
      ch := #255;
      (*diff:=2;*)
     end else
      begin
       ch := Chr(length(Zeile));
       {if zeile[length(zeile)]=#13 then }ch:=Chr(length(Zeile)-1)
      end;
     Hstr := ch + Hstr;
     ch2:=ch;

  TestCom:=hstr;
  SPCompress:=Hstr;
  lang1:=length(hstr)-diff;
  rate:=CompRate(Lang1, Lang2);
  if rate>=100 then rate:=k[kanal]^.tXKompRate;
  k[kanal]^.tXKompRate:=rate;
  SetzeFlags(kanal);
End;


Function SPDeCompress (* Zeile : String, Kanal : Byte) : String *);
Var   Hstr, Hstr2  : String;
      b,i,i1,l : Byte;
      a     : Integer;
      t,t2  : Word;
      Bit   : LongInt;
      ch    : Char;
      lang1,
      rate,
      lang2 : Byte;

Begin
 lang1:=length(zeile)-1;

 Hstr:='';
 Hstr2:='';
 if kanal=0 then delete(Zeile, Length(Zeile),1);
 Hstr2:=Zeile;

  HStr:=''; i:=0;
  if k[kanal]^.SPRxCount>=k[kanal]^.SPRxSoll then
   begin
    ch := Zeile[1];
    delete(Zeile,1,1);
    k[kanal]^.SPRXCount:=0;
    k[kanal]^.SPRxSOLL:=ord (CH);
   end;

  if (ch < #255) and (Zeile[0] > #0) then
  begin
    Hstr := '';
    l := 0;
    Bit := 0;

    for i := 1 to length(Zeile) do
    begin
      Bit := (Bit shl 8) or ord(Zeile[i]);
      l := Byte(l + 8);

      a := 0;

      Repeat
        b := HTable[a].Len;
        if l >= b then
        begin
          t  := HTable[a].Tab;
          t2 := Word(Bit shr (l-b)) shl (16-b);

          if t = t2 then
          begin
            Hstr := Hstr + chr(a);
            l := l - b;
            a := -1;
          end;
        end;
        inc(a);
      Until (a > 257) or (l < 3);
    end;
  end else Hstr := Zeile;

{   hstr[0]:=ch;}
  lang2:=length(hstr)-1;
  k[kanal]^.SPRXCount:=k[kanal]^.SPRXCount+length(hstr);
  if zeile[length(zeile)]=#13 then dec(lang2);
  {if ord(ch)<>lang2 then hstr:='!!COMP FAILED!!'+hstr;}
  SPDeCompress := Hstr;
  rate:=CompRate(Lang1, Lang2);
  if rate>=100 then rate:=k[kanal]^.RXKompRate;
  k[kanal]^.RXKompRate:=rate;
  setzeflags(kanal);
End;
