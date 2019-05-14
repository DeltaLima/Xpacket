{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P S P E A K . P A S                                                  ³
 ³                                                                         ³
 ³ Routinen fr die Sprachausgabe der Rufzeichen. Derzeit werden noch die  ³
 ³ Sprachfiles vom SUPERKISS 3.0 verwendet.                                ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure out_laut(Speed,Laenge : Word; Buffer : Pointer); Assembler;
Const  out_port = $0061;

asm       push bp              { rette argumentenpointer           }
          mov  bp,sp           { point auf den stack               }
                               { rette sonstige register           }
          push bx
          push cx
          push dx
          push es
          push si
          push di

          push ds              { sicherheitshalber retten          }

          in   al, $21
          push ax
          mov  al, $FD
          out  $21, al

          cld                  { aufw„rts laden                    }
          mov di,[bp+12]       { lade die l„nge des buffers        }
          or di,di             { noch testen                       }
          jnz @out_pre         { es gibt aber nichts               }
          jmp @out_end
@out_pre:
          mov si,[bp+8]        { hole den offset des buffers       }
          mov ax,[bp+10]       { segment des buffers               }

          mov dx,out_port      { addresse des modulports           }
          mov ds,ax            { segmentpointer direkt aufsetzen   }
          in al,dx             { lies momentanen portwert          }
          shr al,1             { portwert vorbereiten              }
          shr al,1             { fr sp„tere carrayschiebung       }

          mov bp,[bp+14]       { hole ausgabespeed                 }
          mov es,ax            { und dahinein retten               }


@out_periode:
          lodsb                { 12 lade "ax=*(ds:si++)"           }
          mov bx,ax            { rette den akku                    }

          mov cx,7

@07:      mov ax,es            { 2 hole alten portwert             }
          shr bl,1             { 2 datenbit ins carry schieben     }
          rcl al,1             { 2 bereite ausgangsdatum vor       }
          shl al,1             { 2 setze evtl. bit 1, l”sche bit 0 }
          out dx,al            { 8 nun speaker ansprechen          }

          push cx

          mov cx,bp            { 2 hole verz”gerungszeit           }
@W1:      loop @W1

          pop cx

          loop @07

          mov ax,es            { 2 hole alten portwert             }
          shr bl,1             { 2 datenbit ins carry schieben     }
          rcl al,1             { 2 bereite ausgangsdatum vor       }
          shl al,1             { 2 setze evtl. bit 1, l”sche bit 0 }
          out dx,al            { 8 nun speaker ansprechen          }

          dec di               { 2 nun ein wort weniger            }
          jz @out_end0          { 4 es war nicht das letzte         }

          mov cx,bp            { 2 hole verz”gerungszeit           }
@W2:      loop @W2


          jmp @out_periode      { 15 springe nach oben              }

@out_end0:jmp @out_end          { geht leider nur so...             }


@out_end: mov ax,es            { hole altenportwert                }
          shl al,1             { l”sche beide untern bits          }
          shl al,1
          out dx,al            { alten portwert wieder setzten     }

          pop  ax
          out  $21, al

          pop ds               { der wurde verwendent . . .        }
          pop di               { register restaurieren             }
          pop si
          pop es
          pop dx
          pop cx
          pop bx

          pop bp               { den auch noch                     }
End;



Procedure Sprechen (* Zeile : Str80 *);
Const  maxLaenge = $FF00;

Type   BufferTyp   = Array[1..maxLaenge] of Byte;

Var    Buffer    : ^BufferTyp;
       Result    : Word;
       maxBuf    : LongInt;
       Datei     : File;
       i,i1      : Byte;
       P         : Word;


Begin
{$IFDEF Sound}
if Konfig.WavSprach then
 begin
  Result:=pos('-',Zeile);
  if Result>0 then
   begin
    Result:=(str_int(copy(Zeile,Result+1,length(Zeile)-Result)));
    if Result>9 then
     begin
      Strip(Zeile);
      Zeile:=Zeile+'-';
     end;

    Case Result of
     10: Zeile:=Zeile+#10;
     11: Zeile:=Zeile+#11;
     12: Zeile:=Zeile+#12;
     13: Zeile:=Zeile+#13;
     14: Zeile:=Zeile+#14;
     15: Zeile:=Zeile+#15;
    end;
   end;
  WavStream:=WavStream+Zeile
end;

if not konfig.wavsprach then
 begin
{$ENDIF}
  Buffer := Nil;
  if MaxAvail > maxLaenge then maxBuf := maxLaenge
                          else maxBuf := MaxAvail - 1024;
  GetMem(Buffer,maxBuf);
  FillChar(Buffer^,maxBuf,#0);
  for i := 1 to length(Zeile) do
  case Zeile[i] of
    '-' : Zeile[i] := '_';
    ',' : Zeile[i] := '!';
  end;

  P := 1;
  While length(Zeile) > 0 do
  begin
    i1 := 1;
    if str_int(copy(Zeile,1,2)) in [10..15] then i1 := 2;
    Assign(Datei,konfig.Spkverz + copy(Zeile,1,i1) + SpkExt);
    If ResetBin(Datei,T) = 0 Then
    Begin
      if (FileSize(Datei) + P) > MaxLaenge then
      begin
        LockIntFlag(0);
        out_laut(VSpeed,P,@Buffer^[1]);
        LockIntFlag(1);
        P := 1;
      end;
      BlockRead(Datei,Buffer^[P],maxBuf,Result);
      P := P + Result;
      FiResult := CloseBin(Datei);
    end;
    delete(Zeile,1,i1);
  end;
  if P > 1 then
  begin
    LockIntFlag(0);
    out_laut(VSpeed,P,@Buffer^[1]);
    LockIntFlag(1);
  end;

  FreeMem(Buffer,MaxLaenge);

{$IFDEF Sound}
end; {soundkarte}
{$ENDIF}
End;


Procedure SprachMenu;
Const  ArtMax = 3;
Var    i    : byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       Hstr : String[4];
       infs : string[80];

Begin
  Moni_Off(0);;

  Flag := false;

  for i := 9 to 15 do
   begin
    g^.fstr[i]:='';
    G^.Fstx[i] := 10;
   end;
  G^.Fstr[7] := InfoZeile(445);

  G^.Fstr[9] := InfoZeile(446);
  infs:=InfoZeile(447);
  
  G^.Fstr[11] := InfoZeile(448);


  Art := 1;

  Repeat
    for i := 9 to 11 do
    begin
      G^.Fstr[i][vM+1] := B1;
      G^.Fstr[i][hM+1] := B1;
      G^.Fstr[i][vM] := B1;
      G^.Fstr[i][hM] := B1;
    end;
    if speek then G^.fstr[9][vm+1]:=X_ch;


    if Art in [1..3] then
    begin
      X := vM;
      Y := Art + 8;
    end else
    begin
      X := hM;
      Y := Art + 4;
    end;
    G^.Fstr[Y][X] := A_ch;

    if HardCur then SetzeCursor(X+1,Y);

    {delete(G^.Fstr[9],vM+1,1);
    insert(int_str(TNr),G^.Fstr[9],vM+1);
    if TNC[TNr]^.Bake then G^.Fstr[13][vM+1] := X_ch;}

{    G^.Fstr[14] := '';}
    G^.Fstr[15] := '';

    G^.Fstr[10] :=infs+' '+int_str(VSpeed);
    Fenster(15);

    _ReadKey(KC,VC);
    Case KC of
      _Esc : Flag := true;

     {_AltH : XP_Help(G^.OHelp[3]);}

      _Ret : ;

       _F1 : Art := 1;
       _F2 : Art := 2;
       _F3 : Art := 3;
       _F4,
       _F5,
       _F6,
       _F7,
       _F8,
       _F9,
      _F10 : Alarm;

       _Up : if Art > 1  then dec(Art)
                         else Alarm;

       _Dn : if Art < ArtMax then inc(Art)
                             else Alarm;
   _Andere : case VC of
               B1:;
               else Alarm;
             end;
       else Alarm;
    End;

    if (KC in [_F1.._F3,_Ret]) or ((KC = _Andere) and (VC = B1)) then
    case Art of
      1 : begin  {an/aus}
           speek:=not speek;
          end;
      2 : begin {geschwindigkeit}
            G^.Fstr[10][vM] := S_ch;
            Fenster(15);
            Hstr := int_str(vspeed);
            GetString(Hstr,Attrib[3],4,2,15,KC,0,Ins);
            if KC <> _Esc then
            begin
              VSpeed := Word(str_int(Hstr));
            end;
          end;
      3 : begin {test}
           {$IFDEF Sound}
           If not Konfig.WavSprach then
           {$ENDIF}
             sprechen('TEST');

           {$IFDEF Sound}
           If Konfig.WavSprach then
           begin
            WavStream:='TEST';
            repeat
             sprachwav;
            until wavStream='';
           end;
           {$ENDIF}
          end;
    end;

    SetzeFlags(0);
  Until Flag;

  ClrFenster;
  Neu_Bild;
  Moni_On;
End;
