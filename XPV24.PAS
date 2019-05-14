{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P V 2 4 . P A S                                                      ≥
 ≥                                                                         ≥
 ≥ - Routinen zur Bedienung bis zu 4 Schnittstellen +                      ≥
 ≥   Hardware-Umschaltung bei Multiplexkarten.                             ≥
 ≥                                                                         ≥
 ≥ - Interface zum TFPCR-, TFPCX-Treiber von DL1MEN bzw. DG0FT             ≥
 ≥   Es wird nach dem passenden Software-Interrupt im Bereich              ≥
 ≥   $40 bis $FF gesucht!                                                  ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}

Function  IntFlag : Boolean;
Var   FlagInt : Word;
Begin
  asm
      pushf
      pop   ax
      mov   FlagInt, ax
  end;
  IntFlag := (FlagInt and $200) = $200;
End;


Procedure RTS_Setzen (Nr : Byte);
Begin
  Port[COM[Nr].Base+$04] := (Port[COM[Nr].Base+$04] or $02);
End;

Procedure RTS_Loeschen (Nr : Byte);
Begin
  Port[COM[Nr].Base+$04] := (Port[COM[Nr].Base+$04] and (FF-$02));
End;


Procedure IRQsLock;
Begin
  if IrqMask > 0 then Port[$21] := Port[$21] or IrqMask;
  SynchError := false;
  OverRun := false;
End;

Procedure IRQsFree;
Begin
  if IrqMask > 0 then Port[$21] := Port[$21] and (FF - IrqMask);
End;

Procedure get_Chr_TFPC; assembler;
VAR b : Byte;
    NoData : Byte;
ASM
  XOR AX, AX
  CMP TFPC_installed, 0
  JNZ @jumptfpc

@jumpdrsi:
  JMP @modifydrsi

  JMP @polldrsi

@modifydrsi:
  LEA BX, @modone-1
  MOV DL, Kiss_Int
  MOV CS:[BX], DL
  LEA BX, @jumpdrsi
  MOV DX, 9090h
  MOV CS:[BX], DX

@polldrsi:
  XOR AX, AX
  MOV AH, 0h
  INT $00
@modone:
  CMP AH, 1
  JNZ @abort

  MOV b, AL
  MOV NoData, 0
  JMP @Ende

@jumptfpc:
   jmp @modifytfpc
   jmp @polltfpc

@modifytfpc:
   LEA BX, @nummer-1
   MOV DL, Kiss_Int
   MOV CS:[BX], DL
   LEA BX, @nummer2-1
   MOV CS:[BX], DL
   LEA BX, @jumptfpc
   MOV DX, 9090h
   MOV CS:[BX], DX

@polltfpc:
   XOR AX, AX
   MOV AH, 01h
   INT $00
@nummer:
   CMP AX, 01
   JNZ @Abort

   MOV AH, 02
   INT $00
@nummer2:
   MOV B, AL
   MOV NoData, 0
   JMP @Ende

@abort:
  MOV NoData, 1

@Ende:
  CMP NoData, 0
  JNZ @Final

  XOR BL, BL
  MOV BL, b

  LEA DI, V24Buffer
  ADD DI, BufferPos

  MOV [DS:DI], BL

  INC BufferPos

  CMP BufferPos, maxComBuf
  JNZ @Final

  LEA DI, V24Buffer

  MOV AL, [DS:DI]

  CMP AL, 0
  JZ @Final

@ClearV24Buffer:

  MOV AH, 0
  MOV [DS:DI], AH
  INC DI
  MOV AL, [DS:DI]
  CMP AL, 0
  JNZ @ClearV24Buffer

@Final:
END;



(*Procedure get_Chr_TFPC;
Var  r : Registers;
     b : Byte;
Begin
  if TFPC_installed then
  begin
    r.AH := $01;
    Intr(Kiss_Int,r);
    if r.AX = 1 then
    begin
      r.AH := $02;
      Intr(Kiss_Int,r);
      b := r.AL;
      V24Buffer[BufferPos] := b;
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
  end;

  if DRSI_installed then
  begin
    r.AH := $00;
    Intr(Kiss_Int,r);
    if r.AH = 1 then
    begin
      b := r.AL;
      V24Buffer[BufferPos] := b;
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
  end;
End; *)


{
Procedure get_Chr_Hs (* V24Nr : Byte *);
Begin
  Repeat
    CB := Port[COM[V24Nr].Base + $05];
    TRead := CB and $01 = $01;
    if TRead then
    begin
      V24Buffer[BufferPos] := Port[COM[V24Nr].Base];
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
    if CB and $02 = $02 then OverRun := true;
  Until not TRead;
End;
}

Procedure get_Chr_Hs (* V24Nr : Byte *); Assembler;
Asm
  @1:
     xor  ax, ax
     mov  al, V24Nr
     dec  al
     shl  al, $01
     mov  bx, Offset Default_Base
     add  bx, ax
     mov  dx, [ds:bx]
     add  dx, $05

     in   al, dx
     test al, $02
     jz   @2
     mov  OverRun, $01
  @2:
     test al, $01
     jz   @4

     sub  dx, $05
     in   al, dx

     mov  si, BufferPos
     mov  bx, Offset V24Buffer
     mov  [ds:bx+si], al
     inc  BufferPos
     cmp  BufferPos, maxComBuf
     jb   @3
     mov  BufferPos, $00
  @3:
     jmp  @1
  @4:
End;

(*
{$F+} Procedure Com_Int1; {$F-}  Interrupt;
Const  V24Nr = 1;
Begin
  Repeat
    CB := Port[COM[V24Nr].Base + $05];
    TRead := CB and $01 = $01;
    if TRead then
    begin
      V24Buffer[BufferPos] := Port[COM[V24Nr].Base];
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
    if CB and $02 = $02 then OverRun := true;
  Until not TRead;

  if COM[V24Nr].IRQ_Nr > 7 then Port[$A0] := $20;
  Port[$20] := $20;
End;

{$F+} Procedure Com_Int2; {$F-}  Interrupt;
Const  V24Nr = 2;
Begin
  Repeat
    CB := Port[COM[V24Nr].Base + $05];
    TRead := CB and $01 = $01;
    if TRead then
    begin
      V24Buffer[BufferPos] := Port[COM[V24Nr].Base];
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
    if CB and $02 = $02 then OverRun := true;
  Until not TRead;

  if COM[V24Nr].IRQ_Nr > 7 then Port[$A0] := $20;
  Port[$20] := $20;
End;

{$F+} Procedure Com_Int3; {$F-}  Interrupt;
Const  V24Nr = 3;
Begin
  Repeat
    CB := Port[COM[V24Nr].Base + $05];
    TRead := CB and $01 = $01;
    if TRead then
    begin
      V24Buffer[BufferPos] := Port[COM[V24Nr].Base];
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
    if CB and $02 = $02 then OverRun := true;
  Until not TRead;

  if COM[V24Nr].IRQ_Nr > 7 then Port[$A0] := $20;
  Port[$20] := $20;
End;

{$F+} Procedure Com_Int4; {$F-}  Interrupt;
Const  V24Nr = 4;
Begin
  Repeat
    CB := Port[COM[V24Nr].Base + $05];
    TRead := CB and $01 = $01;
    if TRead then
    begin
      V24Buffer[BufferPos] := Port[COM[V24Nr].Base];
      inc(BufferPos);
      if BufferPos >= maxComBuf then ClearV24Buffer;
    end;
    if CB and $02 = $02 then OverRun := true;
  Until not TRead;

  if COM[V24Nr].IRQ_Nr > 7 then Port[$A0] := $20;
  Port[$20] := $20;
End;
*)

{$F+} Procedure Com_Int1; {$F-}  Interrupt;  Assembler;
Asm
  @1:
     mov  dx, ComAdr1
     add  dx, $05
     in   al, dx
     test al, $02
     jz   @2
     mov  OverRun, $01
  @2:
     test al, $01
     jz   @4

     sub  dx, $05
     in   al, dx

     mov  si, BufferPos
     mov  bx, Offset V24Buffer
     mov  [ds:bx+si], al
     inc  BufferPos
     cmp  BufferPos, maxComBuf
     jb   @3
     mov  BufferPos, $00
  @3:
     jmp  @1
  @4:
     mov  al, $20
     mov  ah, EoiPic1
     test ah, $01
     jz   @5
     out  $A0, al
 @5:
     out  $20, al
End;


{$F+} Procedure Com_Int2; {$F-}  Interrupt;  Assembler;
Asm
  @1:
     mov  dx, ComAdr2
     add  dx, $05
     in   al, dx
     test al, $02
     jz   @2
     mov  OverRun, $01
  @2:
     test al, $01
     jz   @4

     sub  dx, $05
     in   al, dx

     mov  si, BufferPos
     mov  bx, Offset V24Buffer
     mov  [ds:bx+si], al
     inc  BufferPos
     cmp  BufferPos, maxComBuf
     jb   @3
     mov  BufferPos, $00
  @3:
     jmp  @1
  @4:
     mov  al, $20
     mov  ah, EoiPic2
     test ah, $01
     jz   @5
     out  $A0, al
 @5:
     out  $20, al
End;


{$F+} Procedure Com_Int3; {$F-}  Interrupt;  Assembler;
Asm
  @1:
     mov  dx, ComAdr3
     add  dx, $05
     in   al, dx
     test al, $02
     jz   @2
     mov  OverRun, $01
  @2:
     test al, $01
     jz   @4

     sub  dx, $05
     in   al, dx

     mov  si, BufferPos
     mov  bx, Offset V24Buffer
     mov  [ds:bx+si], al
     inc  BufferPos
     cmp  BufferPos, maxComBuf
     jb   @3
     mov  BufferPos, $00
  @3:
     jmp  @1
  @4:
     mov  al, $20
     mov  ah, EoiPic3
     test ah, $01
     jz   @5
     out  $A0, al
 @5:
     out  $20, al
End;


{$F+} Procedure Com_Int4; {$F-}  Interrupt;  Assembler;
Asm
  @1:
     mov  dx, ComAdr4
     add  dx, $05
     in   al, dx
     test al, $02
     jz   @2
     mov  OverRun, $01
  @2:
     test al, $01
     jz   @4

     sub  dx, $05
     in   al, dx

     mov  si, BufferPos
     mov  bx, Offset V24Buffer
     mov  [ds:bx+si], al
     inc  BufferPos
     cmp  BufferPos, maxComBuf
     jb   @3
     mov  BufferPos, $00
  @3:
     jmp  @1
  @4:
     mov  al, $20
     mov  ah, EoiPic4
     test ah, $01
     jz   @5
     out  $A0, al
 @5:
     out  $20, al
End;


{----------------------------------------------------------------------------
|  Eine der V24-Schnittstellen initialisieren
+----------------------------------------------------------------------------}
Procedure V24_Init;
Var   T,Nr,INr,dB : Byte;
      V24Install  : Boolean;
Begin
  for T := 1 to TNC_Anzahl do
  begin
    Nr := TNC[T]^.RS232;

    if (Nr < 5) and not COM[Nr].Active then with COM[Nr] do
    begin
      V24Install := (Port[Base + $05] and $60) = $60;

      if V24Install then
      begin
	While (Port[Base + $05] and $01) = $01 do dB := Port[Base];

	{FIFO-Controlregister eines NSC 16550A initialisieren sofern installiert}
	{Beim 8250/16450 geht diese Initialisierung ins Leere und bewirkt nichts}
	Port[Base + $02] := FifoCfg;
	FifoOn := Port[Base + $02] and $C0 = $C0;

	OrgLCR := Port[Base + $03];                { altes LCR sichern     }
	OrgMCR := Port[Base + $04];                { altes MCR sichern     }
	OrgIER := Port[Base + $01];                { altes IER sichern     }
	Port[Base + $03] := Port[Base + $03] or $80;   { LCR : DLAB=1          }
	OrgLODIV := Port[Base + $00];              { alte Baudrate sichern }
	OrgHIDIV := Port[Base + $01];
	Port[Base+3] := OrgLCR;

	Inline($FA);
	if not HwHs then
	begin
	  if IRQ_Nr > 7 then INr := IRQ_Nr + 104
			else INr := IRQ_Nr + 8;

	  GetIntVec(INr,Old_Vector);

	  Case Nr of
	    1 : SetIntVec(INr,@Com_Int1);
	    2 : SetIntVec(INr,@Com_Int2);
	    3 : SetIntVec(INr,@Com_Int3);
	    4 : SetIntVec(INr,@Com_Int4);
	  end;

	  if IRQ_Nr > 7 then
	  begin
	    Port[$A1] := Port[$A1] and (FF - (1 shl (IRQ_Nr-8)));
	    Port[$21] := Port[$21] and (FF - $04);
	    Port[$20] := $C1;
	  end else
	  begin
	    Port[$21] := Port[$21] and (FF - (1 shl IRQ_Nr));
	    Port[$20] := $C2;        { V24 IRQ-Prioritaet setzen   }
	  end;
	end;
	Inline($FB);

	dB := Byte(Round(115200 / BaudRate));
	Port[Base + $03] := Port[Base + $03] or $80; { LCR : DLAB=1                    }
	Port[Base + $00] := Lo(dB);              { $06 = 19200 bd, $0C = 9600      }
	Port[Base + $01] := Hi(dB);              { HI Baud                         }
	Port[Base + $03] := $03;                 { LCR NoParity 8Data 1Stop:DLAB=0 }

	if not HwHs then
	begin
	  Port[Base + $04] := $0B;               { MCR IRQ-, RTS-, DTR-Ltg freiset.}
	  Port[Base + $01] := $01;               { Interrupt bei Empfangsdaten     }
	  Verzoegern(200);
	end else Port[Base + $04] := $03;        { MCR RTS und DTR= H              }

	Active := true;
      end else Abbruch_XP(13,int_str(Nr));
    end;
    ClearV24Buffer;
  end;
End;

{-----------------------------------------------------------------------------
|  V24_Close  setzt alle Vektoren wieder zurÅck
|  Neu: Interrupts werden gesperrt (nach DL4NO) 11/1989
+----------------------------------------------------------------------------}
Procedure V24_Close;
Var    INr, i : Byte;
Begin
  for i := 1 to 4 do with COM[i] do
  if Active then
  begin
    Port[Base + $01] := $00;               { serielles Port-IER sperren }
    Port[Base + $04] := $00;               { IRQ-Leitung in Tristate    }

    Inline($FA);

    if not HwHs then
    begin
      if IRQ_Nr > 7 then INr := IRQ_Nr + 104
		    else INr := IRQ_Nr + 8;
      SetIntVec(INr,Old_Vector);
    end;

    Port[Base + $03] := Port[Base + $03] or $80;
    Port[Base + $00] := OrgLODIV;        { alte Baudrate restaurieren }
    Port[Base + $01] := OrgHIDIV;
    Port[Base + $03] := OrgLCR;          { LCR restaurieren           }
    Port[Base + $01] := OrgIER;          { IER restaurieren           }

    Inline($FB);

    Port[Base + $04] := OrgMCR;          { MCR restaurieren           }
    Active := false;
  end;
End;


Procedure WriteAux (* V24Nr : Byte; Zeile : String *);
Var   i : Byte;
      r : Registers;
Begin
  if (V24Nr = 5) then
  begin
    for i := 1 to ord(Zeile[0]) do
    begin
      if TFPC_installed then r.AH := 3;
      if DRSI_installed then r.AH := 1;
      r.AL := Ord(Zeile[i]);
      Intr(Kiss_Int,r);
    end;
  end else with COM[V24Nr] do
  begin
    for i := 1 to ord(Zeile[0]) do
    begin
      Repeat Until (Port[Base + $05] and 32) = 32;
      Port[Base] := Ord(Zeile[i]);
    end;
  end;
End;


{------------------------------------------------------------------------------
|  Den gewÅnschten TNC einschalten
+-----------------------------------------------------------------------------}
Procedure Switch_TNC (* TNr : Byte *);
Var    sw  : Byte;
       MCR : Byte;
Begin
  if (TNC[TNr]^.RS232 < 5) and (Old_Active_TNC <> TNr) then
  begin
    Old_Active_TNC := TNr;
    sw := TNC[TNr]^.MPX;
    if sw in [1..4] then with COM[TNC[TNr]^.RS232] do
    begin
      MCR := Port[Base + $04];
      if HwHs then MCR := MCR and $FE
	      else MCR := MCR and $FC;
      case sw of                            { RTS DTR }
	1 : Port[Base + $04] := MCR or $00; {  L   L  } { L = ca.-12V }
	2 : Port[Base + $04] := MCR or $01; {  L   H  } { H = ca.+12V }
	3 : Port[Base + $04] := MCR or $02; {  H   L  }
	4 : Port[Base + $04] := MCR or $03; {  H   H  }
      end;
      Verzoegern(2);       { ... fÅr alle FÑlle ... }
    end;
  end;
End;


Function ReSync (* V24Nr : Byte) : Boolean *);
Var     w,i,iz      : Word;
	KC     : SonderTaste;
	VC, ch     : Char;
	Flag   : Boolean;
	Hstr   : String[10];

Begin
  Inc(Resync_Z);
  if Klingel then Beep(1500,20);
  i := 0;
  VC := #0;
  Flag := false;

  Repeat
    inc(i);
    StatusOut(show,1,3,Attrib[14],'COM-' + int_str(V24Nr) + ' Resynch: ' + int_str(i),1);

    ClearV24Buffer;
    WriteAux(V24Nr,#1);
    Wait_Read(V24Nr);

    move(V24Buffer[2],Hstr[1],10);
    Hstr[0] := #10;
    Flag := pos('INVALID',Hstr) = 1;
    if not Flag then
     begin
      move(V24Buffer[1],Hstr[1],10);
      Hstr[0] := #10;
      Flag := pos('INVALID',Hstr) = 1;
     end;
{    StatusOut(show,1,3,Attrib[14],hstr,1);}

    While _KeyPressed do _ReadKey(KC,VC);
  Until (i = 260) or (VC = ^C) or Flag;

(*  if not Flag then
   begin
  ClearV24Buffer;
  WriteAux(V24Nr,ESC+M1);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,^Q^X);
  Wait_Read(V24Nr);

  if V24Buffer[0] = 6 then
  begin
    WriteAux(V24Nr,^R^X);
    Wait_Read(V24Nr);
  end;

  ClearV24Buffer;
  WriteAux(V24Nr,ESC + 'E1'+ M1);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,^X);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,ESC);
  Wait_Read(V24Nr);


  ClearV24Buffer;
  WriteAux(V24Nr,^Q^X);
  {^Q^M^X statt JHOST0 geht auch anstatt ESC+M1, QX}
  Wait_Read(V24Nr);

  if V24Buffer[0] = 6 then
  begin
    WriteAux(V24Nr,^R^X);
    Wait_Read(V24Nr);
  end;

  ClearV24Buffer;
  WriteAux(V24Nr,ESC + 'E1'+ M1);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,^X);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,ESC);
  Wait_Read(V24Nr);

  ch := Chr(V24Buffer[0]);

    i := 10;
    While (ch <> '*') and (i > 0) do
    begin
      Wait_Read(V24Nr);
      w := BufferPos;
      While (w > 0) and (ch <> '*') do
      begin
        dec(w);
        ch := Chr(V24Buffer[w]);
      end;
      if ch <> '*' then ClearV24Buffer;
      dec(i);
    end;

    Flag:=true; VC:=#23;
    if ch <> '*' then Flag:=False;

    if not Flag then
    begin
     ClearV24Buffer;
     WriteAux(V24Nr,'JHOST1' + M1);
     Wait_Read(V24Nr);
     Verzoegern(300);
    end;

  ClearV24Buffer;

  end;
  *)

  if Flag and (VC <> ^C) then
  begin
    Wait_Read(V24Nr);
    ClearV24Buffer;
    ReSync := true;
  end else ReSync := false;

  SetzeFlags(show);
  if K[show]^.connected then UserInStatus(show)
   else UserInStatus (show);
End;


Procedure Wait_Read (* V24Nr : Byte *);
Var  l : LongInt;
Begin
  TimeOut := 0;
  l := TimerTick;

  if (V24Nr = 5) then
  begin
    Repeat
      get_Chr_TFPC;
      if l <> TimerTick then
      begin
	inc(TimeOut);
	l := TimerTick;
      end;
    Until TimeOut >= Wait_TimeOut;
  end else if HwHs then
  begin
    RTS_Setzen(V24Nr);
    Repeat
      if l <> TimerTick then
      begin
	inc(TimeOut);
	l := TimerTick;
      end;
      get_Chr_Hs(V24Nr);
    Until TimeOut >= Wait_TimeOut;
    RTS_Loeschen(V24Nr);
  end else Verzoegern(120);
End;


Procedure ClearV24Buffer;
var    ch : Char;
Begin
  FillChar(V24Buffer,SizeOf(V24Buffer),0);
  BufferPos := 0;
End;


Procedure get_Response (* Kanal *);
Var     V24Nr,
	a,b     : Byte;
	l       : LongInt;
	Ok      : Boolean;
Begin
  with K[Kanal]^ do
  begin
    V24Nr := V24(Kanal);
    Ok := false;
    TimeOut := 0;
    l := TimerTick;
    if HwHs then RTS_Setzen(V24Nr);
    Repeat
      if HwHs then get_Chr_Hs(V24Nr);
      if V24Nr = 5 then get_Chr_TFPC;
      if (BufferPos = 2) and (V24Buffer[1] = 0) then Ok := true;
      if (BufferPos > 2) then
      begin
	if (V24Buffer[1] < 6) and (V24Buffer[BufferPos-1] = 0) then Ok := true;
	if (V24Buffer[1] > 5) and (V24Buffer[2] + 4 = BufferPos) then Ok := true;
      end;

      if l <> TimerTick then
      begin
	inc(TimeOut);
	l := TimerTick;
      end;
    Until Ok or OverRun or (TimeOut > TNC_TimeOut);

    if HwHs then RTS_Loeschen(V24Nr);

    IRQsFree;
    if OverRun then Wait_Read(V24Nr);

    if TimeOut > TNC_TimeOut then
    begin
      if not ReSync(V24Nr) then DRSI_Hostmode(TncNummer,1);
    end else BufToResp(Kanal);

    ClearV24Buffer;
  end;
End;

Procedure BufToResp (* Kanal : Byte *);
Var    V24Nr : Byte;
       ic    : Word;
       Hstr  : String[80];
Begin
  with K[Kanal]^ do
  begin
    V24Nr := V24(Kanal);

    if not (SynchError or OverRun) then
    begin
      Kan_Char := Chr(V24Buffer[0]);
      TNC_Code := V24Buffer[1];
      if (Pseudo or (Kan_Char = TNCKanal)) and ((TNC_Code >= 0) and (TNC_Code < 8)) then
      begin
	if (TNC_Code = 6) or (TNC_Code = 7) then
	begin
	  TNC_Count := V24Buffer[2] + 1;
	  if TNC_Count > FF then ic := FF
			    else ic := TNC_Count;
	  move(V24Buffer[3],Response[1],ic);
	  Response[0] := Chr(ic);
	  if TNC_Count > FF then Response256 := Chr(V24Buffer[TNC_Count + 2]);
	end else if TNC_Code > 0 then
	begin
	  move(V24Buffer[2],Response[1],BufferPos - 3);
	  Response[0] := Chr(BufferPos - 3);
	end;
      end else SynchError := true;
    end;

    ClearV24Buffer;

    if SynchError or OverRun then
    begin
      Beep(1300,10);
      Hstr := Star + TNC[TncNummer]^.Ident + B1 + SynchErrStr + int_str(V24Nr);
      if OverRun then Hstr := Hstr + B1 + OverRunStr;
      if not K[0]^.RxLRet then Hstr := ^J + Hstr;
      M_aus(Attrib[28],Hstr + ^J, Kanal);
      inc(SynchErrAnz);
    end;

    Pseudo := false;
  end;
End;
