{***************************************************************************
** Unit to play WAV-format files from Turbo Pascal for DOS.               **
**  by Steven H Don                                                       **
**                                                                        **
** For questions, feel free to e-mail me.                                 **
**                                                                        **
**    shd@earthling.net                                                   **
**    http://shd.cjb.net                                                  **
**                                                                        **
***************************************************************************}


{Writes a value to the DSP-chip on the SB}
procedure WriteDSP (value : byte);
begin
{$IFDEF Sound}
  while Port [base + $C] And $80 <> 0 do;
  Port [base + $C] := value;
{$ENDIF}
end;

{Establishes the DSP<->Speaker connection, necessary for older cards.}
function SpeakerOn :  byte;
begin
  WriteDSP ($D1);
end;

{Discontinues the DSP<->Speaker connection, necessary for older cards.}
function SpeakerOff :  byte;
begin
  WriteDSP ($D3);
end;


{Stops playing the wave-file.}
procedure DMAStop;
begin
{$IFDEF Sound}
  {Set general variable to indicate no sound}
  Playing := false;

 {Function :  D0 Stop 8 bit DMA transfer}
  WriteDSP ($D0);
  {Function :  D5 Stop 16 bit DMA transfer}
  WriteDSP ($D5);

  {$I-}
  if WavFileOpen then
   begin
    Close (SoundFile);     {Close the soundfile}
    if IOResult <> 0 then; {Clear Error flag}
   end;
  WavFileOpen := False;
  {$I+}

  {Free the sound buffer}
  if SoundBuffer <> nil then begin
    freemem (SoundBuffer, 16384);
    SoundBuffer := nil;
  end;
{$ENDIF}
end;

{This procedure sets up the DMA controller for DMA transfer.
Then it programs the DSP chip to receive the transfer.
Finally it initiates the transfer.}
{procedure Playback (SoundSeg, SoundOfs, size : longint);}
procedure Playback (Location : Pointer; Start, Size : Word);
var
  SoundSeg, SoundOfs : Word;
  page, offset : longint;

begin
{$IFDEF Sound}
  {Calculate offset and segment part of the buffer}
  SoundSeg := Seg (Location^);
  SoundOfs := Ofs (Location^) + Start;

  {Calculate Offset and Page address of Wave-data}
  if fmt.BitResolution = 8 then begin
    offset := SoundSeg Shl 4 + SoundOfs;
    page := (SoundSeg + SoundOfs shr 4) shr 12;
  end else begin
    size := size shr 1;
    page := (SoundSeg + SoundOfs shr 4) shr 12;
    offset := (SoundSeg Shl 3 + SoundOfs shr 1) mod 65536;
  end;

  {Decrease size by one. This is necessary because the
  DMA controller sends one byte/word more than it is told to}
  {Setup DMA Controller for transfer}
  Port [DMAPort    [Channel, 1]] := 4 or (Channel and 3);
  if fmt.BitResolution = 16 then Port [$D8] := 0;
  Port [DMAPort    [Channel, 3]] := 0;
  Port [DMAPort    [Channel, 2]] := $48 or (Channel and 3);
  Port [DMAChannel [Channel, 2]] := Lo (offset);
  Port [DMAChannel [Channel, 2]] := Hi (offset);
  Port [DMAChannel [Channel, 1]] := page;
  Port [DMAChannel [Channel, 3]] := Lo (size);
  Port [DMAChannel [Channel, 3]] := Hi (size);
  Port [DMAPort    [Channel, 1]] := (Channel and 3);

  {Set DSP}
  if Card = SB8 then begin
    {Set up 8-bit card, sorry no stereo SBPRO support}
    WriteDSP ($14);
  end else begin
    {Set up 16-bit card}
    if fmt.BitResolution = 8 then begin
      {8-Bit file}
      WriteDSP ($C0);
      if fmt.Channels = 1 then WriteDSP ($00); {Mono}
      if fmt.Channels = 2 then WriteDSP ($20); {Stereo}
    end else begin
      {16-Bit file
      Perhaps this also needs to be changed}
      WriteDSP ($B0);
      if fmt.Channels = 1 then WriteDSP ($10); {Mono}
      if fmt.Channels = 2 then WriteDSP ($30); {Stereo}
    end;
  end;

  {Send the size of the transfer to the SB}
  WriteDSP (Lo (size));
  WriteDSP (Hi (size));

  {Set global variable to indicate playing sound}
  Playing := true;
{$ENDIF}
end;

{This procedure is called at the end of a DMA transfer. It starts the
playing of the next portion of the wave-file and reads in another block.}
procedure ServiceIRQ; interrupt;
var
  b, t : Byte;

begin
{$IFDEF Sound}
  {relieve card}
  if Card = SB16 then begin
    Port [base + $4] := $82;
    t := Port [base + $5];
    if t and 1 = 1 then b := Port [base + $E]; { 8bit interrupt}
    if t and 2 = 2 then b := Port [base + $F]; {16bit interrupt}
  end else begin
    {8bit interrupt}
    b := Port [base + $E];
  end;

  {Acknowledge hardware interrupt}
  Port [$20] := $20;

  {Stop playing}
  Playing := false;
  if FreeBuffer then begin
    Dispose (SoundBuffer);
    SoundBuffer := nil;
  end;

  {The following is done when the remaining part of the file
  is less than 16K.}
  if OverHead>0 then begin
    {Play the last part of the sound}
    if Upper then
      PlayBack (SoundBuffer, 0, OverHead)
    else
      PlayBack (SoundBuffer, 16384, OverHead);

    {The file may be closed}
    Close (SoundFile);
    WavFileOpen:=False;
    OverHead := 0;

    {The next time this routine is called, the sound buffer must
    be freed so that the memory it occupies is available to the
    calling programme.}
    FreeBuffer := true;
  end;

  {If there is more than 16K to be played and/or read, it will
  be done in chunks of 16K.}
  if dataC.SoundLength - SoundRead > 0 then begin
    if dataC.SoundLength - SoundRead > 16384 then begin
      {Load into appropriate part of the buffer}
      if Upper then begin
        PlayBack (SoundBuffer, 0, 16384);
        BlockRead (SoundFile, SoundBuffer^ [16384], 16384);
      end else begin
        PlayBack (SoundBuffer, 16384, 16384);
        BlockRead (SoundFile, SoundBuffer^, 16384);
      end;

      {Update position indicators}
      inc (SoundRead, 16384);
      Upper := Not Upper;
    end else begin
      {Load in the last part of the Wave-file and play it.}
      OverHead := dataC.SoundLength-SoundRead;
      if Upper then begin
        PlayBack (SoundBuffer, 0, 16384);
        BlockRead (SoundFile, SoundBuffer^ [16384], Overhead);
      end else begin
        PlayBack (SoundBuffer, 16384, 16384);
        BlockRead (SoundFile, SoundBuffer^, Overhead);
      end;
      inc (SoundRead, Overhead);
      Upper := Not Upper;
    end;
  end;
{$ENDIF}
end;

procedure PlayWave (FileName : String);
begin
{$IFDEF Sound}

  {Assume no error}
    WaveError := 0;

  {Return error if no sound card found}
  if Base = 0 then begin
    WaveError := NoCard;
    Exit;
  end;

  {Stop any DMA-transfer that might be in progress}
  DMAStop;

  {Initialize settings}
  FreeBuffer := false;
  OverHead := 0;

  {Allow access to read-only files}
  FileMode := 0;

  {$I-}
  {Check for existence of file}
  Assign (SoundFile, FileName);
  Reset (SoundFile, 1);
  {If it doesn't exist, maybe the extension should be added}
 { if IOResult <> 0 then begin
    Assign (SoundFile, FileName + '.WAV');
    Reset (SoundFile, 1);
  end;}
  {$I+}
  FileMode:=2;
  {If it doesn't resist, return an error}
  if IOResult <> 0 then begin
    WaveError := FileNotFound;
    Exit;
  end;
  WavFileOpen:=True;
  {Read the RIFF header}
  BlockRead (SoundFile, Header, 8);
  {Check for 'RIFF', if not found :  don't play}
  if Header.RIFF <> rId then begin
    WaveError := InvalidWAVE;
    Close (SoundFile);
    WavFileOpen:=false;
    Exit;
  end;

  {Read the WAVE header}
  BlockRead (SoundFile, Wave, 4);
  {Check for 'WAVE', if not found :  don't play}
  if Wave.WAVE <> wId then begin
    WaveError := InvalidWAVE;
    Close (SoundFile);
    WavFileOpen:=False;
    Exit;
  end;

  {Search for the fmt chunk, that starts with 'fmt '}
  repeat
    BlockRead (SoundFile, fmtH, 8);
    if fmtH.fmt <> fId then Seek (SoundFile, FilePos (SoundFile)-7);
  until fmtH.fmt = fId;

  {Read format specifier}
  BlockRead (SoundFile, fmt, fmtH.fmtDataLength);

  {Check format}
  with fmt do begin
    if (Card = SB8) then begin
      {16bit files can't be played through 8bit card}
      if (BitResolution = 16) then begin
        WaveError := No16BitCard;
        Close (SoundFile);
        WavFileOpen:=False;
        Exit;
      end;
      {Stereo files are only played over 16bit card}
      if (Channels = 2) then begin
        WaveError := NoStereoCard;
        Close (SoundFile);
        WavFileOpen:=False;
        Exit;
      end;
    end;
    {Can only play uncompressed WAVs}
    if WaveType <> 1 then begin
      WaveError := InvalidWAVE;
      Close (SoundFile);
      WavFileOpen:=False;
      Exit;
    end;
  end;

  {Search for data chunk, starting with 'data'}
  datac.data := 0;
  repeat
    BlockRead (SoundFile, dataC, 8);
    if dataC.data <> dId then Seek (SoundFile, FilePos (SoundFile)-7);
  until datac.data = dId;

  {Some wave-files have an incorrect SoundLength. This makes sure
  that the SoundLength is never larger than actually fits in the
  wave file.}
  if dataC.SoundLength>FileSize (SoundFile)-FilePos (SoundFile)-1 then
    dataC.SoundLength := FileSize (SoundFile)-FilePos (SoundFile)-1;
  WaveType.Length := dataC.SoundLength;

  {The WaveLength (not SoundLength) indicates the number of Samples,
  not the number of bytes, so this needs to be adjusted for the
  number of channels (Mono/Stereo) and the bit-resolution (8/16-Bit)}
  if WaveType.Stereo = true then WaveType.Length := WaveType.Length shr 1;
  if WaveType.Resolution = 16 then WaveType.Length := WaveType.Length shr 1;

  {set DMAChannel}
  if fmt.BitResolution = 8 then Channel := DMA8;
  if fmt.BitResolution = 16 then Channel := DMA16;

  {Update global variables so that calling programs can identify
  the wave being played. Pretty useless for games though}
  WaveType.SampleRate := fmt.SampleRate;
  WaveType.Resolution := fmt.BitResolution;
  WaveType.Stereo := fmt.Channels = 2;
  SoundRead := 0;

  {Allocate 32K of memory to the sound buffer}
  getmem (SoundBuffer,16384);
  {If there was an error allocating memory, don't play.}
  if SoundBuffer = nil then begin
    WaveError := NoMemory;
    Close (SoundFile);
    WavFileOpen:=False;
    Exit;
  end;

  {set sample rate}
  case Card of
    {Original SB requires a special 'time-frame' computation}
    SB8  : begin
             WriteDSP ($40);
             WriteDSP (256 - 1000000 div fmt.SampleRate);
           end;
    {SB16 just needs the samplerate. Much easier}
    SB16 : begin
             WriteDSP ($41);
             WriteDSP (hi (fmt.SampleRate));
             WriteDSP (lo (fmt.SampleRate));
           end;
  end;

  {check length of file}
  if dataC.SoundLength>32768 then begin
    {must be played in parts}
    BlockRead (SoundFile, SoundBuffer^, 32768);
    SoundRead := 32768;
    PlayBack (SoundBuffer, 0, 16384);
    Upper := false;
  end else begin
    {can be played at once}
    BlockRead (SoundFile, SoundBuffer^, dataC.SoundLength);
    PlayBack (SoundBuffer, 0, dataC.SoundLength);
    SoundRead := dataC.SoundLength;
    {$I-}
    close(Soundfile);
    if ioresult>0 then;
    WavFileOpen:=False;
    {$I+}
   end;

{$ENDIF}
end;

{Stops playing the sound file}
procedure StopWave;
begin
  DMAStop;
end;

{$F+}
procedure ExitWavePlayer;
begin
{$IFDEF Sound}
  {Restores the ExitProc pointer to the original value}
  ExitProc := OldEP;

  {Stops any DMA-transfer that might be in progress}
  DMAStop;

  {Free interrupt vectors used to service IRQs}
  case IRQ of
    2 : SetIntVec($71, OldIRQ);
   10 : SetIntVec($72, OldIRQ);
   11 : SetIntVec($73, OldIRQ);
  else
    SetIntVec (8 + IRQ, OldIRQ);
  end;

  {Mask IRQs}
  case IRQ of
    2 : Port[$A1] := Port[$A1] or 2;
   10 : Port[$A1] := Port[$A1] or 4;
   11 : Port[$A1] := Port[$A1] or 8;
  else
    Port[$21] := Port[$21] or (1 shl IRQ);
  end;
{$ENDIF}
end;
{$F-}

Procedure FindBlaster;
var
  BLASTER : String;
  p : Byte;

begin
{$IFDEF Sound}

  Playing := false;
  Base := 0;
  {Get BLASTER environment string}
  (*BLASTER := GetEnv ('BLASTER');
  if (BLASTER = '') then Exit;*)

  {Extract type of card from BLASTER string}
  Card := SB8;
  (* p := 0;
  repeat inc (p) until (BLASTER [p] = 'T') or (p > length (BLASTER));
  if BLASTER [p + 1] > '5' then Card := SB16; *)
  if Konfig.SBHiDMA>0 then Card:=SB16;
  {Extract base address from BLASTER string}
(*  p := 0;
  repeat inc (p) until (BLASTER [p] = 'A') or (p > length (BLASTER));
  Base := Ord (BLASTER [p + 2]) - Ord ('0');
  Base := (Base shl 4) + $200; *)
  Base:=konfig.SBBaseADR;
  {Extract IRQ level from BLASTER string}
 (* p := 0;
  repeat inc (p) until (BLASTER [p] = 'I') or (p > length (BLASTER));
  IRQ := Ord (BLASTER [p + 1]) - Ord ('0'); *)
  IRQ:=konfig.SBIRQ;
  {Extract low DMA channel from BLASTER string}
  (*p := 0;
  repeat inc (p) until (BLASTER [p] = 'D') or (p > length (BLASTER));
  DMA8 := Ord (BLASTER [p + 1]) - Ord ('0'); *)
  DMA8:=konfig.SBLoDMA;
  {Extract high DMA channel from BLASTER string}
  (*p := 0;
  repeat inc (p) until (BLASTER [p] = 'H') or (p > length (BLASTER));
  DMA16 := Ord (BLASTER [p + 1]) - Ord ('0'); *)
  DMA16:=Konfig.SBHiDMA;

  {Enable speaker}
  SpeakerOn;

  {Save old IRQ vector}
  case IRQ of
    2 : GetIntVec($71, OldIRQ);
   10 : GetIntVec($72, OldIRQ);
   11 : GetIntVec($73, OldIRQ);
  else
    GetIntVec (8 + IRQ, OldIRQ);
  end;

  {Set new IRQ vector}
  case IRQ of
    2 : SetIntVec($71, Addr (ServiceIRQ));
   10 : SetIntVec($72, Addr (ServiceIRQ));
   11 : SetIntVec($73, Addr (ServiceIRQ));
  else
    SetIntVec (8 + IRQ, Addr (ServiceIRQ));
  end;

  {Enable IRQ}
  case IRQ of
    2 : Port[$A1] := Port[$A1] and not 2;
   10 : Port[$A1] := Port[$A1] and not 4;
   11 : Port[$A1] := Port[$A1] and not 8;
  else
    Port[$21] := Port[$21] and not (1 shl IRQ);
  end;
  if IRQ in [2, 10, 11] then Port[$21] := Port[$21] and not 4;

  {Save ExitProc pointer and set it to our own exit procedure.
  The ExitProc procedure is called after the main (calling)
  programme terminates. The main programme doesn't have to take
  care of resetting the IRQs and so on.}
  OldEP := ExitProc;
  ExitProc := Addr (ExitWavePlayer);

{$ENDIF}
end;