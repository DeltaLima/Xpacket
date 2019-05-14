{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P U S E R . P A S                                                    ≥
 ≥                                                                         ≥
 ≥ Userdatenbank-Verwaltung                                                ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}




Function OpenIDX (var DatI : UIDx_) : Boolean;
var ior:word;
begin
{$I-}
 assign (DatI, Sys1Pfad+userIDX);
 reset (DatI);
 ior:=ioresult;
 OPenidx:=ior<1;
{$I+}
end;


Function OpenUser(var Dat_ : UDat_) : Boolean;
var ior:word;
begin
{$I-}
 assign (Dat_, Sys1Pfad+userDAtei);
 reset (Dat_);
 ior:=ioresult;
 OPenUser:=ior<1;
{$I+}
end;


Function CloseIDX (var DatI : UIDx_) : Boolean;
var ior:word;
begin
{$I-}
  Close (DATI);
 ior:=ioresult;
 Closeidx:=ior<1;
{$I+}
end;


Function CloseUser(var Dat_ : UDat_) : Boolean;
var ior:word;
begin
{$I-}
 Close(DAt_);
 ior:=ioresult;
 CloseUser:=ior<1;
{$I+}
end;


Function OpenUserBackup(var Dat_ : UDat_) : Boolean;
var ior:word;
begin
{$I-}
 assign (Dat_, Sys1Pfad+userBackup);
 reset (Dat_);
 ior:=ioresult;
 OPenUserBackup:=ior<1;
{$I+}
end;


Function OpenIDXBackup(var Dat_ : UIDX_) : Boolean;
var ior:word;
begin
{$I-}
 assign (Dat_, Sys1Pfad+userBackup);
 reset (Dat_);
 ior:=ioresult;
 OPenIDXBackup:=ior<1;
{$I+}
end;


Function BackupRename (AltNam : Str80) :boolean;
var ior : word;
KD_ : file;
begin
{$I-}
 assign (KD_, sys1pfad+userbackup);
 erase(KD_);
 ior:=ioresult;
 close(KD_);
 ior:=ioresult;
 assign (KD_, AltNam);
 rename (Kd_, sys1pfad+userbackup);
 ior:=ioresult;
  BackupRename := ior<1;
 close(KD_);
 ior:=ioresult;
 {$I+}
end;

Procedure DatensatzHolen(*DatP:Longint; Var UDs: User_typ2*);
var HDat : User_Typ2;
    IDat : User_Idx;
    UD   : udat_;
    UDi  : Uidx_;
    obf, obf2 : boolean;
begin
 obf:=openUser (UD);
 obf2:=Openidx(UDi);
 {$I-}

 if (obf) and (obf2) then
   begin
       Seek(Udi,DatP-1);
       read(udi,IDat);
       Seek(UD, Idat.Pos);
       read(UD, hdat);
       Uds := HDat;
 end;
  obf:=CloseUser(UD);
  obf:=CloseIDX(udi);
 {$I+}
end;

Procedure UserExportieren;
var   Result : Word;
      B      : Byte;
      AnzeigZ,
      i, i1, zaehl  : longint;
      f      : Text;
      Call   : string[9];
      Name,
      Hstr   : string[60];
      Bstr   : string[80];
      flag,
      Loesch : Boolean;
      User2 : User_Typ2;
begin
  anzeigZ:=UserAnz div 20;
  if anzeigZ<10 then anzeigZ:=10;
  if anzeigZ>80 then anzeigZ:=80;
  assign(G^.TFile, NamesDatei);
  FiResult:=RewriteTXT(G^.TFile);
  if (FiResult=0) then
  begin
   zaehl:=0;
   While zaehl<UserAnz do
   begin
     inc(zaehl);
     if (zaehl mod AnzeigZ)=0 then
        WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(288)+' '+int_str(zaehl)+'/'+int_str(UserAnz)));
     DatensatzHolen(zaehl,USER2);
     B:=User2.Umlaut;
     Call:=User2.Call;
     Name:=User2.Name;
     KillEndBlanks(Name);
     Hstr := int_str(B) + B1 + EFillStr(9,B1,Call) + DP + Name;
     Writeln(G^.TFile,Hstr);
   end; (* While *)
   FiResult:=CloseTxt(G^.TFile);
  end;
end;


Procedure DoppelteSuchen;
var   uidx : uidx_;
      uidxb : uidx_;
      dcall, UIdx1, UIdx2, UIdx3   : user_Idx;
      obf:boolean;
      schreib,
      such  : longint;
      written : boolean;
begin

 WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+'Suche DoppelgÑnger ...'));
 obf:=BackupRename(sys1pfad+useridx);
 obf:=OpenIDXBackup (UidxB);
 obf:=OpenIDX (UIDX);
{$I-}
 rewrite(uidx);
 obf:=ioresult<1;
 such:=-1;
 schreib:=-1;
 dcall.call:='';

 while not EOF(uidxb) do
 begin
  written:=false;
  inc(such);
  read(uidxb, uidx1);
  obf:=ioresult<1;
  if dcall.call<>uidx1.call then
   begin
    inc(schreib);
    write(uidx,uidx1);
    obf:=ioresult<1;
    written:=true;
   end;
  if (dcall.call=Uidx1.call) and (dcall.pos>uidx1.pos) then
   begin
    seek(uidx, schreib);
    write(uidx, uidx1);
    written:=true;
   end;
  dcall:=uidx1;
 end;
 {$I+}
 obf:=Closeidx(uidxb);
 obf:=CloseIDX(uidx);
 getuser(such);
end;


Function CheckUeberhang : integer;
var uif : uidx_;
    udb : udat_;
    index,
    daten : longint;
    Prozent:integer;
    Diff : real;
    obf:boolean;

begin
Prozent:=0;

 obf:=Openidx(uif);
 obf:=openuser(udb);
{$I-}
 index:=filesize(uif);
 daten:=filesize(udb);
 if (IOResult = 0) and ((daten>0) and (index>0)) then
  begin
   Diff := Daten-index;
   Prozent := Round((100 / Index) * Diff);
  end;
{$I+}
 CheckUeberhang := Prozent;
 obf:=closeidx(uif);
 obf:=closeuser(udb);
end;



Procedure Reorganisation;
var uif : uidx_;
    udb,
    udbb: Udat_;
    renfile: file;
    uidx: user_idx;
    udbd: user_typ2;
    obf : boolean;
    uzz : longint;

begin
uzz:=0;
if InUDB then WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(401)));
{$I-}
obf:=BackupRename(sys1pfad+userDatei);
obf:=OpenUserBackup (Udbb);
obf:=Openidx(uif);
obf:=OpenUser(udb);
{$I-}
rewrite(udb);
obf:=ioresult<1;
while not eof(uif) do
 begin
  read(uif, uidx);
  seek(udbb, uidx.pos);
  read(udbb, udbd);
  udbd.version1:=1; udbd.version2:=80;
  write(udb, udbd);
  uidx.pos:=uzz;
  seek(uif, uzz);
  write(uif, uidx);
  inc(uzz);
 end;
 obf:=ioresult<1;
{$I+}
 obf:=CloseIdx(uif);
 obf:=closeUser(udbb);
 obf:=closeUser(udb);

end;

Procedure IndexSortieren;
Var   x,i,j  : longInt;
      N      : longint;
      Change : Boolean;
      uidx : uidx_;
      UIdx1, UIdx2, UIdx3   : user_Idx;
      obf:boolean;

Begin
if inUDB then WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(402)));
GetUser(n);
{$I-}
if UserAnz>0 then
begin
obf:=openidx(uidx);
{$I-}
  N := UserAnz;
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
          Seek(UIdx, j-1); read(uidx, UIdx1);
          Seek(UIdx, j+x-1); read(uidx, UIdx2);
          if uidx1.call > UIdx2.Call then
          begin
            UIdx3 := UIdx2;
            UIDx2 := UIDX1;
            UIDX1 := UIDx3;
            Seek(UIdx, j-1); write(uidx, UIdx1);
            Seek(UIdx, j+x-1); write(uidx, UIdx2);
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;
{$I+}
 obf:=ioresult<1;
 obf:=closeidx(uidx);

 end;{if UserAnz>0}

End;



Procedure  UserImportieren; {Importieren einer Names.XP}
Const  maxB = $F000;
       maxPuff = 15;
Var    Nstr,
       Hstr  : String[60];
       Cstr  : string[9];
       anzeigZ,
       udbe, Zaehl, gesamt  : LongInt;
       UHelp : User_Typ2;
       Udb   : udat_;
       uidx  : uidx_;
       uid   : user_idx;
       hi,
       zt, FlagByte:Byte;
       kc:sondertaste;
       vc:char;
       uiarr : array[1..maxpuff] of user_idx;
       utarr : array[1..maxpuff] of user_typ2;
       obf,obf2:boolean;

Begin
 zt:=0;
  Nstr := '';
  Assign(G^.TFile,SysPfad + NamesDatei);
  FiResult:=ioresult;
  FiResult := ResetTxt(G^.TFile);
  zaehl:=0; gesamt:=0;
  if FiResult=0 then
  repeat
   readln(G^.TFile,Hstr);
   if (Hstr<>'') and (length(hstr)>9) then inc(gesamt);
  until (EOF(G^.TFILE));
  anzeigZ:=gesamt div 20;
  if anzeigZ<10 then anzeigZ:=10;
  if anzeigZ>100 then anzeigZ:=100;
  FiResult:=ResetTXT(G^.TFile);
  obf2:=OpenUser(udb);
  obf:=OpenIDx(uidx);
  udbe:=0;
  {$I-}
  if not obf2 then rewrite(udb) else udbe:=filesize(udb);
  if not obf then rewrite(uidx);
  seek(udb, FileSize(UDB));
  seek(uidx, FileSize(Uidx));
  Flagbyte:=ioresult;

  if FiResult=0 then
  begin
  WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(285)+' '+
       int_str(zaehl)+'/'+int_str(gesamt)));
  fillChar(UHelp, sizeOf(Uhelp), 0);
  UHelp.Paclen:=230;
  UHelp.MaxFrames:=2;
  UHelp.MailLesen:='RN';
  UHelp.MailKillen:='KM';
  UHelp.ByeBye:='B';
  UHelp.Vorbereitung:='OP';
  UHelp.Nachbereitung:='OP 12';
  UHelp.Prompt:='';
  for hi:=1 to 15 do uhelp.ssids[hi]:=false;
  uhelp.ssids[0]:=true;
  uhelp.show:=true;
  uhelp.remschreib:=false;
{  UHelp.SSids:='';}
  Repeat

   inc(Zaehl);
    if (zaehl mod anzeigZ)=0 then WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(285)+' '+
       int_str(zaehl)+'/'+int_str(gesamt)));

    Readln(G^.TFile,Hstr);
    Cstr := CutStr(copy(Hstr,3,9));
    UHelp.Call:=UpcaseStr(CStr);
    FlagByte := Byte(str_int('$'+ Hstr[1]));
    if not (FlagByte in UmlMenge) then FlagByte := 0;
    UHelp.Umlaut:=FlagByte;
    delete(Hstr,1,pos(DP,Hstr));
    KillEndBlanks(Hstr);
     UHelp.Name := Hstr;
     Inc(UserAnz);

    if cstr<>'' then
     begin
      inc(zt);
      uiarr[zt].call:=Uhelp.call;
      uiarr[zt].pos:=udbe+zaehl-1;
      utarr[zt]:=uhelp;
     end else dec(zaehl);

    if zt=maxpuff then
     begin
      zt:=0;
      while zt<maxpuff do
       begin
        inc(zt);
        utarr[zt].version1:=1; utarr[zt].version2:=80;
        write(Udb, utarr[zt]);
        write(uidx, uiarr[zt]);
       end;
      zt:=0;
     end;

  Until Eof(G^.TFile);
  end;

  for hi:=1 to zt do
       begin
        utarr[zt].version1:=1; utarr[zt].version2:=80;
        write(Udb, utarr[hi]);
        write(uidx, uiarr[hi]);
       end;
  {$I+}
  obf:=closeuser(UDB);
  obf:=closeidx(uidx);
  FiResult := CloseTxt(G^.TFile);
  getuser(zaehl);
  IndexSortieren;
  DoppelteSuchen;
end;



Procedure GetUser (* Zeile : Str80; ax, Art : Byte *);
Var
      obf   : boolean;
      ud : uidx_;
Begin
 obf:=openidx(UD);
 {$I-}
 if obf then UserAnz:=FileSize(UD) else UserAnz:=0;
 {$I+}
 udi:=1;
 obf:=closeidx(UD);
End;

Function UserSuchroutine (* CallS : Str10; var USu :longint; Sali, Shart:boolean) : Boolean *);
{Sali = Suche Alias - auch den Alias ÅberprÅfen
{Shart = Nur direkter Callvergleich - SSID-genau!}
var
      UHelp : User_idx;
      CallA,
      callD : string[9];
      flaggef,
      obf   : boolean;
      ud : uidx_;
      StichFlag,   {bei stichwortsuche (callanfang) erfolgreich}
      Flag: boolean;
      StichCount,
      count:longint;
      KC:Sondertaste;

begin
 flag:=false;
 StichCount:=0;
 count:=0;
 StichFlag:=false;
 flaggef:=false;
 if CallS<>'' then
  begin
  obf:=OpenIDX(uD);
{$I-}
  CallS:=UpcaseStr(CallS);
  if obf then
   begin
{   if not ESC_Call then }      {//db1ras}
    repeat
     inc(Count);
     Read(UD,Uhelp);
     Flag:= UHelp.Call=CallS;
     if (not flag) and (Sali) then flag:=uhelp.alias=CallS;
     if (not StichFlag) and (not SHart) then
      begin
       StichFlag:=Pos(CallS,Uhelp.Call)=1;
       if stichflag then StichCount:=Count;
       if (not stichflag) and (Sali) then stichflag:=Pos(callS, uhelp.alias)=1;
      end;
    until (Flag) or (Eof(UD));
    if (not Flag) and (not Shart) then
     begin
      reset(UD);
      count:=0;
      Strip(CallS);
      repeat
       inc(Count);
       Read(UD,Uhelp);
       Flag:= UHelp.Call=CallS;
       if (not flag) and (Sali) then flag:=uhelp.alias=calls;
      until (Flag) or (Eof(UD));
     end;
    if (not Flag) and (not Shart) then
     begin
      reset(UD);
      count:=0;
      Strip(CallS);
      repeat
       inc(Count);
       Read(UD,Uhelp);
       CallD:=UHelp.Call;
       calla:=uhelp.alias;
       strip(calla);
       Strip(CallD);
       Flag:= CallD=CallS;
       if (not flag) and (Sali) then flag:=calla=calls;
      until (Flag) or (Eof(UD));
     end;
   end;
 {$I+}
 obf:=Closeidx(ud);
 if Flag then Usu:=count else USu:=1;
 if not inudb then stichflag:=false;
 If (StichFlag) and (Usu=1) then USu:=StichCount;
 end;

 if Flag or StichFlag then flaggef:=true else flaggef:=false;
 UserSuchRoutine:=flaggef;
end;


Function UserSuchen (* VAR USuch:Longint; SCall:string; Salias:Boolean *);
Var
      UHelp : User_idx;
      callD,
      CallS  : string[9];
      obf   : boolean;
      ud : uidx_;
      StichFlag,   {bei stichwortsuche (callanfang) erfolgreich}
      Flag: boolean;
      StichCount,
      count:longint;
      KC:Sondertaste;
Begin
  Calls:='';
 if SCall='' then
 begin
  WriteRam(1,MaxZ-1,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(289)));
  GetString(CallS,Attrib[5],9,length(InfoZeile(289))+4,MaxZ-1,KC,1,Ins);
 end else CallS:=SCall;
 if kc=_ESC then Calls:='' else flag:=UserSuchroutine(CallS,Usuch, Salias,false);
 if flag then UserSuchen:=true else UserSuchen:=false;
End;


procedure PutUser (*Neu: User_typ2; Var Resultat:byte; VAR _Dpos:longint; Shard:boolean*);
{SHard wird an UserSuchRoutine weitergegeben: True: absolute suche, False: flexibel}
Var
      UsFile: udat_;
      Usidx:uidx_;
      IDXNeu,
      UHelp  : User_idx;
      uhelp_ : user_typ2;
      uhelp2 : user_typ2;
      dummy,
      leer,
      backup,
      backup2,
      written : boolean; {ist der Neue schon geschrieben??}
      vorh_merk,  {dauermerker fÅr vari vorhanden > fÅrs resultat!}
      vorhanden:boolean; {datensatz war vorhanden}
      savuzz,
      UdHi,
      uzz:longint;
      obf:boolean;



Begin
resultat:=0;
 getuser(Uzz);
  written:=false;
  vorhanden:=false;
  vorh_merk:=false;
  backup:=false;
 obf:=ioresult<1;

if typ>0 then begin
 neu.ssids[0]:=true;
 neu.show:=true;
 neu.RemSchreib:=false;
end;

udhi:=0;
 obf:=openuser(Usfile);
 {$I-}
  if useranz>0 then
    UdHi:=FileSize(USFile)
   else rewrite(usfile);

  IDXNeu.Call:= Neu.Call;
  IDXNeu.Alias:=Neu.Alias;
  IDXNeu.Pos := UDHI;

 obf:=ioresult<1;
{$I+}
if not obf then backup:=false else backup:=true;
 obf:=Openidx(USidx);
{$I-}
 if not obf then rewrite(usidx);
 obf:=ioresult<1;
 uzz:=0;
 uhelp.CALL:='';
 backup2:=backup;
 if obf then
  begin
  { while (backup2) and (userAnz>uzz) do}
  if (backup2) and (useranz>uzz) then
    begin
     {backup2:=not EOF(UsIDX);}
    { inc(uzz);
     leer:=false;
     if backup2 then read(USIDX, UHelp) else Uhelp.Call:='';
     if Uhelp.Call='' then leer:=true;}

     if UserSuchroutine (neu.call, Uzz, true, shard) then

     {if (Neu.call<>'') and (Neu.call=UHelp.Call) and (not Written) then}
      begin
        SavUZZ:=uzz;
         written:=true;
          seek(Usidx, uzz-1);
          read(USidx, UHelp);
          seek(UsFile, UHelp.Pos);
          read(usfile, uhelp_);
          seek(usidx, uzz-1);
          seek(UsFile, UHelp.Pos);
         { if uhelp.alias<>neu.alias then
           begin}
           uhelp.alias:=idxneu.alias;
           UHelp.Call:=idxneu.call;
           write(Usidx,uhelp);
           {end;  }
        if typ=1 then
         begin
          Uhelp2:=Neu;
          Neu:=UHelp_;
          Neu.Name:=Uhelp2.Name;
         end;
        if typ=2 then
         begin
          Uhelp2:=Neu;
          Neu:=UHelp_;
          Neu.Locator:=Uhelp2.Locator;
          if neu.call='' then neu.call:=uhelp2.call;
         end;
        if typ=3 then
         begin
          Uhelp2:=Neu;
          Neu:=UHelp_;
          Neu.QTH:=Uhelp2.QTH;
          if neu.call='' then neu.call:=uhelp2.call;
         end;
        if typ=4 then
         begin
          Uhelp2:=Neu;
          Neu:=UHelp_;
          Neu.Umlaut:=Uhelp2.Umlaut;
          if neu.call='' then neu.call:=uhelp2.call;
         end;
        if Neu.MaxFrames<1 then Neu.MaxFrames:=Konfig.MaxFrameStd;
        if Neu.Paclen<10 then Neu.PacLen:=Konfig.PacLenStd;
        if (typ=0) or (not neu.RemSchreib) then
         begin
         neu.version1:=1; neu.version2:=80;
          write(usfile, neu)
         end
         else resultat:=10;
        vorhanden:=true;
        vorh_merk:=true;
      end;
    end;
   if not written then
    begin
     if Neu.MaxFrames<1 then Neu.MaxFrames:=Konfig.MaxFrameStd;
     if Neu.Paclen<10 then Neu.PacLen:=Konfig.PacLenStd;
     seek(USIdx,filesize(usidx));
{     read(usidx,uhelp);}
     write(UsIdx, idxNeu);
     Seek(Usfile,FileSize(Usfile));
     {read(Usfile,uhelp_);}
     neu.version1:=1; neu.version2:=80;
     write(usfile, neu);
    end;
  end;
{$I+}
obf:=closeuser(usfile);
obf:=closeidx(usidx);

if vorh_merk then
 begin
   if resultat<>10 then resultat:=1;
   _DPos:=SavUZZ;
 end
  else
   begin
    IndexSortieren;
    resultat:=0;
    _Dpos:=1;
    if inudb then dummy:=UserSuchen(_Dpos, idxneu.call,false);
   end;
End;

Procedure NeuNameSave (* User2:User_typ2; Var Result:Byte *);
var Dummy:longint;
begin
 PutUser(User2, Result,1,dummy,false);
end;

  Function UserTagged(TDP:longint;UserT:UsersTag) : Boolean;
   var i:byte;
       uti:boolean;
  begin
   uti:=false;
   i:=1;
   Repeat
    if UserT^[i]=TDP then uti:=true;
    inc(i);
   until (i>MaxUTag) or (uti);
   userTagged:=uti;
  end;



Procedure KillTaggedUser(UserTag_:UsersTag);
Var
      UsFile,
      UsFileB: uidx_;
      UHelp  : User_idx;
      backup2,
      backup,            {backup vorhanden}
      written : boolean; {ist der Neue schon geschrieben??}
      vorhanden:boolean; {datensatz war vorhanden}

      uzz:longint;
      obf:boolean;

Begin
  written:=false;
  vorhanden:=false;
  backup:=false;
  obf:=BackupRename(Sys1Pfad+UserIDX);
  obf:=Openidxbackup(usfileb);

 if not obf then backup:=false else backup:=true;
 obf:=Openidx(UsFile);

{$I-}
 rewrite(usfile);
 obf:=ioresult<1;
 uzz:=0;
 uhelp.CALL:='';
 backup2:=backup;
 if obf then
  begin
   while (backup2) and (userAnz>uzz) do
    begin
     backup2:=not EOF(UsFileB);
     inc(uzz);
     if backup2 then read(USFileB, UHelp);
     if not UserTagged(uzz,userTag_) then write(UsFile, UHelp);
    end;
  end;
{$I+}
obf:=closeidx(usfileb);
obf:=closeidx(usfile);
end;




Procedure KillUser (* Zeile : Str80; ax, Art : Byte *);
Var
      UsFile,
      UsFileB: uidx_;
      UHelp  : User_idx;
      backup2,
      backup,            {backup vorhanden}
      written : boolean; {ist der Neue schon geschrieben??}
      vorhanden:boolean; {datensatz war vorhanden}

      uzz:longint;
      obf:boolean;

Begin
  written:=false;
  vorhanden:=false;
  backup:=false;
  obf:=BackupRename(Sys1Pfad+UserIDX);
  obf:=Openidxbackup(usfileb);

 if not obf then backup:=false else backup:=true;
 obf:=Openidx(UsFile);

{$I-}
 rewrite(usfile);
 obf:=ioresult<1;
 uzz:=0;
 uhelp.CALL:='';
 backup2:=backup;
 if obf then
  begin
   while (backup2) and (userAnz>uzz) do
    begin
     backup2:=not EOF(UsFileB);
     inc(uzz);
     if backup2 then read(USFileB, UHelp);
     if uzz<>UserKilled then write(UsFile, UHelp);
    end;
  end;
{$I+}
obf:=closeidx(usfileb);
obf:=closeidx(usfile);
end;


Function MarkUserStr (Nr : longint; Sp,Dart : Byte; TagUs:Boolean)  : Str80;
var UDummy2,
    UDummy : String[14];
    MUS    : String[80];
    UHelp  : User_typ2;
    ENTFG,RICHTG : real;
    STATUS:boolean;


Begin
  if (Nr>UserAnz) or (Nr=0) then MarkUserStr :=''
   else
   begin
    DatensatzHolen(nr, UHelp);
    With UHelp do
     begin
           if Not TagUs then MUS := +B1+EfillStr(11,B1,Call)
           else MUS := #16+EfillStr(11,B1,Call);
           MUS := MUS+EfillStr(11,B1,Alias);
           UDummy:=Name;
           if length(Name)>14 then
                       UDummy := copy(EfillStr(11,B1,Name),1,11)+'...';
           MUS:=MUS+Efillstr(15,B1,UDummy);
           UDummy:=QTH;
           if length(QTH)>14 then
                       UDummy := copy(EfillStr(11,B1,QTH),1,11)+'...';
           MUS:=MUS+Efillstr(15,B1,UDummy);
           MUS:=MUS+EfillStr(7,B1,UpcaseStr(Locator));

      case DArt of
       1: begin
           MUS:=MUS+EfillStr(3,B1,Int_Str(Umlaut));
           UDummy:=' ';
           if VIP then UDummy:=#254 else UDummy:=' ';
           MUS:=MUS+EfillStr(3,B1,UDummy);
           if Anwesenheit then UDummy:=#254 else UDummy:=' ';
           MUS:=MUS+EfillStr(3,B1,UDummy);
           MUS:=MUS+EfillStr(10,B1,System);
          end; {1}
       2: begin
           Udummy:=Locator;
           UDummy2:=Konfig.PersLoc;
           if (udummy<>'') and (udummy2<>'') then
            begin
             QTH_ENTFG_RICHTG(UDummy2,UDummy,ENTFG,RICHTG,STATUS);
             str(Richtg:0:1,UDummy);
             MUS:=MUS+SFillStr(6,B1,Udummy);
             str(Entfg:0:1,UDummy);
             MUS:=MUS+SFillStr(13,B1,Udummy);
            end else
            begin
             MUS:=MUS+SFillStr(6,B1,'?');
             MUS:=MUS+SFillStr(13,B1,'?');
            end;
          end; {2}
     end; {case}
     MarkUserStr:=MUS;
   end;
   end;
End;


Procedure UserZeigen (* Kanal : Byte; VAR Call2:Str9 *);
Const  Bofs = 1;
Var    X : longint;
       Ueberhang:integer;
       SCall : str10;
       UeberHStr : string[30];
       AnzTags,
       HilfsByte,
       yM,
       Bpos,
       Zmax   : Byte;
       fz:file;
       NeuDpos,
       SavDpos,
       Dpos   : longint;
       w,w1,
       AnzM,
       Result : longint;
       DummyB,
       Flag,
       Fertig : Boolean;
       KC     : Sondertaste;
       VC,
       VA     : Char;
       f      : Text;
       Eing   : String;
       Hstr,
       Sstr,
       Pfad,
       XPfad  : String[80];
       UHelp  : user_typ2;
       UserTag:  Userstag;




  Procedure DirPage(beg : Longint);
  Var      i : Byte;
  Begin

    for i := 1 to Zmax do
     begin

      WriteRam(1,i+Bofs,Attrib[2],1,EFillStr(80,B1,MarkUserStr(beg-1+i,1,G^.Dart,UserTagged(beg-1+i,userTag))));
     end;

    WriteRam(1,maxZ,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(226)));
  End;

  Procedure WartenSchirm;
  Var      i : Byte;
  Begin
    if G^.DArt=1 then WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(195)))
           else WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(405)));
    for i := 1 to Zmax do WriteRam(1,i+1,Attrib[2],1,EFillStr(80,B1,' '));

    WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(230)));
    WriteRam(1,maxZ-1,Attrib[5],1,B1+EFillStr(80,B1,B1+InfoZeile(209)) );
    WriteRam(1,maxZ,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(226)));
  End;

  Procedure GetCursorLine;
  Begin
    WriteRam(1,Bpos+Bofs,Attrib[4],1,EFillStr(80,B1,MarkUserStr(Dpos,1,G^.Dart,UserTagged(DPOS,usertag))));
  End;

  Procedure RestAuflisten;
  var i: byte;
      i2:longint;
  Begin
   i2:=DPos;
   for i:=BPos to zmax do
    begin
     WriteRam(1,i+Bofs,Attrib[2],1,EFillStr(80,B1,MarkUserStr(i2,1,G^.Dart,UserTagged(i2,usertag))));
     inc(I2);
    end;
  End;

  Procedure InitStart(Art : Byte; Bstr : Str12);
  Var    w    : longint;

         Flag : Boolean;
         Vpos : Byte;
         udi   : longint;
         call1,
         call2: string[8];
  Begin
   WartenSchirm;
    Vpos := Bpos;
    yM := 1;
    Bpos := 1;
    Dpos := 1;
    AnzM := 0;
    GetUser(udi);
    if Art = 1 then
     begin
      if flag then DPos:=udi;
      DirPage(Dpos);
     end;
  End;

  Procedure CursorDn;
  Begin
    if Dpos < UserAnz then
    begin
     SCall:='';
      inc(Dpos);
      if Bpos < Zmax then inc(Bpos) else
      begin
        WriteAttr(1,yM+Bofs,80,Attrib[2],1);
        Scroll(Up,1,1+Bofs,Zmax+Bofs);
        WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkUserStr(Dpos,1,G^.Dart,userTagged(DPos,usertag)));
      end;
    end else Alarm;
  End;

 Procedure TagEintragen (VAR Typ:Byte);
 var Ti:byte;
     tif1, tif:boolean;
 begin
  tif1:=false;
  tif:=false;
  ti:=1;
  repeat
   if UserTag^[ti]=DPos then
    begin
     TIF1:=true;
     UserTag^[ti]:=-1;
     dec(AnzTags)
    end;
    inc(ti);
  until (Tif1) or (Ti>MaxUTag);

  if (not Tif1) then
  begin
  ti:=1;

  repeat
   if UserTag^[ti]=-1 then
    begin
     TIF:=true;
     UserTag^[ti]:=DPos;
     Inc(AnzTags);
    end;
   inc(ti);
  until (Tif) or (Ti>MaxUTag);

  end;

  if Tif then Typ:=1; {Neuer eingetragen}
  if Tif1 then Typ:=2; {Alter gelîscht}
  if (not Tif) and (Not Tif1) then Typ:=0; {kein platz mehr!}

 end;

Begin
New(UserTag);
 For Result:=1 to maxUTag do UserTag^[result]:=-1;
 AnzTags:=0;

 SCall:='';
  UeberHStr:=InfoZeile(400);

  MailAusUDB:=false;
  Moni_Off(0);
  DirScroll := true;
  NowFenster := false;
  Zmax := maxZ - 3;
  Fertig := false;
  X := 1;

  Ueberhang:=CheckUeberhang;
  if (K[Kanal]^.connected) or (K[Kanal]^.test) then
   begin
    GetUser(DPos);
    dummyB:=UserSuchen (DPos, K[Kanal]^.Call,true);
    yM := 1;
    AnzM := 0;
    BPos:=1;
    DirPage(Dpos);
   end else InitStart(1,'');
  WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);
  INUdb:=true;
  Repeat
    if Ueberhang>99 then
     begin
     Reorganisation;
      initstart(1,'');
      Ueberhang:=CheckUeberhang;
     end;
    InitCursor(X,Bpos+Bofs);
    hstr:=int_Str(DPos);
    if UserAnz=0 then hstr:='0';
    WriteRam(1,maxZ-1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(209)+' '+hstr+'/'+int_str(UserAnz)));
    WriteRam(80-(length(UeberHStr)+4)-12,maxZ-1,Attrib[5],1,efillStr(9,'_',Scall)+'   '+EFillStr(length(UeberHStr)+4,B1,
             UeberHStr+' '+int_str(Ueberhang)+'%'));
    if G^.DArt=1 then WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(195)))
           else WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(405)));

    getCursorline;
    _ReadKey(KC,VC);

    case KC of
      _Back
       : begin
          if length(scall)>0 then
           begin
            delete(scall, length(scall),1);
            if length(Scall)>0 then
             begin
              flag:=UserSuchroutine(sCall,DPos,false,false);
              BPos:=1;
              DirPage(Dpos);
             end;
           end else Alarm;
         end;
      _Esc
       : begin
           Fertig := true;
         end;

      _Right, _Left:
         begin
          if G^.DArt=2 then G^.DArt:=1 else G^.DArt:=2;
          if G^.DArt=1 then WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(195)))
           else WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(405)));
          DirPage(DPos-bpos+1);
         end;

      _Dn
       : begin
          CursorDn;
         end;

      _Up
       : if Dpos > 1 then
         begin
          SCall:='';
           dec(Dpos);
           if Bpos > 1 then dec(Bpos) else
           begin
             WriteAttr(1,yM+Bofs,80,Attrib[2],1);
             Scroll(Dn,1,1+Bofs,Zmax+Bofs);
             WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkUserStr(Dpos,1,G^.Dart,userTagged(DPos,usertag)));
           end;
         end else Alarm;

      _PgDn
       : if Dpos < UserAnz then
         begin
          SCall:='';
           if Dpos + Zmax - Bpos >= UserAnz then
           begin
             Bpos := BPos+(useranz-Dpos);{Zmax;}
             Dpos := UserAnz;
             if Bpos > UserAnz then Bpos := UserAnz;
           end else
           begin
             Dpos := Dpos + Zmax - 1;
             if Dpos + Zmax - 1 > UserAnz then Dpos := UserAnz - Zmax + Bpos;
             DirPage(Dpos - Bpos + 1);
           end;
         end else Alarm;

      _PgUp
       : if Dpos > 1 then
         begin
         SCall:='';
           if Dpos <= Bpos then
           begin
             Dpos := 1;
             Bpos := 1;
           end else
           begin
             Dpos := Dpos - Zmax + 1;
             if Dpos - Zmax + 1 < 1 then Dpos := Bpos;
             DirPage(Dpos - Bpos + 1);
           end;
         end else Alarm;

      _Home
       : if Dpos > 1 then
         begin
           SCall:='';
           Dpos := 1;
           Bpos := 1;
           DirPage(1);
         end else Alarm;

      _End
       : if Dpos < UserAnz then
         begin
           SCall:='';
           Dpos := UserAnz;
           Bpos := Zmax;
           if Bpos > UserAnz then Bpos := UserAnz;
           DirPage(Dpos - Bpos + 1);
         end else Alarm;

{      _CtrlHome
       : begin
           SCall:='';
           Pfad := copy(Pfad,1,3);
           InitStart(1,'');
         end;}

{      _Right
       : if HardCur then
         begin
           if X < 80 then inc(X) else Alarm;
         end else Alarm;

      _Left
       : if HardCur then
         begin
           if X > 1 then dec(X) else Alarm;
         end else Alarm;
 }
      _CtrlPgUp,
      _Ret
       : if useranz>0 then
         begin
          SCall:='';
          SavDPos:=Dpos;
          DatensatzHolen(DPos, UHelp);
          Neudpos:=Dpos;
          UserEditieren(UHelp, Kanal, false, Maxz, NeuDPos);
          if NeuDpos<>Dpos then
           begin
            GetUser(DPos);
            yM := 1;
            AnzM := 0;
            BPos:=1;
            BPos:=1;
            DPos:=NeuDPos;
           end;
           if DPos=UserAnz then
            begin
             if DPos>ZMax then Bpos:=ZMax;
             DirPage(Dpos-Bpos+1);
            end else
             DirPage(Dpos-Bpos+1);
            Ueberhang:=CheckUeberhang;
         end else alarm;

      _altd, _del
       : begin
          SCall:='';
          if UserAnz>0 then
          begin
           SavDpos:=Dpos;
           if (SiAltD) then
            begin
             WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(224)));
             _ReadKey(KC,VC);
            end;
           if (KC = _Ret) or (UpCase(VC) in YesMenge) or (not SiAltD) then
           begin
            userkilled:=dpos;
            if AnzTags=0 then KillUser
             else
             begin
              KillTaggedUser(UserTag);
              For Result:=1 to MaxUTag do UserTag^[result]:=-1;
              AnzTags:=0;
              Dpos:=1;
              UserKilled:=1;
              Savdpos:=1;
             end;
           { InitStart(1,'');}
            Ueberhang:=CheckUeberhang;
            GetUser(DPos);
            if UserAnz>savDpos then
             begin
              DPos:=SavDpos;

              if ((UserAnz-dpos)<ZMax) and (userAnz>=ZMax) then
               begin
                BPos:=ZMax-(UserAnz-dPos);
                DirPage(Dpos-Bpos+1);
               end else RestAuflisten;
             end
             else
              begin
               DPOs:=UserAnz;
               BPos:=ZMax;
               if UserAnz<ZMax then BPos:=UserAnz;

               if userAnz<1 then
                begin
                 Bpos:=1;
                 Dpos:=1;
                end;
               DirPage(Dpos-Bpos+1);
              end;
           { yM := 1;
            AnzM := 0;
            BPos:=1;
            DirPage(Dpos);}
           end;
         end;
         end;

      _ALTE {EXport}
       : begin
          SCall:='';
          UserExportieren;
          initstart(1,'');
         end;

      _altr:
       begin
        SCall:='';
        Reorganisation;
        initstart(1,'');
        Ueberhang:=CheckUeberhang;
       end;
      _AltH
       : XP_Help(G^.OHelp[95]);

      _ALTI {IMport}
       : begin
          SCall:='';
          UserImportieren;
          initstart(1,'');
          Ueberhang:=CheckUeberhang;
         end;

      _altN, _INS
       : begin
        SCall:='';
          SavDPos:=Dpos;
            fillchar(UHElp,sizeof(uhelp),0);
          uhelp.ssids[0]:=true;
          NeuDpos:=SavdPos;
            UserEditieren(UHelp, Kanal, true,MaxZ,NeudPos);
            GetUser(DPos);

           Dpos:=SavDpos;
           if NeuDpos<>Dpos then
           begin
            yM := 1;
            AnzM := 0;
            BPos:=1;
            if userAnz<MaxZ then BPos:=NeuDPos;
            DPos:=NeuDPos;
           end;
           if ((UserAnz-dpos)<ZMax) and (userAnz>ZMax) then
             begin
               BPos:=ZMax-(UserAnz-dPos);
             end;
           if DPos=UserAnz then
            begin
             if DPos>ZMax then Bpos:=ZMax else BPos:=USerAnz;
             DirPage(Dpos-Bpos+1);
            end else
             {if ((UserAnz-dpos)>ZMax) and (userAnz<ZMax) then}DirPage(Dpos-Bpos+1);

            Ueberhang:=CheckUeberhang;
         end;

      _ALTP
       : Begin
          DatensatzHolen(DPos, UHelp);
          Call2:=UHelp.Call;
          MailSynonym:=UHelp.Synonym;
          MailAusUDB:=true;
          Fertig:=TRUE;
          MailBoxCall:=Uhelp.Call;
         end;

      _ALTS
       : begin
          DummyB:=UserSuchen(DPOs,'',false);
          if dummyB then Scall:='';
          BPos:=1;
          DirPage(Dpos);
         end;
      else case VC of
    #65..#90,#97..#122,#48..#57,#45
       : begin
          if length(Scall)<9 then
           begin
            SCall:=SCall+Upcase(VC);
            flag:=UserSuchroutine(sCall,DPos,false,false);
            BPos:=1;
            {if UserAnz<(Dpos+Zmax) then
             ZMax:=UserAnz-DPos;        }
            DirPage(Dpos);
            vc:=#0;
           end else alarm;
         end;
       #32: begin
             TagEintragen(HilfsByte);
             WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkUserStr(Dpos,1,G^.Dart,userTagged(DPos,usertag)));
             if Hilfsbyte in [1,2] then CursorDn else Alarm;
            end;
      end;


    end;

    WriteAttr(1,yM+Bofs,80,Attrib[2],1);
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);
    yM := Bpos;
  Until Fertig;
  UserAnwesend;
  DirScroll := false;
  Moni_On;
  InUDB:=false;
  Dispose(UserTag);

  UserInStatus(kanal);   {//db1ras}
End;


Procedure UserAnwesend;
type ACalls_ = record
                call:str9;
                ssid:byte;
               end;
var HDat : User_Typ2;
    UD   : udat_;
    udi  : uidx_;
    idat : user_idx;
    KCall:str9;
    ACalls : array[1..MaxAnwesend] of acalls_;
    i: byte;
    obf2,
    obf:boolean;
    dada: longint;
begin
 dada:=0;
  {$I-}
 obf:=OpenUser(UD);
 obf2:=Openidx(udi);
 reset(udi);
 for i:=1 to MaxAnwesend do
  begin
   ACalls[i].Call:='';
   ACalls[i].SSid:=0;
  end;

 for i:=1 to MaxAnwesend do
  begin
   if Anwesend[i]^.Da then
    begin
     inc(dada);
     acalls[dada].ssid:=0;
     if pos('-', Anwesend[i]^.Call)>0 then
        acalls[dada].ssid:=str_int(Copy(Anwesend[i]^.call,pos('-',anwesend[i]^.call)+1, length(Anwesend[i]^.call)));
     strip(Anwesend[i]^.call);
     ACalls[dada].call:=Anwesend[i]^.Call;
    end;
   Anwesend[i]^.Call:='';
   Anwesend[i]^.DA:=False;
  end;
 dada:=0;

 if (obf) and (obf2) then
   begin
   while (not EOF(UDi)) and (dada<100) do
    begin
     read(udi, idat);
     seek(ud, idat.pos);
     read(UD, HDat);
     if Hdat.Anwesenheit then
      begin
       inc(dada);
       Anwesend[dada]^.Call:=Hdat.Call;
       strip(Anwesend[dada]^.call);
       Anwesend[dada]^.da:=false;
       for i:=1 to MaxAnwesend do
         if (Anwesend[dada]^.Call=Acalls[i].call) and
            (hdat.ssids[acalls[i].ssid]) then
          begin
           Anwesend[dada]^.da:=true;
          end;

       for i:=0 to 15 do
        begin
         anwesend[dada]^.ssids[i]:=16;
         if HDat.SSIDs[i] then Anwesend[dada]^.ssids[i]:=i;
        end;
      end;
     end;

 end;
 {$I+}
 obf:=closeidx(UDI);
 obf:=closeuser(UD);

 for i:=1 to MaxAnwesend do
 begin
  for dada:=1 to maxLink do
  begin
  if K[dada]^.connected then
  begin

   KCall:=K[dada]^.Call;
   strip(KCall);
    if (KCall=Anwesend[i]^.Call) or (K[dada]^.Call=Anwesend[i]^.Call) then
     begin
      Anwesend[i]^.call:='';
      Anwesend[i]^.da:=false;
     end;

  end;
  end;
 end;

  scan_:=false;

  for i:=1 to Maxanwesend do if Anwesend[i]^.da then Scan_:=true;

{ if show>0 then
  begin
  for i:=1 to Maxanwesend do
  begin
   _aus(Attrib[18],2,Anwesend[i]^.call+'/');
   if (i mod 7)=0 then _aus(Attrib[18],2,#13)
  end;
  _aus(Attrib[18],2,#13+'--------'+#13)
 end;}
end;



Function UserShow (* Kanal,Suche *);
Var
      UHelp : User_idx;
      UH    : User_Typ2;
      SLoc, SQTH:String[31];
      callD,
      CallS  : string[9];
      obf   : boolean;
      ud : uidx_;
      uf : udat_;
      Flag: boolean;
      count:longint;
Begin
  Calls:=Suche;
  Flag:=false;
  obf:=openuser(uf);
  obf:=openidx(ud);
  CallS:=UpcaseStr(CallS);
{$I-}
  if obf then
   begin
    repeat
     Read(UD,Uhelp);
     if Pos(CallS,Uhelp.Call)=1 then
      begin
       seek(UF,UHelp.Pos);
       Read(UF,UH);
       if UH.Show then
        begin
         if not Flag then S_PAC(Kanal,NU,false,M1 + InfoZeile(5) + M1 + ConstStr('-',29) + M1);
         Flag:=true;

         if UH.QTH='' then sQTH:=InfoZeile(390) else sqth:=uh.qth;
         if uh.locator='' then sloc:=InfoZeile(391) else sloc:=uh.locator;
         S_PAC(Kanal,NU,false,EFillStr(9,b1,UH.Call) + ': ' + Uh.Name+', '+sqth+', '+sloc+m1);
        end;
      end;
    until (Eof(UD));
   end;
  {$i+}
  obf:=closeidx(UD);
  obf:=closeuser(uf);
  UserShow:=flag;
End;
