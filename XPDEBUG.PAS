{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P D E B U G . P A S                                                  ³
 ³                                                                         ³
 ³ Verschiedene Systemausknfte                                            ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Debug_Info (* Kanal,Aufruf : Byte *);
Var   A             : Byte;
      i,i1          : Integer;
      l             : LongInt;
      Istr,
      Chan          : String[2];
      Frei          : String[10];
      Hstr          : String[80];
      f             : Text;


Begin
  A := Aufruf;
  Assign(G^.TFile,G^.TempPfad + DebDatei);
  FiResult := RewriteTxt(G^.TFile);
  if A = 0 then Moni_Off(0);

  Frei := B1 + InfoZeile(325) + B1;

  Writeln(G^.TFile);
  Writeln(G^.TFile,'':5,'D E B U G - I N F O','':10,Version,B2,lastEdit);
  Writeln(G^.TFile,ConstStr('Ä',79));

  Writeln(G^.TFile,EFillStr(30,B1,'Prefix-Segment :  ' + Hex(PrefixSeg,4)) +
                   '³  OvrDosHandle   :  ' + int_str(OvrDosHandle));
  Writeln(G^.TFile,EFillStr(30,B1,'Code-Segment   :  ' + Hex(CSeg,4)) +
                   '³  OvrEmsHandle   :  ' + int_str(OvrEmsHandle));
  Writeln(G^.TFile,EFillStr(30,B1,'Daten-Segment  :  ' + Hex(DSeg,4)) +
                   '³  OvrHeapBegin   :  ' + Pointer_Str(Ptr(OvrHeapOrg,0)));
  Writeln(G^.TFile,EFillStr(30,B1,'Stack-Segment  :  ' + Hex(SSeg,4)) +
                   '³  OvrHeapEnde    :  ' + Pointer_Str(Ptr(OvrHeapEnd,0)));
  Writeln(G^.TFile,EFillStr(30,B1,'Stack-Pointer  :  ' + Hex(SPtr,4)) +
                   '³  OvrHeapPtr     :  ' + Pointer_Str(Ptr(OvrHeapPtr,0)));
  Writeln(G^.TFile,EFillStr(30,B1,'Heap-Anfang    :  ' + Pointer_Str(HeapOrg)) +
                   '³  OvrHeapSize    :  ' + FormByte(int_str(OvrHeapSize)) + B1 + Bytes);
  Writeln(G^.TFile,EFillStr(30,B1,'Akt.HeapSpitze :  ' + Pointer_Str(HeapPtr)) +
                   '³  OvrGetBuf      :  ' + FormByte(int_str(OvrGetBuf)) + B1 + Bytes);
  Writeln(G^.TFile,EFillStr(30,B1,'Heap-Ende      :  ' + Pointer_Str(HeapEnd)) +
                   '³  OvrLoadCount   :  ' + int_str(OvrLoadCount));
  Writeln(G^.TFile,EFillStr(30,B1,'Video-Pointer  :  ' + Pointer_Str(Bild)) +
                   '³  OvrLoadList    :  ' + int_str(OvrLoadList));

  Writeln(G^.TFile,ConstStr('Ä',79));

  for i := 1 to 4 do
  begin
    Hstr := 'Port LPT-' + int_str(i) + ' = ' + Hex(LPT_Base[i],4);
    if not LPT_Error(i) then Hstr := Hstr + '  Printer exist.';
    Writeln(G^.TFile,Hstr);
  end;
  Writeln(G^.TFile,ConstStr('Ä',79));

  for i := 0 to maxLink do
  begin
    l := SizeOf(K[i]^);
    Chan := SFillStr(2,B1,int_str(i));
    Hstr := Chan + '.Kanal-Pointer:  ' + Pointer_Str(K[i]) + ' => '
                       + FormByte(int_str(l)) + B1 + Bytes
                       + '  ³  Syncherrors = ' + int_str(K[i]^.SynchErrAnz);
    Writeln(G^.TFile,Hstr);
  end;

  Writeln(G^.TFile,ConstStr('Ä',79));

  for i := 1 to maxTNC do
  begin
    if TNC_used[i] then l := SizeOf(TNC[i]^) else l := 0;
    Hstr := int_str(i) + '.TNC-Pointer : ' + Pointer_Str(TNC[i]) +
    ' => ' + SFillStr(4,B1,FormByte(int_str(l))) + B1 + Bytes + B1;
    if TNC_used[i] then
    begin
      if TNC[i]^.RS232 <> 5 then
      begin
        if HwHs then Istr := '--'
                else Istr := SFillStr(2,B1,int_str(Com[TNC[i]^.RS232].IRQ_Nr));
        Hstr := Hstr + ' COM/PORT/IRQ/BAUD = '   +
            int_str(TNC[i]^.RS232)         + '/' +
            Hex(Com[TNC[i]^.RS232].Base,4) + '/' +
            Istr                           + '/' +
        int_str(Com[TNC[i]^.RS232].Baudrate)
      end else Hstr := Hstr + B1 + PcxStr;
    end;
    Writeln(G^.TFile,Hstr);
  end;
  Writeln(G^.TFile,ConstStr('Ä',79));
  Writeln(G^.TFile,ConstStr(B1,10) + 'IRQs - 76543210');
  Writeln(G^.TFile,'IRQ-Maske      : ' + Bin(Port[$21],8));

  Writeln(G^.TFile,ConstStr('Ä',79));
  Writeln(G^.TFile,'System-Pfad    :  ' +
  SFillStr(11,B1,FreeStr(SysPfad[1])) + B1 + Bytes + frei + SysPfad);
  Writeln(G^.TFile,'Mailbox-Pfad   :  ' +
  SFillStr(11,B1,FreeStr(G^.MailPfad[1])) + B1 + Bytes + Frei + G^.MailPfad);
  Writeln(G^.TFile,'Remote-Pfad    :  ' +
  SFillStr(11,B1,FreeStr(K[show]^.RemPath[1])) + B1 + Bytes + Frei + K[show]^.RemPath);
  Writeln(G^.TFile,'Runfile-Pfad   :  ' +
  SFillStr(11,B1,FreeStr(G^.RunPfad[1])) + B1 + Bytes + Frei + G^.RunPfad);
  Writeln(G^.TFile,'Speakfile-Pfad :  ' +
  SFillStr(11,B1,FreeStr(G^.SpkPfad[1])) + B1 + Bytes + Frei + G^.SpkPfad);

  if use_VDisk then
    Writeln(G^.TFile,'RAM-Floppy     :  ' +
  SFillStr(11,B1,FreeStr(Vdisk[1])) + B1 + Bytes + Frei + Vdisk);

  Writeln(G^.TFile,ConstStr('Ä',79));

  Assign(f,SysPfad + BootDatei);
  if ResetTxt(f) = 0 then
  begin
    Readln(f);
    Readln(f);
    while not Eof(f) do
    begin
      Readln(f,Hstr);
      Writeln(G^.TFile,Hstr);
    end;
    FiResult := CloseTxt(f);
    Writeln(G^.TFile,ConstStr('Ä',79));
  end;

  Writeln(G^.TFile,'Freier RAM insgesamt :  ' + SFillStr(8,B1,FormByte(int_str(MemAvail))) + B1 + Bytes);
  Writeln(G^.TFile,'gr. freier RAM-Block :  ' + SFillStr(8,B1,FormByte(int_str(MaxAvail))) + B1 + Bytes);
  Writeln(G^.TFile,'RAM vor dem Start    :  ' + SFillStr(8,B1,FormByte(int_str(FreeRam)))  + B1 + Bytes);
  Writeln(G^.TFile,'Belegter Heap        :  ' +
       SFillStr(8,B1,FormByte(int_str(Adr_absolut(HeapPtr) - Adr_absolut(HeapOrg) + OvrGetBuf))) + B1 + Bytes);
  Writeln(G^.TFile,ConstStr('Ä',79));

  for i := 0 to maxLink do
  begin
    l := K[i]^.maxNotCh;
    Chan := SFillStr(2,B1,int_str(i));
    Hstr := Chan + '.Scroll : ' + Pointer_Str(NotCh[i]) + ' => ' +
            SFillStr(6,B1,FormByte(int_str(l))) + B1 + Bytes + '  ³  ';
    l := K[i]^.VorZeilen * 81;
    Hstr := Hstr + Chan + '.Vor : ' + Pointer_Str(VorWrite[i]) + ' => ' +
            SFillStr(6,B1,FormByte(int_str(l))) + B1 + Bytes + B1;
    Writeln(G^.TFile,Hstr);
  end;
  Writeln(G^.TFile,ConstStr('Ä',79));
  FiResult := CloseTxt(G^.TFile);

  if Aufruf = 0 then
  begin
    ExecDOS(G^.Ext_View_Path + B1 + G^.TempPfad + DebDatei);
    Neu_Bild;
    Moni_On;
  end;
  if Aufruf = 1 then SF_Text(Kanal,G^.TempPfad + DebDatei);
  KillFile(G^.TempPfad + DebDatei);
END;
