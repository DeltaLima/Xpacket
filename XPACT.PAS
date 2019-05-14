{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P A C T . P A S                                                ³
 ³                                                                         ³
 ³ Programmcode, der staendig im RAM des Rechners geladen ist              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Unit XPACT;
{$F+}
{-$DEFINE Sound}
{-$DEFINE code}
Interface

Uses CRT,
     DOS,
     OVERLAY,
     MEMORY,

     XPDEFS,
     XPEMS,
     XPXMS;


(* Proceduren und Funtionen der XPIO.PAS *)
Procedure Screen_aus(Art : Byte);
Procedure Uhr_aus;
Procedure GetTNC(Kanal : Byte);
Procedure S_PAC(Kanal,Art : Byte; All : Boolean; Zeile : String);
Procedure TxRxTNC(Kanal,Art : Byte; Zeile : String);
Procedure SendTNC(Var Kanal : Byte; Art : Byte; Zeile : String);
Procedure Moni_Off(Art : Byte);
Procedure Moni_On;
Procedure Check_Mld(Kanal: Byte; Zeile : Str80);
Procedure TNC_Info(Kanal,Attr : Byte; Zeile : String);
Procedure Comp_Sammler(Kanal,Attr : Byte; FrEnd : Boolean; Zeile : String);
Function XComp_Sammler (Kanal: Byte; Zeile : String) : String;
Procedure Connect_Info(Kanal,Attr : Byte; FrEnd : Boolean; Zeile : String);
Function  FreiePuffer(Kanal : Byte) : Word;
Procedure Mon_Header_Auswerten;
Procedure TNCs_Pollen;
Procedure Kanal_Pollen(Kanal : Byte);
Procedure Get_Linkstatus(Kanal : Byte);
Procedure Check_Keyboard;
Procedure Rufz_TNC_init(Kanal : Byte);
Function  QuerCheck(Zeile : String) : Word;
Procedure MH_Check(TNC_Nr : Byte; Zeile : Str128);
Procedure TickerOut;
Function  FormMonFr(TNr : Byte; Hstr : Str5; Zeile : String) : String;


(* Proceduren und Funtionen der XPV24.PAS *)
Procedure IRQsLock;
Procedure IRQsFree;
Procedure get_Chr_TFPC;
Procedure get_Chr_Hs (V24Nr : Byte);
Procedure V24_Init;
Procedure WriteAux (V24Nr : Byte; Zeile : String);
Procedure V24_Close;
Procedure Switch_TNC (TNr : Byte);
Function  ReSync (V24Nr : Byte) : Boolean;
Procedure Wait_Read (V24Nr : Byte);
Procedure ClearV24Buffer;
Procedure get_Response (Kanal : Byte);
Procedure BufToResp (Kanal : Byte);


(* Proceduren und Funtionen der XPKEY.PAS *)
Procedure _ReadKey(var SK : Sondertaste; var VC : char);
Function  _KeyPressed : Boolean;
Procedure MakroKey(var SK : Sondertaste; var VC : char);


(* Proceduren und Funtionen der XPAUS.PAS *)
Procedure Scroll(Art : str2; Aufruf,Y1,Y2 : Byte);
Procedure _aus(Attr,Kanal : Byte; Zeile : String);
Procedure M_aus(Attr : Byte; Zeile : String; Kanal : Byte);
Procedure Write_Notiz(Kanal : Byte);
Procedure Write_Notstr(Kanal : Byte; ch : Char);
Procedure Write_BoxStr(Kanal,Art : Byte);
Procedure Morse(Kanal : Byte; Zeile : str80);
Function  Compress (Zeile : String; Kanal : Byte) : String;
Function  DeCompress (Zeile : String; Kanal : Byte) : String;
Function  SPCompress (Zeile : String; Kanal : Byte) : String;
Function  SPDeCompress (Zeile : String; Kanal : Byte) : String;


Implementation

Uses XPACT1,

     XPOVR,
     XPOVR1,
     XPOVR2,
     XPOVR3,
     XPOVR4,
     xpovr5,
     xpovr6;


{$I XPIO}
{$I XPV24}
{$I XPKEY}
{$I XPAUS}

End.
