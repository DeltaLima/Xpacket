{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P N E T R O M . P A S                                                ³
 ³                                                                         ³
 ³ Netrom-Datenbank-Verwaltung und Online-Ansicht                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Function NodesAnzahl;
var BFNa:string[12];
N:integer;
Bcdt:file of Broadcast;
ioo:word;

begin
{$I-}
 if NAfu then bfna:=BCastHAM else bfna:=BCastCB;
 assign(bcdt, sys1pfad+BFNa);
 reset(bcdt);
 if ioresult=0 then N:=FileSize(bcdt) else N:=0;
 ioo:=ioresult;
 close(bcdt);
 ioo:=ioresult;
{$I+}
Nodesanzahl:=N;
end;

Function BCastBackupRename (AltNam : String) :boolean;
var ior : word;
bkflg:boolean;
BKD_ : file;
begin
 {$I-}
bkflg:=false;
 assign (BKD_, sys1pfad+BcastBAK);
 erase(BKD_);
 ior:=ioresult;
 close(BKD_);
 ior:=ioresult;
 assign (BKD_, AltNam);
 rename (BKd_, sys1pfad+BCastBAK);
 ior:=ioresult;
 if ior<1 then bkflg:=true;
  BCastBackupRename := bkflg;
 close(bKD_);
 ior:=ioresult;
 {$I+}
end;


Procedure BCastKillen;
var ior : word;
bkflg:boolean;
BKD_ : file;

begin
 {$I-}
bkflg:=false;
 assign (BKD_, sys1pfad+BcastCB);
 erase(BKD_);
 ior:=ioresult;
 close(BKD_);
 ior:=ioresult;

 assign (BKD_, sys1pfad+BcastHAM);
 erase(BKD_);
 ior:=ioresult;
 close(BKD_);
 ior:=ioresult;
 {$I+}
end;



Procedure NodesLifetime;
var bfn     : string[12];
    i, kill : integer;
    durch   : byte;
    bdbk,
    bd      : file of broadcast;
    bdd     : broadcast;
    AktDT   : longint;
    min1, min2:longint;
    gekillt : boolean;
    ioo     : word;

begin
aktDT:=LastLTCheck;
{aktdt:=589865783+14400;}

{(Dtst-bcast.DatTime) div 60)*2));}
 ioo:=NodesAnzahl(false);
{$I-}
for durch:=1 to 2 do
 begin
  gekillt:=false;
  if durch=1 then bfn:=BCastHAM else bfn:=BCastCB;
 if BCastBackupRename (Sys1Pfad+bfn) then
 begin
  assign(bd, sys1pfad+bfn);
  rewrite(bd);
  ioo:=ioresult;
  assign(BDBK, Sys1Pfad+BCastBAK); reset(BDBK);
  if ioresult=0 then
  begin
   kill:=0; i:=0;
   while not eof(bdbk) do
   begin
    read(bdbk, bdd);
    ioo:=ioresult;
    {(Dtst-bcast.DatTime) div 60)*2));}
    min1:=0;
    min1:=(aktdt-bdd.dattime) *2;
    if min1>=Konfig.Lifetime then gekillt:=true;;
    if (not gekillt) then write(bd, bdd);
    gekillt:=false;
    ioo:=ioresult;
   end;
  end;
  close(bd);
  ioo:=ioresult;
  close(BDBK);
  ioo:=ioresult;
 end; {if BackupRename}
 end; {for}
 ioo:=ioresult;
 ioo:=NodesAnzahl(false);
{$I+}
end;

Procedure NodesSortieren;
Var   du, x,i,j  : longInt;
      N      : longint;
      Change : Boolean;
      bfn:string[12];
      bcda : file of Broadcast;
      bcda1, bcda2, bcda3   : Broadcast;
      obf:boolean;
      ioo:word;

Begin
{if inUDB then WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(402)));}

{$I-}
for DU:=1 to 2 do
begin
 if Du=1 then
  begin
   bfn:=BCastHAM;
   N:=NodesAnzahl(true);
  end
  else
  begin
   bfn:=BCastCB;
   N:=NodesAnzahl(false);
  end;
  assign(bcda, sys1pfad+bfn);reset(bcda);
  ioo:=ioresult;

if N>0 then
begin
  if N > 1 then
  begin
    x := 1;
    While x <= N do x := x * 3 + 1;
    x := x div 3;
    While x > 0 do
    begin
      i := x;
      While i <= N do
      begin
        j := i - x;
        Change := true;
        While (j > 0) and Change do
        begin
          Seek(bcda, j-1); read(bcda, bcda1);
          Seek(bcda, j+x-1); read(bcda, bcda2);
          if bcda2.DatTime > bcda1.DatTime then
          begin
            bcda3 := bcda2;
            bcda2 := bcda1;
            bcda1 := bcda3;
            Seek(bcda, j-1); write(bcda, bcda1);
            Seek(bcda, j+x-1); write(bcda, bcda2);
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;


 end; {if N}
 obf:=ioresult<1;
 close(bcda);
 obf:=ioresult<0;
 {$I+}
 end;{for du}
End;


Procedure NodeListen (* (Naf : Boolean) *) ;
var BCast   : Broadcast;
    BCDat   : file of broadcast;
    HamZ,
    CBZ,
    bfn     : string[12];
    dummy   : String[80];
    DatPos  : Longint;
    BPos,
    i,
    y       : Byte;
    ZMax    : byte;
    dtst    : longint;
    MaxNodes: integer;
    ioo     : word;
    Raus,
    Change  : boolean;
    KC      : Sondertaste;
    VC      : Char;

 Procedure NodeLesen;
  begin
{   dtst:=packdt;}
   {$I-}
   Seek(BCDat, DatPos); read(BCdat,BCast);
   ioo:=ioresult;
   if ioo<>0 then FillChar(BCast,SizeOf(Bcast), 0);
   {$I+}
   dummy:=b1+efillstr(22,B1,BCast.NodeCall+':'+BCast.NodeAlias);
   dummy:=dummy+efillstr(22,B1,BCast.SourceCall+':'+Bcast.SourceAlias);
   dummy:=dummy+SfillStr(5,B1,int_Str(Bcast.quality))+b2+b1;
   dummy:=dummy+b2+int_Str(Bcast.Port); {+B2+int_str((Konfig.Lifetime div 60));
   dummy:=dummy+sfillstr(6,b1,int_Str(((Dtst-bcast.DatTime) div 60)*2)); }
   if ioo<>0 then dummy:='';
  end;

 Procedure NodeDateiSchalten;
 begin
  {$I-}
  if NAf then bfn:=BCastHAM
      else bfn:=BCastCB;
   MaxNodes:=NodesAnzahl(Naf);
   assign(BCDat, sys1pfad+bfn);reset(BCDat);
   ioo:=ioresult;
   {$I+}
 end;

begin
InNodeListe:=true;
NodesSortieren;
 HamZ:=ParmStr(1,b1,InfoZeile(431));
 CBZ :=ParmStr(2,b1,InfoZeile(431));
 Raus:=False;
  Moni_Off(0);
  DirScroll := true;
  NowFenster := false;
  NodeDateiSchalten;
  if MaxNodes=0 then
   begin
    Naf:=Not Naf;
    {$I-}
    Close(Bcdat);
    datpos:=ioresult;
    {$I+}
    NodeDateiSchalten;
   end;
{ NodeDateiSchalten;}
 ZMax:=MaxZ-4;
 DatPos:=0;
 WriteRam(1,1,Attrib[5],1,EFillStr(64,B1,B1+InfoZeile(432)));

 WriteRam(1,2,Attrib[5],1,EFillStr(64,B1,B1+InfoZeile(429)));
 WriteRam(1,MaxZ,Attrib[5],1,EFillStr(80,B1,B1+'Bl„ttern mit PgUp/PgDn  -  AFU/CB umschalten mit Cursor rechts/links'));
 Change:=true;
 repeat
  if Change then
   begin
    if Naf then WriteRam(65,1,Attrib[5],1,SFillStr(16,B1,HamZ+b1))
           else WriteRam(65,1,Attrib[5],1,sFillStr(16,B1,CBZ+b1));
    WriteRam(65,2,Attrib[5],1,sFillStr(16,B1,'('+int_str(maxNodes)+')'+B1));
    i:=3;
    BPos:=DatPos;
    For DatPos:=Bpos to Bpos+ZMax do
     begin
      NodeLesen;
      WriteRam(1,i,Attrib[2],1,EFillStr(80,b1,Dummy));
      inc(i);
     end;
     Change:=false;
     datpos:=Bpos;
    end;
    _ReadKey(KC,VC);
    Case KC of
     _ESC : raus:=true;
     _AltH: XP_Help(G^.OHelp[94]);
     _Home: begin
             DatPos:=0;
             Change:=true;
            end;
     _PGDn: begin
             if (DatPos+zmax+1)<MaxNodes then
              begin
               inc(DatPos,zmax+1);
               Change:=true;
              end;
            end;
     _PGUp: begin
             if ((DatPos+zmax+1)>zmax) and ((DatPos-(zmax+1))>=0) then
              begin
               Dec(DatPos,zmax+1);
               Change:=true;
              end;
            end;
     _Right, _Left:
            begin
             Naf := Not Naf;
             DatPos:=0;
             Change:=true;
             {$I-}
             Close(BCDat);
             ioo:=ioresult;
             {$I+}
             NodeDateiSchalten;
            end;

    end;
 until Raus;
 {$I-}
 Close(BCDat);
 ioo:=ioresult;
 {$I+}
 DirScroll := false;
 Moni_On;
 inNodeListe:=false;
end;



Procedure REMNodesListen (*Kanal:Byte;CZeile:String*);
Var   i,i1,i2,
      ix      : Integer;
      dB,Tn,C,
      Anz     : Byte;
      Bstr,
      Dummy   : String;
      P       : String[4];
      Komm    : String[80];
      Path    : String[80];
      Rufz    : String[6];
      RufzStr : String[9];
      Hstr    : String[9];
      srec    : SearchRec;
      flagq,
      Flag    : Boolean;
      Parm    : Array[1..3] of String[60];
      Udb     : User_typ2;
      L_I     : Longint;
      ENTFG,
      RICHTG : REAL;
      STATUS : Boolean;
      OESLAE,NOEBRE:real;
      BCDat    : file of Broadcast;
      BCDatNam : string[12];
      BCast    : Broadcast;

begin
 With K[Kanal]^ do
 begin

         if Konfig.MaxNodes>0 then
         begin
          i2:=str_int(RestStr(upcaseStr(CZeile)));
          if i2=0 then i2:=50;
          NodesSortieren;
          if TNC[TncNummer]^.AfuPort then BCDatNam:=BCastHAM else BCDatnam:=BCastCB;
          i:=NodesAnzahl(TNC[TncNummer]^.AfuPort);
            assign (BCDat, sys1pfad+BCDatNam);
            {$I-}
             i1:=0;
             reset(BCDat);
             if (i<=0) or (ioresult<>0) then S_Pac(kanal, nu, false, InfoZeile(430)+M1)
             else
              begin
               S_Pac(kanal, nu, false, m1+InfoZeile(434)+M2);
               while (not eof(BCDat)) and (i1<i2) do
               begin
                read(BCdat,BCast);
                {l„nge: max 19 je node}
                dummy:=efillstr(19,B1,BCast.NodeCall+':'+BCast.NodeAlias);
                inc(i1);
                if (i1 mod 4)=0 then S_Pac(kanal,Nu, false, dummy+m1)
                 else S_Pac(kanal,Nu, false, dummy);
               end;
              end;
              if not ((i1 mod 4)=0) then s_pac(kanal, nu, false, m1);
             close(BCDat);
             i:=ioresult;
            {$I+}
         end else S_Pac(kanal, nu, false, InfoZeile(430)+M1)

 end;{with kanal}


end;


Procedure REMRoutesListen (*Kanal:Byte; CZeile:String*);
Var   i,i1,i2,
      ix      : Integer;
      dB,Tn,C,
      Anz     : Byte;
      Bstr,
      Dummy   : String;
      P       : String[4];
      Komm    : String[80];
      Path    : String[80];
      Rufz    : String[6];
      RufzStr : String[9];
      Hstr    : String[9];
      srec    : SearchRec;
      flagq,
      Flag    : Boolean;
      Parm    : Array[1..3] of String[60];
      Udb     : User_typ2;
      L_I     : Longint;
      ENTFG,
      RICHTG : REAL;
      STATUS : Boolean;
      OESLAE,NOEBRE:real;
      BCDat    : file of Broadcast;
      BCDatNam : string[12];
      BCast    : Broadcast;

begin
with K[Kanal]^ do
begin

         if Konfig.MaxNodes>0 then
         begin
          hstr:=RestStr(upcaseStr(CZeile));
          if hstr<>'' then
          begin
           if TNC[TncNummer]^.AfuPort then BCDatNam:=BCastHAM else BCDatnam:=BCastCB;
            assign (BCDat, sys1pfad+BCDatNam);
            {$I-}
             i1:=0;
             reset(BCDat);
             if (ioresult<>0) then S_Pac(kanal, nu, false, InfoZeile(430)+M1)
             else
              begin
               flag:=false;
               while (not eof(BCDat)) do
               begin
                read(BCdat,BCast);
                if (pos(hstr,bcast.NodeCall)=1) or (pos(hstr, bcast.nodealias)=1) then
                 begin
                  if not flag then S_Pac(kanal, nu, false, m1+InfoZeile(435)+m2+InfoZeile(429)+M2);
                  flag:=true;
                  dummy:=efillstr(22,B1,BCast.NodeCall+':'+BCast.NodeAlias);
                  dummy:=dummy+efillstr(22,B1,BCast.SourceCall+':'+Bcast.SourceAlias);
                  dummy:=dummy+SfillStr(5,B1,int_Str(Bcast.quality))+b2+b1;
                  dummy:=dummy+b2+int_Str(Bcast.Port){+B2+int_str(Bcast.DatTime)};
                  inc(i1);
                  if (i1 mod 4)=0 then S_Pac(kanal,Nu, true, dummy+m1)
                   else S_Pac(kanal,Nu, false, dummy+m1);
                 end;
               end; {while not eof}
               if not flag then S_Pac(kanal, nu, false, m1+InfoZeile(436)+M1);
              end;
             close(BCDat);
             i:=ioresult;
            {$I+}
           end else parmwrong:=true; {if hstr<>'' ...}
         end else S_Pac(kanal, nu, false, InfoZeile(430)+M1)

 end; {with kanal}
end;