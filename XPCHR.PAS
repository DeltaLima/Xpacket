{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P C H R .  P A S                                                     ≥
 ≥                                                                         ≥
 ≥ Routinen fÅr den Vorschreib-Bildschirm                                  ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}




Procedure Chr_Darstell (* Kanal : Byte; KC : Sondertaste; VC : char *);
Begin
  if K[Kanal]^.Cmd then Chr_Cmd_Show(Kanal,KC,VC)
                   else Chr_Vor_Show(Kanal,KC,VC);
End;


Procedure Chr_Cmd_Show (* Kanal : Byte; KC : Sondertaste; VC : char *);
var  i,i1,
     XLV,XH,
     VAnz     : Byte;
     Neben,
     NeuPage  : Boolean;


 Begin
   with K[Kanal]^ do
   Begin
     if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);

     NeuPage := true;

     VAnz := VEnd - VBeg + 1;
     if VAnz > VorCmdZeilen then VAnz := VorCmdZeilen;

     XLV := length(VorWrite[Kanal]^[stC]);

     Case KC of
 _Andere : Case VC of
             #1..#7,#11,#12, #14..#19, #21..#24, #26..#31, #32..#254
              : if XLV < 79 then
                begin
                  NeuPage := false;
                  if Gross then VC := UpCase(VC);
                  if not insert_ON then delete(VorWrite[Kanal]^[stC],X1C,1);
                  insert(VC,VorWrite[Kanal]^[stC],X1C);
                  inc(X1C);
                end else Alarm;

           ^J : Alarm;

           ^T : if X1C <= XLV then
                begin
                  Del_Wort(VorWrite[Kanal]^[stC],X1C);
                  NeuPage := false;
                end else Alarm;

           
           ^Y : begin
                  VorWrite[Kanal]^[stC] := CvCh;
                  X1C := 3;
                end;

           #255: ;
           End;

     _Ret : begin
              Auswert_CMD(Kanal,VorWrite[Kanal]^[stC]);
              Vor_Feld_Scroll(Kanal);
              Cmd := false;
            end;

    _Back : begin
              NeuPage := false;
              if X1C > 3 then
              begin
                delete(VorWrite[Kanal]^[stC],X1C-1,1);
                dec(X1C);
              end else Alarm;
            end;

    _AltK : Gross := not Gross;

    _AltY : begin                 (* ALT-Y *)
              for i := stC to (VorZeilen - 1) do
                  VorWrite[Kanal]^[i] := VorWrite[Kanal]^[i+1];
              VorWrite[Kanal]^[VorZeilen] := CvCh;
              X1C := 3;
            end;

     _Del : if (XLV > 0) and (X1C <= XLV) then  (* DEL *)
            begin
              delete(VorWrite[Kanal]^[stC],X1C,1);
              NeuPage := false;
            end else Alarm;

      _Up : begin    (* Cursor Up *)
              dec(stC); dec(Y1C);
              if Y1C < 1 then Y1C := 1;
              if stC < ((VorZeilen - VorCmdZeilen) + 1) then
              begin
                stC := (VorZeilen - VorCmdZeilen) + 1;
                Alarm;
              end;
              if length(VorWrite[Kanal]^[stC]) < X1C then X1C := length(VorWrite[Kanal]^[stC]) + 1;
            end;

      _Dn : begin    (* Cursor Dn *)
              inc(Y1C); inc(stC);
              if Y1C > VAnz then Y1C := VAnz;
              if stC > VorZeilen then
              begin
                stC := VorZeilen;
                if VorWrite[Kanal]^[stC] <> CvCh then Vor_Feld_Scroll(Kanal)
                                                 else Alarm;
              end;
              if length(VorWrite[Kanal]^[stC]) < X1C then
                 X1C := length(VorWrite[Kanal]^[stC]) + 1;
            end;

    _Left : begin  (* Cursor left *)
              if X1C > 3 then dec(X1C) else Alarm;
              NeuPage := false;
            end;

   _Right : begin   (* Cursor right *)
              if X1C <= XLV then inc(X1C) else Alarm;
              NeuPage := false;
            end;

    _Home : begin         (* Home *)
              X1C := 3;
              NeuPage := false;
            end;

     _Ins : begin         (* Ins *)
              Insert_ON := not Insert_ON;
              NeuPage := false;
            end;

     _End : begin         (* END *)
              X1C := XLV + 1;
              NeuPage := false;
            end;

_CtrlLeft,
_CtrlRight: begin
              Cur_Wort(VorWrite[Kanal]^[stC],KC,X1C,3);
              NeuPage := false;
            end;

_CtrlPgUp : begin   (* Ctrl-Page-Up *)
              stC := (VorZeilen - VorCmdZeilen) + 1;
              X1C := 3; Y1C := 1;
            end;

_CtrlPgDn : begin    (* Ctrl-Page-Dn *)
              i := VorZeilen;
              While (copy(VorWrite[Kanal]^[i],3,77) = '') and
                    (i > VorZeilen-VorCmdZeilen+1) do dec(i);
              stC := i;
              if i < VorZeilen - VorCmdZeilen + VAnz
               then Y1C := i - (VorZeilen - VorCmdZeilen)
               else Y1C := VAnz;
              X1C := length(VorWrite[Kanal]^[stC]) + 1;
            end;

     _Esc : Cmd := false;

     _Nix :;

       else Alarm;

     end; {case KC of}

     if show = Kanal then if NeuPage
      then Neu_BildVor(Kanal)
      else WritePage(Kanal,1,Y1C+Vofs,Attrib[23],0,VorWrite[Kanal]^[stC] + G^.Leer);

     Soft_Cursor(Kanal);
     
   end; {with Kanal}
End;



Procedure Chr_Vor_Show (* Kanal : Byte; KC : Sondertaste; VC : char *);
var  i,i1,XH,
     XLV,VAnz    : Byte;
     Hstr        : String[80];
     Flag,
     Umbruch,
     Neben,
     NeuPage,
     ZWechsel    : Boolean;


 Begin
   with K[Kanal]^ do
   Begin
     if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);

     Hstr := '';
     Umbruch := false;
     NeuPage := true;
     VAnz := VEnd - VBeg + 1;

     XLV := length(VorWrite[Kanal]^[stV]);

     if (vc=^J) and ((SPComp) or (G^.ZeilenwTX)) then KC:=_RET;

     Case KC of

 _Andere : Begin
             if (VC in [#1..#7,#11,#12, #14..#19, #21..#24, #26..#31, #32..#254])
		or AltQFlag then if (not FileSend) then
             begin
               if not((XLV >= 79) and (X1V < 79)) then
               begin
                 NeuPage := false;
		 if ((TxByte + length(VorWrite[Kanal]^[stV])) > 254) then
		 begin
		   Tx_Out(Kanal,false);
		   NeuPage := true;
                 end;

		 if not insert_ON then delete(VorWrite[Kanal]^[stV],X1V,1);
                 insert(VC,VorWrite[Kanal]^[stV],X1V);
                 inc(X1V);

                 if (X1V > 79) then
                 begin
                   i := 1;
                   i1 := 79;
                   While (not(VorWrite[Kanal]^[stV][i1] in UmMenge)) and (i1 > 0) and (i < 79) do
                   begin
		     inc(i);
                     dec(i1);
		   end;
                   if (i > 1) and (i1 > 1) then
                   begin
		     Hstr := copy(VorWrite[Kanal]^[stV],i1+1,i-1);
		     delete(VorWrite[Kanal]^[stV],i1+1,i-1);
		     Umbruch := true;
		   end else ZWechsel := True;
		   KillEndBlanks(VorWrite[Kanal]^[stV]);


		   Set_st_Szeile(Kanal,0,stV);
		   Vor_Feld_Scroll(Kanal);
		   if VorWrite[Kanal]^[stV] > '' then Vor_Dn_Scroll(Kanal);
		   if Umbruch then VorWrite[Kanal]^[stV] := Hstr
			      else VorWrite[Kanal]^[stV] := '';
		   X1V := length(VorWrite[Kanal]^[stV]) + 1;

		   if ((umbruch) or (ZWechsel)) and ((SPComp) or (G^.ZeilenwTX)) then
		    begin
		     {VorWrite[Kanal]^[stV];}
		     Tx_Out(Kanal,true);
		     Set_St_SZeile(Kanal,1,1);
		    end;
		   ZWechsel:=False;

		   NeuPage := true;
		 end;
	       end else Alarm;
	     end else
	      begin
	       Alarm;
	       if FileSend then InfoOut(Kanal,1,1,InfoZeile(25));
	       if KompressUpd then InfoOut(Kanal,1,1,InfoZeile(399));
	      end;

	     if AltQFlag then VC := #255;
	     AltQFlag := false;

             case VC of
               ^J : begin
                      KillEndBlanks(VorWrite[Kanal]^[stV]);
                      if X1V > XLV then
                      begin
                        if (TxByte + XLV) > 254 then TX_Out(Kanal,false);
                        Set_st_Szeile(Kanal,0,stV);
                        Vor_Feld_Scroll(Kanal);
                        X1V := length(VorWrite[Kanal]^[stV]) + 1;
                      end else
                      begin
                        Hstr := copy(VorWrite[Kanal]^[stV],X1V,(XLV-X1V)+1);
			delete(VorWrite[Kanal]^[stV],X1V,(XLV-X1V)+1);
			Set_st_Szeile(Kanal,0,stV);
                        Vor_Feld_Scroll(Kanal);
                        if VorWrite[Kanal]^[stV] > '' then Vor_Dn_Scroll(Kanal);
                        VorWrite[Kanal]^[stV] := Hstr;
                        X1V := length(VorWrite[Kanal]^[stV]) + 1;
                      end;
                    end;

               ^T : if X1V <= XLV then
                    begin
                      Del_Wort(VorWrite[Kanal]^[stV],X1V);
                      NeuPage := false;
                    end else Alarm;

               ^Y : begin
		      VorWrite[Kanal]^[stV] := '';
		      X1V := 1;
                    end;

               #255: ;
             end;
           End;

            {(FileSend) or (SPlSave) or (RX_bin>1)}
     _Ret : if ((not FileSend)) and (not KompressUpd) then
	    begin
	      KillEndBlanks(VorWrite[Kanal]^[stV]);
	      if (TxByte + length(VorWrite[Kanal]^[stV])) > 254
	       then Tx_Out(Kanal,false);
	      Set_st_Szeile(Kanal,0,stV);
	      Tx_Out(Kanal,true);
	      Set_st_Szeile(Kanal,1,1);
	      Vor_Feld_Scroll(Kanal);
	    end else
		 begin
		  if (FileSend) or (SPlSave) or (RX_bin>1) then InfoOut(Kanal,1,1,InfoZeile(25));
		  if KompressUpd then InfoOut(Kanal,1,1,InfoZeile(399));
                 end;

    _Back : begin
              NeuPage := false;
              if X1V > 1 then
              begin
                delete(VorWrite[Kanal]^[stV],X1V-1,1);
                dec(X1V);
              end else Alarm;
            end;

    _Alt7 : begin
              Set_st_Szeile(Kanal,1,1);
              Vor_Feld_Scroll(Kanal);
              VorWrite[Kanal]^[stV] := '';
              X1V := 1;
            end;

    _Alt8 : begin
              Set_st_Szeile(Kanal,1,1);
            end;

    _Alt9 : begin
              Tx_Out(Kanal,false);
              NeuPage := true;
            end;

    _AltY : begin
              for i := stV to (VorZeilen - VorCmdZeilen)-1 do
                    VorWrite[Kanal]^[i] := VorWrite[Kanal]^[i+1];
              VorWrite[Kanal]^[VorZeilen - VorCmdZeilen] := '';
              X1V := 1;
            end;

     _Del : if (XLV > 0) and (X1V <= XLV) then
            begin
              delete(VorWrite[Kanal]^[stV],X1V,1);
              NeuPage := false;
            end else
            begin
              if (X1V > XLV) and (X1V < 79) and (
                 stV < (VorZeilen - VorCmdZeilen)) then
              begin
                i1 := 79 - X1V;
                Hstr := copy(VorWrite[Kanal]^[stV+1],1,i1);
                VorWrite[Kanal]^[stV] := VorWrite[Kanal]^[stV] + Hstr;
                delete(VorWrite[Kanal]^[stV+1],1,i1);
                if VorWrite[Kanal]^[stV+1] = '' then
                begin
                  for i := stV+1 to (VorZeilen - VorCmdZeilen)-1 do
                     VorWrite[Kanal]^[i] := VorWrite[Kanal]^[i+1];
                  VorWrite[Kanal]^[VorZeilen - VorCmdZeilen] := '';
                end;
              end else Alarm;
            end;

      _Up : begin    (* Cursor Up *)
              dec(stV); dec(Y1V);
              if Y1V < 1 then Y1V := 1;
              Set_st_Szeile(Kanal,1,1);
              if stV < 1 then
              begin
                stV := 1;
                Alarm;
              end;
              if length(VorWrite[Kanal]^[stV]) < X1V then X1V := length(VorWrite[Kanal]^[stV]) + 1;
            end;

      _Dn : begin    (* Cursor Dn *)
              Set_st_Szeile(Kanal,1,1);
              inc(stV); inc(Y1V);
              if Y1V > VAnz then Y1V := VAnz;
              if stV > (VorZeilen - VorCmdZeilen) then
              begin
                stV := VorZeilen - VorCmdZeilen;
                if VorWrite[Kanal]^[stV] > '' then Vor_Feld_Scroll(Kanal)
                                              else Alarm;
              end;
              if length(VorWrite[Kanal]^[stV]) < X1V then X1V := length(VorWrite[Kanal]^[stV]) + 1;
            end;

    _Left : begin  (* Cursor left *)
              if X1V > 1 then dec(X1V) else Alarm;
              NeuPage := false;
            end;

   _Right : begin   (* Cursor right *)
              if X1V <= XLV then inc(X1V) else Alarm;
              NeuPage := false;
            end;

    _Home : begin         (* Home *)
              X1V := 1;
              NeuPage := false;
            end;

     _Ins : begin         (* Ins *)
              Insert_ON := not Insert_ON;
              NeuPage := false;
            end;

     _End : begin         (* END *)
              X1V := XLV + 1;
              NeuPage := false;
            end;

     _Tab : begin
              Flag := false;
              if (stV > 1) and TabFill then Hstr := VorWrite[Kanal]^[stV-1]
                                       else Hstr := '';
              if Hstr > '' then
              begin
                if X1V <= length(Hstr) then
                begin
                  delete(Hstr,1,X1V);
                  Hstr := ConstStr('#',X1V) + Hstr;
                  if pos(B1,Hstr) in [X1V..78] then
                  begin
                    i := pos(B1,Hstr);
                    While (Hstr[i] = B1) and (i < length(Hstr)) do inc(i);
                    if XLV + (i - X1V) > 78 then i := Byte(78 - XLV) + X1V;
                    if i - X1V = 0 then Alarm;
                    Insert(ConstStr(B1,i-X1V),VorWrite[Kanal]^[stV],X1V);
                    X1V := i;
                  end else Flag := true;
                end else Flag := true;
              end else Flag := true;
              if Flag then
              begin
                i := length(G^.TabStr);
                if (XLV + i) > 78 then i := Byte(78 - XLV);
                if i = 0 then Alarm;
                Insert(copy(G^.TabStr,1,i),VorWrite[Kanal]^[stV],X1V);
                X1V := X1V + i;
              end;
            end;

_CtrlLeft,
_CtrlRight: begin
              Cur_Wort(VorWrite[Kanal]^[stV],KC,X1V,1);
              NeuPage := false;
            end;

_CtrlPgUp : begin   (* Ctrl-Page-Up *)
              Set_st_Szeile(Kanal,1,1);
              stV := 1; X1V := 1; Y1V := 1;
            end;

_CtrlPgDn : begin    (* Ctrl-Page-Dn *)
              Set_st_Szeile(Kanal,1,1);
              i := (VorZeilen - VorCmdZeilen);
              While (VorWrite[Kanal]^[i] = '') and (i > 1) do dec(i);
              stV := i;
              if i < VAnz then Y1V := stV else Y1V := VAnz;
              X1V := length(VorWrite[Kanal]^[stV]) + 1;
            end;

     _Esc : begin
              Cmd := true;
              X1C := length(VorWrite[Kanal]^[stC]) + 1;
            end;

     _Nix :;

       else Alarm;

     end;  { case KC of }

     if show = Kanal then if NeuPage
      then Neu_BildVor(Kanal)
      else WritePage(Kanal,1,Y1V+Vofs,Attrib[24],0,VorWrite[Kanal]^[stV] + G^.Leer);
     
     Soft_Cursor(Kanal);
     
   end; 
End;

Procedure ChangeXYst (* Kanal,Art : Byte; Var X1,Y1,st : Byte *);
Begin
  with K[Kanal]^ do
  begin
    if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
    if Art = 0 then
    begin
      if Cmd then
      begin
        st := stC; X1 := X1C; Y1 := Y1C;
      end else
      begin
        st := stV; X1 := X1V; Y1 := Y1V;
      end;
    end;

    if Art = 1 then
    begin
      if Cmd then
      begin
        stC := st; X1C := X1; Y1C := Y1;
      end else
      begin
        stV := st; X1V := X1; Y1V := Y1;
      end;
    end;
  end;
End;

(* scrollt das Array fÅr den Vorschreibschirm nach oben *)
Procedure Vor_Feld_Scroll (* Kanal : Byte *);
var   VAnz : Byte;
      i    : Integer;

Begin
  with K[Kanal]^ do
  begin
    if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
    VAnz := VEnd - VBeg + 1;
    if Cmd then
    begin
      X1C := 3;
      inc(stC); inc(Y1C);
      if Y1C > VorCmdZeilen then Y1C := VorCmdzeilen;
      if Y1C > VAnz then Y1C := VAnz;
      if stC > VorZeilen then
      begin
        for i := VorZeilen-VorCmdZeilen+1  to VorZeilen - 1
         do VorWrite[Kanal]^[i] := VorWrite[Kanal]^[i+1];
        stC := VorZeilen;
        VorWrite[Kanal]^[stC][0] := Chr(2);
      end;
    end else

    begin
      X1V := 1;
      inc(stV); inc(Y1V);
      if Y1V > VAnz then Y1V := VAnz;
      if (stV > (VorZeilen - VorCmdZeilen)) and (Y1V = VAnz) then
      begin
        for i := 1 to VorZeilen - VorCmdZeilen - 1 do
        begin
          VorWrite[Kanal]^[i] := VorWrite[Kanal]^[i+1];
          stTX[i] := stTX[i+1];
        end;
        stV := VorZeilen - VorCmdZeilen;
        VorWrite[Kanal]^[stV] := '';
        stTX[stV] := false;
      end;
    end;
  end;
End;

(* scrollt das Array fÅr den Vorschreibschirm ab der Position 'st' nach unten *)
Procedure Vor_Dn_Scroll (* Kanal : Byte *);
Var  i,i1       : Integer;
     X1,Y1,st   : Byte;
Begin
  with K[Kanal]^ do
  begin
    ChangeXYst(Kanal,0,X1,Y1,st);
    i1 := VorZeilen - VorCmdZeilen;
    if st < i1 then for i := 1 to i1 - st do
       VorWrite[Kanal]^[i1-i+1] := VorWrite[Kanal]^[i1-i];
    ChangeXYst(Kanal,1,X1,Y1,st);
  end;
End;

Procedure Neu_BildVor (* Kanal : Byte *);
Var  st,X1,Y1,i,i1,
     VAnz,Attr,AMerk  : Byte;
Begin
  with K[Kanal]^ do
  begin
    ChangeXYst(Kanal,0,X1,Y1,st);
    VAnz := VEnd - VBeg + 1;
    if Cmd then
    begin
      Attr := Attrib[23];
      if VAnz > VorCmdZeilen then
      begin
        VAnz := VorCmdZeilen;
        Teil_Bild_Loesch(VBeg+VAnz,VEnd,Attr);
      end;
    end else Attr := Attrib[24];
    i1 := st - Y1;
    for i := 1 to VAnz do
    begin
      AMerk := Attr;
      if stTX[i1+i] then Attr := Attrib[6];
      WritePage(Kanal,1,i+Vofs,Attr,0,VorWrite[Kanal]^[i1+i] + G^.Leer);
      Attr := AMerk;
    end;
  end;
End;

Procedure Soft_Cursor (* Kanal : Byte *);
Var   X1,Y1,st,
      Xh,Attr  : Byte;
      Neben    : Boolean;
Begin
  with K[Kanal]^ do
  begin
    ChangeXYst(Kanal,0,X1,Y1,st);
    if not HardCur then
    begin
      Neben := false;
      Xh := X1;
      if Xh > 80 then Xh := 80;
      if Xh > length(VorWrite[Kanal]^[st]) then Neben := true;
      if Neben then Attr := Attrib[21] else Attr := Attrib[22];
      if not Insert_ON then Attr := Attr + 128;
      if Neben then WritePage(Kanal,Xh,Y1+Vofs,Attr,0,'€')
               else WriteAttr(Xh,Y1+Vofs,1,Attr,1);
    end else InitCursor(X1,Y1+Vofs);
  end;
End;


Procedure Set_st_Szeile (* Kanal,Art,st : Byte *);
var  i : Byte;
Begin
  with K[Kanal]^ do
  begin
    if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
    if Art = 0 then
    begin
      stTX[st] := true;
      Einer_st := true;
      TxByte := TxByte + length(VorWrite[Kanal]^[st]) + 1;
    end else if Art = 1 then
    begin
      for i := 1 to VorZeilen do stTX[i] := false;
      Einer_st := false;
      TxByte := 0;
    end;
  end;
End;


Procedure TX_Out (* Kanal : Byte; All : Boolean *);
Var  i    : Byte;
     Hstr : String[80];
Begin
  with K[Kanal]^ do
  Begin
    Hstr := '';
    Auto_CON := false;
    if Kanal = 0 then K[0]^.TncNummer := Unproto;

    if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);

    if Conv.Active and (Kanal = ConvHilfsPort) then Conv_Tx_All(Kanal) else
    begin
      EigFlag := Echo in [1,3,5,7];
      for i := 1 to VorZeilen - VorCmdZeilen do if stTX[i] then
      begin
        Hstr := Line_convert(Kanal,1,VorWrite[Kanal]^[i]);
        if Kanal > 0 then NodeConnect(Kanal,UpCaseStr(Hstr));
        S_PAC(Kanal,NU,false,Hstr + M1);
      end;
      if All then S_PAC(Kanal,NU,true,'');
      EigFlag := false;
    end;

    Set_st_Szeile(Kanal,1,1);
  End;
End;  (* TX_out *)


Procedure Del_Wort (* Var Zeile : Str80; X1 : Byte *);
Begin
  if Zeile[X1] in Menge then delete(Zeile,X1,1) else
  begin
    Repeat
      delete(Zeile,X1,1);
    Until (X1 > length(Zeile)) or (Zeile[X1] in Menge);
  end;
  While (Zeile[X1] = B1) and (X1 <= length(Zeile)) do delete(Zeile,X1,1);
End;

Procedure Cur_Wort (* Zeile : Str80; KC : Sondertaste; Var X1 : Byte; XM : Byte *);
Var  XLV : Byte;
Begin
  if KC = _CtrlLeft then
  begin
    if X1 > XM then
    begin
      Repeat
        dec(X1);
      Until (X1 < XM ) or (not(Zeile[X1] in Menge));
      While (X1 >= XM) and (not(Zeile[X1] in Menge)) do dec(X1);
      inc(X1);
    end else Alarm;
  end else if KC = _CtrlRight then
  begin
    XLV := length(Zeile);
    if X1 <= XLV then
    begin
      While (X1 <= XLV) and (not(Zeile[X1] in Menge)) do inc(X1);
      While (X1 <= XLV) and (Zeile[X1] in Menge) do inc(X1);
    end else Alarm;
  end;
End;
