{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P C R C .  P A S                                                     ³
 ³                                                                         ³
 ³ CRC - Ermittlung                                                        ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure CRC_Datei (* var Zeile : str80 *);
Const PufferGroesse = $FFD0;
Type  PufferPtr = Array[0..Puffergroesse] of Byte;

Var   i,Anz,i1   : Integer;
      lergebnis,
      CRC,Anzahl,
      maxPuffer  : Word;
      Groesse,
      absolut,z,
      von,bis    : LongInt;
      Puffer     : ^PufferPtr;
      Datei      : File;
      ok         : Boolean;
      Files,
      Hstr       : string[80];
      PuffPtr,
      CrcPtr     : Pointer;
Begin
  ok := false;
  KillEndBlanks(Zeile);
  Files := UpCaseStr(ParmStr(1,' ',Zeile));
  Anz := ParmAnz;
  CRC := 0;
  Assign(Datei,Files);
  if ResetBin(Datei,T) = 0 then
  begin
    Puffer := Nil;
    if MaxAvail < maxPuffer then maxPuffer := MaxAvail;
    GetMem(Puffer,maxPuffer);
    FillChar(Puffer^,maxPuffer,#0);
    Groesse := Filesize(Datei);
    absolut := Groesse;
    if Anz = 3 then
    begin
      Zeile := RestStr(Zeile);
      von := str_int(CutStr(Zeile));
      bis := str_int(RestStr(Zeile));
      if (bis >= von) and (bis < Groesse) and (von >= 0) then
      begin
        ok := true;
        absolut := bis - von + 1;
      end;
    end else

    if Anz = 2 then
    begin
      von := str_int(RestStr(Zeile));
      if (von >= 0) and (von < Groesse) then
      begin
        ok := true;
        bis := Groesse - 1;
        absolut := bis - von + 1;
      end;
    end;

    if not ok then
    begin
      absolut := Groesse;
      von := 0;
      bis := Groesse - 1;
    end else Seek(Datei,von);
    z := absolut;

    PuffPtr := Addr(Puffer^[0]);
    CrcPtr := Addr(G^.CrcFeld[0]);
    
    Repeat
      if z > maxPuffer then
      begin
        Anzahl := maxPuffer;
        z := z - Anzahl;
      end else
      begin
        Anzahl := Word(z);
        z := 0;
      end;
      Blockread(Datei,Puffer^,Anzahl,lergebnis);

        asm   push ds
              les  di,PuffPtr
              mov  dx,lergebnis
              mov  cl,8
              mov  ax,CRC
              lds  si,CrcPtr
    @Again:
              mov  bx,ax
              shl  ax,cl
              or   al,[es:di]
              shr  bx,cl
              shl  bx,1
              xor  ax,[ds:si+bx]
              inc  di
              dec  dx
              ja   @Again

              pop  ds
              mov  CRC,ax
        end;

      (*
      for z := 0 to lergebnis-1
      do  CRC := crcFeld[(CRC shr 8)] xor ((CRC shl 8) or Puffer^[z]);
      *)

    Until z = 0;

    FiResult := CloseBin(Datei);
    While pos(BS ,Files) <> 0 do delete(Files,1,pos(BS ,Files));
    Zeile := 'CRC = ' + int_str(CRC) + '(dez) ' + Hex(CRC,4) + '(hex)  '+
    Files + ' -> Anzahl = ' + int_str(absolut) + ' Bytes (' + int_str(von) +
    '-' + int_str(bis) + ')';
    FreeMem(Puffer,maxPuffer);
  end;
End;


Procedure GetNetRom;
Const PufferGroesse = $FFD0;
Type  PufferPtr = Array[0..Puffergroesse] of Byte;

Var   i,Anz,i1   : Integer;
      lergebnis,
      CRC,Anzahl,
      maxPuffer  : Word;
      Groesse,
      absolut,z,
      von,bis    : LongInt;
      Puffer     : ^PufferPtr;
      Datei      : File;
      ok         : Boolean;
      zeile,
      Files,
      Hstr       : string[80];
      PuffPtr,
      CrcPtr     : Pointer;
Begin
 maxpuffeR:=puffergroesse;
  Zeile:='XPACKET.EXE';
  ok := false;
  KillEndBlanks(Zeile);
  Files := UpCaseStr(ParmStr(1,' ',Zeile));
  Anz := ParmAnz;
  CRC := 0;
  Assign(Datei,Files);
  if ResetBin(Datei,T) = 0 then
  begin
    Puffer := Nil;
    if MaxAvail < maxPuffer then maxPuffer := MaxAvail;
    GetMem(Puffer,maxPuffer);
    FillChar(Puffer^,maxPuffer,#0);
    Groesse := Filesize(Datei);
    absolut := Groesse;
    if Anz = 3 then
    begin
      Zeile := RestStr(Zeile);
      von := str_int(CutStr(Zeile));
      bis := str_int(RestStr(Zeile));
      if (bis >= von) and (bis < Groesse) and (von >= 0) then
      begin
        ok := true;
        absolut := bis - von + 1;
      end;
    end else

    if Anz = 2 then
    begin
      von := str_int(RestStr(Zeile));
      if (von >= 0) and (von < Groesse) then
      begin
        ok := true;
        bis := Groesse - 1;
        absolut := bis - von + 1;
      end;
    end;

    if not ok then
    begin
      absolut := Groesse;
      von := 0;
      bis := Groesse - 1;
    end else Seek(Datei,von);
    z := absolut;

    PuffPtr := Addr(Puffer^[0]);
    CrcPtr := Addr(G^.CrcFeld[0]);
    
    Repeat
      if z > maxPuffer then
      begin
        Anzahl := maxPuffer;
        z := z - Anzahl;
      end else
      begin
        Anzahl := Word(z);
        z := 0;
      end;
      Blockread(Datei,Puffer^,Anzahl,lergebnis);

        asm   push ds
              les  di,PuffPtr
              mov  dx,lergebnis
              mov  cl,8
              mov  ax,CRC
              lds  si,CrcPtr
    @Again:
              mov  bx,ax
              shl  ax,cl
              or   al,[es:di]
              shr  bx,cl
              shl  bx,1
              xor  ax,[ds:si+bx]
              inc  di
              dec  dx
              ja   @Again

              pop  ds
              mov  CRC,ax
        end;

      (*
      for z := 0 to lergebnis-1
      do  CRC := crcFeld[(CRC shr 8)] xor ((CRC shl 8) or Puffer^[z]);
      *)

    Until z = 0;
    hstr:=Hex(CRC,4);
    if hstr<>CRCNROM then
     begin
      {$I-}
{     rewrite(datei);
      if ioresult<>0 then HALT;}
      HALT;
      {$I+}
     end;
    FiResult := CloseBin(Datei);
    FreeMem(Puffer,maxPuffer);
  end;
End;


