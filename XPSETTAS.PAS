UNIT XPSetTas;

{ Unit zur Tastenauswertung }


INTERFACE
USES dos, CRT;

VAR Aktion,
  AktionSeitLetztem : BOOLEAN;
  klicks2 : INTEGER;
  
  
CONST
  F1  = #180;
  PgUp = #193;
  F2  = #181;
  PgDn = #194;
  F3  = #182;
  Pos1 = #195;
  F4  = #183;
  Ende = #196;
  F5  = #184;
  Einf = #197;
  F6  = #185;
  Entf = #198;
  F7  = #186;
  CsUp = #199;
  F8  = #187;
  CsDn = #200;
  F9  = #189;
  CsRt = #201;
  f10 = #190;
  CsLt = #202;
  F11 = #191;
  Esc  = #27;
  F12 = #192;
  CR   = #13;
  BS  = #8;
  CtrlY = #206;
  TAB = #9;
  SHIFT_TAB = #208;
  CTRL_PgUp = #209;
  CTRL_PgDn = #210;
  CTRL_CsRt = #211;
  CTRL_CsLt = #212;
  CTRL_POS1 = #213;
  CTRL_Ende = #214;
  CTRL_ENTF = #12; {********* ACHTUNG! IST CTRL-L!!! ****}
  
  SHIFT_F5 = #216;
  SHIFT_F6  = #217;
  SHIFT_F7 = #218;
  SHIFT_F8  = #219;
  SHIFT_F9 = #220;
  SHIFT_F10 = #221;
  CTRL_F5  = #222;
  CTRL_F6   = #223;
  CTRL_F7  = #176;
  CTRL_F8   = #177;
  CTRL_F9  = #178;
  CTRL_F10  = #179;
  
  ALT_F5   = #28;
  alt_F6    = #29;
  ALT_F7   = #203;
  alt_F8    = #204;
  ALT_F9   = #207;
  alt_F10   = #205;
  
  CTRL_T   = #20;
  CTRL_K   = #11;
  CTRL_V   = #22;
  ALT_K    = #255;
  ALT_V    = #254;
  CTRL_S   = #19;
  CTRL_Z   = #26;
  CTRL_r   = #18;
  CTRL_I   = #09;
  ctrl_w   = #23;
  
FUNCTION taste : CHAR;
FUNCTION TastFlag (Flag   : BOOLEAN;
FlagReg : INTEGER) : BOOLEAN;

  IMPLEMENTATION
  
  
  

VAR saawar : BOOLEAN;
  regi : REGISTERS;
  fa : BYTE;
  
FUNCTION TastFlag (Flag   : BOOLEAN;       { der letzte Status des Flags }
FlagReg : INTEGER  { der aktuelle Status des Flag (0 = aus) }
) : BOOLEAN;

VAR FRegs : REGISTERS;
  
BEGIN
    FRegs.ah := $2;             { Funktionsnummer fÅr Tastatursatus lesen }
    INTR ($16, FRegs );
    FlagReg := FRegs.al AND FlagReg;
    IF (Flag AND (FlagReg = 0) ) OR            { testen ob sich der Status }
       (NOT (Flag) AND (FlagReg <> 0) ) THEN    { des Flags geÑndert hat    }
       BEGIN                                                           { JA }
         IF FlagReg = 0 THEN                           { ist Flag jetzt aus? }
            BEGIN                                                         { JA }
              TastFlag := FALSE;              { Ergebnis der Funktion : Flag aus }
            END
         ELSE
            BEGIN                                          { Flag ist jetzt an }
              TastFlag := TRUE;                  { Ergebnis der Funktion : Flag an }
            END;
       END
    ELSE
       TastFlag := Flag         { Status des Flags hat sich nicht verÑndert }
END;


FUNCTION taste : CHAR;
VAR t : CHAR;
  
 PROCEDURE Auswertung (t2 : CHAR);
 BEGIN
    CASE t2 OF
         #15 : t := SHIFT_TAB;
         #59 : t := F1;
         #73 : t := PgUp;
         #60 : t := F2;
         #81 : t := PgDn;
         #61 : t := F3;
         #71 : t := Pos1;
         #62 : t := F4;
         #79 : t := Ende;
         #63 : t := F5;
         #82 : t := Einf;
         #64 : t := F6;
         #83 : t := Entf;
         #65 : t := F7;
         #72 : t := CsUp;
         #66 : t := F8;
         #80 : t := CsDn;
         #67 : t := F9;
         #77 : t := CsRt;
         #68 : t := f10;
         #75 : t := CsLt;
         #132 : t := CTRL_PgUp;
         #118 : t := CTRL_PgDn;
         #116 : t := CTRL_CsRt;
         #115 : t := CTRL_CsLt;
         #119 : t := CTRL_POS1;
         #117 : t := CTRL_Ende;
         
         #88 : t := SHIFT_F5;
         #89 : t := SHIFT_F6;
         #90 : t := SHIFT_F7;
         #91 : t := SHIFT_F8;
         #92 : t := SHIFT_F9;
         #93 : t := SHIFT_F10;
         
         #98 : t := CTRL_F5;
         #99 : t := CTRL_F6;
         #100 : t := CTRL_F7;
         #101 : t := CTRL_F8;
         #102 : t := CTRL_F9;
         #103 : t := CTRL_F10;
         
         #108 : t := ALT_F5;
         #109 : t := alt_F6;
         #110 : t := ALT_F7;
         #111 : t := alt_F8;
         #112 : t := ALT_F9;
         #113 : t := alt_F10;
         
         #37 : t := ALT_K;
         #47 : t := ALT_V;
         
    END;
 END;

BEGIN
      saawar := FALSE;
         t := READKEY;
         IF t = #0 THEN
            Auswertung (READKEY);
         IF t = #12 THEN
            t := CTRL_ENTF;
         IF t = #13 THEN
            t := CR;
         IF t = #20 THEN
            t := CTRL_T;
         IF t = #19 THEN
            t := CTRL_S;
         IF t = #11 THEN
            t := CTRL_K;
         IF t = #22 THEN
            t := CTRL_V;
         IF t = #27 THEN
            t := Esc;
         IF t = #25 THEN
            t := CtrlY;
         IF t = #26 THEN
            t := CTRL_Z;
         IF t = #9  THEN
            t := TAB;
         IF t = #8  THEN
            t := BS;
           taste:=t;
         
END;
END.