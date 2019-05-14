{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P X B I N . P A S                                                    ³
 ³                                                                         ³
 ³ X-Protokoll-Verarbeitung                                                ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Function CRC_Zeile (CRCZeile : string) : String;

var   CRC : Word;
      z : word;

Begin
CRC:=0;
      for z := 1 to length(CRCZeile)
      do  CRC := g^.crcFeld[(CRC shr 8)] xor ((CRC shl 8) or ORD(CRCZeile[z]));
{if xbtest then crc:=0;
xbtest:=false;}
 CRC_zeile:=HEx(CRC,4);
End;


Procedure XBinAbbruch(kanal : byte);
begin
with k[kanal]^ do
begin
 s_pac(kanal,nu,true,#13+Meldung[10]+#13);
 s_pac(kanal,nu,true,M1+'XBIN-TX abgebrochen.'+m1);
{    xbtest:=true;}
    CloseXBinProt(kanal);
    FiResult := CloseBin(TxFile);
    xbin.an:=false;
    xbin.rx:=false;
         xbin.tx:=false;
         xbin.eof:=false;
         xbin.rtxok:=true;

         rx_save:=false;
         BoxZaehl:=5;
         setzeflags(kanal);
end;
end;

Function Endung(Kanal:byte) : Str8;
begin
 Endung:= sfillstr(3,'0',int_str(Kanal));
end;

Procedure OpenXBinProt {(Kanal:byte)};
begin
 with K[kanal]^ do
  begin
   assign(XbinPFile, Sys1Pfad+XBinProtokoll+Endung(Kanal));
   rewrite(XBinPfile);
   xbin.ProtPos:=0;
   xbin.pdat:=true;
   xbin.retries:=0;
   xbin.datpos:=0;
  end;
end;


Procedure CloseXBinProt {(Kanal:byte)};
begin
 with K[kanal]^ do
  begin
   close(XBinPfile);
   xbin.pdat:=false;
  end;
end;


{XBinCheck (kanal : Byte; XBinZ:string; DtPos:longint; XZeile:string);}
Procedure XBinCheck;

VAR CRC1, CRC2 : Str8;
     i,
    frNr : byte;
    proto:xbinfile_;
    Art : char;
    bef:integer;
    rept:string;
    firesult:word;

begin
 with K[kanal]^ do
 begin
  if not xbin.pdat then
  begin
   OpenXBinProt(kanal);
   xbin.ProtPos:=0;
  end;
  delete (XBinZ, 1,2);

  art:=xbinz[1];
  delete(xbinz,1,1);

  if Art=#255 then
   begin
    frnr:=ord(XbinZ[1]);
    if frnr>XBin.FrameNr then
     begin
      i:=Length(XZeile);
      rept:=EFillStr(i,#0,rept);
       while frnr>xbin.framenr do
        begin
         BlockWrite(RXFile,rept,i,bef);
          if xbin.pdat then
           begin
           Proto.DatPos:=DtPos;
           Proto.FrameNr:=XBin.FrameNr;
           Proto.OK:=false;
           proto.rxcrc:='FAIL';
           proto.crc:='URE!';
           write(XBinPfile, Proto);
          end;
         DtPos:=FilePos(RxFile);
         inc(Xbin.FrameNr);
        end;
      rept:='';
     end else Proto.FrameNr:=frnr;

    delete(XbinZ,1,1);
    CRC1:=XBinZ;


    if xbin.pdat then
     begin
      Proto.DatPos:=DtPos;
      if not xbin.RTXOK then
       begin
        seek(XBinPFile, Proto.FrameNr);
        read (xbinpfile, proto);
        seek(RXFile, Proto.DatPos);
        seek(XBinPFile, Proto.FrameNr);
       end;
      crc2:=CRC_Zeile(XZeile);
      if CRC2<>CRC1 then Proto.OK:=false else Proto.OK:=true;
      proto.rxcrc:=CRC1;
      proto.crc:=crc2;
      
      write(XBinPfile, Proto);
     end;
    inc(Xbin.FrameNr);
   end {if art=255}
   else begin {art=0}

   bef:=ord(XBinZ[1]);

    case bef of
     TRASK:
      begin
       if xbin.rtxok then XBin.DatPosA:=filePos(RXFile);
       xbin.rtxok:=true;
       {xbin.pdat:=false;}
       reset(XbinPFile);
       rept:='';
       while not EOF(xbinpfile) do
        begin
         read(xbinpfile, proto);
         if not proto.ok then rept:=rept+chr(Proto.framenr);
        end;
       if rept<>'' then
        begin
         xbin.rtxok:=false;
         if length(rept)>5 then
         begin
          rept:=copy(rept,1,5);
         end;

         s_pac(kanal,nu,true,xprot+COMD+chr(REP)+rept);
         {xbin.pdat:=true;}
        end else
         begin
          s_pac(kanal,nu,true,xprot+COMD+chr(TROK));
          {rewrite(XBinPFile);}
          xbin.ProtPos:=FilePos(XBinPFile);
          seek(RXFile, XBin.DatPosA);
          xbin.FrameNr:=0;
         end;
      end; {TRASK}

     TROK:
      begin
       if XBin.EOF then
        begin
         s_pac(kanal,nu,true,xprot+COMD+chr(XEOF));
         s_pac(kanal,nu,true,M1+'XBIN-TX abgeschlossen.'+m1);
{         xbtest:=true;}
         CloseXBinProt(kanal);
         FiResult := CloseBin(TxFile);
         xbin.an:=false;
         xbin.rx:=false;
         xbin.tx:=false;
         xbin.eof:=false;
         xbin.rtxok:=true;

         rx_save:=false;
         BoxZaehl:=5;
         setzeflags(kanal);
        end else
        begin
         {Rewrite(XbinPFile);}
         xbin.ProtPos:=FilePos(XBinPFile);
         seek(TXFile, XBin.DatPosA);
        end;
       filesendwait:=false;
       xbin.FrameNr:=0;
      end; {TROK}

     REP:
      begin
       xbin.Nachford:=xbin.Nachford+copy(xbinZ, 2, length(xbinz));
       filesendwait:=false;
       xbin.rtxok:=false;
      end; {REP}

     XEOF:
      begin
        xbin.rx:=false;
        xbin.tx:=false;
        rx_save:=false;
        xbin.eof:=false;
        xbin.rtxok:=true;
        BoxZaehl:=5;
        CloseXBinProt(kanal);
        CloseRxFile(Kanal,0);
        xbin.an:=false;
        setzeflags(kanal);
        s_pac(kanal,nu,true,M1+'XBIN-RX abgeschlossen.'+m1);
      end; {xeof}
    end;
   end;
 end; {with kanal...}
end;



{**}

{Function XBinStr (Kanal : Byte; Zeile : String; TXPos:longint) : String;}
Function XBinStr;
var hstr:string;
proto:xbinfile_;
begin
 with K[kanal]^ do
 begin
  hstr:=xprot+#255+chr(XBin.FrameNr)+CRC_Zeile(Zeile);
  XBinStr:=HStr;
  if not XBin.pdat then OpenXBinProt(kanal);
  if (XBin.PDat) and (Xbin.RTXok) then
   begin
    Proto.retries:=0;
    Proto.FrameNr:=XBin.FrameNr;
    Proto.DatPos :=TXPos;
    Proto.RXCRC:='XBTX';
    Proto.CRC:='XBTX';
    Proto.OK:=true;
    write(XBinPFile, Proto);
   end;

  inc(xbin.FrameNr)
 end;
end;


Function Position(Fnr :Byte; kanal : Byte) : longint;
var proto:xbinfile_;
begin
with k[kanal]^ do
 begin
  close (XbinPFile); reset(XbinPFile);
  seek(xbinPfile, fnr);

  read(xbinpfile, Proto);
 if xbin.tx then
  begin
   seek(xbinPfile, fnr);
   inc(proto.retries);
   write(xbinpfile, Proto);
   if proto.retries=11 then XBinAbbruch(kanal);
  end;
  xbin.framenr:=fnr;
  Position:=proto.DatPos;
 end;
end;


procedure XBinWrite {(kanal:Byte; Zeile:string)};
Var     i,i1   : Integer;
        Free   : LongInt;
        DatPos:longint;
        Result : Word;
        Hstr   : String[80];
        VC     : Char;
        Bstr   : String;
        XBinRX : string;

begin
with k[kanal]^ do
begin
          if MldOk in [5,6,10] then
           begin
             if MldOk = 10 then
             begin
               FiResult := CloseBin(RxFile);
               FiResult := EraseBin(RxFile);
               if xbin.pdat then closeXBinProt(kanal);
               S_PAC(Kanal,NU,false,InfoZeile(41) + M1);
               Send_Prompt(Kanal,FF);
             end else CloseRxFile(Kanal,1);
             xbin.rx:=false; xbin.an:=false; xbin.tx:=false; xbin.framenr:=0;
             setzeFlags(kanal);
           end
           else
           begin

  if length(zeile)>8 then
   begin
    XBinRX := copy (Zeile, 1, 8);
    delete (Zeile,1,8);
   end else
   begin
     XBinRX := Zeile;
     zeile:='';
   end;
    DatPos:=filePos(RXFile);
    XBinCHECK(Kanal, XBinRX, DatPos, Zeile);

             i1 := length(Zeile);
             {if (RX_Count + i1) > RX_Laenge then i1 := Byte(RX_Laenge - RX_Count);}
             BlockWrite(RXFile,Zeile[1],i1,Result);
             RX_CRC := Compute_CRC(RX_CRC,copy(Zeile,1,Result));
             if XBin.RTXOk then RX_Count := RX_Count + i1;
             FileInfo(Kanal,0,RX_Laenge,RX_Count,0,0);

             if RX_Count >= RX_Laenge then
             begin

               {if xbin.pdat then closeXbinprot(kanal);}
               Result := Word(RX_CRC);
               BoxZaehl:=5;
               AutoBinOn := AutoBin;
               Ignore := false;
               SetzeFlags(Kanal);
             (*
               Hstr := Time_Differenz(RX_Time,Uhrzeit);
               Zeile := FName_aus_FVar(RxFile);
               While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));

               Zeile := M1 + B1 + InfoZeile(103) + B1 +
                        EFillStr(14,B1,Zeile) + InfoZeile(100) +
                        int_str(Result) + B2 + LRK + Hex(Result,4) + B1 +
                        BdStr + FileBaud(Hstr,int_str(RX_Count)) + B2 +
                        LRK + Hstr + RRK + M1;

               if (RX_Soll_CRC > 0) and (Result <> RX_Soll_CRC)
                then Zeile := Zeile + B1 + InfoZeile(113) + ^G + M1;
               if SysArt in [1..6,14,18] then
                    S_PAC(Kanal,NU,true,M1)
               else
               begin
                {S_PAC(Kanal,NU,false,Zeile);
                 Send_Prompt(Kanal,FF);}
               end; *)
     end;
     end; {else (mldok)}
end;{with kanal}
end; {procedure xbinwrite}





Procedure XBinSend (* Kanal : Byte; OFlag : Boolean; *);
Var   Zeile      : String;
      Hstr       : String[9];
      i,l        : Byte;
      ch         : Char;
      FileEnde   : Boolean;
      Result     : Word;
      XBTrans    : Boolean;
      TXSpos,
      DatPos    : longint;
Begin
  
  FileEnde := false;
  Zeile := '';
  with K[Kanal]^ do
  Begin
   XBTrans:=(XBIN.tx);
    FileFlag := false;
    if XBin.TX then
    Begin
      if TxComp then l := maxCompPac
                else l := FF;

      if XBTrans then l:=paclen-8;
      if xbtrans and txcomp then l:=Paclen-10;

      if (not xbin.rtxok) and (xbin.nachford<>'') then
       begin
        reset(TXFile, t);
        TXSPos:=Position(ord(xbin.Nachford[1]), kanal);
        if xbin.tx then seek(TxFile, TXSPos);
        delete(xbin.Nachford,1,1);
       end;

  if xbin.tx then
   begin
      if xbtrans then DatPos:=filepos(TXFile);

      BlockRead(TxFile,Zeile[1],l,Result);

      {if ((TX_Count + Result) > TX_Laenge) and (xbin.rtxok) then Result := TX_Laenge - TX_Count;}

      Zeile[0] := chr(Byte(Result));
      if XBTRANS then Zeile:=XBinStr(Kanal, Zeile, DatPos)+Zeile;

      {if XBTrans then Zeile[0] := chr(Byte(Result+7));}

      if xbin.rtxok then
       begin
        TX_Count := TX_Count + Result;
        TX_CRC := Compute_CRC(TX_CRC,Zeile);
       end;

      IF (not XBin.EOF) and (eof(TXFile)) then
       begin
        FileEnde := true;
        xbin.eof:=true;
       end;



{   if xbtest then Zeile[10]:='A';
   xbtest:=false;}

      S_PAC(Kanal,NU,true,Zeile);
      FileInfo(Kanal,1,TX_Laenge,TX_Count,0,0);

      if (not xbin.rtxok) and (xbin.nachford='') then
       begin
        fileende:=true;
       end;
                                      { 255 }
      if (xbin.rtxok) and (xbin.frameNr=XBinMaxFrame) then
       begin
        s_pac(kanal,nu,true,xprot+COMD+chr(TRASK));
        FileSendWait:=true;
        xbin.DatPosA:=FilePos(TXFile);
       end;

      if FileEnde then
      Begin
        TNC_Puffer := false;
        FileSend := false;
        Result := Word(TX_CRC);
        boxzaehl:=5;

        if not DirScroll then SetzeFlags(Kanal);

         (*       Hstr := Time_Differenz(TX_Time,Uhrzeit);
                Zeile := FName_aus_FVar(TxFile);
                While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));

                Zeile := M1 + B1 + InfoZeile(102) + B1 +
                         EFillStr(14,B1,Zeile) + InfoZeile(100) +
                         int_str(Result) + B2 + LRK + Hex(Result,4) + B1 +
                         BdStr + FileBaud(Hstr,int_str(TX_Count)) + B2 +
                         LRK + Hstr + RRK + M1;

                if OFlag then _aus(Attrib[20],Kanal,Zeile);
              {  if FileSendRem then
                begin }
                 if SysArt in [1..6,14,18] then
                    S_PAC(Kanal,NU,true,M1)
                 else
                  begin if not XBin.An then
                   begin
                    S_PAC(Kanal,NU,false,Zeile);
                    Send_Prompt(Kanal,FF);
                   end else
                   begin *)
                    S_pac(kanal,NU,TRUE,'');
                    s_pac(kanal,nu,true,xprot+COMD+chr(TRASK));

                    xbin.Nachford:='';
                    xbin.framenr:=0;
                    xbin.ok:=false;
                    {xbin.pdat:=false;}
                    xbin.datpos:=0;
                    xbin.retries:=0;
                    xbin.rtxok:=true;

                    fileende:=false;
                    filesendwait:=true;
(*
                   end;
                  end; *)
              {  end else S_PAC(Kanal,NU,true,''); }
        FileSendRem := false;
      End;
    End;
   end; {if xbin.tx}
    FileFlag := false;
  End;
End;
