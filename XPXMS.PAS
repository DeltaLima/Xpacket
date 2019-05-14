Unit XPXMS;
{$F+}

Interface


Const  ixms = $2F;

Var     XMS_Version,
        XMS_Treiber,
        HMA           : Word;
        XMS_installed : Boolean;
        Failure       : Byte;

        XmsControl    : Pointer;

        RecXms : record                    { XMS-INFOBLOCK        }
                   Len       : LongInt;    { length of Bytes      }
                   fr_Handle : Word;       { source handle        }
                   fr_Adr    : LongInt;    { source pointer       }
                   to_Handle : Word;       { destination handle   }
                   to_Adr    : LongInt;    { destination pointer  }
                 end;


Procedure get_XMS_Install;
Function  get_XMS_Free : Word;
Function  get_XMS_Ram(SizeKb : Word) : Word;
Procedure Free_XMS_Ram(Handle : Word);
Procedure Data_To_XMS(Source : Pointer; Handle : Word; Adresse,Count : LongInt);
Procedure Xms_To_Data(Source : Pointer; Handle : Word; Adresse,Count : LongInt);
Procedure Init_XMS;

Implementation

Procedure get_XMS_Install;
var    Erg : Byte;
Begin
  Erg := 0;
  if not XMS_installed then
  begin
    asm  mov  ax, $4300
         int  ixms
         mov  Erg, al
         cmp  al, $80
         jne  @NoDrv

         mov  ax, $4310
         int  ixms
         mov  Word(XmsControl),bx
         mov  Word(XmsControl+2),es

         xor  ah,ah
         call XmsControl
         mov  XMS_Version,ax
         mov  XMS_Treiber,bx
         mov  HMA,dx

      @NoDrv:
    end;
    XMS_installed := (Erg = $80);
  end;
End;

Function get_XMS_Free : Word;
var    Free : Word;
Begin
  asm  mov  ah,$08
       call XmsControl
       mov  Free,ax
       mov  Failure,bl
  end;
  get_XMS_Free := Free;
End;

Function  get_XMS_Ram(SizeKb : Word) : Word;
var     Handle : Word;
Begin
  asm  mov  ah, $09
       mov  dx, SizeKb
       call XmsControl;
       mov  Handle, dx
  end;
  get_XMS_Ram := Handle;
End;

Procedure Free_XMS_Ram(Handle : Word);
Begin
  asm  mov  ah, $0A
       mov  dx, Handle
       call XmsControl;
  end;
End;


Procedure Data_To_XMS(Source : Pointer; Handle : Word; Adresse,Count : LongInt);
var      Erg : Word;
         m   : Pointer;
Begin
  m := Addr(RecXms);
  If Count mod 2 <> 0 then inc(Count);

  RecXms.Len := count;
  RecXms.fr_Handle := 0;
  RecXms.fr_Adr := LongInt(Source);
  RecXms.to_Handle := handle;
  RecXms.to_adr := Adresse;
  asm  mov  ah, $0b
       mov  si, Word [m]
       mov  bl,0
       call XmsControl
       mov  Erg, ax
       mov  Failure,bl
  end;
End;


Procedure Xms_To_Data(Source : Pointer; Handle : Word; Adresse,Count : LongInt);
var      Erg : Word;
         m   : Pointer;
Begin
  m := Addr(RecXms);
  If Count mod 2 <> 0 then inc(Count);

  RecXms.Len := count;
  RecXms.to_Handle := 0;
  RecXms.to_adr := LongInt(Source);
  RecXms.fr_Handle := Handle;
  RecXms.fr_Adr := Adresse;

  asm  mov  ah, $0b
       mov  si, Word [m]
       mov  bl,0
       call XmsControl
       mov  Erg, ax
       mov  Failure,bl
  end;
End;

Procedure Init_XMS;
Begin
  XMS_installed := false;
  get_XMS_Install;
End;

End.
