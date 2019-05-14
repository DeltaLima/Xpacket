{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P U S E R . P A S                                                    ³
 ³                                                                         ³
 ³ Userdatenbank-Verwaltung                                                ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{Folge:
Call
Name
System
QTH
Locator
Adresse
Telefon
Umlaut
PacLen
Maxframe
Scan (anwesenheit)
SSIDs
VIP
FBBStreng
Vorbereitung
MailLesen
MailKillen
Nachbereitung
ByeBye
Prompt

}


Procedure UserEditieren(*User_:User_Typ2; Kanal :Byte; Neu:boolean; ZMax:Byte*);
Const  ArtMax = 12;

Var    AnAusDiff, e,i      : Byte;
       KC     : Sondertaste;
       VC     : Char;
       atr    : array[1..3] of byte;
       Anfang,
       geaendert,
       grossSave,  {grosschreibungs-flag speichern}
       RemAll_,
       Flag,
       Flag1,
       Seitenwechsel  : Boolean;
       ulw,
       Flagbyte,
       obf,
       X,Y,
       Seite,
       Art    : Byte;
       HStr,
       Eing,
       Teil1,
       Teil2,
       Teil3,
       Teil4,
       Teil5,
       teil6,
       teil7 : str80;
       ZeileOU,
       ZeileRL,
       ULautZ,
       eingh : string;
       Zahl  : longint;         {//db1ras}

       HStrAn, HStrAus : string[20];
       SaveDat : User_typ2; {schluávergleich: wirklich ge„ndert??}
       Udat : file of User_Typ2;


Begin
Seite:=1;
Anfang:=true;
  if (User_.MaxFrames<1) or (user_.maxframes>7) then User_.maxFrames:=Konfig.MaxFrameStd;
  if (user_.paclen<5) or (user_.paclen>255) then user_.paclen:=Konfig.PacLenStd;
User_.VErsion1:=1; User_.Version2:=80;
    Flag := false;
    Flag1 := false;
    grosssave:=gross;
    gross:=false;
    HstrAn :=InfoZeile(76);
    HstrAus:=InfoZeile(77);
    Teil1:=infozeile(366); {Allgemein}
    Teil2:=InfoZeile(378);
    Teil3:=Infozeile(367); {Poll}
    Teil4:=Infozeile(368); {Poll}
    Teil5:=Infozeile(369); {Poll}
    Teil6:=InfoZeile(371); {Kompression beim Login}
    teil7:=InfoZeile(373); {Passwort beim Login}
    ULautZ :=infozeile(372);
    ZeileOU:=InfoZeile(389);
    ZeileRL:=InfoZeile(404);

    if Length(HstrAn)>Length(HstrAus) then AnAusDiff:=Length(HstrAn);
    if Length(HstrAus)>Length(HstrAn) then AnAusDiff:=Length(HstrAus);
    if Length(HstrAus)=Length(HstrAn) then AnAusDiff:=Length(HstrAus);
    Art := 1;
Seitenwechsel:=true;

    SaveDat:=User_;

    Repeat

    if Seitenwechsel then
     begin
      Seitenwechsel:=false;
      if anfang then
       begin
        for i := 1 to Zmax do WriteRam(1,i,Attrib[2],1,cefillstr(80,B1,B1));
        WriteRam(1,1,Attrib[5],1,cefillstr(80,B1,B1+InfoZeile(365)));

        WriteRam(1,maxz,Attrib[5],1,cefillstr(80,B1,B1+ ZeileOU));
       end else for i := 3 to Zmax-1 do WriteRam(1,i,Attrib[2],1,cefillstr(80,B1,B1));
      WriteRam(67,2,Attrib[5],1,cefillstr(14,B1,B1+ParmStr(2,bs,Teil5)+b1+int_Str(Seite)+'/3'));
      Case Seite of
       1: begin
            Art:=1;
            WriteRam(1,2,Attrib[5],1,cefillstr(66,B1,B1+ParmStr(3,bs,Teil5)));

            WriteRam(1,4,Attrib[2],1,cefillstr(9,B1,B1+ParmStr(1,b1,Teil1))+': '+User_.Call);
            WriteRam(1,5,Attrib[2],1,cefillstr(9,B1,B1+ParmStr(2,b1,Teil1))+': '+User_.alias);
            WriteRam(34,4,Attrib[2],1,cefillstr(9,B1,ParmStr(3,b1,teil1))+': '+User_.Name);
            WriteRam(1,6,Attrib[2],1,cefillstr(9,B1,B1+ParmStr(4,b1,teil1))+': '+User_.System);
            WriteRam(34,5,Attrib[2],1,cefillstr(9,B1,parmstr(5,b1,teil1))+': '+User_.QTH);
            WriteRam(34,6,Attrib[2],1,cefillstr(9,B1,parmstr(7,b1,teil1))+': '+UpcaseStr(User_.Locator));
            WriteRam(1,8,Attrib[2],1,cefillstr(9,B1,B1+parmstr(6,b1,teil1))+': '+User_.Adress);
            WriteRam(1,9,Attrib[2],1,cefillstr(9,B1,B1+parmstr(8,b1,teil1))+': '+User_.Telefon);
            WriteRam(1,11,Attrib[2],1,cefillstr(9,B1,B1+ParmStr(9,b1,teil1))+': '+int_str(User_.PacLen));
            WriteRam(34,11,Attrib[2],1,cefillstr(9,B1,ParmStr(10,b1,teil1))+': '+int_str(User_.MaxFrames));

            WriteRam(1,13,Attrib[2],1,cefillstr(9,b1,b1+ParmStr(1, b1, ULautZ))+':');
            WriteRam(12,13,Attrib[2],1,'[ ] '+cefillstr(16,b1,ParmStr(2, b1, ULautZ)));
            WriteRam(34,13,Attrib[2],1,'[ ] '+cefillstr(16,b1,ParmStr(3, b1, ULautZ)));
            WriteRam(56,13,Attrib[2],1,'[ ] '+cefillstr(16,b1,ParmStr(4, b1, ULautZ)));
            case User_.umlaut of
              1: writeRam(13,13,attrib[2],1,'X');
              2: writeRam(35,13,attrib[2],1,'X');
              3: writeRam(57,13,attrib[2],1,'X');
            end;

    {+int_str(User_.umlaut));}




            if User_.Anwesenheit then WriteRam(1,15,Attrib[2],1,' [X]'+cefillstr(10,B1,B1+ParmStr(12,b1,teil1)))
             else WriteRam(1,15,Attrib[2],1,' [ ]'+cefillstr(10,B1,B1+ParmStr(12,b1,teil1)));


            if User_.VIP then WriteRam(15,15,Attrib[2],1,'[X] '+cefillstr(9,B1,parmstr(11,b1,teil1)))
              else WriteRam(15,15,Attrib[2],1,'[ ] '+cefillstr(9,B1,parmstr(11,b1,teil1)));

   {SHOW}   if User_.show then WriteRam(30,15,Attrib[2],1,'[X] '+cefillstr(9,B1,B1+ParmStr(13,b1,teil1)))
            else WriteRam(30,15,Attrib[2],1,'[ ] '+cefillstr(9,B1,ParmStr(13,b1,teil1)));

   {RemSch} if User_.RemSchreib then WriteRam(45,15,Attrib[2],1,'[X] '+cefillstr(34,B1,B1+ParmStr(1,bs,teil3)))
             else WriteRam(45,15,Attrib[2],1,'[ ] '+cefillstr(34,b1,ParmStr(1,bs,teil3)));

            WriteRam(1,17,Attrib[2],1,cefillstr(9,B1,B1+parmstr(1,b1,teil2) )+': ');
            i:=1;
            x:=12;y:=17;
            while i<17 do
             begin
               if user_.ssids[i-1] then WriteRam(x,y,Attrib[2],1,'[X] '+cefillstr(5,B1,parmstr(i+1,b1,teil2)))
                else WriteRam(x,y,Attrib[2],1,'[ ] '+cefillstr(5,B1,parmstr(i+1,b1,teil2)));
      {for e:=0 to 15 do
        if}
               inc(i);
              inc(x,8);
              if i=9 then
                begin
                 inc(y);
                 x:=12;
                end;
             end;
    {User_.SSids}

           WriteRam(2,20,Attrib[2],1,ParmStr(1,bs,teil6));
           WriteRam(62,21,Attrib[2],1,cefillstr(10,B1,B1+ParmStr(5,bs,teil6))+': '+int_str(user_.StopCode));
           Case User_.Kompression of
            0:
             begin
              WriteRam(1,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(2,bs,teil6)));
              WriteRam(20,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));
              {WriteRam(40,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));}

             end;
            1:
             begin
              WriteRam(1,21,Attrib[2],1,' [X]'+cefillstr(19,B1,B1+ParmStr(2,bs,teil6)));
              WriteRam(20,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));
            {  WriteRam(40,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));}
             end;
            3:
             begin
              WriteRam(1,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(2,bs,teil6)));
              WriteRam(20,21,Attrib[2],1,' [X]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));
             { WriteRam(40,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));}
             end;
            {3:
             begin
              WriteRam(1,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(2,bs,teil6)));
              WriteRam(20,21,Attrib[2],1,' [ ]'+cefillstr(19,B1,B1+ParmStr(3,bs,teil6)));
              WriteRam(40,21,Attrib[2],1,' [X]'+cefillstr(19,B1,B1+ParmStr(4,bs,teil6)));
             end;}
           end;

           if User_.AutoBOXPassw then WriteRam(1,23,Attrib[2],1,' [X]'+cefillstr(60,B1,B1+ParmStr(1,BS,teil7)))
             else WriteRam(1,23,Attrib[2],1,' [ ]'+cefillstr(60,B1,B1+ParmStr(1,bs,teil7)));

          end;
        2:begin
           WriteRam(1,2,Attrib[5],1,cefillstr(67,B1,B1+ParmStr(4,bs,Teil5)));
           Art:=20;
           x:=2;y:=4;
           i:=1;
           While g^.Remotes[i].Befehl<>'' do
            begin
             writeRam(x,y,Attrib[2],1,cefillstr(14,B1,'[ ] '+g^.Remotes[i].Befehl));
             if User_.RemAusnahmen[i] then writeRam(x+1,y,attrib[2],1,'X');
             inc(X,15);
             if i in [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90] then
              begin
               x:=2;
               inc(y);
              end;
             inc(i);
            end;
          end;
        3:begin
          Art:=21;
            WriteRam(1,2,Attrib[5],1,cefillstr(67,B1,B1+ParmStr(5,bs,Teil5)));

            if User_.FBBStreng_ then WriteRam(1,4,Attrib[2],1,' [X] '+cefillstr(30,B1,parmStr(2,bs,teil3)))
              else WriteRam(1,4,Attrib[2],1,' [ ] '+cefillstr(30,B1,ParmStr(2,bs,Teil3)));

            WriteRam(45,4,Attrib[2],1,cefillstr(15,B1,ParmStr(5,bs,teil4))+': '+User_.Synonym);

     {2. spalte x=24}
            WriteRam(1,6,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(3,bs,teil3))+': '+User_.Vorbereitung);

            WriteRam(1,8,Attrib[2],1,cefillstr(15,B1,B1+parmStr(1,bs,teil4)) +': '+User_.MailLesen);
            WriteRam(45,8,Attrib[2],1,cefillstr(15,B1,ParmStr(2,bs,teil4)) +': '+User_.MailKillen);

            WriteRam(1,10,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(4,bs,teil3)) +': '+User_.Nachbereitung);
            WriteRam(1,12,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(3,bs,teil4)) +': '+User_.ByeBye);
            WriteRam(1,14,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(4,bs,teil4)) +': '+User_.Prompt);
            WriteRam(1,15,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(6,bs,teil4)) +': '+User_.PWPrompt);
            WriteRam(1,16,Attrib[2],1,cefillstr(15,B1,B1+ParmStr(1,bs,teil5)) +': '+User_.SStopPrompt);

          end;
      end; {case}
     end; {if seitenwechsel}


{

      Case KC of
        _Esc : Flag := true;

        _Ret : ;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5 : Art := 5;
         _F6 : Art := 6;
         _F7 : Art := 7;
         _F8 : Art := 8;
         _F9 : Art := 9;
        _F10 : Art := 10;
        _CTRLF1: ART:=11;



      End;

      if (KC in [_F1.._F10,_Ret,_CTRLF1]) or ((KC = _Andere) and (VC = B1)) then}

      if not Anfang then
      begin
      if kc=_Tab then kc:=_RET;
      if kc=_ShTab then kc:=_Up;
       if Seite=1 then
        begin
         if (kc=_dn) or (kc=_Ret) then inc (art);
         if art>19 then art:=1;

         if (kc=_up) then dec (art);
         if art<1 then art:=19;
        end; {if Seite1}
       if Seite=3 then
        begin
         if (kc=_dn) or (kc=_Ret) then inc (art);
         if art>30 then art:=21;

         if (kc=_up) then dec (art);
         if art<21 then art:=30;
        end; {if Seite3}
      end;
      anfang:=false;

      case Art of
        1 : begin {call}
             eingh:=User_.Call;
             GetString(eingh,Attrib[2],9,12,4,KC,1,Ins);
             User_.Call:=UpcaseStr(eingh);
             WriteRam(12,4,Attrib[2],1,cefillstr(9,b1,User_.Call));

            end;

        2 : begin {alias-call}
             eingh:=User_.alias;
             GetString(eingh,Attrib[2],9,12,5,KC,1,Ins);
             User_.alias:=UpcaseStr(eingh);
             WriteRam(12,5,Attrib[2],1,cefillstr(9,b1,User_.alias));

            end;


        3 :   {System}
            begin
             eingh:=User_.System;
             GetString(eingh,Attrib[2],10,12,6,KC,1,Ins);
             User_.System:=upcaseStr(eingh);   {//db1ras}
             WriteRam(12,6,Attrib[2],1,cefillstr(10,b1,User_.System));
            end;

        4 : begin {name}
             eingh:=User_.Name;
             GetString(eingh,Attrib[2],30,45,4,KC,1,Ins);
             User_.Name:=eingh;
             WriteRam(45,4,Attrib[2],1,cefillstr(30,B1,User_.Name));
            end;

        5 : begin {qth}
             eingh:=User_.QTH;
             GetString(eingh,Attrib[2],30,45,5,KC,1,Ins);
             User_.QTH:=eingh;
             WriteRam(45,5,Attrib[2],1,cefillstr(30,b1,User_.QTH));
            end;

        6 : begin {locator}
             eingh:=User_.Locator;
             GetString(eingh,Attrib[2],7,45,6,KC,1,Ins);
             User_.Locator:=upcaseStr(eingh);
             WriteRam(45,6,Attrib[2],1,cefillstr(10,b1,User_.Locator));
            end;

        7 : begin {adresse}
             eingh:=User_.Adress;
             GetString(eingh,Attrib[2],60,12,8,KC,1,Ins);
             User_.Adress:=eingh;
             WriteRam(12,8,Attrib[2],1,cefillstr(60,b1,User_.Adress));
            end;

        8 : begin  {telefon}
             eingh:=User_.Telefon;
             GetString(eingh,Attrib[2],20,12,9,KC,1,Ins);
             User_.Telefon:=eingh;
             WriteRam(12,9,Attrib[2],1,cefillstr(20,b1,User_.Telefon));
            end;

        9 : begin {Paclen}
             eing:=int_str(User_.PacLen);
              GetString(eing,Attrib[2],3,12,11,KC,1,ins);
              Flagbyte := str_int(eing);
              if flagbyte in [5..255] then eing:=eing else flagbyte:=Konfig.PacLenStd;

                 User_.PacLen:=flagbyte;
              WriteRam(12,11,Attrib[2],1,cefillstr(3,b1,int_str(User_.PacLen)));
            end;

        10: begin {Maxframes}
             eing:=int_str(User_.MaxFrames);
              GetString(eing,Attrib[2],1,45,11,KC,1,ins);
              Flagbyte := str_int(eing);
              if flagbyte in [1..7] then eing:=eing else flagbyte:=Konfig.MaxFrameStd;

                 User_.Maxframes:=flagbyte;
              WriteRam(45,11,Attrib[2],1,int_str(User_.MaxFrames));
            end;


        11 : begin {Umpaut}
            WriteRam(1,maxz,Attrib[5],1,cefillstr(80,B1,B1+ZeileRL ));
            ulw:=1;
            atr[1]:=5;
            atr[2]:=2;
            atr[3]:=2;
            repeat
             case User_.umlaut of
               0: begin
                   writeRam(13,13,attrib[atr[1]],1,' ');
                   writeRam(35,13,attrib[atr[2]],1,' ');
                   writeRam(57,13,attrib[atr[3]],1,' ');
                  end;
               1: begin
                   writeRam(13,13,attrib[atr[1]],1,'X');
                   writeRam(35,13,attrib[atr[2]],1,' ');
                   writeRam(57,13,attrib[atr[3]],1,' ');
                  end;
               2: begin
                   writeRam(13,13,attrib[atr[1]],1,' ');
                   writeRam(35,13,attrib[atr[2]],1,'X');
                   writeRam(57,13,attrib[atr[3]],1,' ');
                  end;
               3: begin
                   writeRam(13,13,attrib[atr[1]],1,' ');
                   writeRam(35,13,attrib[atr[2]],1,' ');
                   writeRam(57,13,attrib[atr[3]],1,'X');
                  end;
               end;
             _ReadKey(KC,VC);

              if kc=_right then inc (ulw);
              if kc=_left then dec (ulw);
              if ulw=0 then ulw:=3;
              if ulw=4 then ulw:=1;
              if vc=#32 then
               begin
                if (user_.umlaut=0) or (user_.umlaut<>ulw) then user_.umlaut:=ulw
                 else user_.umlaut:=0;
               end;
              case ulw of
               1: begin
                   atr[1]:=5;
                   atr[2]:=2;
                   atr[3]:=2;
                  end;
               2: begin
                   atr[1]:=2;
                   atr[2]:=5;
                   atr[3]:=2;
                  end;
               3: begin
                   atr[1]:=2;
                   atr[2]:=2;
                   atr[3]:=5;
                  end;
              end;
              if user_.umlaut=4 then user_.umlaut:=0;
             until kc in udbexit;
             writeRam(13,13,attrib[2],1,' ');
             writeRam(35,13,attrib[2],1,' ');
             writeRam(57,13,attrib[2],1,' ');
             case User_.umlaut of
               1: writeRam(13,13,attrib[2],1,'X');
               2: writeRam(35,13,attrib[2],1,'X');
               3: writeRam(57,13,attrib[2],1,'X');
             end;
             {eing:=int_str(User_.Umlaut);
              GetString(eing,Attrib[2],1,12,9,KC,1,Ins);
              Flagbyte := Byte(str_int('$'+ eing[1]));
               if not (FlagByte in UmlMenge) then Eing:='0';
              if str_int(eing) in [0..5] then
                 User_.Umlaut:=str_int(eing);
              WriteRam(1,9,Attrib[2],1,cefillstr(80,B1,B1+InfoZeile(372) +' '+int_str(User_.umlaut)));}
              WriteRam(1,maxz,Attrib[5],1,cefillstr(80,B1,B1+ZeileOU ));
            end;





        12: begin   {Anwesenheit /Scan}
            if User_.Anwesenheit then writeRam(3,15,Attrib[5],1,'X')
                         else WriteRam(3,15,Attrib[5],1,' ');
             repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.Anwesenheit:=not User_.Anwesenheit;
             if User_.Anwesenheit then writeRam(3,15,Attrib[5],1,'X')
                         else WriteRam(3,15,Attrib[5],1,' ');
             until kc in UdbExit;
             if User_.Anwesenheit then writeRam(3,15,Attrib[2],1,'X')
                         else WriteRam(3,15,Attrib[2],1,' ');
            end;

        13: begin {VIP}
            if User_.VIP then writeRam(16,15,Attrib[5],1,'X')
                         else WriteRam(16,15,Attrib[5],1,' ');
            repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.VIP:=not User_.VIP;
              if User_.VIP then writeRam(16,15,Attrib[5],1,'X')
                         else WriteRam(16,15,Attrib[5],1,' ');
            until kc in UdbExit;
            if User_.VIP then writeRam(16,15,Attrib[2],1,'X')
                         else WriteRam(16,15,Attrib[2],1,' ');
           end;


        14: begin {show}
            if User_.show then writeRam(31,15,Attrib[5],1,'X')
                         else WriteRam(31,15,Attrib[5],1,' ');
            repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.show:=not User_.show;
              if User_.show then writeRam(31,15,Attrib[5],1,'X')
                         else WriteRam(31,15,Attrib[5],1,' ');
            until kc in UdbExit;
            if User_.show then writeRam(31,15,Attrib[2],1,'X')
                         else WriteRam(31,15,Attrib[2],1,' ');
           end;

        15: begin {RemSchreib}
            if User_.RemSchreib then writeRam(46,15,Attrib[5],1,'X')
                         else WriteRam(46,15,Attrib[5],1,' ');
            repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.RemSchreib:=not User_.RemSchreib;
              if User_.RemSchreib then writeRam(46,15,Attrib[5],1,'X')
                         else WriteRam(46,15,Attrib[5],1,' ');
            until kc in UdbExit;
            if User_.RemSchreib then writeRam(46,15,Attrib[2],1,'X')
                         else WriteRam(46,15,Attrib[2],1,' ');
           end;



        16:   {SSIDs}
            begin
             ulw:=0;
             WriteRam(1,maxz,Attrib[5],1,cefillstr(80,B1,B1+ZeileRL ));
             repeat
              x:=13; y:=17;
              for obf:=0 to 15 do
               begin
                if obf=ulw then atr[1]:=5 else atr[1]:=2;
                if user_.ssids[obf] then writeRam(x,y,Attrib[atr[1]],1,'X')
                  else writeRam(x,y,Attrib[atr[1]],1,' ');
                inc (x,8);
                if obf=7 then
                 begin
                  x:=13;
                  inc(y);
                 end;
               end;
              _ReadKey(KC,VC);

              if vc=#32 then user_.SSids[ulw]:=not user_.ssids[ulw];
              if kc=_right then inc(ulw);
              if kc=_left then dec(ulw);
              if ulw=255 then ulw:=15;
              if ulw=16 then ulw:=0;
             until kc in UdbExit;
             atr[1]:=2;
             x:=13; y:=17;
             for obf:=0 to 15 do
               begin
                if user_.ssids[obf] then writeRam(x,y,Attrib[atr[1]],1,'X')
                  else writeRam(x,y,Attrib[atr[1]],1,' ');
                inc (x,8);
                if obf=7 then
                 begin
                  x:=13;
                  inc(y);
                 end;
               end;
               WriteRam(1,maxz,Attrib[5],1,cefillstr(80,B1,B1+ZeileOU ));
            end;

        17: begin
             {Kompression}
             ulw:=1;
             if user_.Kompression=1 then WriteRam(3,21,Attrib[5],1,'X')
                              else WriteRam(3,21,Attrib[5],1,' ');
             repeat
              _ReadKey(KC,VC);


              if vc=#32 then
              begin
                if (ulw=1) then
                 if (User_.Kompression=1) then User_.Kompression:=0
                                          else User_.Kompression:=1;
                {if (ulw=2) then
                 if (User_.Kompression=2) then User_.Kompression:=0
                                          else User_.Kompression:=2;}
                if (ulw=3) then
                 if (User_.Kompression=3) then User_.Kompression:=0
                                          else User_.Kompression:=3;
              end;


              if kc=_right then inc(ulw,2);
              if kc=_left then dec(ulw,2);
              if (ulw<1) or (ulw>200) then ulw:=3;
              if (ulw<190) and (ulw>3) then ulw:=1;
              case ulw of
               1:
                begin
                 if user_.Kompression=1 then WriteRam(3,21,Attrib[5],1,'X')
                                        else WriteRam(3,21,Attrib[5],1,' ');
                 if user_.Kompression=3 then WriteRam(22,21,Attrib[2],1,'X')
                                        else WriteRam(22,21,Attrib[2],1,' ');
                 {if user_.Kompression=3 then WriteRam(42,21,Attrib[2],1,'X')
                                        else WriteRam(42,21,Attrib[2],1,' ');}
                end;
               {2:
                begin
                 if user_.Kompression=1 then WriteRam(3,21,Attrib[2],1,'X')
                                        else WriteRam(3,21,Attrib[2],1,' ');
                 if user_.Kompression=2 then WriteRam(22,21,Attrib[5],1,'X')
                                        else WriteRam(22,21,Attrib[5],1,' ');
                 if user_.Kompression=3 then WriteRam(42,21,Attrib[2],1,'X')
                                        else WriteRam(42,21,Attrib[2],1,' ');


                end;}
               3:
                begin
                 if user_.Kompression=1 then WriteRam(3,21,Attrib[2],1,'X')
                                        else WriteRam(3,21,Attrib[2],1,' ');
                 if user_.Kompression=3 then WriteRam(22,21,Attrib[5],1,'X')
                                        else WriteRam(22,21,Attrib[5],1,' ');
                 {if user_.Kompression=3 then WriteRam(42,21,Attrib[5],1,'X')
                                        else WriteRam(42,21,Attrib[5],1,' ');}
                end;
              end;

             until kc in UdbExit;


             if user_.Kompression=1 then WriteRam(3,21,Attrib[2],1,'X')
                                    else WriteRam(3,21,Attrib[2],1,' ');
             if user_.Kompression=3 then WriteRam(22,21,Attrib[2],1,'X')
                                    else WriteRam(22,21,Attrib[2],1,' ');
             {if user_.Kompression=3 then WriteRam(42,21,Attrib[2],1,'X')
                                    else WriteRam(42,21,Attrib[2],1,' ');}

            end;

        18: begin
             eingh:=int_str(User_.stopcode);
             GetString(eingh,Attrib[2],5,74,21,KC,1,Ins);
             User_.stopcode:=str_int(UpcaseStr(eingh));
             WriteRam(62,21,Attrib[2],1,cefillstr(17,B1,B1+ParmStr(5,bs,teil6)+': '+int_str(user_.StopCode)));
            end;

        19: begin
             {autopw}

             if User_.AutoBoxPassw then writeRam(3,23,Attrib[5],1,'X')
                         else WriteRam(3,23,Attrib[5],1,' ');
            repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.AutoBoxPassw:=not User_.autoboxpassw;
              if User_.autoboxpassw then writeRam(3,23,Attrib[5],1,'X')
                         else WriteRam(3,23,Attrib[5],1,' ');
            until kc in UdbExit;
            if User_.autoboxpassw then writeRam(3,23,Attrib[2],1,'X')
                         else WriteRam(3,23,Attrib[2],1,' ');

            end;

        {Seite 2:}
        20: begin
            ulw:=0;
             e:=1;i:=2;
             repeat
             y:=2;
              x:=2;y:=4;
              i:=1;
               While g^.Remotes[i].Befehl<>'' do
                begin
                 if i=e then ATR[1]:=5 else ATR[1]:=2;
                 if User_.RemAusnahmen[i] then writeRam(x+1,y,Attrib[atr[1]],1,'X')
                   else writeRam(x+1,y,Attrib[atr[1]],1,' ');
                 inc(X,15);
                 if i in [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90] then
                  begin
                   inc(y);
                   x:=2;
                  end;
                 inc(i);
                ulw:=i-1;
               end;
              i:=e;
             _ReadKey(KC,VC);
             if VC=#32 then user_.RemAusnahmen[e]:=not user_.remAusnahmen[e];
             case Kc of
              _dn:begin
                   if e+5>ulw then Alarm else inc(e,5);
                  end;
              _up:begin
                   if (e-5<1) or (e+5>200) then Alarm else dec(e,5);
                  end;
              _right:begin
                   if e+1>ulw then e:=1 else inc(e);
                  end;
              _left:begin
                   if e-1<1 then e:=ulw else dec(e);
                  end;

              end;

             until kc in [_PgUp, _Pgdn, _ESC];
             i:=1;
             x:=2;y:=4;
             While g^.Remotes[i].Befehl<>'' do
                begin
                 if User_.RemAusnahmen[i] then writeRam(x+1,y,attrib[2],1,'X')
                   else writeRam(x+1,y,attrib[2],1,' ');
                 inc(X,15);
                 if i in [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75] then
                  begin
                   x:=2;
                   inc(Y);
                  end;
                 inc(i);
                end;
            end;

        {Seite 3:}
        21: begin   {FBBStreng}
            if User_.FBBStreng_ then writeRam(3,4,Attrib[5],1,'X')
                         else WriteRam(3,4,Attrib[5],1,' ');
             repeat
              _ReadKey(KC,VC);
              if vc=#32 then User_.FBBStreng_:=not User_.FBBStreng_;
              if User_.FBBStreng_ then writeRam(3,4,Attrib[5],1,'X')
                         else WriteRam(3,4,Attrib[5],1,' ');
             until kc in UdbExit;
             if User_.FBBStreng_ then writeRam(3,4,Attrib[2],1,'X')
                         else WriteRam(3,4,Attrib[2],1,' ');
            end;

        22:   {Synonym}
            begin
             eingh:=User_.Synonym;
             GetString(eingh,Attrib[2],10,62,4,KC,1,Ins);
             User_.Synonym:=eingh;
             WriteRam(62,4,Attrib[2],1,cefillstr(10,b1,User_.Synonym));
            end;

        23:   {Vorbereitung}
            begin
             eingh:=User_.Vorbereitung;
             GetString(eingh,Attrib[2],60,18,6,KC,1,Ins);
             User_.Vorbereitung:=eingh;
             WriteRam(18,6,Attrib[2],1,cefillstr(60,B1,User_.vorbereitung));
            end;

        24:   {MailLesen}
            begin
             eingh:=User_.MailLesen;
             GetString(eingh,Attrib[2],10,18,8,KC,1,Ins);
             User_.MailLesen:=eingh;
             WriteRam(18,8,Attrib[2],1,cefillstr(10,B1,User_.MailLesen));
            end;

        25:   {MailL”schen}
            begin
             eingh:=User_.MailKillen;
             GetString(eingh,Attrib[2],10,62,8,KC,1,Ins);
             User_.MailKillen:=eingh;
             WriteRam(62,8,Attrib[2],1,cefillstr(10,B1,User_.MailKillen));
            end;

        26:   {Nachbereitung}
            begin
             eingh:=User_.Nachbereitung;
             GetString(eingh,Attrib[2],60,18,10,KC,1,Ins);
             User_.Nachbereitung:=eingh;
             WriteRam(18,10,Attrib[2],1,cefillstr(60,B1,User_.Nachbereitung));
            end;

        27:   {ByeBye}
            begin
             eingh:=User_.ByeBye;
             GetString(eingh,Attrib[2],10,18,12,KC,1,Ins);
             User_.ByeBye:=eingh;
             WriteRam(18,12,Attrib[2],1,cefillstr(10,B1,User_.ByeBye));
            end;

        28:   {Prompt}
            begin
             eingh:=User_.Prompt;
             GetString(eingh,Attrib[2],60,18,14,KC,1,Ins);
             User_.Prompt:=eingh;
             WriteRam(18,14,Attrib[2],1,cefillstr(60,B1,User_.Prompt));
            end;

        29:   {PWPrompt}
            begin
             eingh:=User_.PWPrompt;
             GetString(eingh,Attrib[2],60,18,15,KC,1,Ins);
             User_.PWprompt:=eingh;
             WriteRam(18,15,Attrib[2],1,cefillstr(60,B1,User_.PWPrompt));
            end;

        30:   {SStopPrompt}
            begin
             eingh:=User_.SStopPrompt;
             GetString(eingh,Attrib[2],60,18,16,KC,1,Ins);
             User_.SStopPrompt:=eingh;
             WriteRam(18,16,Attrib[2],1,cefillstr(60,B1,User_.SStopPrompt));
            end;


      end;
      if kc=_Esc then Flag := true;
      if kc=_PgDn then
       begin
        inc(Seite);
        Seitenwechsel:=true;
       end;
      if kc=_PgUp then
       begin
        dec(Seite);
        Seitenwechsel:=true;
       end;
      if Seite>3 then Seite:=1;
      if Seite<1 then Seite:=3;
    Until Flag;
    geaendert:=false;
    if User_.Call<>SaveDat.Call then Geaendert:=true;
    if User_.Alias<>SaveDat.alias then Geaendert:=true;
    if User_.name<>SaveDat.Name then Geaendert:=true;
    if User_.QTH <>SaveDat.QTH then Geaendert:=true;
    if User_.Locator <>SaveDat.Locator then Geaendert:=true;
    if User_.Adress <>SaveDat.Adress then Geaendert:=true;
    if User_.Telefon <>SaveDat.Telefon then Geaendert:=true;
    if User_.PacLen <>SaveDat.PacLen then Geaendert:=true;
    if User_.Umlaut <>SaveDat.Umlaut then Geaendert:=true;
    if User_.FBBStreng_ <>SaveDat.FBBStreng_ then Geaendert:=true;
    if User_.VIP <>SaveDat.VIP then Geaendert:=true;
    if User_.MaxFrames <>SaveDat.MaxFrames then Geaendert:=true;
    if User_.Anwesenheit <> SaveDat.Anwesenheit then geaendert:=true;
    if User_.Show<>SaveDat.Show then Geaendert:=true;
    if User_.RemSchreib<>SaveDat.RemSchreib then Geaendert:=true;
    if User_.System <>SaveDat.System then Geaendert:=true;
    if User_.MailLesen<>SaveDat.MailLesen then Geaendert:=true;
    if User_.Mailkillen<>SaveDat.Mailkillen then Geaendert:=true;
    if User_.ByeBye<>SaveDat.ByeBye then Geaendert:=true;
    if User_.Prompt<>SaveDat.Prompt then Geaendert:=true;
    if User_.pwPrompt<>SaveDat.pwPrompt then Geaendert:=true;
    if User_.SStopPrompt<>SaveDat.SStopPrompt then Geaendert:=true;
    if User_.StopCode<>SaveDat.StopCode then Geaendert:=true;

    for i:=0 to 15 do
     if User_.SSids[i]<>SaveDat.ssids[i] then Geaendert:=true;
    for i:=1 to maxrem do
     begin
      if (g^.Remotes[i].Befehl<>'') and (user_.RemAusnahmen[i]<>SaveDat.RemAusnahmen[i])
       then Geaendert:=true;
     end;

    if User_.Vorbereitung<>SaveDat.Vorbereitung then Geaendert:=true;
    if User_.Nachbereitung<>SaveDat.Nachbereitung then Geaendert:=true;
    if User_.Synonym<>SaveDat.Synonym then Geaendert:=true;
    if User_.Kompression<>SaveDat.Kompression then Geaendert:=true;
    if User_.AutoBoxPassw<>SaveDat.AutoBoxPassw then geaendert:=true;

    if geaendert then
     begin
      WriteRam(1,16,Attrib[5],1,cefillstr(80,B1,B1+InfoZeile(196)));
      _ReadKey(KC,VC);
      VC := UpCase(VC);
     end else begin
              KC := _Dn;
              VC :='N';
              end; {saveDat}
      if (KC =_Ret) or (VC in YesMenge) then
       begin
       {sortUser;}
        WriteRam(1,16,Attrib[5],1,cefillstr(80,B1,B1+InfoZeile(232)));
        PutUser(User_,art,0,neupos, true);

        {Aenderungen auf die connecteten Kanaele weiterleiten   //db1ras}
        For i:=1 to maxlink Do
          If k[i]^.Connected Then
            If k[i]^.Call=User_.Call Then Begin
              If k[i]^.System<>User_.System Then Begin
                k[i]^.User_Name := GetName(i,User_.Call,k[i]^.Umlaut,true);
                SetzeSysArt(i);
              End Else
                k[i]^.User_Name := GetName(i,User_.Call,k[i]^.Umlaut,true);
            End Else Begin
              hstr:=k[i]^.Call;
              Strip(hstr);
              If (hstr = User_.Call) And
                 (UserSuchRoutine(k[i]^.Call,Zahl,false,true) = false) Then
              Begin
                If k[i]^.System<>User_.System Then Begin
                  k[i]^.User_Name := GetName(i,User_.Call,k[i]^.Umlaut,true);
                  SetzeSysArt(i);
                End Else
                  k[i]^.User_Name := GetName(i,User_.Call,k[i]^.Umlaut,true);
              End;
            End;

{ Den Code hier verstehe ich nicht. Sollte aber von meinem Code    }
{ (oberhalb) mit abgedeckt werden (hoffe ich zumindest)   //db1ras }
{        if user_.stopCode<>SaveDat.StopCode then
         begin
          geaendert:=false;
          for i:=1 to maxlink do
           begin
            if k[i]^.Call=User_.Call then
             begin
              Geaendert:=true;
              k[i]^.StopCode:=User_.StopCode;
             end;
            if not Geaendert then
             begin
              hstr:=K[i]^.Call;
              strip(hstr);
              strip(User_.Call);
              for i:=1 to maxlink do
               begin
                if hstr=User_.Call then
                 begin
                  Geaendert:=true;
                  k[i]^.StopCode:=User_.StopCode;
                 end;
               end;
             end;
           end;
         end;
}
      end else if (Neu) and (UserAnz>0) then dec(UserAnz);
   gross:=grosssave;

End;

