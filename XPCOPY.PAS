{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P C O P Y . P A S                                                    ³
 ³                                                                         ³
 ³ Filekopier-Routinen                                                     ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure FileKopieren (* Var Zeile : String *);
Var    i,i1,i2,
       Anzahl      : Integer;
       fq,fz       : File;
       Par         : Array[1..3] of String[80];
       Hstr,Joker  : String;
       srec        : SearchRec;
       maxPuffer   : Word;


    
    Procedure Kopieren(von,nach : String);
    Var  rResult,
         wResult : Word;
         Attr    : Word;
         FTime   : LongInt;

    Begin
      Assign(fq,von);
      GetFAttr(fq,Attr);
      SetFAttr(fq,$20);

      Assign(fz,nach);

      if ResetBin(fq,T) = 0 then
      begin
        GetFTime(fq,FTime);
        if RewriteBin(fz,T) = 0 then
        begin
          Repeat
            Blockread(fq,Page^,maxPuffer,rResult);
            BlockWrite(fz,Page^,rResult,wResult);
          Until Eof(fq);
          SetFTime(fz,FTime);
          FiResult := CloseBin(fz);
          SetFAttr(fz,Attr);
        end else dec(Anzahl);
        FiResult := CloseBin(fq);
      end else dec(Anzahl);
    End;


Begin
  if MaxAvail > maxNotChBuf then maxPuffer := maxNotChBuf
                            else maxPuffer := MaxAvail - 1024;
  GetMem(Page,maxPuffer);
  FillChar(Page^,maxPuffer,0);

  for i := 1 to 3 do Par[i] := ParmStr(i,' ',Zeile);

  if pos(DP,Par[1]) = 0 then Par[1] := Par[3] + Par[1];
  if pos(DP,Par[2]) = 0 then Par[2] := Par[3] + Par[2];

  if not (((pos(Pkt ,Par[2]) > 0) and (pos('*',Par[1]) > 0))) then
  begin
    Joker := '';
    i := length(Par[1]);
    While (Par[1][length(Par[1])] <> BS) and (length(Par[1]) > 0) do
    begin
      Joker := Par[1][i] + Joker;
      delete(Par[1],length(Par[1]),1);
      dec(i);
    end;
    if pos(Pkt ,Par[2]) = 0 then
    begin
      if Par[2][length(Par[2])] <> BS then Par[2] := Par[2] + BS;
    end;

    if PfadOk(1,Par[2]) then
    begin
      Anzahl := 0;
      FindFirst(Par[1] + Joker,AnyFile-Directory,srec);
      While DosError = 0 do
      begin
        inc(Anzahl);
        if pos(Pkt ,Par[2]) = 0 then
        begin
          Hstr := Par[2] + srec.Name;
        end else Hstr := Par[2];
        if Hstr <> (Par[1] + srec.Name) then Kopieren(Par[1] + srec.Name,Hstr) else
        begin
          dec(Anzahl);
        end;
        Hstr := '';
        FindNext(srec);
      end;
      str(Anzahl,Hstr);
      Zeile := Hstr + ' ' + InfoZeile(315);
    end else Zeile := InfoZeile(316);
  end else Zeile := InfoZeile(317);
  FreeMem(Page,maxPuffer);
End;


Procedure Delete_Datei (* var Zeile : str80 *);
var    Anzahl   : Word;
       f,fd     : Text;
       Hstr     : String[80];
       srec     : SearchRec;

Begin
  Anzahl := 0;
  Hstr := Zeile;
  While (length(Hstr) > 3) and (Hstr[length(Hstr)] <> BS)
  do delete(Hstr,length(Hstr),1);
  if Hstr[length(Hstr)] <> BS then Hstr := '';
  FindFirst(Zeile,AnyFile-Directory,srec);
  While DosError = 0 do
  begin
    Assign(fd,Hstr + srec.Name);
    if EraseTxt(fd) = 0 then inc(Anzahl);
    FindNext(srec);
  end;
  Zeile := int_str(Anzahl) + B1 + InfoZeile(35);
End;
