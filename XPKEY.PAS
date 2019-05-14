{ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
 ｳ                                                                         ｳ
 ｳ                             X - P a c k e t                             ｳ
 ｳ                                                                         ｳ
 ｳ                                                                         ｳ
 ｳ  X P K E Y . P A S                                                      ｳ
 ｳ                                                                         ｳ
 ｳ Routinen f〉 die Tastaturabfrage                                        ｳ
 ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ}


Procedure _ReadKey (* var SK : Sondertaste; var VC : char *);
var  Code,
     Scan   : Byte;
     Shift  : Boolean;

   Procedure FunktionsTaste(cch: char);
   begin
     case cch of
       #59  : SK := _F1;    #84  : SK := _ShF1;    #94  : SK :=  _CtrlF1;
       #60  : SK := _F2;    #85  : SK := _ShF2;    #95  : SK :=  _CtrlF2;
       #61  : SK := _F3;    #86  : SK := _ShF3;    #96  : SK :=  _CtrlF3;
       #62  : SK := _F4;    #87  : SK := _ShF4;    #97  : SK :=  _CtrlF4;
       #63  : SK := _F5;    #88  : SK := _ShF5;    #98  : SK :=  _CtrlF5;
       #64  : SK := _F6;    #89  : SK := _ShF6;    #99  : SK :=  _CtrlF6;
       #65  : SK := _F7;    #90  : SK := _ShF7;    #100 : SK :=  _CtrlF7;
       #66  : SK := _F8;    #91  : SK := _ShF8;    #101 : SK :=  _CtrlF8;
       #67  : SK := _F9;    #92  : SK := _ShF9;    #102 : SK :=  _CtrlF9;
       #68  : SK := _F10;   #93  : SK := _ShF10;   #103 : SK :=  _CtrlF10;
       #133 : SK := _F11;   #135 : SK := _ShF11;   #137 : SK :=  _CtrlF11;
       #134 : SK := _F12;   #136 : SK := _ShF12;   #138 : SK :=  _CtrlF12;

       #104 : SK := _AltF1;       #120 : SK := _Alt1;
       #105 : SK := _AltF2;       #121 : SK := _Alt2;
       #106 : SK := _AltF3;       #122 : SK := _Alt3;
       #107 : SK := _AltF4;       #123 : SK := _Alt4;
       #108 : SK := _AltF5;       #124 : SK := _Alt5;
       #109 : SK := _AltF6;       #125 : SK := _Alt6;
       #110 : SK := _AltF7;       #126 : SK := _Alt7;
       #111 : SK := _AltF8;       #127 : SK := _Alt8;
       #112 : SK := _AltF9;       #128 : SK := _Alt9;
       #113 : SK := _AltF10;      #129 : SK := _Alt0;
       #139 : SK := _AltF11;
       #140 : SK := _AltF12;

       #16 : SK := _AltQ;    #30 : SK := _AltA;    #44 : SK := _AltZ;
       #17 : SK := _AltW;    #31 : SK := _AltS;    #45 : SK := _AltX;
       #18 : SK := _AltE;    #32 : SK := _AltD;    #46 : SK := _AltC;
       #19 : SK := _AltR;    #33 : SK := _AltF;    #47 : SK := _AltV;
       #20 : SK := _AltT;    #34 : SK := _AltG;    #48 : SK := _AltB;
       #21 : SK := _AltY;    #35 : SK := _AltH;    #49 : SK := _AltN;
       #22 : SK := _AltU;    #36 : SK := _AltJ;    #50 : SK := _AltM;
       #23 : SK := _AltI;    #37 : SK := _AltK;
       #24 : SK := _AltO;    #38 : SK := _AltL;
       #25 : SK := _AltP;

       #71 : SK := _Home;    #114 : SK := _CtrlPrtSc;
       #73 : SK := _PgUp;    #115 : SK := _CtrlLeft;
       #79 : SK := _End;     #116 : SK := _CtrlRight;
       #81 : SK := _PgDn;    #117 : SK := _CtrlEnd;
       #82 : SK := _Ins;     #118 : SK := _CtrlPgDn;
       #83 : SK := _Del;     #119 : SK := _CtrlHome;
       #72 : SK := _Up;      #132 : SK := _CtrlPgUp;
       #80 : SK := _Dn;
       #77 : SK := _Right;
       #75 : SK := _Left;
       #15 : SK := _ShTab;
       #76 : SK := _Fuenf;
        else SK := _Nix;
     end;  { case }
     VC := cch;
     if Shift then
     begin
       case SK of
         _Left  : SK := _ShLeft;
         _Right : SK := _ShRight;
         _Up    : SK := _ShUp;
         _Dn    : SK := _ShDn;
         _Ins   : SK := _ShIns;
         _Del   : SK := _ShDel;
         _Home  : SK := _ShHome;
         _End   : SK := _ShEnd;
         _PgUp  : SK := _ShPgUp;
         _PgDn  : SK := _ShPgDn;
       end;
     end;
   end;

Begin
  if G^.Makro then MakroKey(SK,VC) else
  begin

     {-------------------------------------------------------------|
     | Status liefert den Status der Sondertasten                  |
     +-------------------------------------------------------------|
     | Bit 0 = 1 : Rechte Shift-Taste gedr…kt                     |
     | Bit 1 = 1 : Linke Shift-Taste gedr…kt                      |
     | Bit 2 = 1 : Crtl-Taste gedr…kt                             |
     | Bit 3 = 1 : Alt-Taste gedr…kt                              |
     | Bit 4 = 1 : [Scroll Lock] gedr…kt                          |
     | Bit 5 = 1 : [Num Lock] gedr…kt                             |
     | Bit 6 = 1 : [Caps Lock] gedr…kt                            |
     | Bit 7 = 1 : [Ins] gedr…kt                                  |
     +-------------------------------------------------------------}


    Case Kbd of
      0 : begin
            Repeat
            { if OnlHelp then TNCs_pollen; }
            Until Key1A <> Key1C;
            code := TastPuffer[Key1A];
            scan := TastPuffer[Key1A+1];
            if Key1A + 2 > $3D then Key1A := $1E
                               else Key1A := Key1A + 2;
          end;
      1 : begin
            asm
              mov  ah, $10
              int  $16
              mov  code,al
              mov  scan,ah
            end;
          end;
      2 : begin
            asm
              mov  ah, $00
              int  $16
              mov  code,al
              mov  scan,ah
            end;
          end;
      3 : begin
            asm
              mov  ah,$07
              int  $21
              mov  code,al
              cmp  code,0
              jnz  @1
              mov  ah,$07
              int  $21
              mov  scan,al
             @1:
            end;
          end;
    End;

    if (code = $E0) and (scan > 0) then code := $00;
    if (code = $F0) and (scan > 0) then code := $00;
    VC := Chr(Code);
    Shift := (KeyStatus and 3) in [1..3];

    if VC = #0 then FunktionsTaste(Chr(scan)) else
    begin
      case VC of
        M1 : SK := _Ret;
        ^I : SK := _Tab;
        ^H : SK := _Back;
       #27 : SK := _Esc;
       else  SK := _Andere;
      end;

      if Shift and (KeyOpt in [1,3]) then
      case VC of
        '1' : SK := _ShEnd;
        '2' : SK := _ShDn;
        '3' : SK := _ShPgDn;
        '4' : SK := _ShLeft;
        '6' : SK := _ShRight;
        '7' : SK := _ShHome;
        '8' : SK := _ShUp;
        '9' : SK := _ShPgUp;
      end;

      if KeyOpt in [2,3] then
      case VC of
        '+': if scan = 78 then SK := _Plus;
        '-': if scan = 74 then SK := _Minus;
        '*': if scan = 55 then SK := _Star;
        '/': if scan = 53 then SK := _Slash;
      end;

    end;
    if G^.MakroLearn then Makro_Erlernen(SK,VC);
  end;
End;

Function  _KeyPressed (* : Boolean *);
Var   w : Word;
Begin
  Case Kbd of
    0 : _KeyPressed := Key1A <> Key1C;
    1 : begin
          asm
            mov  ah, $11
            int  $16
            pushf
            pop  w
            and  w, $40
          end;
          _KeyPressed := w = 0;
        end;
    2 : begin
          asm
            mov  ah, $01
            int  $16
            pushf
            pop  w
            and  w, $40
          end;
          _KeyPressed := w = 0;
        end;
    3 : _KeyPressed := KeyPressed;
  End;

  if G^.Makro then _KeyPressed := true;
End;


Procedure MakroKey (* var SK : Sondertaste; var VC : char *);
var    Taste : Sondertaste;
       Flag  : Boolean;

  Procedure Init;
  Begin
    G^.Makro := false;
    G^.MakroZeile := '';
    SK := _Nix;
    VC := #255;
  End;

Begin
  if G^.MakroZeile = '' then MakroZeile_holen;
  if pos(S_ch+B1,G^.MakroZeile) = 1 then
  begin
    G^.MakroZeile := UpCaseStr(RestStr(G^.MakroZeile));
    Taste := _CtrlF1;
    Flag := false;
    While not Flag and (Taste <> _Key2) do
    begin
      if Key[Taste].Ta = G^.MakroZeile then
      begin
        SK := Taste;
        VC := Key[Taste].Ze;
        Flag := true;
      end;
      inc(Taste);
    end;

    if not Flag then
    begin
      if (pos(CTRL,G^.MakroZeile) = 1) and (length(G^.MakroZeile) = 5) then
      begin
        VC := G^.MakroZeile[5];
        if VC in ['A'..'Z'] then
        begin
          VC := chr(ord(VC)-64);
          SK := _Andere;
          Flag := true;
        end;
      end;
      if not Flag then
      begin
        SK := _Nix;
        VC := #255;
      end;
    end;
    G^.MakroZeile := '';
  end else
  begin
    SK := _Andere;
    VC := G^.MakroZeile[1];
    delete(G^.MakroZeile,1,1);
  end;
  if G^.MakroFileEnd and (G^.MakroZeile = '') then MakroInit;
End;

