unit SPECTRA.Detour;

interface

  {$IFDEF MSWINDOWS}
  procedure RedirectProcedure(OldAddress, NewAddress: Pointer);
  {$ENDIF MSWINDOWS}

implementation

uses
  Winapi.Windows;

{$IF NOT DECLARED(FireMonkeyVersion)}

{$IFDEF MSWINDOWS}
type
  PAbsoluteIndirectJmp = ^TAbsoluteIndirectJmp;
  TAbsoluteIndirectJmp = packed record
    OpCode: Word; // $FF25(Jmp, FF /4)
    Addr: DWORD;  // 32-bit address
                  // in 32-bit mode: it is a direct jmp address to target method
                  // in 64-bit mode: it is a relative pointer to a 64-bit address used to jmp to target method
  end;

  PInstruction = ^TInstruction;
  TInstruction = packed record
    Opcode: Byte;
    Offset: Integer;
  end;
{$ENDIF MSWINDOWS}


function GetActualAddr(Proc: Pointer): Pointer;
begin
  Result := Proc;
  if Result <> nil then
    if PAbsoluteIndirectJmp(Result)^.OpCode = $25FF then  // we need to understand if it is proc entry or a jmp following an address
{$ifdef CPUX64}
      Result := PPointer( NativeInt(Result) + PAbsoluteIndirectJmp(Result)^.Addr + SizeOf(TAbsoluteIndirectJmp))^;
      // in 64-bit mode target address is a 64-bit address (jmp qword ptr [32-bit relative address] FF 25 XX XX XX XX)
      // The address is in a loaction pointed by ( Addr + Current EIP = XX XX XX XX + EIP)
      // We also need to add (instruction + operand) size (SizeOf(TAbsoluteIndirectJmp)) to calculate relative address
      // XX XX XX XX + Current EIP + SizeOf(TAbsoluteIndirectJmp)
{$else}
      Result := PPointer(PAbsoluteIndirectJmp(Result)^.Addr)^;
      // in 32-bit it is a direct address to method
{$endif}
end;

procedure PatchCode(Address: Pointer; const NewCode; Size: Integer);
var
  OldProtect: DWORD;
begin
  if VirtualProtect(Address, Size, PAGE_EXECUTE_READWRITE, OldProtect) then //FM: remove the write protect on Code Segment
  begin
    Move(NewCode, Address^, Size);
    FlushInstructionCache(GetCurrentProcess, Address, Size);
    VirtualProtect(Address, Size, OldProtect, @OldProtect); // restore write protection
  end;
end;

procedure RedirectProcedure(OldAddress, NewAddress: Pointer);
var
  NewCode: TInstruction;
begin
  OldAddress := GetActualAddr(OldAddress);

  NewCode.Opcode := $E9;//jump relative
  NewCode.Offset := NativeInt(NewAddress) - NativeInt(OldAddress) - SizeOf(NewCode);

  PatchCode(OldAddress, NewCode, SizeOf(NewCode));
end;

{$ENDIF}

end.
