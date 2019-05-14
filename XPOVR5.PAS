{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 5 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR5;
{$F+,O+}

Interface

Uses CRT,
     DOS,
     OVERLAY,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funktionen der XPUSER.PAS *)
Procedure UserZeigen (Kanal : Byte; VAR Call2:Str9);
Procedure GetUser(var udi:longint);
Procedure PutUser(Neu: User_typ2; Var Resultat : Byte; Typ : Byte; VAR _DPos:longint; Shard:Boolean);
Function UserSuchroutine (CallS : Str10; var USu:longint; Sali, shart:boolean) : Boolean;
Function UserSuchen (VAR USuch:Longint; SCall:string; SAlias:boolean) : Boolean;
Procedure DatensatzHolen(DatP:Longint; Var UDs: User_typ2);
Procedure NeuNameSave(User2: User_typ2; Var Result : Byte);
Procedure UserAnwesend;

(* XPUSEDIT.Pas *)
Procedure UserEditieren(User_:User_Typ2; Kanal :Byte; Neu:boolean; ZMax:Byte; VAR NeuPos : LongInt);
Function UserShow (Kanal:Byte;Suche:Str9) : Boolean;

(* XPMAIL.PAS *)
Procedure StartMailPolling(Kanal : byte; RXCall:str9);
Procedure Link_Holen (Var Port : Byte; Var CString : Str80);
Procedure MailVersucheRauf (DPos:LongInt);
Function MailsVorhanden : Boolean;
Procedure MailKillen (Box, RX:Str10; DPos : longint);
Procedure MailSpeichern (Mail : Mail_Typ);
Procedure MailsZeigen (Kanal : Byte);
Procedure MailPollGo (Kanal:Byte; NFwd:boolean);
Procedure MailSchliessen (Kanal:byte);
procedure CancelMailPoll (Kanal:Byte);
procedure LinksVorbereiten(Port:byte;QRG:Str10);
procedure LinksKillen;


{XPXBIN}
Function XBinStr (Kanal : Byte; Zeile : String; TXPos:longint) : String;
Procedure XBinCheck (kanal : Byte; XBinZ:string; DtPos:longint; XZeile:string);
procedure XBinWrite (kanal:Byte; Zeile:string);
Procedure XBinSend (Kanal : Byte; OFlag : Boolean);
Procedure OpenXBinProt (Kanal:byte);
Procedure CloseXBinProt (Kanal:byte);

{XPQTH}

PROCEDURE QTH_Pruefen      (QTH             : STRING;
                            VAR
                             OESLAE,
                             NOEBRE         : REAL;
                            VAR
                              STATUS        : BOOLEAN);
PROCEDURE QTH_ENTFG_RICHTG (QTH1            : STRING;
                            QTH2            : STRING;
                            VAR
                              ENTFG,
                              RICHTG        : REAL;
                            VAR
                              STATUS        : BOOLEAN);
FUNCTION  WINKEL_IN_ALT(OESLAE,NOEBRE :REAL):STRING;
FUNCTION  WINKEL_IN_NEU(OESLAE,NOEBRE :REAL):STRING;
FUNCTION  WINKEL_IN_GMS (OESLAE,NOEBRE:REAL):STRING;
Procedure Compute_QTH (Var Zeile : Str80 );

{$IFNDEF no_Netrom} {//db1ras}
{Funktionen und Prozeduren in XPNETROM.PAS}
Procedure NodesSortieren;
Procedure NodesLifetime;
Function NodesAnzahl(Nafu:Boolean) : integer;
Procedure NodeListen(Naf : Boolean);
Procedure BCastKillen;
Procedure REMNodesListen (Kanal:Byte;CZeile:String);
Procedure REMRoutesListen (Kanal:Byte; CZeile:String);
{$ENDIF}



Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR1,
      XPOVR2,
      XPOVR3,
      xpovr4,
      xpovr6;


{$I XPUSER}
{$I XPUSEDIT}
{$I XPMAIL}
{$I XPQTH}
{$I XPXBIN}

{$IFNDEF no_Netrom} {//db1ras}
{$I XPNETROM}
{$ENDIF}
End.
