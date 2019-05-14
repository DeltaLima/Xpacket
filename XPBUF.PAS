{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P B U F .  P A S                                                     ³
 ³                                                                         ³
 ³ Routinen fuer das Pufferfilehandling                                    ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure OpenBufferFile (* Kanal : Byte *);
Var   Ex : String[3];
Begin
  with K[Kanal]^ do 
{  if (not node) or ((node) and (Test)) then}
  begin
    Ex := SFillStr(3,'0',int_str(Kanal));
    if Vdisk_Exists and (DiskFree(ord(VDisk[1])-64) > minFreeVdisk)
      then Assign(BufFile,VDisk + BufDatei + Ex)
      else Assign(BufFile,Konfig.TempVerz + BufDatei + Ex);

    if RewriteBin(BufFile,T) = 0 then BufExists := true;
  end;
End;


Procedure WriteBuffer (* Kanal : Byte; Zeile : String *);
var    Result : Word;
Begin
  with K[Kanal]^ do if BufExists then
  begin
    Seek(BufFile,FileSize(BufFile));
    BlockWrite(BufFile,Zeile[1],length(Zeile),Result);
  end;
End;


Procedure SendBuffer (* Kanal : Byte *);
Var    Result  : Word;
       Zeile   : String;
       BufTill : LongInt;
       BufStr  : String[10];
Begin
  with K[Kanal]^ do if BufExists then
  begin
    Seek(BufFile,BufPos);
    BlockRead(BufFile,Zeile[1],PacLen,Result);
    BufPos := FilePos(BufFile);

    BufStr := '';
    BufTill := FileSize(BufFile) - BufPos;
    if BufTill > 9999 then
    begin
      BufTill := BufTill div 1024;
      BufStr := 'K';
    end;
    if BufTill > 9999 then
    begin
      BufTill := BufTill div 1024;
      BufStr := 'M';
    end;
    BufStr := int_str(BufTill) + BufStr;
    StatusOut(Kanal,6,4,Attrib[7],SFillStr(5,B1,BufStr),2);

    if Result > 0 then
    begin
      Zeile[0] := chr(Result);
      TxRxTNC(Kanal,0,Zeile);
    end else EraseBufferFile(Kanal);
  end;
End;


Procedure EraseBufferFile (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
    begin
     FiResult:=CloseBin(BufFile);
      FiResult := EraseBin(BufFile);
      BufExists := false;
      WishBuf := false;
      BufPos := 0;
      SetzeFlags(Kanal);
    end;
{  with K[Kanal]^ do if BufExists then
  begin
    if CloseBin(BufFile) = 0 then
    begin
      FiResult := EraseBin(BufFile);
      BufExists := false;
      WishBuf := false;
      BufPos := 0;
      SetzeFlags(Kanal);
    end;
  end;  }
End;


Procedure SendTestBuffer (* Kanal : Byte *);
Var    Result : Word;
       Zeile  : String;
Begin
  with K[Kanal]^ do if BufExists then
  begin
    Seek(BufFile,0);
    Repeat
      BlockRead(BufFile,Zeile[1],PacLen,Result);
      if Result > 0 then
      begin
        Zeile[0] := chr(Result);
       if (SPComp) and (Test) and (RXComp) then
        begin
         while Zeile[length(Zeile)]=#0 do
         delete(Zeile, Length(Zeile), 1);
         Zeile[0]:=chr(length(Zeile));
        end;

        TNC_Info(TestMerk,Attrib[18],Zeile);
      end else EraseBufferFile(Kanal);
    Until not BufExists;
  end;
End;
