{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R . P A S                                                ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR;
{$F+,O+}
{-$DEFINE Sound}
Interface

Uses CRT,
     DOS,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funtionen der XPINI.PAS *)
Procedure Var_Init(Kanal : Byte);


(* Proceduren und Funtionen der XPLIB1.PAS *)
Function CheckXP161 (kanal:Byte) :Boolean;
Function PackDT : longint;
PROCEDURE Editor;
Procedure Link_erhalter(Kanal : Byte; var Zeile : Str80);
Procedure RC_update(Kanal : Byte; var Zeile : str80);
Procedure File_Umbenennen(alt,neu : Str80; var Ueber,Art : Integer);
Function SetzeSysArt (Kanal : Byte) : Boolean;   {//db1ras}

{$IFNDEF no_Bake}       {//db1ras}
Procedure BakenMenu;
{$ENDIF}

Procedure Tschuess(Kanal : Byte);
Procedure TschuessFenster;
Procedure TestCheck(Kanal : Byte; Zeile : Str80);
Procedure UserInStatus (Kanal : Byte);
Procedure Connect(Kanal : Byte; Zeile : Str80);
Procedure S_Aus(Kanal,Art : Byte; Zeile : String);
Procedure RC_Alle(Kanal,Art : Byte);
Procedure TNC_Parm(Kanal,Art : Byte);
Procedure GetVideoMode;
Procedure Umlautstatus_Aendern(Kanal : Byte);
Procedure Echo_Menue(Kanal : Byte);
Function  LPT_Error(Nr : Byte) : Boolean;
Procedure Write_Lpt(Kanal : Byte; Zeile : Str20);
Procedure Write_Drucker(Kanal : Byte; Zeile : String);
Procedure LptEscSeq(Kanal : Byte; Zeile : Str80);
Procedure Lpt_On_Off(Kanal : Byte);
Procedure Vorschreib_Uebergabe;
Procedure Vorschreib_Such(Kanal : Byte);
Procedure Belog_Eintrag(Kanal : Byte);
Procedure BoxListe (Kanal : Byte);
Procedure L_ON(Kanal : Byte; Zeile : Str128; Connect_out,ReKon : Boolean);
Procedure L_Off(Kanal : Byte);
Procedure LogBuchEintrag(Kanal,Art : Byte);
Procedure Line_ON(Kanal : Byte);
Procedure FreiKanalSuch(Kanal : Byte; Zeile : Str80);
Procedure Remote_Connect_Aufbauen(Kanal : Byte; Zeile : Str80);
Procedure RemConInit(Kanal : Byte);
Procedure Unproto_darstellen;
Procedure Terminal_Kanal(Kanal : Byte; Anz : ShortInt);
Procedure Trennzeilen(Kanal : Byte; KC : SonderTaste);
Procedure Fenster_Berechnen;
Procedure Change_WIN;
Procedure ClearVorBuffer(Kanal : Byte);
Procedure ClearScrBuffer(Kanal : Byte);
Function  GetWeekDay (Dstr : Str8) : Str2;
Procedure Text_Einstellung(Kanal : Byte);
Procedure Compress_Ein_Aus(Kanal : Byte);
Procedure CompressMenu(Kanal : Byte);
Procedure Morse_Menue(Kanal : Byte);
Procedure Voice_Menue(Kanal : Byte);
Procedure QRG_Einstellen(Kanal : Byte; Zeile : Str8);
Procedure Verschiedene_Einstellungen(Kanal : Byte);
Procedure Alt_Disc(Kanal : Byte);
Procedure Auswert_Kopieren(Kanal : Byte; Zeile : Str80);
Procedure Idle_Einstellen(Kanal : Byte; Zeile : Str20);
Procedure Remote_Emulieren(Kanal : Byte; Zeile : Str80);
Procedure GetString(var S     : Str80;
                        Attr,
                        L,X,Y : Byte;
                    var TC    : Sondertaste;
                        Art   : Byte;
                    var Ins   : Boolean);




(* Proceduren und Funtionen der XPMH.PAS *)
Procedure MH_Sort(Art : Byte);
Procedure MH_Show;
Procedure RemoteMH(Kanal,T : Byte; Zeile : Str9);
Function CBCallCheck (CBCall : Str9) : Boolean;

{$IFDEF Sound} {//db1ras}
(* Function der XPMIDI *)
Function PlayMidi (MidiFilename : String) : Boolean;
{$ENDIF}

Implementation

Uses  XPACT,
      XPACT1,

      XPOVR1,
      XPOVR2,
      XPOVR3,
      XPOVR4,
      xpovr5

{$IFDEF Sound} {//db1ras}
      ,midifm,
      midifile,
      ibk
{$ENDIF}
      ;



{$I XPINI}
{$I XPLIB1}
{$I XPMH}

{$IFDEF Sound} {//db1ras}
{$I MID2}
{$ENDIF}

End.
