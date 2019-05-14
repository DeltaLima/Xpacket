{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P D O S .  P A S                                                     ³
 ³                                                                         ³
 ³ Routinen fr den DOS-Austieg                                            ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure DosAufruf (* Var Zeile : Str128; Art : Byte *);
Var    Flag : Boolean;
       f    : File;
       INr,
       i,Z  : Byte;

Begin
  Ini_TNC_Text(1);
  if Art = 1 then Teil_Bild_Loesch(1,maxZ,7);
  if Art = 2 then Teil_Bild_Loesch(1,maxZ,Attrib[18]);

  SetzeCursor(1,2);

  Flag := (Zeile = '');
  if Flag then WriteRam(1,1,Attrib[5],0,InfoZeile(254));

  if Zeile > '' then Zeile := COM_C + Zeile;

  Close_SaveFiles;
  StoreHeap;

  Call_DOS(Zeile);

  LoadHeap;
  if DosError = 0 then Zeile := 'OK' else Zeile := '';
  Open_SaveFiles;

  Z := Zeilen_ermitteln;

  if (Art = 1) and not Flag then
  begin
    Teil_Bild_Loesch(Z,Z,7);
    WriteRam(1,Z,Attrib[5],0,InfoZeile(78));
    SetzeCursor(length(InfoZeile(78))+2,Z);
    Warten;
  end;

  if Art = 2 then
  begin
    Assign(f,Konfig.TempVerz + DosBild);
    if ResetBin(f,T) = 0 then
    begin
      if FileSize(f) = 0 then
      begin
        FiResult := CloseBin(f);
        FiResult := EraseBin(f);
        DosBildSave(Z);
      end else FiResult := CloseBin(f);
    end else DosBildSave(Z);
  end;

  if Z <> maxZ then Switch_VGA_Mono;
  ColorItensity(HighCol);
  Cursor_Aus;

  if not HwHs and HardCur then for i := 1 to 4 do
   with COM[i] do if Active then
   begin
     Port[Base + $01] := $01;
   end;

  Ini_TNC_Text(0);
  Neu_Bild;
  Init_HardDrive;
End;

Procedure ExecDOS (* Zeile : str128 *);
Var   Z : Byte;
Begin
  if Zeile > '' then Zeile := COM_C + Zeile;

  Ini_TNC_Text(1);
  Teil_Bild_Loesch(1,maxZ,7);
  SetzeCursor(1,1);
  Close_SaveFiles;
  StoreHeap;

  Call_DOS(Zeile);

  LoadHeap;
  Open_SaveFiles;

  Z := Zeilen_ermitteln;
  if Z <> maxZ then Switch_VGA_Mono;
  ColorItensity(HighCol);
  Cursor_aus;
  Init_HardDrive;
  Ini_TNC_Text(0);
End;

Procedure DosBildSave (* Zeilen : Byte *);
var i,i1,
    max  : Word;
    f    : text;
    H    : string[80];

Begin
  H := '';
  Assign(f,Konfig.TempVerz + DosBild);
  FiResult := RewriteTxt(f);
  i1 := 1;
  max := Zeilen * 160;
  for i := 1 to max do
  begin
    if i mod 2 = 1 then
    begin
      if Bild^[i] in [#32..#254] then H := H + Bild^[i];
      inc(i1);
      if i1 > 80 then
      begin
        KillEndBlanks(H);
        if H <> '' then Writeln(f,H);
        H := '';
        i1 := 1;
      end;
    end; 
  end;
  Writeln(f);
  FiResult := CloseTxt(f);
End;

Procedure StoreHeap;
var       Result : Word;
          Zaehl  : LongInt;
Begin
  HeapFeld := HeapOrg;
  Zaehl := Adr_absolut(HeapPtr) - Adr_absolut(HeapOrg);
  SizeHeap := Zaehl;
  if use_XMS and ((LongInt(get_XMS_Free) * 1024) > Zaehl) then
  begin
    SwpHandle := get_XMS_Ram((Zaehl div 1024) + 2);
    Data_to_XMS(HeapOrg,SwpHandle,0,SizeHeap);
    SwapXms := true;
  end else
  begin
    if Vdisk_Exists and (DiskFree(ord(VDisk[1])-64) > (Zaehl + 2048))
       then  Assign(HeapFile,VDisk + SwapDatei)
       else  Assign(HeapFile,Konfig.TempVerz + SwapDatei);
    FiResult := RewriteBin(HeapFile,T);
    if Zaehl > $FFFF then
    Repeat
      if Zaehl >= $FFFF  then BlockWrite(HeapFile,HeapFeld^,$FFFF,Result)
                         else BlockWrite(HeapFile,HeapFeld^,Word(Zaehl),Result);
      Zaehl := Zaehl - Result;
      HeapFeld := Ptr(Seg(HeapFeld^) + $1000,Ofs(HeapFeld^));
    Until Zaehl <= 0 else BlockWrite(HeapFile,HeapFeld^,Zaehl,Result);
    FiResult := CloseBin(HeapFile);
  end;
End;

Procedure LoadHeap;
var       Result : Word;
Begin
  HeapFeld := HeapOrg;
  if use_XMS and SwapXms then
  begin
    XMS_to_Data(HeapOrg,SwpHandle,0,SizeHeap);
    SwapXMS := false;
    Free_XMS_Ram(SwpHandle);
  end else
  begin
    FiResult := ResetBin(HeapFile,T);
    Repeat
      BlockRead(HeapFile,HeapFeld^,$FFFF,Result);
      HeapFeld := Ptr(Seg(HeapFeld^) + $1000,Ofs(HeapFeld^));
    Until Result <= 0;
    FiResult := CloseBin(HeapFile);
    FiResult := EraseBin(HeapFile);
  end;
End;


Function  Zeilen_ermitteln (* : Byte *);
var    r : Registers;
       i : Integer;
Begin
  if Hercules then Zeilen_ermitteln := 25 else
  begin
    r.ah := $11;
    r.al := $30;
    intr($10,r);
    i := r.dl + 1;
    if i in [25,30,34,43,50,60] then Zeilen_ermitteln := Byte(i)
                                else Zeilen_ermitteln := 25;
  end;
End;

Procedure Switch_VGA_Mono;
Begin
  if not Hercules then
  begin
    if _VGA then TextMode(LastModeStore or $100)
            else TextMode(LastModeStore and $FF);
  end;
End;

Procedure Ini_TNC_Text (* Art : Byte *);
Var  i : Byte;
Begin
  for i := 1 to TNC_Anzahl do
  begin
    K[0]^.TncNummer := i;
    S_PAC(0,CM,true,'U' + int_str(Art));
  end;
End;
