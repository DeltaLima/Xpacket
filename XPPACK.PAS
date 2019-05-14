{$A+,B-,D+,E+,F-,I-,L+,N+,O-,R-,S-,V-}
{$M 16384,0,655360}
program LZH_Test;
uses
  dos,crt,LZH;
CONST
{ MaxInstall = 20;
 PackDats : array [1..maxInstall] of String[12] =
       ('160_170.TXT', 'LOGO.XP', 'MSGS.XP',     'CMD.XP',
        'REMOTES.XP',
        'ONLHELP.XP',  'XPSETHLP.XP', 'UPDATE.EXE',
        'LINKS.XP',    'LOG.XP'   ,   'USER.XP',
        'PASSWORD.XP', 'TEXT.XP'    , 'TNC.XP',
        'CALLS.XP',    'COLOR.XP'   , 'COOKIE.XP',
        'QRG.XP',      'XPACKSET.EXE', 'XPACKET.EXE');
 }

 MaxInstall = 65;
 PackDats : array [1..maxInstall] of String[12] =
        ('V181.txt', 'MSGS.xp',     'XPACKSET.exe', 'UPDATE.exe',
        'XPACKET.exe',  'ONLHELP.xp', 'XPSETHLP.xp', 'LOGO.xp', 'XP.ico',
        'CMD.xp',

        'A.SPK','B.SPK','C.SPK','D.SPK','E.SPK','F.SPK','G.SPK','H.SPK','I.SPK','J.SPK',
        'K.SPK','L.SPK','M.SPK','N.SPK','O.SPK',
        'P.SPK','Q.SPK','R.SPK','S.SPK','T.SPK','U.SPK','V.SPK','W.SPK','X.SPK','Y.SPK',
        'Z.SPK','0.SPK','1.SPK','2.SPK','3.SPK','4.SPK',
        '5.SPK','6.SPK','7.SPK','8.SPK','9.SPK','10.SPK',
        '11.SPK','12.SPK','13.SPK','14.SPK','15.SPK','_.SPK','!.SPK',

        'REMOTES.xp',

	'LINKS.xp',    'LOG.xp'   ,
	'PASSWORD.xp', 'TEXT.xp'    , 'TNC.xp',
	'CALLS.xp',    'COLOR.xp'   , 'COOKIE.xp',
	'QRG.xp',

        'USER.xp');


  procedure OpenInput (fn: String);
  begin
    assign(infile,fn); reset(infile,1);
    if IoResult>0 then Error('! Can''t open input file');
    inbuf:= @ibuf;
    ReadToBuffer:= ReadNextBlock;
    ReadToBuffer;
  end;


begin {main}
comp:=false; decomp:=false;
{   if ParamCount<>1 then begin
     writeln('Usage: lz e(compression)|d(uncompression) infile');
     HALT(1)
   end;}

   PackDat:=ParamStr(3);
   SourceDat:=ParamStr(2);

   s:= ParamStr(1);
   case s[1] of
     'e','E':begin
              {sourceDat:=DirInfo.Name;}
              OpenOutput('XPPACK.XPP'); {PackDat}
              for i:=1 to MaxInstall do
               begin
                SourceDat:=PackDats[i];
                {SourceDat:='ONLHELP.XP';}
                    Write(EFillStr(12,' ',Sourcedat)+':');
                    PackDat:=SourceDat;
                    delete(PackDat,pos('.',packdat),length(PackDat)-pos('.',packdat)+1);
                    PackDat:=packdat+'.'+Exten;
                    writeln(PackDAt);
                    OpenInput(SourceDat);
                    
                    comp:=true;
                    Encode(filesize(infile),SourceDat);
                    close(infile); if IoResult>0 then Error('! Error closing input file');
                    if outptr>0 then WriteNextBlock;

                end;
                
                
                close(outfile); if IoResult>0 then Error('! Error closing output file');

             end;
     'd','D': begin
              FindFirst(ParamStr(2), Archive, DirInfo);
               while DosError = 0 do
                begin
                 ZielDat:='';
                 sourceDat:=DirInfo.Name;
                { if Sourcedat[length(sourceDat)]='#' then
                   begin}
                   OpenInput(SourceDat);
                   {OpenOutput(PackDat);}
                   decomp:=true;
                   Decode;
                   close(infile); if IoResult>0 then Error('! Error closing input file');
                   if outptr>0 then WriteNextBlock;
                   close(outfile); if IoResult>0 then Error('! Error closing output file');
                 { end;  }
                 FindNext(DirInfo);
                end;
              end;
   else
     Error('! Use [D] for Decompression or [E] for Compression')
   end;
{   close(infile); if IoResult>0 then Error('! Error closing input file');
   if outptr>0 then WriteNextBlock;
   close(outfile); if IoResult>0 then Error('! Error closing output file');}
end.
