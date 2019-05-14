{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  UNIT: X P D E F S . P A S                                              ≥
 ≥                                                                         ≥
 ≥ Globale Variablen-, Typ- und Konstantendeklarationen.                   ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}
{XPIO Check_mld, XPAUS function comp, xplib1 _F6}
{Comp_Key-vari gegen neue COMPC-Varianten tauschen!!}
{User_Typ2 = Userrecord - STOP schon vorgesehen :-)}

UNIT XPDEFS;
{$F+}
{-$DEFINE Sound}
Interface

Uses Dos,
     Crt;
                                     {1.80B1 - 1 fÅr BETA 1}
Const    Version          = 'XPacket 1.81b8';
         LastEdit         = '29.12.2001';
         NodeK            = 'N';

{         SoundKarte=true;}
{$IFDEF Sound}
SB8 = 8; SB16 = 16;
  {Constants used for programming of the DMA-controller}
  DmaChannel : Array [0..7, 1..3] of Byte  =
     ( ($87, $0, $1), ($83, $2, $3), ($81, $4, $5), ($82, $6, $7),
       ($8F, $C0, $C2), ($8B, $C4, $C6), ($89, $C8, $CA), ($8A, $CC, $CE));
  DmaPort : Array [0..7, 1..3] of Byte  =
     ( ($A, $B, $C), ($A, $B, $C), ($A, $B, $C), ($A, $B, $C),
       ($D4, $D6, $D8), ($D4, $D6, $D8), ($D4, $D6, $D8), ($D4, $D6, $D8));

  {Chunk-identification values}
  rId = $46464952;  {RIFF}
  wId = $45564157;  {WAVE}
  fId = $20746D66;  {fmt }
  dId = $61746164;  {data}


  FileNotFound = $01;
  InvalidWAVE  = $02;
  NoCard       = $03;
  NoStereoCard = $04;
  No16BitCard  = $05;
  NoMemory     = $06;
{$ENDIF}

         {X-Protokoll-Sequenzen}
         XPROT            =#0#255;
         DATA             =#255;
         COMD             =#0;

         TRASK            = 127;
         TROK             = 128;
         REP              = 129;

         SRX              = 138;
         CRX              = 139;

         XEOF             = 140;
         XbinMaxFrame     = 255;
         {************************}

         maxpmak    = 65; {stopkomp}


         Scr              = 1;
         Vor              = 2;
         NU               = 0;
         CM               = 1;
         T                = 1;
{        MindestHeap      = 95000; }
         MindestHeap      = 105000;  {//db1ras}
         NeubildRam       = 4000;
         maxVorZeilen     = 200;
         maxNotChBuf      = 65500;
         maxNotLines      = 10000;
         maxMbxLines      = 200;

         maxMsgChr        = 50000;
         maxMsgRet        = 1000;

         maxInfoOut       = 50;

         maxHistory       = 10;

         maxTable         = 100;
         maxDir           = 1000;
         maxDirRem        = 500;

         maxLnk           = 100;

         maxKanal         = 60;
         maxTNC           = 8;
         maxComBuf        = 300;
         maxArrayTNC      = maxTNC + 1;
         maxMhRec         = 200;
         maxAnwesend      = 70;
         maxUTag          = 100;
         maxPrompt        = 42;
         maxVz            = maxVorZeilen - (maxVorZeilen div 5) + 1;

         maxSCon          = 22;
         maxUser          = 4;

         maxFileParm      = 5;

         MaxAutoSys       = 6;

         maxMorAnz        = 46;

         maxESC           = 80;

         maxCmds          = 36;

         maxREM           = 83;

         maxAttr          = 63;

         maxQRG           = 50;

         MaxMailPollCmd   = 5;

         maxAutoJmpPtr    = 10;

         maxCompPac       = 253;

         maxHelpZln       = 200;

         maxHlpAnw        = 20;

         maxOHelp         = 95;  {direkteinstiegs-rubriken onlinehilfe}

         maxBlBox         = 8;

         maxParm          = 11;

         maxMld           = 43;

         maxHlpNr         = 1000;

         minFreeVdisk     = 500000;

{$IFNDEF no_Bake}               {//db1ras}
         MinBake          = 1;
         DefBake          = 20;
{$ENDIF}

         SZ1              = 23;
         SZ2              = 24;
         SZL              = 14;

         TL               = 77;

         ColMonBeg        = 31;

         HlpRemBeg        = 31;

         Wait_TimeOut     = 3;
         TNC_TimeOut      = 120; { ca. 6-7 Sek }

         Lpt_TimeOut      = 364;

         SegHGC           = $b000; {B000}
         SegVGA           = $b800; {B800}

         TEI              = $2B;

         FF               = 255;
         N999             = 9999;
         FA00             = 64000;
         FFFF             = 65535;
         EINT             = 1000;
         T500             = 1500;
         ZWEI             = 2000;

         ESC              = #27;
         M1               = #13;
         M2               = #13 + #13;
         M3               = #13 + #13 + #13;
         B1               = ' ';
         B2               = B1 + B1;
         B3               = B1 + B1 + B1;
         BS               = '\';
         DP               = ':';
         LZ               = '#';
         LRK              = '(';
         RRK              = ')';
         LSK              = '<';
         RSK              = '>';
         Pipe             = '|';
         Pkt              = '.';
         GPkt             = '˘';
         Km               = ',';
         DpS              = '//';
         Star             = '*** ';
         Pfeil            = '> ';
         Plus             = '+++ ';

         X_ch             = 'X';
         S_ch             = '*';
         A_ch             = '˛';
         DatenKenner     = '-';
         vM               = 2;
         hM               = 41;

         CursorStr        = #24 + #25 + #26 + #27;

         Up               = 'Up';
         Dn               = 'Dn';

         PcxStr           = '<<TFPCR/X>>';
         BdStr            = 'hex)  Baud=';
         SynchErrStr      = 'Synch. faild COM-';
         OverRunStr       = '<Overrun>';

         CTRL             = 'CTRL';

         BBUS             = '(BBUS)';

         PWD              = DP + 'PWD';

         NoCall           = 'XP0CL';

         BoxRec           = 91;

         HlpRec           = 80;

         maxNoneName      = 14;

         Files            = 'Files';
         DIRs             = 'DIRs';
         OneByte          = 'Byte';

         PseudoQRG        = '###.###';
         UpDir            = ' (UPDIR)';
         SubDir           = '(SUBDIR)';
         Txt              = 'TEXT';

         ON               = 'ON';
         OFF              = 'OFF';
         OK               = 'OK';
         EIN              = 'EIN';
         AUS              = 'AUS';
         SYN              = 'SYNCH';
         RX               = 'RX';
         TX               = 'TX';
         EchoCh           = 'Ø';
         LSym             = 'L>';

         BSXP            = 'X-Packet';

         GL               = '=';
         TncI             = 'TNC';
         TCtx             = DP + 'CTX' + GL;
         TInf             = DP + 'INF' + GL;
         TAkt             = DP + 'AKT' + GL;
         TQtx             = DP + 'QTX' + GL;
         TFix             = DP + 'FIX:';
         TGrt             = DP + 'GRT';

         Rrtn             = 'RTN';
         Rrch             = 'RCH';
         Rrgl             = 'RGL';
         Rpar             = DP + 'PAR';
         Rcon             = 'CON';

         Rsetl            = DP + 'SETL';
         Ridle            = DP + 'IDLE';
         Rmfreq           = DP + 'MFREQ';
         Rega             = DP + 'EGA';
         Rplen            = DP + 'PLEN';
         Rsynch           = DP + 'SYNCH';
         Rlstd            = DP + 'LSTD';
         Rlmin            = DP + 'LMIN';
         Rcnr             = DP + 'CNR';
         Rvsp             = DP + 'VSP';
         Rinfo            = DP + 'INFO';

         MrkCALL          = DP + 'CALL=';
         MrkDATE          = DP + 'DATE=';
         MrkBEG           = DP + 'BEG=';
         MrkTEXT          = DP + 'TEXT=';
         MrkART           = DP + 'ART=';

         RFR              = DP + 'RFR';
         RNOT             = DP + 'RNOT';
         CNOT             = DP + 'CNOT';
         GNOT             = DP + 'GNOT';
         CCAN             = DP + 'CCAN';

         INI              = DP + 'INI';
         DEI              = DP + 'DEI';

         OHelpStr         = '*OHELP';

         ReadStr          = 'R';
         EraseStr         = 'E';
         TrStr            = 'TR';
         KbStr            = 'K';
         BinStr           = 'B';
         DirStr           = 'D';
         PlusStr          = '7';
         BsStr            = 'BS';
         KillStr          = 'K';
         UnprStr          = 'U';
         RBinStr          = 'RB';
         CrcStr           = 'CRC';
         SetStr           = 'SETL';
         RepStr           = 'REP';
         RunStr           = 'RUN';
         ElStr            = 'EL';

         ReadCh           = '˛';
         EraseCh          = 'Ï';
         SetCh            = '@';
         RepCh            = '%';
         KbCh             = '$';

         EmsStr           = 'EMS:' + B1;
         XmsStr           = 'XMS:' + B1;
         RamStr           = 'RMD:' + B1;

         Ext              = '.XP';
         MsgExt           = '.MSG';
         SpkExt           = '.SPK';
         KeyExt           = '.KEY';
         DocExt           = '.DOC';

         DosBild          = 'DOSBILD.$$$';
         TestName         = 'TESTDIR.$$$';
         NotName          = '###$$###';

         DExt             : Array [1..3] of String[4] = ('.COM','.EXE','.BAT');

         InfoZe           : String[2] = '˛˘';
         CvCh             : String[2] = '* ';

         SaveName         : String[12] = 'SAVE.';
         TxtName          : String[12] = Txt + Pkt ;

         LngExt           : String[3]  = 'XP';
         TxtExt           : String[3]  = 'TXT';
         CfgDatei         : String[12] = 'CONFIG';
         CooDatei         : String[12] = 'COOKIE'  + Ext;
        { TncIniDatei      : String[12] = 'TNCINI';}
         TmpDatei         : String[12] = '$$TMP$$.$$$';
         ScrollDatei      : String[12] = 'SCROLL'  + Ext;
         BuffDatei        : String[12] = 'BUFFERS' + Ext;
         TxtDatei         : String[12] =  Txt      + Ext;

         {//db1ras}
         MerkDatei        : String[12] = 'MEMO';
         MerkV1           : Byte       = 1;
         MerkV2           : Byte       = 81;
{$IFDEF ReadOldMemo}   {//db1ras}
         OldMerkV1        : Byte       = 1;
         OldMerkV2        : Byte       = 74;
{$ENDIF}

         NamesDatei       : String[12] = 'NAMES'   + Ext;
         UserDatei        : String[12] = 'USER'    + Ext;
         UserIDX          : String[12] = 'USER'    +'.XPI';
         UserBackup       : String[12] = 'USER'    + '.XPB';
         PwDatei          : String[12] = 'PASSWORD'+ Ext;
         LinkDatei        : String[12] = 'LINKS'   + Ext;
         EmbDatei         : String[12] = 'LOGO'    + Ext;
         RemDatei         : String[12] = 'REMOTES' + Ext;
         CallDatei        : String[12] = 'CALLS'   + Ext;
         EscDatei         : String[12] = 'CMD'     + Ext;
         TncDatei         : String[12] = 'TNC'     + Ext;
         ConDatei         : String[12] = 'CONNECT' + Ext;
{        BootDatei        : String[12] = 'FIREUP'  + Ext;   }
{        DebDatei         : String[12] = 'DEBUG'   + Ext;}
         SwapDatei        : String[12] = 'SWAP'    + Ext;
        { QrtDatei         : String[12] = 'QRT'     + Ext; }
         QrgDatei         : String[12] = 'QRG'     + Ext;
         THlpDatei        : String[12] = 'HELP'    + Ext;
         MailsDatei       : String[12] = 'MAILFRMS'+ Ext;

         BCastHAM         : string[12] = 'BROADHAM'+ ext;
         BCastCB          : string[12] = 'BROADCB' + ext;
         BCastBAK         : String[12] = 'BROADCST'+'XPK';

         AttrDatei        : String[12] = 'COLOR';
         MsgsDatei        : String[12] = 'MSGS'+EXT;
         HelpDatei        : String[12] = 'ONLHELP'+EXT;
         LogDatei         : String[12] = 'LOG.';

         BufDatei         : String[12] = 'CHANBUF.';
         MakDatei         : String[12] = 'MAKRO';
         AutoDatei        : String[12] = 'AUTO.';
         VorWriteDatei    : String[12] = 'VORWRITE.';
         DBoxDatei        : String[12] = 'CHKLST.';
         Tmp1Datei        : String[12] = 'TEMP1.TMP';
         Tmp2Datei        : String[12] = 'TEMP2.TMP';
         XBINProtokoll    : String[12] = 'XBIN.';

         AutoExecFile     : String[12] = 'AUTOEXEC'+ KeyExt;

         INT_IO_Mask      : Byte = $02;

         TncBusyStr       = 'TNC BUSY - LINE IGNORED';
         TncInvStr        = 'INVALID';
         TncConStr        = Star + 'CONNECTED TO';

         PfStr            = '  ==>  ';
         fm               = 'fm ';
         zu               = ' to ';
         IFrame           = ' ctl I';
         UFrame           = ' ctl UI';

         MailFrame1        = ' to ';
         MailFrame2        = ' ctl UI'; {' to MAIL ctl UI';}
         MailFrame         = MailFrame1 + 'MAIL' + MailFrame2;

         E7m              = #27 + '[7m';
         E0m              = #27 + '[0m';

         COM_C            = ' /C ';
         Joker            = '*.*';
         Bytes            = 'Bytes';

         ConStr           = Star + 'Connected to ';
         ReconStr         = Star + 'Reconnected to ';
         FailStr          = Star + 'Failure with ';
         BusyStr          = Star + 'Busy from ';


         Default_Base     : Array [1..4] of Word = ($3F8,$2F8,$3E8,$2E8);
         Default_IRQ      : Array [1..4] of Byte = (4,3,4,3);

         MatchTFPC        : String[4] = 'N5NX';
         MatchDRSI1       : String[3] = (#83+#30+#187);
         MatchDRSI2       : String[6] = (#142+#219+#132+#228+#116+#32);


         Prompts          : Array [1..maxPrompt] of Byte =
                           (2,3,5,6,7,8,18,19,20,21,22,23,24,25,
                            27,28,29,30,31,32,33,34,35,36,38,39,40,
                            42,43,44,45,46,47,48,51,52,56,57,58,59,
                            60,255);

         NoneNames    : Array[1..maxNoneName] of String[6] =
                            ('CLOCK','CLOCK$','AUX', 'COM1',
                             'COM2', 'COM3',  'COM4','CON',
                             'LPT1', 'LPT2',  'LPT3','LPT4',
                             'NUL',  'PRN');

         TNC_Art      : Array[0..4] of String[4] =
                            ('----','TNC2','TNC3','TFPC','FALC');

         LSM          : Array[1..9] of String[15] =
                            ('BUSY fm',
                             'CONNECTED to',
                             'LINK RESET fm',
                             'LINK RESET to',
                             'DISCONNECTED fm',
                             'LINK FAILURE',
                             'CONNECT REQUEST',
                             'FRAME REJECT fm',
                             'FRAME REJECT to');

codierung    : array[1..253] of byte =
(248, 193, 211, 140, 159, 162, 99, 108, 144, 242, 192, 167, 224, 29, 130,
170, 6, 197, 225, 238, 190, 155, 45, 131, 14, 193, 207, 225, 125, 124,
61, 158, 176, 159, 214, 168, 2, 196, 175, 77, 136, 109, 206, 33, 15,
116, 55, 122, 132, 140, 242, 60, 35, 166, 221, 242, 76, 121, 218, 175,
206, 134, 200, 251, 38, 99, 110, 238, 184, 14, 245, 54, 116, 152, 252,
126, 15, 145, 25, 206, 197, 190, 95, 132, 164, 51, 123, 18, 103, 220,
30, 197, 152, 0, 252, 50, 151, 53, 181, 218, 129, 249, 28, 118, 63,
231, 234, 190, 51, 241, 251, 173, 60, 125, 38, 172, 20, 26, 166, 244,
60, 28, 215, 79, 252, 124, 48, 200, 46, 172, 19, 56, 184, 69, 3,
113, 54, 196, 252, 180, 241, 198, 59, 175, 61, 91, 137, 235, 219, 104,
13, 203, 10, 84, 19, 68, 72, 75, 57, 229, 239, 217, 41, 36, 96,
209, 151, 156, 12, 136, 90, 6, 231, 245, 173, 0, 5, 97, 21, 202,
21, 99, 87, 214, 116, 157, 148, 116, 225, 105, 119, 64, 204, 64, 227,
22, 31, 191, 202, 132, 212, 129, 235, 41, 211, 27, 183, 92, 176, 13,
147, 42, 114, 128, 56, 107, 132, 1, 234, 132, 96, 139, 204, 31, 148,
209, 115, 210, 60, 95, 142, 198, 15, 243, 101, 107, 151, 126, 60, 27,
73, 74, 24, 56, 82, 107, 100, 240, 165, 121, 105, 234, 4);

         Meldung      : Array[1..maxMld] of String[18] =
                            ('FAILURE',
                             'BUSY FROM',
                             'INVALID',
                             'DX DE ',
                             '> RECONNECTED TO',
                             '*** RECONNECTED TO',
                             '*** CONNECTED TO', {7}
                             '#BIN#',
                             '#OK#',
                             '#ABORT#',
                             ' GO_7+. ',
                             ' STOP_7+. ',
                             '//',
                             ' GO_TEXT. ',
                             ' STOP_TEXT.',
                             #26,
                             '***END',
                             'CONNECTED TO', {18}
                             '#COMP:ON#',
                             '#COMP:OFF#',
                             '#COMP:1#',
                             '#COMP:0#',
                             '#COMP:RES#',
                             '/',
                             '#RTF#',
                             '#COMPC:ON#',
                             '#COMPC:1#',  {Nr.27}
                             '#XPPW:1#',
                             '#XPPW:0#',
                             'RETURNED TO NODE', {30}
                             '#LOC#',
                             '#NAM#',
                             '#QTH#', {33}
                             '#XBIN#',
                             '} WELCOME BACK', {35}
                             '#REQUESTNAME:',
                             '//COMP ON',
                             '//COMP OFF',
                             '//COMP 1',
                             '//COMP 0',  {40 -- 7+:11 u 12}
                             ' GO_INFO. ',
                             ' STOP_INFO.',
                             ': CAN'+#39+'T ROUTE'); {43}

         TextCmd       : Array[1..MaxCmds] of String[6] =
                           ('#TIME#', '#DATE#', '#NAME#', '#TCHN#', '#CALL#',
                            '#PRPT#', '#TTYP#', '#MCAL#', '#TNCI#', '#PVER#',
                            '#LEDI#', '#STIM#', '#SDAT#', '#SDAY#', '#UCAL#',
                            '#UASK#', '#BELL#', '#RETN#', '#TNCN#', '#NODE#',
                            '#NSID#', '#LDAY#', '#CTLZ#', '#SQSO#', '#LQSO#',
                            '#CONN#', '#MCSI#', '#TQRG#', '#SP',    '#TEXT#',
                            '#SLSH#', '#PORT#', '#AQTH#', '#ALOC#', '#ACTI#',
                            '#RING#');

         MailPollC     : array[1..MaxMailPollCmd] of string[3] =
                           ('#?','#E','#C','#P','#?P');

         NodeCmds      : Set of Byte =
                           [1,2,5,6,7,9,10,23,26,33,34,35,36,37,42,47,
                            48,50,51,52,59,60,62,99];

         LinkStatus    : Array[0..15] of String[12] =
                            {'DIS',          'SET',      'FMR',}
                           ('Disconnected','LinkSetup   ','FrameReject ',

                            {'DRQ',         'INF',       'REJ',}
                            'DiscRequest ','Info-Transf ','Reject      ',

                            {'WAK',        'DBS',         'RBS',}
                            'WaitAck     ','DeviceBusy  ','RemoteBusy  ',

                            {'BBS',        'WDB',          'WRB',}
                            'BothBusy    ','WAck/DevBus ','WAck/RemBus ',

                            {'WBB',        'RDB',       'RRB',}
                            'WAck/BothBs ','RemDevBusy  ','Rej/RemBus ',

                            {RBB}
                            'Rej/BothBus');

         SNam          : Array [0..maxSCon] of String[5] =
                            ('',
                        { 1} 'DBOX','BBOX','FBB', 'WBOX','EBOX',
                        { 6} 'BDXL','RMNC','TNN' ,'NETR','BN',
                        {11} 'DXC' ,'TCP' ,'FALC','TBOX','BPQ',
                        {16} 'FLEX', 'XP', 'XN',  'XPN', 'DIGIC',
                        {21} 'PROFI', 'CLUST');

         AutoSysKenner : Array [0..MaxAutoSys] of String[15] =
                         ('',
                          '[FBB-', 'PC/FlexNet V', '[XPACKET-',
                          '[THEBOX-', '[XNODE-', '[PROFIPACKET-');

         AutoSysName   : Array [0..MaxAutoSys] of String[11] =
  {SetzeFlags in XPLib}  ('',
  {aktualisieren!!}       ':FBB',':PCFlexNet',':XPacket',
                          ':DieBox', ':XNode',':ProfiP.');

         UNam          : Array [1..maxUser] of String[4] =
                          ('TOP','SP','XP', 'XN');

         ParmCmd       : Array [1..maxParm] of String[5] =
                          ('NOEMS','NOXMS','NORAM','NEOVR','HS',
                          {c        f       t             net}
                           'F',   'CRC',  'VER',  'HLP',  'PWD', 'NXOVR');

         FileParm      : Array [1..maxFileParm] of String[3] =
                          ('SAV','VOR','QSO','EDI','CRC');


         Menge         : Set of Char = [#32..#47,#92];

         UmMenge       : Set of Char = [#32,#33,#42..#47];

         UmlMenge      : Set of Byte = [0..3];
                                       {0..5,15..25,27..31,}
         BinMenge      : Set of Byte = [0,155..224,226..254];

         SysMenge      : Set of Byte = [1,2,3,4,5,14];

         YesMenge      : Set of Char = [#74,#89,#79];

         RemMenge      : Set of Byte = [1..98];

         ConvMenge     : Set of Byte = [1..99];

         Comp_Key_Tab  : Array [1..255] of Byte =
                         (52, 49, 31, 33, 59, 95, 57, 67, 76, 62,
                          75, 41, 34, 57, 23, 24, 63, 14, 55, 26,
                          42, 42, 57, 44, 36, 67, 76, 53, 72, 34,
                          56, 73, 93, 52, 24, 74, 78, 13, 35, 45,
                          38, 28, 47, 84, 12, 35, 37, 54, 74, 53,
                          51, 81, 31, 23, 71, 84, 23, 31, 32, 54,
                          44, 32, 28, 65, 16, 72, 69, 31, 12, 75,
                          22, 63, 83, 23, 64, 45, 99, 64, 84, 32,
                          55, 34, 41, 76, 41, 33, 55, 48, 49, 44,
                          17, 25, 59, 37, 37, 84, 74, 96, 13, 38,
                          71, 47, 45, 47, 66, 27, 30, 51, 28, 56,
                          98, 62, 97, 78, 33, 42, 96, 44, 54, 17,
                          42, 73, 29, 63, 41, 27, 43, 24, 43, 68,
                          92, 54, 41, 32, 69, 32, 46, 36, 66, 45,
                          39, 17, 28, 85, 88, 76, 93, 06, 72, 76,
                          21, 52, 91, 82, 82, 56, 94, 42, 86, 95,
                          55, 78, 58, 27, 94, 86, 52, 23, 23, 55,
                          39, 42, 79, 98, 45, 43, 13, 54, 33, 45,
                          22, 48, 53, 85, 64, 23, 12, 35, 67, 14,
                          26, 47, 62, 27, 11, 35, 71, 84, 74, 47,
                          71, 34, 39, 78, 37, 25, 44, 46, 83, 23,
                          48, 43, 58, 58, 53, 25, 43, 51, 53, 17,
                          84, 58, 86, 88, 53, 42, 67, 89, 95, 11,
                          75, 87, 92, 63, 95, 54, 33, 46, 77, 28,
                          18, 54, 43, 41, 47, 67, 43, 14, 55, 78,
                          91, 66, 57, 88, 79);



TYPE

 WType = record
  SampleRate : Word;
  Resolution : Byte;
  Stereo : Boolean;
  Length : LongInt;
end;

  HeaderChunk = record
    RIFF : LongInt;
    NextChunkSize : LongInt;
  end;

{$IFDEF Sound}
  WaveChunk = record
    WAVE : LongInt;
  end;

  fmtHeader = record
    fmt : LongInt;
    fmtDataLength : LongInt;
  end;

  fmtChunk = record
    WaveType : Word;
    Channels : Word;
    SampleRate : LongInt;
    BytesPerSecond : LongInt;
    BlockAlignment : Word;
    BitResolution : Word;
  end;

  DataChunk = record
    data : LongInt;
    SoundLength : LongInt;
  end;
{$ENDIF}

  ThirtyTwoK = array [0..32767] of Byte;


      Sondertaste = (_CtrlF1,  _CtrlF2, _CtrlF3, _CtrlF4, _CtrlF5,
                     _CtrlF6,  _CtrlF7, _CtrlF8, _CtrlF9, _CtrlF10,
                     _CtrlF11, _CtrlF12,

                     _Alt1,   _Alt2,   _Alt3,   _Alt4,   _Alt5,
                     _Alt6,   _Alt7,   _Alt8,   _Alt9,   _Alt0,
                     _AltF1,  _AltF2,  _AltF3,  _AltF4,  _AltF5,
                     _AltF6,  _AltF7,  _AltF8,  _AltF9,  _AltF10,
                     _AltF11, _AltF12,

                     _F1,     _F2,     _F3,     _F4,     _F5,
                     _F6,     _F7,     _F8,     _F9,     _F10,
                     _F11,    _F12,

                     _ShF1,   _ShF2,   _ShF3,   _ShF4,   _ShF5,
                     _ShF6,   _ShF7,   _ShF8,   _ShF9,   _ShF10,
                     _ShF11,  _ShF12,

                     _AltA,   _AltB,   _AltC,   _AltD,   _AltE,
                     _AltF,   _AltG,   _AltH,   _AltI,   _AltJ,
                     _AltK,   _AltL,   _AltM,   _AltN,   _AltO,
                     _AltP,   _AltQ,   _AltR,   _AltS,   _AltT,
                     _AltU,   _AltV,   _AltW,   _AltX,   _AltY,
                     _AltZ,

                     _Home,   _End,   _PgUp,   _PgDn,    _Ins,
                     _Del,    _Up,     _Dn,    _Right,  _Left,
                     _CtrlLeft, _CtrlRight, _CtrlEnd, _CtrlPgDn,
                     _CtrlHome, _CtrlPgUp, _CtrlPrtSc, _Andere,
                     _Ret, _Back, _Tab, _Esc, _Nix, _ShTab, _ShHome,
                     _ShEnd, _ShUp, _ShDn, _ShPgUp, _ShPgDn, _ShIns,
                     _ShDel, _ShLeft, _ShRight, _Plus, _Minus, _Star,
                     _Slash, _Fuenf,_Key2 );

       TypKey = Record
                  Ta : String[6];
                  Ze : Char;
                End;

    Table_typ = Record
                  Tab : Word;
                  Len : Byte;
                End;


   MorZeichen = Record
                  Ze : char;
                  Co : string[6];
                End;



Const           UDBExit : Set of SonderTaste = [_esc, _ret, _up, _dn, _PgDn, _PgUp,_Tab,_ShTab];


      Key : Array [_CtrlF1.._Key2] of TypKey =

      ((Ta : 'CF1';       Ze : #94),  (Ta : 'CF2';       Ze : #95),
       (Ta : 'CF3';       Ze : #96),  (Ta : 'CF4';       Ze : #97),
       (Ta : 'CF5';       Ze : #98),  (Ta : 'CF6';       Ze : #99),
       (Ta : 'CF7';       Ze : #100), (Ta : 'CF8';       Ze : #101),
       (Ta : 'CF9';       Ze : #102), (Ta : 'CF10';      Ze : #103),
       (Ta : 'CF11';      Ze : #137), (Ta : 'CF12';      Ze : #138),

       (Ta : 'ALT1';      Ze : #120), (Ta : 'ALT2';      Ze : #121),
       (Ta : 'ALT3';      Ze : #122), (Ta : 'ALT4';      Ze : #123),
       (Ta : 'ALT5';      Ze : #124), (Ta : 'ALT6';      Ze : #125),
       (Ta : 'ALT7';      Ze : #126), (Ta : 'ALT8';      Ze : #127),
       (Ta : 'ALT9';      Ze : #128), (Ta : 'ALT0';      Ze : #129),

       (Ta : 'ALTF1';     Ze : #104), (Ta : 'ALTF2';     Ze : #105),
       (Ta : 'ALTF3';     Ze : #106), (Ta : 'ALTF4';     Ze : #107),
       (Ta : 'ALTF5';     Ze : #108), (Ta : 'ALTF6';     Ze : #109),
       (Ta : 'ALTF7';     Ze : #110), (Ta : 'ALTF8';     Ze : #111),
       (Ta : 'ALTF9';     Ze : #112), (Ta : 'ALTF10';    Ze : #113),
       (Ta : 'ALTF11';    Ze : #139), (Ta : 'ALTF12';    Ze : #140),

       (Ta : 'F1';        Ze : #59),  (Ta : 'F2';        Ze : #60),
       (Ta : 'F3';        Ze : #61),  (Ta : 'F4';        Ze : #62),
       (Ta : 'F5';        Ze : #63),  (Ta : 'F6';        Ze : #64),
       (Ta : 'F7';        Ze : #65),  (Ta : 'F8';        Ze : #66),
       (Ta : 'F9';        Ze : #67),  (Ta : 'F10';       Ze : #68),
       (Ta : 'F11';       Ze : #133), (Ta : 'F12';       Ze : #134),

       (Ta : 'SHF1';      Ze : #84),  (Ta : 'SHF2';      Ze : #85),
       (Ta : 'SHF3';      Ze : #86),  (Ta : 'SHF4';      Ze : #87),
       (Ta : 'SHF5';      Ze : #88),  (Ta : 'SHF6';      Ze : #89),
       (Ta : 'SHF7';      Ze : #90),  (Ta : 'SHF8';      Ze : #91),
       (Ta : 'SHF9';      Ze : #92),  (Ta : 'SHF10';     Ze : #93),
       (Ta : 'SHF11';     Ze : #135), (Ta : 'SHF12';     Ze : #136),

       (Ta : 'ALTA';      Ze : #30),  (Ta : 'ALTB';      Ze : #48),
       (Ta : 'ALTC';      Ze : #46),  (Ta : 'ALTD';      Ze : #32),
       (Ta : 'ALTE';      Ze : #18),  (Ta : 'ALTF';      Ze : #33),
       (Ta : 'ALTG';      Ze : #34),  (Ta : 'ALTH';      Ze : #35),
       (Ta : 'ALTI';      Ze : #23),  (Ta : 'ALTJ';      Ze : #36),
       (Ta : 'ALTK';      Ze : #37),  (Ta : 'ALTL';      Ze : #38),
       (Ta : 'ALTM';      Ze : #50),  (Ta : 'ALTN';      Ze : #49),
       (Ta : 'ALTO';      Ze : #24),  (Ta : 'ALTP';      Ze : #25),
       (Ta : 'ALTQ';      Ze : #16),  (Ta : 'ALTR';      Ze : #19),
       (Ta : 'ALTS';      Ze : #31),  (Ta : 'ALTT';      Ze : #20),
       (Ta : 'ALTU';      Ze : #22),  (Ta : 'ALTV';      Ze : #47),
       (Ta : 'ALTW';      Ze : #17),  (Ta : 'ALTX';      Ze : #45),
       (Ta : 'ALTY';      Ze : #21),  (Ta : 'ALTZ';      Ze : #44),

       (Ta : 'HOME';      Ze : #71),  (Ta : 'END';       Ze : #79),
       (Ta : 'PGUP';      Ze : #73),  (Ta : 'PGDN';      Ze : #81),
       (Ta : 'INS';       Ze : #82),  (Ta : 'DEL';       Ze : #83),
       (Ta : 'UP';        Ze : #72),  (Ta : 'DN';        Ze : #80),
       (Ta : 'RIGHT';     Ze : #77),  (Ta : 'LEFT';      Ze : #75),
       (Ta : 'CLEFT';     Ze : #115), (Ta : 'CRIGHT';    Ze : #116),
       (Ta : 'CEND';      Ze : #117), (Ta : 'CPGDN';     Ze : #118),
       (Ta : 'CHOME';     Ze : #119), (Ta : 'CPGUP';     Ze : #132),
       (Ta : 'CPRTSC';    Ze : #114), (Ta : 'ANDERE';    Ze : #0),
       (Ta : 'RET';       Ze : #13),  (Ta : 'BACK';      Ze : #8),
       (Ta : 'TAB';       Ze : #9),   (Ta : 'ESC';       Ze : #27),
       (Ta : 'NIX';       Ze : #0),   (Ta : 'SHTAB';     Ze : #15),
       (Ta : 'SHHOME';    Ze : #71),  (Ta : 'SHEND';     Ze : #79),
       (Ta : 'SHUP';      Ze : #72),  (Ta : 'SHDN';      Ze : #80),
       (Ta : 'SHPGUP';    Ze : #73),  (Ta : 'SHPGDN';    Ze : #81),
       (Ta : 'SHINS';     Ze : #82),  (Ta : 'SHDEL';     Ze : #83),
       (Ta : 'SHLEFT';    Ze : #75),  (Ta : 'SHRIGH';    Ze : #77),
       (Ta : 'PLUS';      Ze : #43),  (Ta : 'MINUS';     Ze : #45),
       (Ta : 'STAR';      Ze : #42),  (Ta : 'SLASH';     Ze : #47),
       (Ta : 'FUENF';     Ze : #76),  (Ta : 'KEY2';      Ze : #0));



       {STOP-Codier-Tabellen:}
       CodeTab : Array [0..255] of Byte =
         ($02, $55, $08, $5B, $37, $89, $32, $B3,
          $F3, $46, $71, $1B, $B2, $90, $0A, $2A,
          $D0, $AF, $C3, $D3, $F5, $38, $6D, $D6,
          $EC, $CF, $73, $9A, $A9, $99, $8C, $B8,
          $1D, $67, $1F, $AB, $79, $7D, $58, $DE,
          $43, $2E, $6C, $B1, $29, $A5, $9F, $00,
          $C9, $44, $76, $62, $60, $94, $47, $2B,
          $CE, $4B, $68, $3D, $69, $0D, $7E, $FB,
          $11, $12, $41, $F9, $5A, $36, $3F, $C2,
          $E3, $E7, $BC, $88, $09, $21, $75, $7B,
          $98, $40, $A6, $E2, $E0, $8D, $82, $9E,
          $C5, $3C, $22, $9D, $07, $F2, $A1, $B7,
          $BB, $92, $F4, $FD, $49, $A3, $2C, $8F,
          $C6, $63, $20, $25, $56, $EB, $A7, $B5,
          $FF, $6B, $03, $F1, $8B, $A0, $95, $CA,
          $6E, $D5, $FC, $F0, $A4, $39, $4F, $E5,
          $9C, $14, $D8, $BA, $AC, $AE, $C1, $FA,
          $3E, $E9, $52, $26, $19, $15, $87, $E4,
          $84, $D2, $D9, $BD, $10, $5D, $18, $61,
          $81, $05, $8A, $34, $6A, $74, $1E, $0F,
          $13, $2D, $06, $BE, $27, $DF, $3A, $DB,
          $B9, $C8, $9B, $4C, $F8, $96, $35, $30,
          $EE, $17, $59, $42, $78, $DC, $E8, $F6,
          $72, $AA, $8E, $2F, $0E, $54, $53, $66,
          $97, $4A, $1A, $CB, $65, $A2, $91, $85,
          $48, $4E, $4D, $CD, $64, $ED, $D7, $C0,
          $83, $86, $5F, $7F, $E1, $B4, $7C, $DA,
          $D1, $EA, $77, $BF, $6F, $16, $23, $7A,
          $57, $45, $31, $FE, $EF, $1C, $B6, $AD,
          $24, $D4, $A8, $80, $C4, $01, $C7, $B0,
          $DD, $CC, $51, $33, $04, $F7, $5C, $0C,
          $E6, $28, $93, $70, $3B, $0B, $5E, $50);

     DeCodeTab : Array [0..255] of Byte =
         ($2F, $ED, $00, $72, $F4, $99, $A2, $5C,
          $02, $4C, $0E, $FD, $F7, $3D, $BC, $9F,
          $94, $40, $41, $A0, $81, $8D, $DD, $B1,
          $96, $8C, $C2, $0B, $E5, $20, $9E, $22,
          $6A, $4D, $5A, $DE, $E8, $6B, $8B, $A4,
          $F9, $2C, $0F, $37, $66, $A1, $29, $BB,
          $AF, $E2, $06, $F3, $9B, $AE, $45, $04,
          $15, $7D, $A6, $FC, $59, $3B, $88, $46,
          $51, $42, $B3, $28, $31, $E1, $09, $36,
          $C8, $64, $C1, $39, $AB, $CA, $C9, $7E,
          $FF, $F2, $8A, $BE, $BD, $01, $6C, $E0,
          $26, $B2, $44, $03, $F6, $95, $FE, $D2,
          $34, $97, $33, $69, $CC, $C4, $BF, $21,
          $3A, $3C, $9C, $71, $2A, $16, $78, $DC,
          $FB, $0A, $B8, $1A, $9D, $4E, $32, $DA,
          $B4, $24, $DF, $4F, $D6, $25, $3E, $D3,
          $EB, $98, $56, $D0, $90, $C7, $D1, $8E,
          $4B, $05, $9A, $74, $1E, $55, $BA, $67,
          $0D, $C6, $61, $FA, $35, $76, $AD, $C0,
          $50, $1D, $1B, $AA, $80, $5B, $57, $2E,
          $75, $5E, $C5, $65, $7C, $2D, $52, $6E,
          $EA, $1C, $B9, $23, $84, $E7, $85, $11,
          $EF, $2B, $0C, $07, $D5, $6F, $E6, $5F,
          $1F, $A8, $83, $60, $4A, $93, $A3, $DB,
          $CF, $86, $47, $12, $EC, $58, $68, $EE,
          $A9, $30, $77, $C3, $F1, $CB, $38, $19,
          $10, $D8, $91, $13, $E9, $79, $17, $CE,
          $82, $92, $D7, $A7, $B5, $F0, $27, $A5,
          $54, $D4, $53, $48, $8F, $7F, $F8, $49,
          $B6, $89, $D9, $6D, $18, $CD, $B0, $E4,
          $7B, $73, $5D, $08, $62, $14, $B7, $F5,
          $AC, $43, $87, $3F, $7A, $63, $E3, $70);

        {Ende STOP-Codier-Tabellen}


     HTable : Array [0..257] of Table_Typ =

    { STOP HTable : Array [0..257] of Table_Typ =}

  ((Tab : $AB2C; Len : 15), (Tab : $AA84; Len : 15), (Tab : $9FC4; Len : 15),
   (Tab : $AB3C; Len : 15), (Tab : $AB1C; Len : 15), (Tab : $AAFC; Len : 15),
   (Tab : $AAEC; Len : 15), (Tab : $AAD4; Len : 15), (Tab : $AAB4; Len : 15),
   (Tab : $F340; Len : 10), (Tab : $AAA4; Len : 15), (Tab : $7D64; Len : 15),
   (Tab : $AADC; Len : 15), (Tab : $F400; Len :  7), (Tab : $AA94; Len : 15),
   (Tab : $9FF4; Len : 15), (Tab : $9FD4; Len : 15), (Tab : $7D74; Len : 15),
   (Tab : $AB44; Len : 15), (Tab : $AB34; Len : 15), (Tab : $AB24; Len : 15),
   (Tab : $AB14; Len : 15), (Tab : $AB04; Len : 15), (Tab : $AAF4; Len : 15),
   (Tab : $AAE4; Len : 15), (Tab : $AB60; Len : 14), (Tab : $AB0C; Len : 15),
   (Tab : $AACC; Len : 15), (Tab : $AABC; Len : 15), (Tab : $AAAC; Len : 15),
   (Tab : $AA9C; Len : 15), (Tab : $AA8C; Len : 15), (Tab : $C000; Len :  3),
   (Tab : $3A80; Len :  9), (Tab : $ABC0; Len : 10), (Tab : $0060; Len : 11),
   (Tab : $7D40; Len : 12), (Tab : $AB5C; Len : 14), (Tab : $0000; Len : 12),
   (Tab : $AB58; Len : 14), (Tab : $7C00; Len :  9), (Tab : $3C80; Len :  9),
   (Tab : $7D00; Len : 11), (Tab : $0010; Len : 12), (Tab : $1200; Len :  7),
   (Tab : $7A00; Len :  7), (Tab : $B800; Len :  6), (Tab : $3200; Len :  7),
   (Tab : $2200; Len :  7), (Tab : $F600; Len :  8), (Tab : $3D00; Len :  8),
   (Tab : $9E00; Len :  9), (Tab : $BD80; Len :  9), (Tab : $7C80; Len :  9),
   (Tab : $0080; Len :  9), (Tab : $AA00; Len :  9), (Tab : $BD00; Len :  9),
   (Tab : $9F00; Len :  9), (Tab : $0300; Len :  8), (Tab : $AB78; Len : 13),
   (Tab : $AB68; Len : 13), (Tab : $3C00; Len :  9), (Tab : $3000; Len :  9),
   (Tab : $0020; Len : 11), (Tab : $7D50; Len : 12), (Tab : $3800; Len :  7),
   (Tab : $7800; Len :  7), (Tab : $9C00; Len :  7), (Tab : $FE00; Len :  7),
   (Tab : $2400; Len :  6), (Tab : $BC00; Len :  8), (Tab : $0200; Len :  8),
   (Tab : $0100; Len :  8), (Tab : $F100; Len :  8), (Tab : $0040; Len : 11),
   (Tab : $3100; Len :  8), (Tab : $F200; Len :  8), (Tab : $3400; Len :  7),
   (Tab : $1C00; Len :  7), (Tab : $1E00; Len :  7), (Tab : $BE00; Len :  7),
   (Tab : $ABA0; Len : 11), (Tab : $3E00; Len :  7), (Tab : $1400; Len :  6),
   (Tab : $3600; Len :  7), (Tab : $F380; Len :  9), (Tab : $F080; Len :  9),
   (Tab : $2000; Len :  8), (Tab : $FC00; Len :  8), (Tab : $9F80; Len : 10),
   (Tab : $9E80; Len :  9), (Tab : $AB90; Len : 12), (Tab : $3B80; Len :  9),
   (Tab : $AB80; Len : 12), (Tab : $AB54; Len : 14), (Tab : $3A50; Len : 13),
   (Tab : $AB50; Len : 14), (Tab : $A000; Len :  5), (Tab : $1800; Len :  6),
   (Tab : $9800; Len :  6), (Tab : $7000; Len :  5), (Tab : $4000; Len :  3),
   (Tab : $0400; Len :  6), (Tab : $AC00; Len :  6), (Tab : $F800; Len :  6),
   (Tab : $6000; Len :  4), (Tab : $3A00; Len : 10), (Tab : $FD00; Len :  8),
   (Tab : $2800; Len :  5), (Tab : $B000; Len :  6), (Tab : $8000; Len :  4),
   (Tab : $B400; Len :  6), (Tab : $1000; Len :  7), (Tab : $7D20; Len : 12),
   (Tab : $E000; Len :  5), (Tab : $9000; Len :  5), (Tab : $E800; Len :  5),
   (Tab : $0800; Len :  5), (Tab : $F700; Len :  8), (Tab : $A800; Len :  7),
   (Tab : $7D80; Len :  9), (Tab : $F300; Len : 10), (Tab : $7E00; Len :  7),
   (Tab : $AB48; Len : 14), (Tab : $3A48; Len : 13), (Tab : $AB4C; Len : 14),
   (Tab : $3A60; Len : 12), (Tab : $9FFC; Len : 15), (Tab : $9FEC; Len : 15),
   (Tab : $2100; Len :  8), (Tab : $9FDC; Len : 15), (Tab : $9FCC; Len : 15),
   (Tab : $F000; Len :  9), (Tab : $7D7C; Len : 15), (Tab : $7D6C; Len : 15),
   (Tab : $3A40; Len : 14), (Tab : $AB40; Len : 15), (Tab : $AB38; Len : 15),
   (Tab : $AB30; Len : 15), (Tab : $AB28; Len : 15), (Tab : $AB20; Len : 15),
   (Tab : $AB18; Len : 15), (Tab : $AB70; Len : 13), (Tab : $AB10; Len : 15),
   (Tab : $AB08; Len : 15), (Tab : $AB00; Len : 15), (Tab : $AAF8; Len : 15),
   (Tab : $AAF0; Len : 15), (Tab : $3B00; Len :  9), (Tab : $AAE8; Len : 15),
   (Tab : $AAE0; Len : 15), (Tab : $AAD8; Len : 15), (Tab : $AAD0; Len : 15),
   (Tab : $AB64; Len : 14), (Tab : $7D30; Len : 12), (Tab : $AAC8; Len : 15),
   (Tab : $AAC0; Len : 15), (Tab : $AAB8; Len : 15), (Tab : $AAB0; Len : 15),
   (Tab : $AAA8; Len : 15), (Tab : $AAA0; Len : 15), (Tab : $AA98; Len : 15),
   (Tab : $AA90; Len : 15), (Tab : $AA88; Len : 15), (Tab : $AA80; Len : 15),
   (Tab : $9FF8; Len : 15), (Tab : $9FF0; Len : 15), (Tab : $9FE8; Len : 15),
   (Tab : $9FE0; Len : 15), (Tab : $9FD8; Len : 15), (Tab : $9FD0; Len : 15),
   (Tab : $9FC8; Len : 15), (Tab : $9FC0; Len : 15), (Tab : $7D78; Len : 15),
   (Tab : $7D70; Len : 15), (Tab : $3A58; Len : 13), (Tab : $7D68; Len : 15),
   (Tab : $7D60; Len : 15), (Tab : $AB46; Len : 15), (Tab : $AB42; Len : 15),
   (Tab : $AB3E; Len : 15), (Tab : $AB3A; Len : 15), (Tab : $AB36; Len : 15),
   (Tab : $AB32; Len : 15), (Tab : $AB2E; Len : 15), (Tab : $AB2A; Len : 15),
   (Tab : $AB26; Len : 15), (Tab : $AB22; Len : 15), (Tab : $AB1E; Len : 15),
   (Tab : $AB1A; Len : 15), (Tab : $AB16; Len : 15), (Tab : $AB12; Len : 15),
   (Tab : $AB0E; Len : 15), (Tab : $AB0A; Len : 15), (Tab : $AB06; Len : 15),
   (Tab : $AB02; Len : 15), (Tab : $AAFE; Len : 15), (Tab : $AAFA; Len : 15),
   (Tab : $AAF6; Len : 15), (Tab : $AAF2; Len : 15), (Tab : $AAEE; Len : 15),
   (Tab : $AAEA; Len : 15), (Tab : $AAE6; Len : 15), (Tab : $AAE2; Len : 15),
   (Tab : $AADE; Len : 15), (Tab : $AADA; Len : 15), (Tab : $AAD6; Len : 15),
   (Tab : $AAD2; Len : 15), (Tab : $AACE; Len : 15), (Tab : $AACA; Len : 15),
   (Tab : $AAC6; Len : 15), (Tab : $AAC2; Len : 15), (Tab : $AABE; Len : 15),
   (Tab : $AABA; Len : 15), (Tab : $AAB6; Len : 15), (Tab : $AAB2; Len : 15),
   (Tab : $AAAE; Len : 15), (Tab : $AAAA; Len : 15), (Tab : $AAA6; Len : 15),
   (Tab : $AAA2; Len : 15), (Tab : $AA9E; Len : 15), (Tab : $3A44; Len : 15),
   (Tab : $AA9A; Len : 15), (Tab : $AA96; Len : 15), (Tab : $AA92; Len : 15),
   (Tab : $3080; Len :  9), (Tab : $AA8E; Len : 15), (Tab : $AA8A; Len : 15),
   (Tab : $AA86; Len : 15), (Tab : $AA82; Len : 15), (Tab : $9FFE; Len : 15),
   (Tab : $9FFA; Len : 15), (Tab : $9FF6; Len : 15), (Tab : $9FF2; Len : 15),
   (Tab : $9FEE; Len : 15), (Tab : $9FEA; Len : 15), (Tab : $9FE6; Len : 15),
   (Tab : $9FE2; Len : 15), (Tab : $9FDE; Len : 15), (Tab : $9FDA; Len : 15),
   (Tab : $9FD6; Len : 15), (Tab : $9FD2; Len : 15), (Tab : $9FCE; Len : 15),
   (Tab : $9FCA; Len : 15), (Tab : $9FC6; Len : 15), (Tab : $9FC2; Len : 15),
   (Tab : $7D7E; Len : 15), (Tab : $7D7A; Len : 15), (Tab : $7D76; Len : 15),
   (Tab : $7D72; Len : 15), (Tab : $7D6E; Len : 15), (Tab : $7D6A; Len : 15),
   (Tab : $7D66; Len : 15), (Tab : $7D62; Len : 15), (Tab : $3A46; Len : 15),
   (Tab : $3A70; Len : 12), (Tab : $AAC4; Len : 15), (Tab : $9FE4; Len : 15));



       Mchs : Array[1..maxMorAnz] of MorZeichen =

      ((Ze:'A'; Co:'.-'    ), (Ze:'B'; Co:'-...'  ), (Ze:'C'; Co:'-.-.'  ),
       (Ze:'D'; Co:'-..'   ), (Ze:'E'; Co:Pkt      ), (Ze:'F'; Co:'..-.'  ),
       (Ze:'G'; Co:'--.'   ), (Ze:'H'; Co:'....'  ), (Ze:'I'; Co:'..'    ),
       (Ze:'J'; Co:'.---'  ), (Ze:'K'; Co:'-.-'   ), (Ze:'L'; Co:'.-..'  ),
       (Ze:'M'; Co:'--'    ), (Ze:'N'; Co:'-.'    ), (Ze:'O'; Co:'---'   ),
       (Ze:'P'; Co:'.--.'  ), (Ze:'Q'; Co:'--.-'  ), (Ze:'R'; Co:'.-.'   ),
       (Ze:'S'; Co:'...'   ), (Ze:'T'; Co:'-'     ), (Ze:'U'; Co:'..-'   ),
       (Ze:'V'; Co:'...-'  ), (Ze:'W'; Co:'.--'   ), (Ze:'X'; Co:'-..-'  ),
       (Ze:'Y'; Co:'-.--'  ), (Ze:'Z'; Co:'--..'  ),

       (Ze:'1'; Co:'.----' ), (Ze:'2'; Co:'..---' ), (Ze:'3'; Co:'...--' ),
       (Ze:'4'; Co:'....-' ), (Ze:'5'; Co:'.....' ), (Ze:'6'; Co:'-....' ),
       (Ze:'7'; Co:'--...' ), (Ze:'8'; Co:'---..' ), (Ze:'9'; Co:'----.' ),
       (Ze:'0'; Co:'-----' ),

       (Ze:Pkt ; Co:'.-.-.-'), (Ze:','; Co:'--..--'), (Ze:DP; Co:'---...'),
       (Ze:'-'; Co:'-....-'), (Ze:'/'; Co:'-..-.' ), (Ze:'('; Co:'-.--.' ),
       (Ze:')'; Co:'-.--.-'), (Ze:'?'; Co:'..--..'), (Ze:'='; Co:'-...-' ),
       (Ze:'˛'; Co:'...-.-' ));


Type
     Str2       = String[2];
     Str3       = String[3];
     Str4       = String[4];
     Str5       = String[5];
     Str6       = String[6];
     Str7       = String[7];
     Str8       = String[8];
     Str9       = String[9];
     Str10      = String[10];
     Str11      = String[11];
     Str12      = String[12];
     str15      = String[15];
     Str19      = String[19];
     Str20      = String[20];
     Str25      = String[25];
     str28      = string[28];
     Str32      = String[32];
     Str40      = String[40];
     Str60      = String[60];    { fÅr Filenamen }
     Str30      =string[30];
     Str70      =string[70];
     Str80      = String[80];
     Str88      = String[88];
     Str128     = String[128];
     strk       = string[41];
     Str255     = String[255];
     StrBox     = String[BoxRec];

     PSPtablePtr= Array [1..20] of Byte;

     BildPtr    = Array [1..80*60*2] of Char;      { max 80x60 Zeichen  }
                                                   { plus Videoattribute }

     NotChPtr   = Array[0..maxNotChBuf] of Byte;

     GetHeapPtr = Array[1..$FFFF] of Byte;

    VorWritePtr = Array[1..maxVorZeilen] of String[80];


     MsgFeldPtr = Array [1..maxMsgChr] of Char;
     MsgPosPtr  = Array [1..maxMsgRet] of Word;

     PWArrayPtr = Array [0..59] of String[27];       { nur fÅr DieBox }

     MbxZeile   = Array [1..BoxRec] of Char;

     MbxTypPtr  = Array [1..maxMbxLines] of MbxZeile;

     HistoryPtr = Array [1..maxHistory+1] of String[80];

     HlpNrPtr   = Array [1..maxHlpNr] of String[13];

     Freq_Type  = Record
                    QRG : String[8];
                    TNr : Byte;
                  End;

     Freq_Ptr   = Array[1..maxQRG] of Freq_Type;


     InfoOutPtr = Record
                    IZ : Array [1..maxInfoOut] of String[80];
                    Ka : Array [1..maxInfoOut] of Byte;
                  End;

      QRG_Type  = Record
                    Call : String[9];
                    QRG  : String[8];
                  End;

      BroadCast  = Record
                    SourceCall,
                    SourceAlias,        {source: woher kam der Broadcast}
                    NodeCall,
                    NodeAlias : Str9;   {node: Broadcast-eintrag}
                    Quality   : Byte;
                    Port      : byte;
                    DatTime   : longint;
                   end;

      Lnk_Type   = Record
                    Entry : String[80];
                    Ext   : Boolean;
                  End;

      Lnk_Ptr   = Array [1..maxLnk] of Lnk_Type;

      Hlp_Type  = Record
                    Entry : String[HlpRec];
                    ID    : String[6];
                    Attr  : Byte;
                    Sp7   : Char;
                  End;

      Hlp_Ptr   = Array [1..maxHelpZln] of Hlp_Type;

      REM_Type  = Record
                    BefNr  : Byte;
                    Befehl : String[8];
                    AnzCh  : Byte;
                    AnzPa  : Byte;
                    Level  : Byte;
                    LevelN : Byte;
                  End;


      Mon_Type  = Record
                    MonBeide,
                    MonActive,
                    MonDisAbr,
                    MonHCall,
                    MonEHCall,
                    MonStrict,
                    MonSignal,
                    MonIFr,
                    MonUFr       : Boolean;
                    MonAttr      : Byte;
                    MonLast      : String[25];
                    MonNow       : Array [1..2] of Boolean;
                    MonStr       : Array [1..2] of String[25];
                    MonFirst     : Array [1..2] of Boolean;
                    MonFrameNr   : Array [1..2] of Byte;
                    MonCtrl      : Array [1..2] of Array [0..7] of Word;
                  End;

     Conv_Typ   = Record
                    Active       : Boolean;
                    Ret          : Boolean;
                    NoCHead      : Boolean;
                    Count        : Byte;
                    Chan         : Byte;
                    LLen         : Byte;
                    LCall        : String[9];
                    AfuStatus    : Byte;
                    Fehler       : Str80;
                     {Afustatus:
                      0=noch nicht festgelegt
                      1=AFU
                      2=CB}
                  End;

     Dir_Typ    = Record
                    Name         : String[13];
                    Size         : String[8];
                    Attr         : String[4];
                    Date         : String[8];
                    Time         : String[5];
                    Mark         : Boolean;
                  End;

     UsersTag_   = array[1..MaxUTag] of Longint;
     UsersTag    = ^UsersTag_;

     RemAusn_   = Array[1..115] of Boolean;

     User_Typ2  = Record
                   Version1, Version2: Byte;
                   Call,
                   Alias         : String[10];
                   Name          : String[30];
                   QTH           : String[30];
                   Locator       : String[6];
                   Adress        : String[60];
                   Telefon       : String[20];
                   PacLen,
                   Umlaut        : Byte;
                   FBBStreng_,
                   Anwesenheit,
                   VIP,
                   Show,
                   RemSchreib    : Boolean;
                   RemAusnahmen  : RemAusn_;
                   MaxFrames     : Integer;
                   System,
                   MailLesen,
                   MailKillen,
                   ByeBye        : String[10];
                   Vorbereitung,
                   Nachbereitung : String[60];
                   Prompt,
                   PWPrompt,
                   SStopPrompt   : string[60];
                   SSIDs         : array[0..15] of Boolean;
                   Synonym       : string[10];
                   StopCode      : word;
                   Kompression,
                   dummybyte1,
                   dummybyte2,
                   dummybyte3    : Byte;
                   AutoBoxPassw,
                   dummybool1,
                   dummybool2,
                   dummybool3    : Boolean
                  end;

      User_Idx  = Record
                   Call,
                   Alias: String[10];
                   Pos  : Longint;
                  end;

     Dir_Feld   = Array [1..maxDir] of Dir_Typ;

     Anwesend_   = Record
                   Call: String[9];
                   Da  : boolean;
                   SSIDs : array[0..15] of byte;
                  end;


     MH_Typ     = Record
                    Rej   : Word;        { Anzahl REJ-Frames     }
                    UIs   : Word;        { Anzahl der UI-Frames  }
                    TNr   : Byte;        { Nummer des TNCs       }
                    Qrg   : String[8];   { Frequenz              }
                    Call  : String[9];   { Rufzeichen            }
                    Zeit  : String[14];  { zuletzt gehîrt um ... }
                    Link  : String[50];  { ausfÅhrl. Link        }
                  End;

     MH_Feld    = Array [1..maxMHRec] of MH_Typ;


     ComType    = Record
                    Active      : Boolean;
                    Base        : Word;
                    BaudRate    : LongInt;
                    IRQ_Nr      : Byte;
                    Old_Vector  : Pointer;
                    FifoOn      : Boolean;
                    FifoCfg     : Byte;

                    OrgLODIV    : Byte;  {Original Baudratenteiler LOW -Byte}
                    OrgHIDIV    : Byte;  {Original Baudratenteiler HIGH-Byte}
                    OrgLCR      : Byte;  {Original Line Control Register}
                    OrgMCR      : Byte;  {Original Modem Control Register}
                    OrgIER      : Byte;  {Original Interrupt Enable Register}
                  End;


     MemoTNC    = Record
                   BText        : String[80];{ Bakentext                 }
                   BPfad        : String[80];{ Pfad der Bake             }
                   BCall        : String[9];
                   BTimer       : Word;      { Minuten-Intervall         }
                   Bake         : Boolean;   { Bake ein/aus              }
                   CText        : Byte;      { C-Text Variante           }
                   Info         : Byte;      { Info Text Variante //i    }
                   Aktuell      : Byte;      { Aktuell Text Variante //a }
                   QText        : Byte;      { Quittext Variante //q     }
                   Fix          : Byte;      { Festtext Variante SH-F1.. }
                   QRG_Akt      : String[8]; { aktuelle Frequenz         }
                  end;

     MemoKanal   = Record
                    OwnCall      : Str9;        { Eigenes Call }
                    Paclen       : Word;        { Paclen fÅr diesen Kanal }
                    MaxFrame     : Byte;        { Maxframe fÅr diesen Kanal }
                    UmlautMerk   : Byte;
                    UnStat,
                    ObStat       : Byte;        { Y_Pos der Trennzeile }
                    FRxName      : Str60;       { File-Rx-Name }
                    SaveFName    : Str60;
                    SPlFName     : Str60;
                    Spl_gCount   : LongInt;
                    Spl_tCount  : LongInt;
                    Spl_gLaenge : LongInt;
                    Spl_tLaenge : LongInt;
                    Umlaut,
                    Echo      : Byte;
                    Auto,
                    RX_Beep,
                    TXBeepAck,
                    AutoBin,
                    SPlus,
                    TXComp,
                    RXComp,
                    CompC,
                    SPComp,
                    StopComp    : Boolean;
                    StopCode    : Word;
                    KompressUpd : boolean;
                    CompCUpdZahl : Byte;
                    Kompression : Array [1..255] of Byte;
                    NoCurJump,
                    Node      : Boolean;
                    Ignore    : Boolean;

                    {//db1ras}
                    CSelf        : Byte;
                    AutoZeile    : String[80];
                    Auto1Zeile   : String[80];
                    AutoTime     : String[5];
                    AutoZaehl    : Word;
                    AutoJump     : Word;
                    AutoZyConst  : Word;
                    AutoZyCount  : Word;
                    AutoWait     : Word;
                    AutoToConst  : Word;
                    AutoToCount  : Word;
                    AutoToAnz    : Word;
                    AutoToMax    : Word;
                    AutoToAnzJmp : Word;
                    AutoChMerk   : Byte;
                    AutoArt      : Byte;
                    AutoCheckLn  : Boolean;
                    AutoJmpPtr   : Byte;
                    AutoJmpRet   : Array [1..maxAutoJmpPtr] of Word;

                    bool1, bool2, bool3 : boolean;
                    byte1, byte2, byte3 : byte;
                    word1, word2, word3 : word;
                  end;

{$IFDEF ReadOldMemo}   {//db1ras}
     MemoKanal174= Record {alter Record der Version 1.74}
                    OwnCall      : Str9;        { Eigenes Call }
                    AutoZyConst  : Word;
                    Paclen       : Word;        { Paclen fÅr diesen Kanal }
                    MaxFrame     : Byte;        { Maxframe fÅr diesen Kanal }
                    UmlautMerk   : Byte;
                    UnStat,
                    ObStat       : Byte;        { Y_Pos der Trennzeile }
                    FRxName      : Str60;       { File-Rx-Name }
                    SaveFName    : Str60;
                    SPlFName     : Str60;
                    Spl_gCount   : LongInt;
                    Spl_tCount  : LongInt;
                    Spl_gLaenge : LongInt;
                    Spl_tLaenge : LongInt;
                    Umlaut,
                    Echo      : Byte;
                    Auto,
                    RX_Beep,
                    TXBeepAck,
                    AutoBin,
                    SPlus,
                    TXComp,
                    RXComp,
                    CompC,
                    SPComp,
                    StopComp    : Boolean;
                    StopCode    : Word;
                    KompressUpd : boolean;
                    CompCUpdZahl : Byte;
                    Kompression : Array [1..255] of Byte;
                    NoCurJump,
                    Node      : Boolean;
                    Ignore    : Boolean;
                    bool1, bool2, bool3 : boolean;
                    byte1, byte2, byte3 : byte;
                    word1, word2, word3 : word;
                  end;
{$ENDIF}

        MemoGlobal=Record
                    Gross     : Boolean;
                    TopBox,
                    morsen,
                    Klingel,
                    CtrlBeep,
                    Time_Stamp,
                    PacOut,
                    ZeigeRet,
                    ConMorsen,
                    ReconMorsen,
                    GlobalTrenn,
                    BinOut,
                    Ins,
                    NoBinMon,
                    RX_TX_Win,
                    VIP,
                    SoZeichen : boolean;
                    SETL      : Array[1..10] of Word;
                    SetNr     : Byte;
                    Idle_Pos  : Boolean;
                    Idle_anz,
                    Idle_Tout : Word;
                    TonHoehe  : Word;
                    _VGA      : Boolean;
                    MPause,
                    Resync_Z  : Word;
                    CNr       : Longint;
                    InfoStr   : Str80;
                    StatusModus : byte;
                    ZeilenwTX : Boolean;
                    Speak,
                    Bool2, Bool3 : boolean;
                    byte1, byte2, byte3 : byte;
                    SpeakSpeed,
                    word2, word3 : word;
                  end;

     MemoTyp    = Record
                    v1, v2 : byte;
                    TNC : array [1..MaxTNC] of MemoTNC;
                    Kanal : Array [0..maxKanal] of MemoKanal;
                    Global : MemoGlobal;
                  end;

{$IFDEF ReadOldMemo}   {//db1ras}
     OldMemoTyp = Record
                    v1, v2 : byte;
                    TNC : array [1..MaxTNC] of MemoTNC;
                    Kanal : Array [0..maxKanal] of MemoKanal174;
                    Global : MemoGlobal;
                  end;
{$ENDIF}

     TNC_Typ    = Record
                (*    TXBedarf     : Boolean;   {sendesperre hier schnellstmîglich lîsen}
                    TXGesperrt   : Boolean;   {Sender gesperrt} *)
                    Channels     : Byte;      { Anzahl der TerminalkanÑle }
                    TncChannels  : Byte;      { Anzahl der TNC-KanÑle     }
                    Kvon         : Byte;      { 1. log. Terminalkanal     }
                    Kbis         : Byte;      { letzter. log. Terminalk.  }
                    RS232        : Byte;      { Com-Nummer                }
                    MPX          : Byte;      { FÅr Multiplexkarten       }
                    HF_Port      : Byte;      { Bei DRSI der HF-Port      }
                    HF_PortStr   : String[10];{ FÅr DRSI das Portkommando }
                    Ident        : Str4;      { Identifier                }
                    MoniStatus   : Str80;     { Speicher fÅr den Moni-Status}
                    Hostcall     : Str9;      { Call auf Kanal 0          }
                    Bake         : Boolean;   { Bake ein/aus              }
                    CText        : Byte;      { C-Text Variante           }
                    Info         : Byte;      { Info Text Variante //i    }
                    Aktuell      : Byte;      { Aktuell Text Variante //a }
                    QText        : Byte;      { Quittext Variante //q     }
                    Fix          : Byte;      { Festtext Variante SH-F1.. }
                    BText        : String[80];{ Bakentext                 }
                    BPfad        : String[80];{ Pfad der Bake             }
                    BCall        : String[9];{ Send-Call der Bake        }
                    BTimer       : Word;      { Minuten-Intervall         }
                    DRSI         : Byte;      { TNC ein DRSI-TNC          }
                    ExtHost      : Boolean;   { Extended Hostmode ?       }
                    FALC         : Boolean;   { Falcon-TNC ?              }
                    TNC3         : Boolean;   { TNC3 ?                    }
                    PCXD         : Boolean;   { TFPCX in DRSI ?           }
                    TNC_im_Host  : Boolean;   { TNC im Hostmode ?         }
                    DEDHost      : Boolean;
                    QRG_Akt      : String[8]; { aktuelle Frequenz         }
                    TicStr       : String[TL];{ Tickerzeile               }
                    AFUPort,
                    Tic          : Boolean;   { Tickerzeile ein/aus       }
                    MBufHeap     : Word;      { max. ermittelt. Puffer    }
                    MailBakenTimer:Byte;
                  End;

                 Sich_Rec18   = Record
                        QSOAblauf,
                        Dateien,
                        User,
                        Shutdown : Boolean;
                      end;

        TNC_Konf   = Record {1.8}
                      Art         : Byte;   {tfpcx, tnc ....}
                      MaxKan      : Byte;
                      NodeKan     : Byte;
                      Identi      : Str2;
                      Port        : Byte;
                      Tickzeile   : Boolean;
                      Com,
                      IRQ         : Byte;
                      Adresse     : Str8;
                      Baud        : Longint;
                      AfuPort,
                      Fifo        : Boolean;
                      MultiplexNr : Byte;
                      PortNam     : str20;
                      IniA        : array[1..16] of str30;
                      IniB        : str70;
                      DIniA       : array[1..16] of str30;
                      DIniB       : str70;
                      TX_X0,                 {TNC-Command TX-Sperre AN}
                      TX_X1       : string[5];{TNC-Command TX-Sperre AUS}
                      TX_Bundle   : Byte; {BÅndel-Nummer um fÅr mehrere Antennen Sets zuzulassen}
                     end;



        QuietZeit   = Record
                       StdAnf, MinAnf,
                       StdEnd, MinEnd  : Byte;
                       Aktiv : boolean;
                      end;

        QuietZeiten = Array[1..3] of QuietZeit;

         Konfig_Rec = Record {1.8}
                       kenner: strk;
                       TNC  : array[1..MaxTnc] of TNC_KONF;
                       RemVerz,
                       SavVerz,
                       MailVerz : String;
                       Teil1 : byte;
                       RunVerz,
                       BinVerz,
                       SPlVerz,
                       MakVerz,
                       ViewVerz,
                       EditVerz,
                       SPKVerz,
                       TempVerz : str80;
                       Teil5 : byte;
                       CDRom    : Char;
                       ZeitBez : str8;
                       UTCDiff : integer;
                       teil2 : byte;
                       UTCBenutzen,
                       Echtzeit : Boolean;
                       PopupZeit : integer;
                       LockIRQ   : Boolean;
                       SichAbfr  : Boolean;
                       IDLE      : Boolean;
                       ScrSavZ   : Byte;
                       PromptS   : Str30;
                       NTimeOut,
                       TTimeOut,
                       MaxFrameStd,
                       PacLenStd,
                       MaxNodes,
                       Lifetime  : integer;
                       Teil4     : byte;
                       version   : integer;

                       QuietDH,
                       QuietZG   : Boolean;
                       QuietZt   : QuietZeiten;


                       MH        : Byte;
                       BackScRam : Byte;
                       VorschZRam: Byte;
                       BufferDat : Boolean;

                       LPTNr     : Byte;
                       LPTAdr    : Str8;

                       SoftHardC,
                       WinRout    : Boolean;
                       WinRoutTime: Byte;
                       RXBeepStart,
                       AchzigBrail,
                       Steuerz,
                       MarkTon,
                       AusgabeBios: Boolean;
                       Teil3      : Byte;
                       MailFErl   : Boolean;
                       MailFrame  : array[1..10] of str10;
                       OwnMailFr  : Boolean;
                       OwnMailPfad: String[50];
                       MailFrameZeit : Byte;

                       PersName,
                       PersQTH    : string[30];
                       PersLoc    : string[10];

                       CBFilter   : Boolean;
                       ReqNam     : Boolean;
                       NodeSound  : Boolean;
                       MaxLoginUser : Byte;

                       Sicherheit : Sich_Rec18;

                       WavOut, MidiOut, WavSprach, bool4, bool5, bool6 : boolean;
                       BackupTime, SBHiDMA, SBLoDMA, SBIRQ, byte5, byte6 : byte;
                       MidiADR, SBBaseADR, word3, word4, word5, word6 : word;

                      end;




       MemoCTyp = Record
                     cv1,
                     cv2          : Byte;        { Versions-Bytes }
                     Call         : Str9;        { Call der Gegenstation }
                     QSO_Date     : String[11];  { Datum QSO-Beginn }
                     QSO_Begin    : String[5];   { Zeit QSO-Beginn }
                     QSO_End      : String[5];   { Zeit QSO-Ende }
                     ConText      : String[80];  { Text fuers Log }
                     Eingangskanal,
                     Ausgangskanal: boolean;
                     Gegenkanal   : byte;
                     SystemErkannt,
                     OnAct        : String[20];
                     SysArt,
                     UserArt      : Byte;
                     HoldLauf     : Integer;
                     Hold         : Boolean;
                     HoldTime     : Byte;
                     HoldStr      : String[25];
                     RemAll,
                     SelfSysop    : Boolean;
                  end;


       XBIN_    = Record   {fÅr XBin RX/TX-Betrieb}
                   An      : Boolean;
                   RX,
                   TX      : boolean;
                   FrameNr : byte;
                   DatPos,    {aktuelle Dateiposition}
                   DatPosA : longint; {Dateiposition bei FrameNr 255}
                   Retries : byte;
                   OK      : Boolean;
                   PDat    : Boolean; {protokolldatei offen?}
                   RTXOk   : Boolean; {bei Fileende oder nach 256 frames nachfragen}
                   ProtPos : longint; {xbin.xxx-datpos fÅr neues frameset}
                   Nachford: string[5];  {Nachgeforderte Frames (fÅr TX)}
                   EOF     : Boolean; {Datei zuende, nach bestÑtigung ende}
                   VorPuffer:String;  {vorschreibschirm zwischenspeicher in S_pac
                                        um paclen auszunutzen}
                  end;

       XBINFile_ =Record   {XBin-Protokoll-Datei, um RAM zu sparen}
                   FrameNr : Byte;
                   DatPos  : Longint;
                   OK      : Boolean;
                   RXCRC   : str8;
                   CRC     :str8;
                   Retries : Byte;
                  end;

       KanalPtr = Record    { fuer jeden Kanal wird folg. Struktur angelegt: }
                     OwnCall      : Str9;        { Eigenes Call }
                     Call         : Str9;        { Call der Gegenstation }
                     Alias        : str9;
                     RemoteAus    : RemAusn_;
                     System       : str10;
                     User_autopw  : boolean;     {"user" schickt passwort-sequenz, diese wird mit pw bestÑtigt}
                     ReqName,                    {hat schon ein reqeustName stattgefunden?}
                     connected    : Boolean;     { true wenn connected }
                     QSO_Date     : String[11];  { Datum QSO-Beginn }
                     QSO_Begin    : String[5];   { Zeit QSO-Beginn }
                     QSO_End      : String[5];   { Zeit QSO-Ende }
        {??}         ConText      : String[80];  { Text fuers Log }
                     SendZeile    : String;
                     XBIN         : XBIN_;
                     XBinPFile    : file of XBinFile_;
                     TxByte       : Word;
                     FBBStreng,                  {FBB-Auswertung streng, oder locker [@]}
                     Loesch       : Boolean;
                     Rx_Beep,
                     SysTextEcho  : Boolean;
                     BellCount,
                     Echo         : Byte;
                     Cmd          : Boolean;     { Kommando-Eingabe }
                     First_Frame  : Boolean;     { Merker fuer erstes Frame }
                     X2           : Byte;        { Cursor-Position }
                     UnStat,
                     ObStat       : Byte;        { Y_Pos der Trennzeile }
                     Vofs,
                     VBeg,VEnd,
                     QBeg,QEnd    : Byte;
                     Response     : String;      { Antwort des TNC }
                     Response256  : Char;        { fuer 256er Frames }
                     AnzLines     : Integer;
                     AnzNotiz     : Word;
                     stV,
                     stC,
                     Y1V,
                     Y1C,
                     X1V,
                     X1C          : Byte;
                     RemoteSave   : Boolean;
                     NodeCon      : Boolean;
                     NodeCmd      : Boolean;
                     merkInfo     : String[80];
                     EinstiegsKanal : Boolean; { Wurde hier //c eingegeben ? }
                     AusstiegsKanal : Boolean; { GegenKanal zum Einstiegskanal }
                     GegenKanal   : Byte;      { der andere Kanal auf dem der //c ausgefÅhrt wird }
                     Kanal_benutz : Boolean;   { Ist hier grad ein Link Setup oder Connect aktiv ? }
                     RemConReady  : Boolean;   { //c erfolgreich ? }
                     Insert_ON    : Boolean;
                     NZeile       : String;
                     ACZeile      : String[80];
                     RxLRet       : Boolean;
                     TxLRet       : Boolean;
                     SvLRet       : Boolean;
                     L_Status     : Array [1..6] of Byte;
                     FlagTxBeep   : Boolean;
                     TxBeepAck    : Boolean;
                     TXFile       : File;        { Sende-File }
                     TX_Laenge    : LongInt;     { Laenge von Binaerfiles }
                     TX_Count     : LongInt;     { Zaehler f. Bin-Uebertr. }
                     TX_Baud      : LongInt;
                     TX_Bin       : Integer;     { Merker fuer Filesendeart }
                     TX_Time      : String[8];
                     TX_CRC       : Integer;
                     FileSend     : Boolean;     { Merker fuer FileSend }
                     FileSendRem  : Boolean;
                     XbinWait,
                     FileSendWait,
                     FileSendWaitS : Boolean;
                     FTxName      : Str60;       { Sendefile-Name }
                     RXFile       : File;        { ALT-E File }
                     Rx_Save      : Boolean;     { Merker fuer Save }
                     Rx_Time      : String[8];
                     RX_TextZn    : LongInt;
                     RX_Laenge    : LongInt;     { nur fÅr Auto-Binfiles }
                     RX_Count     : LongInt;
                     RX_Baud      : LongInt;
                     RX_Bin       : Byte;        { FÅr Filesteuerung }
                     RX_Date      : LongInt;
                     RX_CRC       : Integer;
                     RX_Soll_CRC  : Word;
                        {Anzeigezeit fÅr Info-Box; 0=immer}
                     LstRXInfo,
                     LstTXInfo    : string[80];
                     SvName       : String[60];
                     SFile        : File;        { Save-File }
                     Save         : Boolean;
                     FRxName      : Str60;       { File-Rx-Name }
                     AutoBin      : Boolean;
                     AutoBinOn    : Boolean;
                     SPlus        : Boolean;
                     SplFile      : File;
                     SplSave      : Boolean;
                     Spl_gCount   : LongInt;
                     Spl_tCount   : LongInt;
                     Spl_gLaenge  : LongInt;
                     Spl_tLaenge  : LongInt;
                     Spl_Time     : String[8];
                     Spl_Baud     : LongInt;
                     Spl_COR_ERR  : Boolean;
                     Spl_UmlMerk  : Byte;
                     RemPath      : String[64];
                     LogMerker    : String[20];
                     BeLogEintr   : Boolean;
                     Drucker      : Boolean;     { Merker fuer Ausdruck }
                     Umlaut       : Byte;        { Umlautwandlung }
                     UmlautMerk   : Byte;
                     NR_Stelle    : Integer;
                {??}     ConnectMerk  : String[40];
                {??}     ACMerk       : String[80];
                     Pause        : Integer;
                     Paclen       : Word;        { Paclen fÅr diesen Kanal }
                     MaxFrame     : Byte;        { Maxframe fÅr diesen Kanal }
                     TNCKanal     : Char;        { phys. Kanal des TNCs }
                     Kan_Char     : Char;
                     TNC_Code     : Byte;
                     TNC_Count    : Word;
                     TncNummer    : Byte;        { laufende Nummer des TNCs }
                     TncAkt       : Byte;
                     Auto         : Boolean;     { Fernsteuerung ein/aus }
                     Outside      : Boolean;     { Connect kam "von au·en" }
                     Auto_CON     : Boolean;
                     FoundCall    : Boolean;
                     Last_CR_Pos  : Byte;
        {??}         Ziel_Call    : String[20]; {remote-zielcall}
                     NochNichtGelesen : Boolean;
                     Ignore       : Boolean;
                     unknown      : Boolean;
                     notRC        : Boolean;
                     ParmWrong    : Boolean;
                     HoldLauf     : integer;
                     Hold         : Boolean;
                     HoldTime     : Byte;
                     HoldStr      : String[25];
                     RTF          : Boolean;
                     Test         : Boolean;
                     TestMerk     : Byte;
                     Priv_Errechnet : String[5];
                     Priv_Modus,
                     RemAll       : Boolean;
                     SysopStr     : String[10];
                     SysopArt     : String[6];
                     SysopParm    : Boolean;
                     StatZeile    : Array[1..4*40] of Char;
                     FlagZeile    : array[1..2*80] of char;
                     FlagZeile2   : array[1..2*80] of char;
                     Rekonnekt    : Boolean;
                     Now_Msg_holen : Boolean;
                     MeldeCompZ   : String[80];
                     MeldeZeile   : String[80];
                     MldOk        : Byte;
                     ExtMld       : String[80]; {bay-box}
                 {   FwdMsgsHolen, }{wieviele msgs beim fwd geholt werden}
                    {FwdMails     : Byte;}
                   { FwdFS,      }  {FS wurde gesendet, FF soll zurÅckgehalten werden}
                    {FwdNxt,      wird fÅr neuerîffnung gesetzt/nÑchste mail anfordern [FF]}
                   { FwdStarted, }  {wird nach FS-frame gesetzt}
                    MailPrompt    : Str60; {Wenn MailPoll #? dann mit MailPrompt_ fÅllen}
                    BoxAutoPW,    {bei "normalen" box-connects zusammen mit fwd}
                    Fwd,          {wird gesetzt, wenn forward angezettelt wird}
                    FwdGo,        {wird bei forward gesetzt, wenn end-station connectet}
                     ExtMldFlag   : Boolean;
                     EigMail      : Boolean;
                     MsgToMe      : Boolean;
                     AltEnd       : Word;
                     TNC_Puffer   : Boolean;
                     maxNotCh     : Word;
                     Pos_im_Scr   : LongInt;
                     VorZeilen    : Byte;
                     VorCmdZeilen : Byte;
                     Einer_st     : Boolean;
                     stTX         : Array[1..maxVorZeilen] of Boolean;
                     NotPos       : Word;
                     PagesNot     : Array[0..3] of Byte;
                     PagesAnz     : Byte;
                     BufFile      : File;
                     BufPos       : LongInt;
                     BufExists    : Boolean;
                     BufToLow     : Boolean;
                     Conv         : Conv_Typ;
                     RX_Datenpieps : Boolean;
                {!-} User_Name    : String[20]; { Namen der OMs }
                     User_QTH     : String[20];
                     User_Loc     : String[6];
                     User_Komp    : Byte;      {komp direkt nach login}
                     NeueZeilen   : Word;
                     ScrZlnMerk   : Word;
                     BoxZlnMerk   : LongInt;
                     Mo           : Mon_Type;
                     QsoScroll    : Boolean;
                     Ext_Poll     : Boolean;
                     C_Poll       : Boolean;
                     DieBoxPW     : String[6];  { PW fÅr DIE BOX ab V1.4 }
                     DBoxScaned   : Boolean;
                     DBox         : File;
                     FSize        : LongInt;
                     ChkLstOpen   : Boolean;
                     SysArt       : Byte;
                     UserArt      : Byte;
                     BoxScroll    : Boolean;
                     BoxStr       : String[BoxRec];
                     SCon         : Array [0..maxSCon] of Boolean;
                     Rubrik       : String[8];
                     RunRub       : String[60];
                     NewChkLst    : LongInt;
                     ChecksSorted : Boolean;
                     PassRetry    : Byte;
                     PassRight    : Byte;
                     RxComp       : Boolean;
                     TxComp       : Boolean;
                     SPComp       : Boolean;
                     SPRxCount    : word;
                     SPRxSOLL     : Byte;
                     STOPComp     : Boolean;
                     STopCode     : Word;
                     CompZeile    : String;
                     TncNix       : Boolean;
                     Kopieren     : Byte;
                     KopierenFm   : Byte;
                     WishBuf      : Boolean;
                     NoCurJump    : Boolean;
                     use_RomLw    : Boolean;
                     SynchErrAnz  : Word;
                     GrtFlag      : Boolean;
                     EigFlag      : Boolean;
                     FileFlag     : Boolean;
                     RemFlag      : Boolean;
                     CSelf        : Byte;
        {??}         AutoZeile    : String[80];
        {??}         Auto1Zeile   : String[80];
                     AutoTime     : String[5];
                     AutoZaehl    : Word;
                     AutoJump     : Word;
                     AutoZyConst  : Word;
                     AutoZyCount  : Word;
                     AutoWait     : Word;
                     AutoToConst  : Word;
                     AutoToCount  : Word;
                     AutoToAnz    : Word;
                     AutoToMax    : Word;
                     AutoToAnzJmp : Word;
                     AutoChMerk   : Byte;
                     AutoArt      : Byte;
                     AutoCheckLn  : Boolean;
                     AutoJmpPtr   : Byte;
                     AutoJmpRet   : Array [1..maxAutoJmpPtr] of Word;
                     Node         : Boolean; {true = Kanal laeuft als Node}
                     XPNodeC      : Boolean; {wird gesetzt, wenn XP-Node}
                                             {erkannt wurde (-N])}
                    SystemErkannt : Str15;   {??evtl nur noch version?}
                     QSOZeilen    : Byte;
                     SelfSysop    : Boolean;
                     AutoKenn     : Boolean;
                     BoxListeErg  : Boolean;
 {einer reicht!}     NodeTimeOut  : Integer;
                     TermTimeOut  : Integer;
                     VIP_,
                     Mail_SP      : Boolean;
                     PWMerk       : String[20]; {Merkt sich den Passwort-String bei UnvollstÑndigkeit}
                     OnAct        : String[20];
                     TXKompRate,
                     RXKompRate   : Byte;
                     Kompression  : Array[1..255] of Byte;
                     UnknownCount,           {ZÑhlt die Anzal unbekannter befehle}
                     CompCUpdZahl : Byte;    {ZÑhlt den Fortschritt des Komp-Updates mit}
                     CompC        : Boolean; {zeigt an, da· COMPC in Aktion ist}
                     KompressUpd  : Boolean; {soll dafÅr sorgen, dass wÑhrend Aktivierung
                                              COMPC nicht gesendet und beim Empfang Tab. kommen kann}
                   End;


        LokalPtr = Record
                     DetCode : Word;
                     Config           : file of konfig_rec;
                     LinkFile,
                   {  BootFile,}
                     MakroFile,
                     AutoFile,
                     TFile             : Text;
                     BFile             : File;

                     C1_Ton,
                     C1_TonTime,
                     C2_Ton,
                     C2_TonTime,
                     Alarm_Freq,
                     Alarm_Time,
                     RxPiepFreq,
                     RxPiepTime,
                     TxPiepFreq,
                     TxPiepTime,
                     RemPiepFreq,
                     RemPiepTime,
                     PopFreq,
                     PopFreqTime,
                     CTRL_G_Freq,
                     CTRL_G_Time,
                     TonHoehe,
                     BLockAnfFreq,
                     BLockEndFreq,
                     BlockPiep1Time,
                     BlockPiep2Time : Word;
                     NRCall         : str10;

                     Drive            : String[60];
                     Merk_Drive       : String[60];

                     {MailPfad         : String[60];}
                     {RunPfad          : String[60];}
                     {SpkPfad          : String[60];}
                     {SavePfad         : String[60];}
                     {BinPfad          : String[60];}
                     {SPlusPfad        : String[60];}
                     {TempPfad         : String[60];}
                     {MakroPfad        : String[60];}
                     {Ext_Edi_Path     : String[60];}
                     {Ext_View_Path    : String[60];}

                     Cmd_Line         : String[80];
                     InfoStr          : String[80];
                     Leer             : String[80];
                     Conn_Str         : String[80];
                     HeaderStr        : String[80];
                     PromptStr        : String[60];
                     TabStr           : String[20];

                     InfoDieBox       : String[60];
                     UserDieBox       : String[60];
                     InfoBayBox       : String[60];
                     InfoTnc3Box      : String[60];
                     RubrikStr        : String[60];

                     EzFileStr        : String[60];
                     EzMsgStr         : String[60];

                     RunElDir         : String[60];
                     RunElFile        : String[60];
                     RunElTree        : String[60];
                     BinEL            : String[10];
                     TxtEL            : String[10];
                     DirEL            : String[10];

                     CrcFeld          : Array [0..255] of Word;
                     SETL             : Array [1..10] of Word;
                     ESCP             : Array [1..maxESC] of String[13];
                     Fstr             : Array [7..20] of String[80];
                     Fstx             : Array [7..20] of Byte;
                     Remotes          : Array [1..maxREM] of REM_Type;
                     QRG              : Array [1..maxQRG] of QRG_Type;
                     QRG_Anz          : Byte;
                     MlStr            : Array [1..maxBlBox] of String[60];
                     OHelp            : Array [1..maxOHelp] of String[6];

                     Makro            : Boolean;
                     MakroLearn       : Boolean;
                     MakroZeile       : String[80];
                     MakroReturn      : Boolean;
                     MakroFileEnd     : Boolean;
                     MakroZaehl       : Word;
                     DArt             : Byte; {darstellung in udb 1=Umlaut, VIP, ...; 2= Distanz, Azimut}
                     StatusModus      : byte;
                     ZeilenwTX        : Boolean;
                   End;

        Mail_Typ = Record
         BoxCall     : str9;
         ZielCall    : str9;
         Port        : Byte;    {port auf dem gehîrt}
         Versuche    : Byte; {connect-versuche}
         Uhrzeit     : str10;   {Zeit/datum zuletzt gehîrt}
         Datum       : Str11;
        end;

        MailDat    = file of Mail_typ;

        UIdx_      = File of User_idx;
        UDat_      = file of User_typ2;




VAR
      Kanal2           : Byte;
{$IFNDEF no_Bake}      {//db1ras}
      MailBakenZeit    : Byte;
      MailBake         : Boolean;
{$ENDIF}
      Konfig           : Konfig_Rec;
      Quiet_Uhr,        {Schalten zw. Uhrzeit und QUIET-Anzeige}
      Quiet            : Boolean;   {QUIET-Befehl - Ruhe - kein Klingeln/Beep}
      QuietZeitG       : Boolean;
      QuietZtenAn      : array[1..3] of str8;
      QuietZtenAus     : array[1..3] of str8;
      OnlHelp          : Boolean;
      NTimeOut         : Integer;
      COM              : Array [1..4] of ComType;
      ComPortBase      : Array [1..4] of Word Absolute $0000:$0400;
      Old_IntMask      : Byte;
      ComAdr1,
      ComAdr2,
      ComAdr3,
      ComAdr4          : Word;
      EoiPic1,
      EoiPic2,
      EoiPic3,
      EoiPic4          : Boolean;
      TFPC_installed   : Boolean;
      DRSI_installed   : Boolean;
      Kiss_Int         : Byte;
      CB               : Byte;
      TRead            : Boolean;

      G                : ^LokalPtr;
      Bild             : ^BildPtr;
      Page             : ^NotChPtr;
      Msg              : ^MsgFeldPtr;
      MsgPos           : ^MsgPosPtr;
      HeapFeld         : ^GetHeapPtr;
      BFeld            : ^GetHeapPtr;
      Anwesend         : Array [1..MaxAnwesend] of ^Anwesend_;
      K                : Array [0..maxKanal] of ^KanalPtr;
      NotCh            : Array [0..maxKanal] of ^NotChPtr;
      VorWrite         : Array [0..maxKanal] of ^VorWritePtr;
      TNC              : Array [1..maxTNC] of ^TNC_Typ;
      TNC_used         : Array [1..maxArrayTNC] of Boolean;
      LptEsc           : Array [1..10] of Str20;        { Drucker-Steuerzeichen }
      AusStr           : String[80];
      SK_out           : Sondertaste;
      VC_out           : Char;
      maxLink          : Byte;
      show             : Byte;        { zur Zeit angezeigter Kanal }
      QRT              : Boolean;     { Ende-Merker }
      Mon_Anz          : Byte;
      ScrHandle,
      VorHandle,
      XMS_Handle       : Word;
      x                : Char;
      ZeitMerk         : String[8];
      UtcZeit          : String[8];
      UseUTC           : Boolean;
      TagOver          : Boolean;
      ZeitDiff         : ShortInt;
      HeapFile         : File;
      MPort            : Integer;
      FirstA           : Boolean;
      stFirst          : Integer;
      stLast           : Integer;
      TNC_ReadOut      : Boolean; { Erst die vorhandenen Frames beim Programmstart aus dem TNC lesen }
      JumpRxScr        : Boolean;
      JumpRxZaehl      : Integer;
      Win_Rout         : Boolean;
      Win_Time         : Word;
      Box_Time         : Word;

      NowCurBox        : Boolean;
      FirstConCh       : Byte;
      ZeitArt          : String[3];
      ch_in            : Char;
      ch_aus           : Boolean;
      Priv_PassWord    : String[80];
      Y4               : Integer;
      notScroll        : Boolean;
      DZeile           : String;
      Poll             : Byte;
      PollTnr          : Byte;
      PollRate         : Byte;
      D_Spalte         : Integer;
      Time_stamp       : Boolean; { Merker, Software soll Zeit anfuegen (Moni) }
      PacOut           : Boolean; {PacLen-Ausgabe bei Info-Monitorheader }

      Old_active_TNC   : Byte;
      TNC_Anzahl       : Byte;
      SendKanal        : Byte;
      SysPfad          : String[60];     { Pfad fÅr die Packet-Systemfiles }
      Sys1Pfad         : String[60];
      OvrDatei         : String[60];
      VDisk            : String[60];
      Vdisk_Exists     : Boolean;
      use_Vdisk        : Boolean;
      RomDisk          : String[3];
      Rom_Exists       : Boolean;

      Resync_Z         : Word;                        { Zaehler fuer Resync's }
      Nodes_Change     : Boolean;                     { Aenderungen in der Nodes-Liste? }
      Klingel          : Boolean;
      CtrlBeep         : Boolean;
      Uebernahme       : Boolean;
      Unproto          : Integer;
      multiTNC         : Boolean;
      Aufwaerts        : Boolean;
      ScreenSTBY       : Boolean;
      ScreenInit       : Word;
      ScreenTimer      : Word;
      StartVideoMode   : Integer;
      LastModeStore    : Integer;
      BreakStatus      : Boolean;
      _VGA             : Boolean;
      TNC_K            : Boolean; { im TNC ist K eingeschaltet }
      TNC_Date         : String[11];
      TNC_Time         : String[8];
      Ausgabe          : Boolean;
      Print            : Boolean;
      LPT_PORTs        : Array [1..4] of Word Absolute $0000:$0408;
      LPT_Base         : Array [1..4] of Word;
      LPT_vorhanden    : Boolean;   { Druckerschnittstelle vorhanden? }
      PrtPort          : Byte;
      PrtFailure       : Boolean;
      Gate             : Integer;
      maxPath          : Integer;
      LastName         : Integer;     { Anzahl der gespeicherten Namen }
      CNr              : LongInt;     { Anzahl der Connects            }
      NoActivity,        {letzte Sysop-AktivitÑt in minuten}
      LaufZeit         : LongInt;
      WBox             : Str9;
      WCall            : Str9;        { fÅr WATCH-Funktion              }
      Attrib           : Array[1..maxAttr] of Byte;   { Bildschirm-Attribute }
      FreiKanal        : Byte;
      NeuCall          : String[70];
      RemoteCall       : String[9];
      LastInfoOut      : ^InfoOutPtr;
      LastInfoCount    : Byte;
      LastInfoFlag     : Boolean;
      History          : ^HistoryPtr;
      HistoryCount     : Byte;
      Del              : Boolean;
      ShowMerk         : Byte;
      ZeigeRET         : Boolean;
      TopBox           : Boolean;
      morsen           : Boolean;
      MPause           : Word;
      HardCur          : Boolean;
      Gross            : Boolean;
      minTncBuf        : Word;
      maxTncBuf        : Word;
      Fenst_Y          : Byte;
      NowFenster       : Boolean;
      ScrollVor        : Boolean;
      BlTon            : Boolean;
      XL,XR            : Byte;
      FreeRam          : LongInt;
      maxZ             : Byte;
      ParmAnz          : Byte;
      ParmPos          : Byte;

      NrStat           : Array[1..4] of Byte;
      Eig_Mail_Zeile   : String[80];
      TNC_Halt         : Boolean;
      polling          : Boolean;
      PollTime         : LongInt;

      VideoSeg         : Word;
      XCP              : Byte;
      Color            : Boolean;
      StartColor       : Byte;
      Hercules         : Boolean;
      EMS_Pages_Ins    : Word;
      ParamZeile       : ^String;
      CFGNr            : Byte;
      ColNr            : Byte;
      TncINr           : Byte;
      CRC_PR_EXE       : Boolean;
      File_Frame_max   : Integer;
      Pseudo           : Boolean;  { Rufzeichen in den TNC-KanÑlen > maxLink }
      ConvHilfsPort    : Byte;
      ReconMorsen      : Boolean;
      ConMorsen        : Boolean;
{      ReconVoice       : Boolean;
      ConVoice         : Boolean; }
      MonID            : Byte;      { Ident im Monitor schreiben ?}
      ShTab_Pressed    : Boolean;
      Braille80        : Boolean;
      GesamtNotCh,
      GesamtVorCh      : LongInt;
      PortStufe        : Byte;
      Mstr             : String[80];
      volle_Breite     : Boolean;
      Nutze_EMS        : Boolean;
      Nutze_XMS        : Boolean;
      Vor_im_EMS       : Boolean;
      use_EMS          : Boolean;
      use_XMS          : Boolean;
      OVRtoXMS,
      OVRtoEMS         : Boolean;
      Speek            : Boolean;
      VSpeed           : Word;
      UeberNr          : String[2];
      Key1A            : Byte absolute $0040:$001A;
      Key1C            : Byte absolute $0040:$001C;
      KeyStatus        : Byte absolute $0040:$0017;
      TastPuffer       : Array [$1E..$3D] of Byte absolute $0040:$001E;
      BufText          : Word;
      SwapXms          : Boolean;
      SwpHandle        : Word;
      SizeHeap         : LongInt;
      KeyDelay         : Word;
      GlobalTrenn      : Boolean;
      ScrollFile       : File;
      BuffFile         : File;
      AT               : Boolean;
      TimerTick        : LongInt absolute $0040:$006C;
      TimerFlag        : Byte;
      TimeOut          : LongInt;
      HwHs             : Boolean;
      HlpCompile       : Boolean;
      BinOut           : Boolean;
      Ins              : Boolean;
      HighCol          : Boolean;
      Kbd              : Byte;
      SortMhNr         : Byte;
      Cursor_on        : Boolean;
      CurX,
      CurY             : Byte;
      HD_was_Active    : Boolean;
      Old2Bvec         : Pointer;
      TopString        : String[3];
      IrqMask          : Byte;
      AnyConnect       : Boolean;
      DateiInfo        : Byte;
      SSAV             : Byte;
      LogArt           : Byte;
      RTC              : Boolean;
      WishBoxLst       : Boolean;
      WishDXC          : Boolean;
      KillEsc          : Boolean;
      WCTRL            : Boolean;
      Upload           : Boolean;
      K_Record_on_Heap : Boolean;
      QRT_Text         : Boolean;
      SynchError       : Boolean;
      OverRun          : Boolean;
      ColMon           : Byte;
      MonCode5         : Boolean;
      WeekDayStr       : String[60];
      WochenTag        : String[10];
      OrigExit         : Pointer;
      HD_Read          : Word;
      KStat            : Boolean;
      KStatTr          : String[1];
      ZlnMerk          : Boolean;
      NoBinMon         : Boolean;
      maxBefehl        : Word;
      RX_TX_Win        : Boolean;
      SplCountLines    : Boolean;
      BiosOut          : Boolean;
      MhKill           : Boolean;
      AltQFlag         : Boolean;
      V24Buffer        : Array [0..MaxComBuf] of Byte;
      BufferPos        : Word;
      Dir              : ^Dir_Feld;
      UserKilled,                      {filepos des zu lîschenden users (userdatenbank)}
      DirSize          : LongInt;
      DirFiles         : Word;
      MailAnz,
      UserAnz          : longint;
      MH               : ^MH_Feld;
      MHeard           : ^MH_Feld;
      MH_Anz           : Byte;
      maxMH            : Byte;
      FreqList         : ^Freq_Ptr;
      FreqPos,
      FreqCount        : Byte;
      Lnk              : ^Lnk_Ptr;
      Lnk_Anz          : Byte;
      Hlp              : ^Hlp_Ptr;
      Hlp_Anz          : Byte;
      Hlp_ZlnNr        : LongInt;
      HoldDXC          : Boolean;
      HoldDXcStr       : String[25];
      KeyCheck         : Boolean;
      RecCheck         : Boolean;
      SETNr            : Byte;
      TicAnz           : Byte;
      ModMonFr         : Boolean;
      FiResult         : Integer;
      WeFlag           : Boolean;
      DirScroll        : Boolean;
      KeyOpt           : Byte;
      EraseChk         : LongInt;
      LogChk           : LongInt;
      SiAltD           : Boolean;
      SiAltK           : Boolean;
      TabFill          : Boolean;
      MoniStaAnz       : Byte;
      Idle             : Boolean;
      Idle_Pos         : Boolean;
      Idle_Anz         : Word;
      Idle_Count       : Word;
      Idle_Tout        : Word;
      Idle_TCount      : Word;
      Idle_TMerk       : LongInt;
      DelayCor         : Real;
      LockInt          : Boolean;
      BoxZaehl         : Word;
    (*  ShowQTH,                         {> FÅr Rem.- und ESC-Befehl Show,}
      ShowLoc          : String[31];   {> hier solll der Kanal ja nicht beschrieben werden}*)
      MailPolling      : String;       {hier werden alle Poll-Befehle abgelegt und ausgelesen}
      PollStr          : string;       {Ersatz fÅr MeldeZeile in der IO}
      MailPrompt_      : Str60;        {Such-Prompt fÅr MailPolling [#?] }
      MailSSTopPrompt_,
      MailPWPrompt_    : str60;
      MailBoxCall,
      MailRXCall,
      CRCNROM          : Str9; {tarnung - ist CRC-prÅfungs-vari!}
      MailSynonym      : String[12];
      BackupBremsen,
      BackupJetzt      : Boolean;
      MailAusUDB       : Boolean;
      FWD_             : Boolean;      {Anzeige, da· bereits MailPolling aktiv!}
      MailPWWait       : Boolean;
      alte_Table       : ^PSPtablePtr;
      neue_Table       : Array [1..maxTable] of Byte;
      TabAdresse       : ^Pointer;
      TabLaenge        : ^Word;
{     Comp_Key         : Array [0..maxTable] of Boolean;}
      Versi            : str20; {VErsi-,Mail-Anzeige rein, um mit scan wechseln zu kînnen}
      Scan_,
      KommtMail        : Boolean; { Mail-Frame erkannt, warten auf MailJetzt }
      MailJetzt        : Byte;    { Frame ZÑhler: Wann kommt Info-Frame? }
      _OnAct,
      MailInBox,                  {fÅr flags}
      inNodeListe,                {um dateizugriff auf Netrom-geschichten wÑhrend Listenaufenthalt zu verhindern}
      InUdb,                      {fÅr Anzeigen in UDB, damit nicht im qso-schirm}
      VIPG,                       {VIP-funkt. an/aus?}
      SoZeichen        : Boolean; {Sonderzeichen od. Inv. Gro·buchstaben? }
     { UD               : File of User_Typ2;}
     TestDec,
     TestCom:string;
     NetRom,
     MailFrFlag,
     ESC_Call : boolean; {suchroutine bei ESC Call abschotten}
     Mail       : Mail_Typ;
     LastLTCheck : Longint;
     maxmsgs:integer;        {anzahl zeilen in msgs zÑhlen!}
     tag_, monat_, jahr_, wotag_,
     Stunde,Minute,Sekunde,
     lminute               : word;
     gotLastHr,
     gotlastdt             : boolean; {letztes datum geholt}
  {   TXZeit: byte;
     TXoffen,
     TXbed,
     TXZMax,
     TXSicher  : Byte;
   }

     xbtest:boolean;
     BackUpLauf,
     BackUpProc,
     wavfileopen : Boolean;
     SoundFile : File;
{$IFDEF Sound}
     WavStream : String;

     {Variables available to the calling programme : }
    Playing : Boolean; {True if currently playing a wave-file}
    WaveError : Byte; {If an error has occurred, contains the error code}
    WaveType : WType; {Contains wave-file information}

  {Pointer to old IRQ handler}
  OldIRQ,
  {Pointer to old exit procedure}
  OldEP : pointer;
  {The SB base address}
  Base : Word;
  {What kind of card is installed}
  Card,
  {The IRQ level}
  IRQ,
  {The DMA channel currently used}
  Channel : Byte;
  {One DMA channel for 8bit, the other for 16bit}
  DMA8, DMA16 : Byte;

  {The sound buffer itself}
  SoundBuffer : ^ThirtyTwoK;

  {The amount of bytes already read}
  SoundRead,
  {If the amount of bytes to be played is not a multiple of 16384 (most
  likely, it isn't), this is used to store the difference}
  OverHead : LongInt;
  {Which buffer is being played}
  Upper,
  {Should the sound buffer be release?}
  FreeBuffer : Boolean;
  {A handle to the sound file}
{  SoundFile : File;}
  {The chunks that should be read from the file}
  Header : HeaderChunk;
  Wave : WaveChunk;
  fmtH : fmtHeader;
  fmt : fmtChunk;
  dataC : DataChunk;

{$ENDIF}




Implementation

Var a : Byte;

Begin
  MailPrompt_:='';
  MailpwPrompt_:='';
  MailPWWait:=false;
  MailSynonym:='';
  MailAusUDB:=false;
  MailSSTopprompt_:='';
  SoZeichen:= false;
  VIPG     := false;
  {ShowQTH :=''; ShowLoc:='';}
  PollStr:='';
  MailInBox:=False;
  MailJetzt:=0;
  KommtMail:=false;
  {For A:=1 to maxKanal do
   begin
    Comp_Key[A]:=false;
   end;}

  GetIntVec(TEI,Old2Bvec);
  TopString := 'XP';

  AT := (Mem[$F000:$FFFE] = 252);
  HwHs := false;
  HlpCompile := false;

  Mstr := '';
  CFGNr := 0;
  ColNr := 0;
  TncINr := 0;
  CRC_PR_EXE := false;
  OVRtoEMS := true;
  OVRtoXMS := true;
  Nutze_EMS := true;
  Nutze_XMS := true;
  use_Vdisk := true;
  Vdisk_Exists := true;

  if (Lo(LastMode) = 7) then VideoSeg := SegHGC
                        else VideoSeg := SegVGA;

  Bild := Ptr(VideoSeg,0);

  for A := 1 to 4 do with COM[A] do
  begin
    FillChar(COM[A],SizeOf(COM[A]),0);
    BufferPos := 0;
    Active := false;
    FifoOn := false;
    FifoCfg := 0;
    Base := ComPortBase[A];
    if A in [3,4] then if Base = 0 then Base := Default_Base[A];
    Old_Vector := Nil;
    IRQ_Nr := Default_IRQ[A];
  end;

  TFPC_installed := false;
  DRSI_installed := false;

  QUIET:=false;
  Quiet_Uhr:=false;

  OnlHelp:=False;
  xbtest:=true;
{  TXZeit := 255;
  TXoffen := 0;
  TXbed  := 0;
  TXSicher := 2;
  TXZMax   := 5;
}
End.
