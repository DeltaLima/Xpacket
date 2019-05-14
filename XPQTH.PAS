{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P Q T H . P A S                                                      ³
 ³                                                                         ³
 ³ QTH-Kennerberechnung nach Routinen von DL5FBD (QTHBER V2.2)             ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

(***********************************************************)
(* Funktionsprozeduren und Funktionen zur QTH-Kennerbe-    *)
(* rechnung in Turbo-Pascal                                *)
(* UNIT QTHBER V2.2 von G. M. Ritter DL5FBD  Juni 1993     *)
(***********************************************************)


(***********************************************************)
(* Procedure Entfernung_Richtung                           *)
(* Die Prozedur dient zur Berechnung von Entfernung und    *)
(* Richtung bei gegebenen geografischen Koordinaten im     *)
(* Gradmass.                                               *)
(* Ergebnis sind Entfernung in Kilometern und Richtung in  *)
(* Grad von QTH1 nach QTH2.                                *)
(* O1,N1 Oestliche Laenge,Noerdliche Breite von QTH1       *)
(* O2,N2 Oestliche Laenge,Noerdliche Breite von QTH2       *)
(***********************************************************)

PROCEDURE Entfernung_Richtung (O1,N1,O2,N2             :REAL;
                               VAR Entfernung,Richtung :REAL);

CONST PI=3.1415926; (*Kreiskonstante PI    *)
VAR   EW,RV :REAL;  (*EW Entfernungswinkel *)
                    (*RV vorlaeufige Richtg*)


(* Funktion GSIN                                           *)
(* Berechnung des Sinus zu einem gegebenen Gradwinkel      *)

FUNCTION GSIN(WINKEL :REAL):REAL;
BEGIN
   GSIN:=SIN(Winkel*PI/180);
END;


(* Funktion GCOS                                           *)
(* Berechnung des Cosinus zu einem gegebenen Gradwinkel    *)

FUNCTION GCOS(WINKEL :REAL):REAL;
BEGIN
   GCOS:=COS(Winkel*PI/180);
END;


(* Funktion ARCGCOS                                        *)
(* Berechnung des Gradwinkels zum gegebenen Cosinuswert    *)

FUNCTION ARCGCOS(COSINUS :REAL) :REAL;
VAR ARCBOG :REAL; (*Hilfsvariable vor Gradumrechnung*)
BEGIN
   IF        COSINUS>= 1 THEN ARCGCOS:=  0  (*Sonderfall   0 Grad*)
     ELSE IF COSINUS<=-1 THEN ARCGCOS:=180  (*Sonderfall 180 Grad*)
            ELSE BEGIN
              ARCBOG:=PI/2-ARCTAN(COSINUS/(SQRT(1-SQR(COSINUS))));
              (*Umrechnung vom Bogenmaá in Grad*)
              ARCGCOS:=ARCBOG*180/PI;
            END;
END;


(* Beginn der eigentlichen Entfernungs-Richtungsberechnung *)

BEGIN

(* Entfernungsberechnung *)

  EW:=arcgcos(gsin(n1)*gsin(n2)+gcos(n1)*gcos(n2)*gcos(o2-o1));
  Entfernung:=40009/360*EW;

(* Richtungsberechnung *)

  RV:=arcgcos((gsin(n2)-gsin(n1)*gcos(ew))/(gcos(n1)*gsin(ew)));
  If gsin(o2-o1)>=0  then Richtung:=RV;
  IF gsin(o2-o1)< 0  then Richtung:=360-RV;

END;

(*********** Ende PROCEDURE Entfernung_Richtung ************)


(***********************************************************)
(* FUNCTION NEU_Pruefen                                    *)
(* Diese FUNCTION dient zur Pruefung ob der uebergebene    *)
(* QTH-Kenner ein korrektes Format hat.                    *)
(* Funktionsergebnis TRUE=OK FALSE=ungueltiger Kenner      *)
(* QTHKENN zu pruefender neuer QTH-Kenner als String       *)
(* VERGLEICH[I] Mengenfeld zur Gueltigkeitspruefung        *)
(* I  Index fuer ARRAY-Operationen                         *)
(***********************************************************)

FUNCTION NEU_Pruefen (QTHKENN :STRING):BOOLEAN;

TYPE  MENGE = SET OF CHAR;

CONST VERGLEICH :array [1..6] of MENGE   (* Definitionsmenge des.. *)

 = (['A'..'R','a'..'r'],                 (* 1. Zeichen *)
    ['A'..'R','a'..'r'],                 (* 2. Zeichen *)
    ['0'..'9'],                          (* 3. Zeichen *)
    ['0'..'9'],                          (* 4. Zeichen *)
    ['A'..'X','a'..'x'],                 (* 5. Zeichen *)
    ['A'..'X','a'..'x']);                (* 6. Zeichen *)

VAR   I   :byte;

BEGIN

  IF LENGTH(QTHKENN)=6 THEN

    BEGIN
      NEU_Pruefen:=TRUE;
      For I:=1 to 6 do
        BEGIN
          IF NOT(QTHKENN[I] IN VERGLEICH[I]) then NEU_Pruefen:=FALSE;
        END;
    END

  ELSE NEU_Pruefen:=false;

END;


(***********************************************************)
(* FUNCTION ALT_Pruefen                                    *)
(* Diese FUNCTION dient zur Pruefung ob der uebergebene    *)
(* QTH-Kenner ein korrektes Format hat.                    *)
(* Funktionsergebnis TRUE=OK FALSE=ungueltiger Kenner      *)
(* QTHKENN zu pruefender neuer QTH-Kenner als String       *)
(* VERGLEICH[I] Mengenfeld zur Gueltigkeitspruefung        *)
(* I      Index fuer ARRAY-Operationen                     *)
(* MINFO  Mittelfeldziffer fr Bereichspruefung der        *)
(*        Mittelfelder 10-70 wegen unstetiger Kodierung    *)
(***********************************************************)

FUNCTION ALT_Pruefen (QTHKENN :STRING):BOOLEAN;

TYPE  MENGE = SET OF CHAR;

CONST VERGLEICH :array [1..7] of MENGE   (* Definitionsmenge des..*)

 = (['A'..'Z','a'..'z'],                 (* 1. Zeichen *)
    ['A'..'Z','a'..'z'],                 (* 2. Zeichen *)
    ['0'..'8'],                          (* 3. Zeichen *)
    ['0'..'9'],                          (* 4. Zeichen *)
    ['A'..'H','a'..'h','J','j'],         (* 5. Zeichen *)
    ['/'],                               (* 6. Zeichen *)
    ['1'..'4']);                         (* 7. Zeichen *)

VAR   I      :byte;
      MFINFO :string[2];

BEGIN

  IF (LENGTH(QTHKENN)=5) OR (LENGTH(QTHKENN)=7) THEN

    BEGIN
      ALT_Pruefen:=TRUE;

     (*Jedes Kodezeichen des QTH-Kenners auf Gueltigkeit ueberpruefen*)

      For I:=1 to LENGTH(QTHKENN) do
        BEGIN
          IF NOT(QTHKENN[I] IN VERGLEICH[I]) THEN ALT_Pruefen:=FALSE;
        END;

      (* sowie unerlaubte Mittelfeldkodierungen ausschliessen   *)

      MFINFO:=Copy(QTHKENN,3,2);
      IF (MFINFO='00') OR (MFINFO>'80') THEN ALT_Pruefen:=false;
    END

  ELSE ALT_Pruefen:=false;

END;

(***********************************************************)
(* PROCEDURE NEU_IN_WINKEL                                 *)
(* Diese Procedure dient zum Umwandeln eines neuen QTH-    *)
(* kenners in geografische Laenge und Breite               *)
(* I        Indexvariable fuer Feldzuweisung               *)
(* OESLAE   Oestliche Laenge als Gleitkommawinkel          *)
(* NOEBRE   Noerdliche Breite als Gleitkommawinkel         *)
(* QTHKENN  QTH-Kenner als STRING                          *)
(* WIINFO[6] Feld der QTH-Kennerindexziffern               *)
(* ASCKOR[6] Hilfsfeld zur ASCII-Indexziffernumrechnung    *)
(* Maske [6] Hilfsfeld zur Grossschrifteinstellung         *)
(***********************************************************)

PROCEDURE NEU_IN_WINKEL (QTHKENN :STRING; VAR OESLAE,NOEBRE :REAL);

CONST     ASCKOR :array [1..6] of byte = (065,065,048,048,065,065);
          MASKE  :array [1..6] of byte = (223,223,255,255,223,223);

VAR I      :byte;
    WIINFO :array [1..6] of byte;

BEGIN

(* Ermittlung der Indexziffern aus dem QTH-Kenner *)

  For I:=1 to 6 do
    BEGIN
      WIINFO[I]:=(ORD(qthkenn[I]) AND MASKE[I])-ASCKOR[I];
    END;

(* Berechnung der geografischen Koordinate aus den Indexziffern *)

  OESLAE:=-180+WIINFO[1]*20+WIINFO[3]*2+WIINFO[5]/12+1/24;
  NOEBRE:= -90+WIINFO[2]*10+WIINFO[4]*1+WIINFO[6]/24+1/48;

END;

(************* Ende PROCEDURE NEU_IN_WINKEL ****************)


(***********************************************************)
(* PROCEDURE ALT_IN_WINKEL                                 *)
(* Diese Procedure dient zum Umwandeln eines alten QTH-    *)
(* kenners in geografische Laenge und Breite               *)
(* I        Indexvariable fuer Feldzuweisung               *)
(* OESLAE   Oestliche Laenge als Gleitkommawinkel          *)
(* NOEBRE   Noerdliche Breite als Gleitkommawinkel         *)
(* QTHKENN  QTH-Kenner als STRING                          *)
(* WIINFO[5] Feld der QTH-Kennerindexziffern               *)
(* ASCKOR[5] Hilfsfeld zur ASCII-Indexziffernumrechnung    *)
(* Maske [5] Hilfsfeld zur Grossschrifteinstellung         *)
(* KLOST [10] Hilfsfeld zur Kleinfeldlaengenzuweisung      *)
(* KLNORD [10] Hilfsfeld zur Kleinfeldbreitenzuweisung     *)
(* A          INDEX fuer Quadrantenursprungszuweisung 1-4  *)
(* ALTURN [4] Feld fuer die 4 noerdlichen Ursprungsbreiten *)
(* ALTURO [4] Feld fuer die 4 oestlichen Ursprungslaengen  *)
(***********************************************************)

PROCEDURE ALT_IN_WINKEL (QTHKENN :STRING; VAR OESLAE,NOEBRE :REAL);

CONST     ASCKOR :array [1..5]  of byte     = (065,065,048,048,064);
          MASKE  :array [1..5]  of byte     = (223,223,255,255,223);
          KLNORD :array [1..10] of ShortInt = (-1,-1,-3,-5,-5,-5,-3,-1,0,-3);
          KLOST  :array [1..10] of ShortInt = ( 3, 5, 5, 5, 3, 1, 1, 1,0, 3);
          ALTURO :array [1..4]  of ShortInt = (-52,  0,-52,  0);
          ALTURN :array [1..4]  of ShortInt = ( 40, 40, 14, 14);

VAR I      :byte;
    A      :byte;
    H      :Integer;               (* Dummivariable fuer VAL-Procedure*)
    WIINFO :array [1..5] of byte;

BEGIN

(* Ermittlung des Feldursprungs aus der Quadrantenkennziffer *)

  IF    LENGTH(QTHKENN)=7 THEN  VAL(QTHKENN[7],A,H)
  ELSE  A:=2;

(* Ermittlung der Indexziffern aus dem QTH-Kenner *)

  For I:=1 to 5 do
    BEGIN
      WIINFO[I]:=(ORD(qthkenn[I]) AND MASKE[I])-ASCKOR[I];
    END;

(* Berechnung der geografischen Koordinate aus den Indexziffern *)

  OESLAE:=ALTURO[A]+WIINFO[1]*2    +(WIINFO[4]-1)*0.2 +KLOST [WIINFO[5]]/30;
  NOEBRE:=ALTURN[A]+(WIINFO[2]+1)*1+WIINFO[3]*(-0.125)+KLNORD[WIINFO[5]]/48;

(* Korrektur des systematischen Fehlers bei den oestlichsten Mittelfeldern *)

  IF WIINFO[4] = 0 THEN
    BEGIN
      OESLAE:=OESLAE+2;
      NOEBRE:=NOEBRE+0.125;
    END;
END;

(************* Ende PROCEDURE ALT_IN_WINKEL ****************)


(***********************************************************)
(* PROCEDURE GRAD_UMW                                      *)
(* Diese Procedure wandelt eine als String uebergebene     *)
(* geografische Koordinate im Format +GGG:MM:SS/-GG:MM:SS  *)
(* mit Unterlaengen +GG:MM und -GG in die entsprechenden   *)
(* Gleitkommawinkel um.  (Oestl. Laenge/Noerd. Breite)     *)
(* Uebergeben wird der Koordinatenstr. und zurueck werden  *)
(* die Gleitkommawinkel und eine Statusvariable uebergeben *)
(* Ist diese False so ist ein Formatfehler entdeckt worden *)
(* und die uebergebenen Winkelparameter undefiniert.       *)
(* QTHKENN     Koordinatenstring                           *)
(* OESLAE      Oestliche Laenge als REAL-Zahl              *)
(* NOEBRE      Noerdliche Breite als REAL-Zahl             *)
(* STATUS      TRUE Umwandlung erfolgreich vorgenommen     *)
(*             FALSE Formatfehler entdeckt oder Bereichs-  *)
(*                   fehler der Koordinatenwinkel          *)
(* MENGE       Definition des Stringmengentyps             *)
(* REFERENZ    Gueltige Elementemenge von QTHKENN          *)
(* RASTER      Feld der gueltigen Formatraster von QTHKENN *)
(* I           Index fuer Feldzugriffe                     *)
(* P           Position des Trennzeichens '/' in QTHKENN   *)
(*             und Kontrollvariable fuer VAL-Funktion      *)
(* OES,NOE     String der oestlichen Laenge,noerdl. Breite *)
(*             zur Umwandlung in den Gleitkommawinkel      *)
(* VERGLEICH   Strukturabbild von QTHKENN zur Format-      *)
(*             pruefung des Koordinatenstrings             *)
(* LAENGE      Laenge von QTHKENN fuer Abfrageschleifen    *)
(***********************************************************)

PROCEDURE GRAD_UMW (QTHKENN          :STRING;
                   VAR OESLAE,NOEBRE :REAL;
                   VAR STATUS        :BOOLEAN);

(***********************************************************)
(* FUNCTION GMS_UMW                                        *)
(* Die Funktion dient zur Umwandlung des Laengen und       *)
(* Breitengradstring in den entsprechenden Gleitkommawinkel*)
(* GMS      Stringteil mit Winkelinformation +GG:MM:SS     *)
(* UMWAND   Gleitkommawinkel                               *)
(* REST     Teilstring fuer Entnahme der GG,MM,SS-Info     *)
(* POSI     Position des Trennzeichens ':' in REST         *)
(* VORZEI   Vorzeichenfaktor des Winkels +1 oder -1        *)
(* I        Potenz des Minuten und Sekundenfaktors zur     *)
(*          BASIS 60 fuer Gleitkommawinkelberechnung       *)
(* D        Fehlerposition fuer VAL-Procedure              *)
(* Teil     Enthaelt Ziffernfaktor fuer Grad,Min.,Sekunden *)
(* Summe    Teil- und Endsumme des Gleitkommawinkels       *)
(***********************************************************)

FUNCTION GMS_UMW (GMS :String):REAL;

VAR REST   : STRING;
    POSI   : BYTE;
    VORZEI : ShortInt;
    I      : BYTE;
    D      : INTEGER;
    Teil   : REAL;
    SUMME  : REAL;

BEGIN
  I:=0;
  SUMME:=0;
  REST:=GMS;
  IF GMS[1]='-' THEN VORZEI:=-1     (*Vorzeichen ent- *)
                ELSE VORZEI:=1;     (*nehmen          *)

  REPEAT

    (* Winkelinformation in Grad,Min. oder Sekunden entnehmen*)

    VAL(REST,TEIL,D);
    IF D<>0 THEN VAL((COPY(REST,1,D-1)),TEIL,D);

    (* Winkelinformation gemaess Wertigkeitsfaktor aufsummieren *)
    (* Wertigkeitsfaktor Grad=1 ,Min.=1/60hoch1 ,Sek.=1/60hoch2 *)

    IF I=0 THEN SUMME:=TEIL
           ELSE SUMME:=SUMME+VORZEI*TEIL/(EXP(LN(60)*I));
    I:=I+1;

    (* Pruefen ob noch eine Information in REST ist   *)
    (* wenn ja dann REST um bearbeiteten TEIL kuerzen *)

    POSI:=POS(':',REST);
    REST:=Copy(REST,POSI+1,(LENGTH(REST)-POSI));

  UNTIL POSI=0; (* Wenn keine Info in REST mehr dann Ende *)

  GMS_UMW := SUMME
END;

(**********************************************************)
(* Hier beginnt GRAD_UMW()                                *)
(**********************************************************)

TYPE  MENGE = SET OF CHAR;

CONST REFERENZ :MENGE = ['0'..'9','+','-','/',':','.']; (* Definitionsmenge *)

      RASTER   :array[1..10] of string

                = ('VZ:Z:Z/VZ:Z:Z' , 'VZ:Z:Z/VZ:Z' , 'VZ:Z:Z/VZ' ,
                     'VZ:Z/VZ:Z:Z' ,   'VZ:Z/VZ:Z' ,   'VZ:Z/VZ' ,
                       'VZ/VZ:Z:Z' ,     'VZ/VZ:Z' ,     'VZ/VZ' ,
                       'VZ.Z/VZ.Z');

VAR   I         :Byte;
      P         :Integer;
      OES,NOE,
      VERGLEICH :STRING;
      LAENGE    :BYTE;

BEGIN

(* 1. Stringformat und Zeichengueltigkeit ueberpruefen     *)
(* 2. Wenn gueltig in Gleitkommawinkel umwandeln und       *)
(*    danach Gueltigkeitspruefung der Winkel vornehmen     *)
(* 3. Wenn auch das in Ordnung Winkel und STATUS=TRUE      *)

  LAENGE:=LENGTH(QTHKENN);
  IF LAENGE<=20 THEN
    BEGIN

      (* Ueberpruefung von Format und Inhalt der Stringinformation *)

      VERGLEICH:='';
      For I:=1 to LAENGE do
        BEGIN
          IF NOT(QTHKENN[I] IN REFERENZ)     THEN VERGLEICH:=VERGLEICH+'?'

          ELSE

            BEGIN
              IF QTHKENN[I] IN ['+','-']     THEN VERGLEICH:=VERGLEICH+'V';
              IF QTHKENN[I] ='/'             THEN VERGLEICH:=VERGLEICH+'/';
              IF QTHKENN[I] =':'             THEN VERGLEICH:=VERGLEICH+':';
              IF QTHKENN[I] ='.'             THEN VERGLEICH:=VERGLEICH+'.';
              IF QTHKENN[I] IN ['0'..'9']    THEN
                BEGIN
                  P:=LENGTH(VERGLEICH);
                  IF VERGLEICH[P]<>'Z'      THEN VERGLEICH:=VERGLEICH+'Z';
                END;
            END;

          END;

        (* Vorzeichenkennungen fuer Schreibfaule nachtragen *)

        IF VERGLEICH[1]='Z' THEN Insert('V',VERGLEICH,1);
        P:=Pos('/',VERGLEICH)+1;
        IF VERGLEICH[P]='Z' THEN Insert('V',VERGLEICH,P);

        (* Abfrage ob Vergleichsraster einem der gueltigen *)
        (* Raster entspricht                               *)

            STATUS:=False;
            FOR I:=1 to 10 do
              STATUS:=STATUS OR (VERGLEICH = RASTER[I]);

    END

  ELSE STATUS := FALSE;

  (* 3. Zeichenkette in Koordinaten umwandeln wenn in Ordnung *)

  IF STATUS THEN
  BEGIN
    P:=POS('/',QTHKENN);
    OES:=Copy(QTHKENN,1,P-1);
    NOE:=Copy(QTHKENN,P+1,(LAENGE-P));
    IF POS('.',OES) > 0 THEN VAL(OES,OESLAE,P)
                        ELSE OESLAE := GMS_UMW(OES);
    IF POS('.',NOE) > 0 THEN VAL(NOE,NOEBRE,P)
                        ELSE NOEBRE := GMS_UMW(NOE);
    IF ABS(NOEBRE) > 90  THEN STATUS  := False;
    IF ABS(OESLAE) > 180 THEN STATUS := False;
  END;

END;


(**********************************************************)
(* Procedure QTH_ENTFG_RICHTG                             *)
(* Diese Procedure berechnet bei Uebergabe von zwei QTH-  *)
(* Kennern Entfernung und Richtung zwischen den QTHs.     *)
(* Gueltige QTH-Kenner bzw. Koordinaten sind:             *)
(*  1. Der neue QTH-Kenner  z.B. JO40HC                   *)
(*  2. Der alte QTH-Kenner mit Regionskennziffer 1-4      *)
(*     z.B. EK74H/3                                       *)
(*  3. Eine geografische Koordinate (Laenge/Breite)       *)
(*     im Format +GGG:MM:SS/-GG:MM:SS  GG=Grad,MM=Minuten *)
(*     und SS=Sekunden                                    *)
(*     Minuten und Sekunden koennen weggelassen werden    *)
(* Die Procedure ordnet automatisch die eingegebenen QTH- *)
(* kenner richtig zu und veranlasst bei korrektem Format  *)
(* die Berechnung von Entfernung und Richtung             *)
(* QTH1,QTH2    QTH-Kenner QTH1=Bezug fuer Richtung       *)
(* ENTFG        Entfernung zwischen den QTHs              *)
(* RICHTG       Richtung von QTH1 nach QTH2               *)
(* STATUS       BOOLEAN FALSE=QTH-Kennerformatfehler bei  *)
(*              Auswertung entdeckt                       *)
(* QTH[2]       Stringfelder fuer QTH1,QTH2               *)
(* WINKEL[K]    Realfelder fuer OESLAE,NOEBRE1 und ..2    *)
(* I            Feldindex fuer QTH[I]                     *)
(* K            Feldindex fuer WINKEL[K]                  *)
(* LAENGE       Laenge des aktuellen QTH-Kennerstrings    *)
(**********************************************************)


PROCEDURE QTH_ENTFG_RICHTG (QTH1            : STRING;
                            QTH2            : STRING;
                            VAR
                              ENTFG,
                              RICHTG        : REAL;
                            VAR
                              STATUS        : BOOLEAN);

VAR QTH        : array[1..2] of STRING;
    Winkel     : array[1..4] OF REAL;
    I          : byte;
    K          : ShortInt;
    LAENGE     : Byte;

BEGIN
  QTH[1]:=QTH1;
  QTH[2]:=QTH2;
  K:=-1;
  STATUS:=TRUE;

  FOR i:=1 TO 2 DO
    IF STATUS=TRUE THEN
      BEGIN
        LAENGE:=Length(QTH[I]);
        K:=K+2;

        (* QTH-Kenner ist geografische Koordinate? *)

        IF QTH[I][1] IN ['+','-','0'..'9'] THEN
          BEGIN
            GRAD_UMW (QTH[I],WINKEL[K],WINKEL[K+1],STATUS);
          END

        (* Alter QTH-Kenner mit Feldkennung? *)

        ELSE IF LAENGE IN [5,7] THEN
          BEGIN
            IF ALT_PRUEFEN(QTH[I])=TRUE THEN
              BEGIN
                ALT_IN_WINKEL(QTH[I],WINKEL[K],WINKEL[K+1]);
              END
            ELSE STATUS:=False;
          END

        (* Neuer QTH-Kenner *)

        ELSE IF LAENGE=6 THEN
          BEGIN
            IF NEU_PRUEFEN(QTH[I])=TRUE THEN
              BEGIN
                NEU_IN_WINKEL(QTH[I],WINKEL[K],WINKEL[K+1]);
              END
            ELSE STATUS:=False;
          END

        (* Format nicht zuzuordnen *)

        ELSE STATUS:=False;

      END;

    (* Berechnung wenn kein Formatfehler *)

    IF STATUS=TRUE THEN
      BEGIN
        ENTFERNUNG_RICHTUNG(WINKEL[1],WINKEL[2],WINKEL[3],WINKEL[4],
                            ENTFG,RICHTG);
      END;

END;

(************ Ende PROCEDURE QTH_ENTFG_RICHTG *************)


(**********************************************************)
(* Procedure QTH_Pruefen                                  *)
(* Diese Procedure berechnet bei Uebergabe eines QTH-     *)
(* Kennern die geografische Koordinate des QTH-Kenners    *)
(* als Gleitkommawinkel                                   *)
(* Gueltige QTH-Kenner bzw. Koordinaten sind:             *)
(*  1. Der neue QTH-Kenner  z.B. JO40HC                   *)
(*  2. Der alte QTH-Kenner mit Regionskennziffer 1-4      *)
(*     z.B. EK74H/3                                       *)
(*  3. Eine geografische Koordinate (Laenge/Breite)       *)
(*     im Format +GGG:MM:SS/-GG:MM:SS  GG=Grad,MM=Minuten *)
(*     und SS=Sekunden                                    *)
(*     Minuten und Sekunden koennen weggelassen werden    *)
(* Die Procedure ordnet automatisch die eingegebenen QTH- *)
(* kenner richtig und ueberprueft veranlasst deren Prue-  *)
(* fung und Umrechnung                                    *)
(* QTH          QTH-Kenner                                *)
(* STATUS       BOOLEAN FALSE=QTH-Kennerformatfehler bei  *)
(*              Auswertung entdeckt                       *)
(* LAENGE       Laenge des aktuellen QTH-Kennerstrings    *)
(* OESLAE       Oestliche Laenge als Gleitkommazahl       *)
(* NOEBRE       Noerdliche Breite als Gleitkommazahl      *)
(**********************************************************)


PROCEDURE QTH_Pruefen(QTH             : STRING;
                            VAR
                             OESLAE,
                             NOEBRE         : REAL;
                            VAR
                              STATUS        : BOOLEAN);

VAR I          : byte;
    K          : ShortInt;
    LAENGE     : Byte;

BEGIN
  STATUS:=TRUE;
  Laenge:=Length(QTH);

  (* QTH-Kenner ist geografische Koordinate? *)

  IF QTH[1] IN ['+','-','0'..'9'] THEN GRAD_UMW (QTH,OESLAE,NOEBRE,STATUS)

  (* Alter QTH-Kenner mit Feldkennung? *)

  ELSE IF LAENGE IN [5,7] THEN
    BEGIN
      IF ALT_PRUEFEN(QTH)=TRUE THEN ALT_IN_WINKEL(QTH,OESLAE,NOEBRE)
                               ELSE STATUS:=False;
    END

  (* Neuer QTH-Kenner *)

  ELSE IF LAENGE=6 THEN
    BEGIN
      IF NEU_PRUEFEN(QTH)=TRUE THEN NEU_IN_WINKEL(QTH,OESLAE,NOEBRE)
                               ELSE STATUS:=False;
    END

  (* Format nicht einzuordnen *)

  ELSE STATUS:=False;

END;

(*************** Ende PROCEDURE QTH_Pruefen ***************)


(**********************************************************)
(* FUNCTION WINKEL_IN_NEU                                 *)
(* Diese FUNCTION ermittelt zu einer eingegebenen geo-    *)
(* grafischen Koordinate den zugehoerigen neuen QTH-Kenner*)
(* und gibt diesen als String zurueck                     *)
(* OESLAE       oestliche Laenge                          *)
(* NOEBRE       noerdliche Breite                         *)
(* URS[I,K]     Ursprungsoffset fuer Gross/Mittelfelder   *)
(* BWF[I,K]     Bewertungsfaktoren fuer Gross/Mittelfelder*)
(* ASCKOR[I,K]  ASCIIOFFSET zur QTH-Kennerstringberechnung*)
(* BWFK[I]      Bewertungsfaktoren fuer Kleinfelder       *)
(* ZUORD[I,K]   Zuordnungsindex zwischen 2D-Feld und Zei- *)
(*              chenposition im QTH-Kenner                *)
(* I,K          Indezes fuer Feldoperationen              *)
(*              I=1 Oestliche Laenge                      *)
(*              I=2 Noerdliche Breite                     *)
(*              K=1 Grossfeldbearbeitung                  *)
(*              K=2 Mittelfeldbearbeitung                 *)
(*              K=3 Kleinfeldbearbeitung                  *)
(**********************************************************)

FUNCTION WINKEL_IN_NEU(OESLAE,NOEBRE :REAL):STRING;

CONST  BWF      :array[1..2,1..2] of BYTE = ((20,2) ,(10,1));
       ASCKOR   :array[1..2,1..3] of BYTE = ((65,48,65),(65,48,65));
       BWFK     :array[1..2]      of BYTE = (12,24);
       ZUORD    :array[1..2,1..3] of BYTE = ((1,3,5),(2,4,6));


VAR    WIINFO   :               BYTE;
       REST     :array[1..2] of REAL;
       X        :               BYTE;
       I        :               BYTE;
       K        :               BYTE;
       QTH      :               STRING;

BEGIN
  REST[1] :=OESLAE+180;
  REST[2] :=NOEBRE+90;
  QTH:='';
  FOR I:=1 to 2 DO
    FOR K:=1 to 3 DO
      BEGIN
        IF K<>3 THEN
          BEGIN
            REST[I]:=REST[I]/BWF[I,K];
            WIINFO:=TRUNC(REST[I]);
            REST[I]:=(REST[I]-WIINFO)*BWF[I,K];
          END
        ELSE WIINFO:=TRUNC(REST[I]*BWFK[I]);
          Insert((CHR(WIINFO+ASCKOR[I,K])),QTH,ZUORD[I,K]);
      END;
  WINKEL_IN_NEU:=QTH;
END;


(**********************************************************)
(* FUNCTION WINKEL_IN_ALT                                 *)
(* Diese FUNCTION ermittelt zu einer eingegebenen geo-    *)
(* grafischen Koordinate den zugehoerigen alten QTH-Kenner*)
(*              und gibt diesen als String zurueck        *)
(* OESLAE       Oestliche Laenge                          *)
(* NOEBRE       Noerdliche Breite                         *)
(* ASCKOR[I,K]  ASCIIOFFSET zur QTH-Kennerstringberechnung*)
(* KLNORD[I]    Bewertungsfaktor fuer Kleinfeldbreite     *)
(* KLOST[I]     Bewertungsfaktor fuer Kleinfeldlaenge     *)
(* ZUORD[I,K]   Zuordnungsindex zwischen 2D-Feld und Zei- *)
(*              chenposition im QTH-Kenner                *)
(* F1-F3[I,K]   Bewertungsfaktoren in normierter Funktion *)
(* V1-V2[I,K]   Vorzeichenfaktoren in normierter Funktion *)
(* O1-O2[I,K]   Rechensummanden in normierter Funktion    *)
(*              Normierte Funktion ist die Berechnungs-   *)
(*              gleichung fuer die gemeinsamme Berechnung *)
(*              der QTH-Kenner-Indexanteile in einer 2D-  *)
(*              Feldanordnung fuer Gross- und Mittelfeld  *)
(*              des alten QTH-Kenner analog der Berechnung*)
(*              beim neuen QTH-Kenner                     *)
(* I,K          Indezes fuer Feldoperationen              *)
(*              I=1 Oestliche Laenge                      *)
(*              I=2 Noerdliche Breite                     *)
(*              K=1 Grossfeldbearbeitung                  *)
(*              K=2 Mittelfeldbearbeitung                 *)
(*              K=3 Kleinfeldbearbeitung                  *)
(**********************************************************)


FUNCTION WINKEL_IN_ALT(OESLAE,NOEBRE :REAL):STRING;

CONST  ALTURO   :array[1..4]       of ShortInt = (-52,  0,-52,  0);
       ALTURN   :array[1..4]       of ShortInt = ( 40, 40, 14, 14);
       KLNORD   :array[1..10]      of ShortInt = (1,1,3,5,5,5,3,1,7,3);
       KLOST    :array[1..10]      of ShortInt = (3,5,5,5,3,1,1,1,7,3);
       ASCKOR   :array[1..2,1..2]  of BYTE     = ((65,48),(65,48));
       F1       :array[1..2,1..2]  of REAL     = ((0.5,5),(1, 8));
       F2       :array[1..2,1..2]  of BYTE     = ((2,30 ),(1,48));
       F3       :array[1..2,1..2]  of BYTE     = ((1, 5 ),(1, 8));
       V1       :array[1..2,1..2]  of ShortInt = ((1, 1 ),(-1,1));
       V2       :array[1..2,1..2]  of ShortInt = ((-1,-1),(1,-1));
       O1       :array[1..2,1..2]  of ShortInt = (( 0,-1),(1, 0));
       O2       :array[1..2,1..2]  of ShortInt = (( 0, 1),(0, 0));
       ZUORD    :array[1..2,1..2]  of byte     = (( 1, 4),(2, 3));

VAR    WIINFO   :array[1..2,1..2]  of BYTE;
       REST     :array[1..2,1..3]  of REAL;
       ALTFELD  :                     BYTE;
       I        :                     BYTE;
       K        :                     BYTE;
       QTH      :                     STRING;
       HILF     :                     CHAR;
       STATUS   :                     BOOLEAN;

BEGIN

  (* Gueltigkeitsbereich ueberpruefen *)

  STATUS:=TRUE;
  IF (OESLAE <-52) OR (OESLAE >=52) THEN STATUS:=FALSE;
  IF (NOEBRE < 14) OR (NOEBRE > 66) THEN STATUS:=FALSE;

  IF STATUS=TRUE THEN

     BEGIN

       (* Alt-QTH-Kennerfeld zuweisen *)

       IF (OESLAE>=-52) AND (OESLAE< 0) AND (NOEBRE> 40) THEN ALTFELD:=1;
       IF (OESLAE>=  0) AND (OESLAE<52) AND (NOEBRE> 40) THEN ALTFELD:=2;
       IF (OESLAE>=-52) AND (OESLAE< 0) AND (NOEBRE<=40) THEN ALTFELD:=3;
       IF (OESLAE>=  0) AND (OESLAE<52) AND (NOEBRE<=40) THEN ALTFELD:=4;

       (* QTH-Kenner-STRING zusammenrechnen und setzen *)

       QTH:='     / ';
       (* Gross- und Mittelfeldanteile berechnen *)
       REST[1,1]:=OESLAE-ALTURO[ALTFELD];
       REST[2,1]:=NOEBRE-ALTURN[ALTFELD];

       FOR I:=1 TO 2 DO
         FOR K:=1 TO 2 DO
           BEGIN
             REST[I,K]:=REST[I,K]*F1[I,K];
             WIINFO[I,K]:=TRUNC(REST[I,K])+O2[I,K];
             REST[I,K+1]:=(V1[I,K]*REST[I,K]+V2[I,K]*(WIINFO[I,K]+O1[I,K]))
                          *F2[I,K]/F3[I,K];
           END;

       (* Korrektur bei oestlichstem Mittelfeld ausfuehren *)
       IF WIINFO[1,2]=10 THEN BEGIN
                                WIINFO[1,2]:=0;
                                WIINFO[2,2]:=WIINFO[2,2]+1;
                              END;

       (* Kleinfeld zuweisen *)
       FOR I:=1 to 10 DO
         IF (ABS(REST[2,3]-KLNORD[I])<=1)
           AND
           (ABS(REST[1,3]-KLOST[I])<=1) THEN
             BEGIN
               QTH[5]:=CHR(I+64);
             END;

       (* QTH-Kennerstring [1..4,7] zusammenbauen *)

       QTH[7]:=CHR(ALTFELD+48);
       FOR I:=1 TO 2 DO
         FOR K:=1 TO 2 DO
           BEGIN
             QTH[ZUORD[I,K]]:=CHR(ASCKOR[I,K]+WIINFO[I,K]);
           END;
         WINKEL_IN_ALT:=QTH;

     END

  ELSE WINKEL_IN_ALT:='-------';
END;


(**********************************************************)
(* FUNCTION WINKEL_IN_GMS                                 *)
(* Diese FUNCTION berechnet aus den Gleitkommawinkelkoor- *)
(* dinaten einen STRING im Format GRAD:MINUTEN:SEKUNDEN   *)
(* und gibt als Ergebnis den Formatstring GG:MM:SS zurueck*)
(* OESLAE     Oestliche Laenge                            *)
(* NOEBRE     Noerdliche Breite                           *)
(* RUND[I]    Rundungsparameter Sekunde wird aufgerundet  *)
(* K,I        Indexzaehler fuer Arrayoperationen          *)
(* REST[K]    Feld der Restwerte der Winkel               *)
(* HILF[K,I]  Feld der Koordinatenparameter               *)
(*            I=1 Grad  I=2 Minuten  I=3 Sekunden         *)
(*            K=1 Oestliche Laenge  K=2 Noerdliche Breite *)
(* TEIL       Hilfsstring zur Stringermittlung            *)
(* QTH        Ermittelter String                          *)
(* VZ[K]      Vorzeichen des Winkels als Summationsfaktor *)
(*            und fuer Abfragen (+1 oder -1)              *)
(**********************************************************)

Function WINKEL_IN_GMS(OESLAE,NOEBRE:REAL):STRING;

CONST   RUND :array[1..3] of REAL = (0,0,0.5);

VAR     K    :                    BYTE;
        I    :                    BYTE;
        REST :array[1..2]      of REAL;
        HILF :array[1..2,1..3] of INTEGER;
        TEIL :                    STRING[3];
        QTH  :                    STRING;
        VZ   :array[1..2]      of ShortInt;

BEGIN
  QTH:='';
  REST[1]:=OESLAE;
  REST[2]:=NOEBRE;

  (* Grad,Minuten und Sekunden ermitteln *)
  FOR K:=1 TO 2 DO
    BEGIN
      IF REST[K]<0 THEN VZ[K]:=-1
                   ELSE VZ[K]:=1;
      FOR I:=1 TO 3 DO
        BEGIN
          HILF[K,I]:=TRUNC(REST[K]+RUND[I]*VZ[K]);
          REST[K]:=FRAC(REST[K])*60;
        END;
    END;

  (* Koordinate bei Sekundenrundungsfehler "GG:MM:60" korrigieren *)
  FOR K:=1 TO 2 DO
    BEGIN
      FOR I:=3 DOWNTO 2 DO
        BEGIN
          IF HILF[K,I]=(VZ[K]*60) THEN
            BEGIN
              HILF[K,I]:=0;
              HILF[K,I-1]:=HILF[K,I-1]+VZ[K];
            END;
        END;
    END;

  (* Koordinatenstring zusammensetzen *)
  FOR K:=1 TO 2 DO
    BEGIN
      FOR I:=1 TO 3 DO
        BEGIN
          IF (VZ[K]<0) AND (I=1) THEN QTH:=QTH+'-';
          STR(ABS(HILF[K,I]),TEIL);
          QTH:=QTH+TEIL;
          IF I<3 THEN QTH:=QTH+':';
        END;
      IF K=1 THEN QTH:=QTH+'/';
    END;
  WINKEL_IN_GMS:=QTH;
END;


Procedure Compute_QTH (* Var Zeile : Str80 *);
Const   DXC = 'DXC.DAT';

Var     f    : Text;
        Flag : Boolean;
        i,l,
        AnzP : Byte;
        Diff : ShortInt;
        Entf,
        Azim : Real;

        Dstr : String[3];
        Sstr : String[6];
        Tstr : String[8];
        Fstr : String[13];
        QTH  : String[20];
        Nstr : String[40];
        Lstr,
        Rstr,
        Hstr : String;
Begin
  Hstr := ParmStr(3,B1,Zeile);
  if Hstr[length(Hstr)] = DP then
  begin
    Flag := false;
    Assign(f,SysPfad + DXC);
    if ResetTxt(f) = 0 then
    begin
      Readln(f,Hstr);
      QTH := ParmStr(4,B1,Hstr);
      Fstr := ParmStr(5,B1,Zeile);
      l := 0;
      While not Eof(f) do
      begin
        Readln(f,Hstr);
        Lstr := ParmStr(1,DP,Hstr);
        Sstr := ParmStr(1,Km,Lstr);
        ParmAnz := AnzP;
        i := 0;
        Repeat
          inc(i);
          Sstr := ParmStr(i,Km,Lstr);
          if (pos(Sstr,Fstr) = 1) and (ord(Sstr[0]) > l) then
          begin
            Flag := true;
            l := ord(Sstr[0]);
            Rstr := Hstr;
          end;
        Until i >= AnzP;
      end;
      FiResult := CloseTxt(f);

      if Flag then
      begin
        Lstr := ParmStr(1,DP,Rstr);
        Zeile := EFillStr(27,B1,ParmStr(2,DP,Rstr));
        Zeile := Zeile + 'Zone' + DP + SFillStr(3,B1,ParmStr(3,DP,Rstr)) + B2 + 'Dist' + DP;
        Lstr := ParmStr(4,DP,Rstr);
        Dstr := ParmStr(3,';',Lstr);
        i := pos(Pkt,Dstr);
        if i > 0 then Dstr := copy(Dstr,1,i-1);
        Diff := ShortInt(str_int(Dstr));
        Tstr := Uhrzeit;
        Tstr := UtcZeit;
        i := str_int(copy(Tstr,1,2));
        i := i + 24 + Diff;
        While i > 23 do i := i - 24;
        Tstr := SFillStr(2,'0',int_str(i)) + DP + copy(Tstr,4,2);
        QTH_ENTFG_RICHTG(QTH,ParmStr(2,';',Lstr) + '/' +
                             ParmStr(1,';',Lstr),Entf,Azim,Flag);
        if Flag then
        begin
          Zeile := Zeile + SFillStr(6,B1,int_str(Round(Entf))) + B1 + 'km' + B3 + 'Beam' + DP +
                           SFillStr(4,B1,int_str(Round(Azim))) + 'ø' +
                           B3 + '(' + Tstr + ')';
        end;
      end else Zeile := '';
    end else WishDXC := false;
  end else Zeile := '';
End;
