{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P C O L .  P A S                                                     ³
 ³                                                                         ³
 ³ Routinen fr die Farbeinstellung                                        ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Color_Einstellung;
Const xb   = 5;
      ya   = 5;
      lp   = '²' + Chr(16);
      rp   = Chr(17) + '²';
      Cstr = 'Color-Nr = ';
      Zstr = 'Zeile: ';

Type  ColPtr = Array[1..maxAttr] of String[70];

Var   Old_Attrib,
      i,yb,ym,yl : Byte;
      ch         : Char;
      KC         : Sondertaste;
      Merker,
      Flag       : Boolean;
      Hstr       : String[3];
      ADoc       : ^ColPtr;

  Procedure Attrib_Read(Art : Byte);
  Var  i,i1 : Byte;
  Begin
    FiResult := ResetTxt(G^.TFile);
    i1 := ya;
    for i := 1 to maxAttr do
    begin
      Readln(G^.TFile,DZeile);
      ADoc^[i] := EFillStr(70,B1,B2 + RestStr(DZeile));
      if Art = 1 then Attrib[i] := Byte(str_int(CutStr(DZeile)));
      if i1 <= ym then
      begin
        WriteRam(xb,i1,Attrib[i],0,ADoc^[i]);
        inc(i1);
      end;
    end;
    Readln(G^.TFile,DZeile);
    HighCol := Byte(str_int(copy(DZeile,1,1))) = 1;
    ColorItensity(HighCol);
    FiResult := CloseTxt(G^.TFile);
  End;

  Procedure KillPfeil;
  Begin
    WriteRam(xb-2,yb,15,0,B2);
    WriteRam(xb+70,yb,15,0,B2);
  End;

Begin
  Assign(G^.TFile,Sys1Pfad + AttrDatei + LngExt);
  flag := false;
  Merker := true;
  Neu_Bild;
  Teil_Bild_Loesch(1,maxZ,0);
  GetMem(ADoc,SizeOf(ADoc^));
  FillChar(ADoc^,SizeOf(ADoc^),0);

  i := length(InfoZeile(33));
  WriteRam(40-i div 2,1,15,0,InfoZeile(33));
  WriteRam(40-i div 2,2,15,0,ConstStr('-',i));

  ym := maxZ - 5;
  yb := ya;
  yl := 1;

  Attrib_Read(0);

  WriteRam(xb,maxZ-1,15,0,InfoZeile(22));
  WriteRam(xb,maxZ,15,0,InfoZeile(23));

  Repeat
    if Merker then Old_Attrib := Attrib[yl];
    WriteRam(xb,maxZ-3,15,0,Cstr +
      EFillStr(4,B1,int_str(Attrib[yl])) +
      EFillStr(8,B1,'(' + int_str(Old_Attrib) + ')') +
      EFillStr(length(Zstr)+3,B1,Zstr + int_str(yl)));
    WriteRam(xb,yb,Attrib[yl],0,ADoc^[yl]);
    WriteRam(xb-2,yb,15,0,lp);
    WriteRam(xb+70,yb,15,0,rp);

    _ReadKey(KC,ch);
    case KC of
     _Ret,
     _Esc :;

    _AltH : XP_Help(G^.OHelp[6]);

      _Up : if (yl > 1) then
            begin
              KillPfeil;
              dec(yl);
              if yb > ya then dec(yb) else Scroll(Dn,0,ya,ym);
            end else Alarm;

      _Dn : if (yl < maxAttr) then
            begin
              KillPfeil;
              inc(yl);
              if yb < ym then inc(yb) else Scroll(Up,0,ya,ym);
            end else Alarm;

      _F1 : begin
              yl := 1;
              yb := ya;
              Teil_Bild_Loesch(ya,ym,0);
              Attrib_Read(1);
              Flag := false;
            end;

   _Right : if Attrib[yl] < 255 then inc(Attrib[yl]);

   _Left  : if Attrib[yl] > 0   then dec(Attrib[yl]);

      _F5 : if Attrib[yl] >= 16 then dec(Attrib[yl],16);

      _F6 : if Attrib[yl] <= 239 then inc(Attrib[yl],16);

      _F7 : begin
              dec(Attrib[yl]);
              if (Attrib[yl]+1) mod 16 = 0 then inc(Attrib[yl],16);
            end;

      _F8 : begin
              inc(Attrib[yl]);
              if Attrib[yl] mod 16 = 0 then dec(Attrib[yl],16);
            end;

      _F9 : begin
              HighCol := not HighCol;
              ColorItensity(HighCol);
            end;

     _F10 : if Attrib[yl] > 127 then Attrib[yl] := Attrib[yl] - 128
                                else Attrib[yl] := Attrib[yl] + 128;

  _Andere : if ch in ['0'..'9'] then
            begin
              Hstr := ch;
              GetString(Hstr,15,3,xb+length(Cstr),maxZ-3,KC,3,Ins);
              if KC <> _Esc then
              begin
                Attrib[yl] := Byte(str_int(Hstr));
                Flag := true;
              end;
              KC := _Nix;
            end else Alarm;
       else Alarm;
    end;

    Merker := not(KC in [_F5.._F10,_Right,_Left]);
    if (KC in [_F5.._F10,_Right,_Left]) then Flag := true;
  Until KC in [_Esc,_Ret];

  if Flag then
  begin
    Teil_Bild_Loesch(ym+1,maxZ,0);
    WriteRam(xb,maxZ-1,15,0,InfoZeile(34));
    _ReadKey(KC,ch);
    
    if (UpCase(ch) in YesMenge) or (KC in [_Ret]) then
    begin
      FiResult := RewriteTxt(G^.TFile);
      for i := 1 to maxAttr do
        Writeln(G^.TFile,EFillStr(3,B1,int_str(Attrib[i])) + ADoc^[i]);
      if HighCol then i := 1
                 else i := 0;
      Writeln(G^.TFile,i);
      FiResult := CloseTxt(G^.TFile);
    end;
    Cursor_aus;
  end;

  FreeMem(ADoc,SizeOf(ADoc^));
  Neu_Bild;
End;
