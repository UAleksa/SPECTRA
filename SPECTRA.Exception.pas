unit SPECTRA.Exception;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;


  procedure ShowExceptionForm(Show: boolean);

var
  FErrorLogFullPath: string;

implementation

uses
  Vcl.ExtCtrls, SPECTRA.Consts, JclHookExcept, JclDebug;

type
  PAbsoluteIndirectJmp = ^TAbsoluteIndirectJmp;
  TAbsoluteIndirectJmp = packed record
    OpCode: Word;  // $FF25(Jmp, FF /4)
    Addr: DWORD;  // 32-bit address
                  // in 32-bit mode: it is a direct jmp address to target method
                  // in 64-bit mode: it is a relative pointer to a 64-bit address used to jmp to target method
  end;

  PInstruction = ^TInstruction;
  TInstruction = packed record
    Opcode: Byte;
    Offset: Integer;
  end;

  TSubApplication = class(TApplication)
  public
    procedure ShowException(E: Exception);
  end;

var
  FShowExceptionForm: boolean;
  FHideModules: TStringList;
  FExceptAddr: Pointer;
  frm: TForm;
  mem: TMemo;
  lbl: TLabel;
  pnlBottom: TPanel;
  btnExpand: TButton;
  FOldAddress: Pointer;


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

procedure Show_Exception(E: Exception);
begin
end;


procedure ShowExceptionForm(Show: boolean);
begin
  FShowExceptionForm:= Show;

  if Show then
  begin
    FOldAddress:= @TApplication.ShowException;
    RedirectProcedure(@TApplication.ShowException,@Show_Exception);
  end else
  begin
    RedirectProcedure(@TApplication.ShowException,@TSubApplication.ShowException);
  end;
end;

procedure ShowForm(ErrorInfo: TStringList; ErrMsg: string);
begin
  mem.Clear;
  mem.Lines.AddStrings(ErrorInfo);
  lbl.Caption:= ErrMsg;
  {$IFDEF MSWINDOWS}
    MessageBeep(MB_ICONERROR);
  {$ENDIF}
  frm.ShowModal;
end;

procedure Expand(Sender: TObject);
begin
  if pnlBottom.Height = 42 then
  begin
    pnlBottom.Height:= 200;
    frm.Height:= frm.Height + 160;
    frm.Constraints.MinHeight:= 170 + 160;
    frm.Constraints.MaxHeight:= frm.Height;
    btnExpand.Caption:= 'Details <<';
  end else
  begin
    pnlBottom.Height:= 42;
    frm.Constraints.MinHeight:= 170;
    frm.Height:= frm.Height - 160;
    frm.Constraints.MaxHeight:= frm.Height + 160;
    btnExpand.Caption:= 'Details >>';
  end;
end;

procedure CreateForm;
var
  Method: TMethod;
  btnOK: TButton;
  Image: TImage;
  Ico: TIcon;
  pnlMemo: TPanel;
  pnlButton: TPanel;
begin
  frm:= TForm.Create(nil);

  frm.Width:= 400;
  frm.Height:= 170;
  frm.Caption:= 'Îøèáêà';
  frm.Position:= poScreenCenter;
  frm.Caption:= Application.Title;
  frm.Icon:= Application.Icon;
  frm.BorderIcons:= [biSystemMenu];
  frm.Color:= clWindow;
  frm.Constraints.MinHeight:= 170;
  frm.Constraints.MinWidth:= 400;
  frm.Constraints.MaxWidth:= 600;
  frm.Constraints.MaxHeight:= frm.Height + 160;

  Image:= TImage.Create(frm);
  Image.Parent:= frm;
  Image.Width:= 32;
  Image.Height:= 32;
  Image.Left:= 16;
  Image.Top:= 16;

  lbl:= TLabel.Create(frm);
  lbl.Parent:= frm;
  lbl.Align:= alClient;
  lbl.AutoSize:= false;
  lbl.WordWrap:= true;
  lbl.AlignWithMargins:= true;
  lbl.Margins.Left:= 64;
  lbl.Margins.Top:= 16;
  lbl.Margins.Right:= 4;
  lbl.Margins.Bottom:= 0;
  lbl.EllipsisPosition:= epEndEllipsis;

  pnlBottom:= TPanel.Create(frm);
  pnlBottom.Parent:= frm;
  pnlBottom.Align:= alBottom;
  pnlBottom.Height:= 42;
  pnlBottom.BevelOuter:= bvNone;
  pnlBottom.ParentColor:= false;
  pnlBottom.Color:= clBtnFace;

  pnlButton:= TPanel.Create(frm);
  pnlButton.Parent:= pnlBottom;
  pnlButton.Align:= alBottom;
  pnlButton.Height:= 40;
  pnlButton.ParentColor:= false;
  pnlButton.ParentBackground:= false;
  pnlButton.Color:= clBtnFace;
  pnlButton.BevelOuter:= bvNone;

  pnlMemo:= TPanel.Create(frm);
  pnlMemo.Parent:= pnlBottom;
  pnlMemo.Align:= alClient;
  pnlMemo.BevelOuter:= bvNone;

  btnOK:= TButton.Create(frm);
  btnOK.Parent:= pnlButton;
  btnOK.Caption:= 'OK';
  btnOK.ModalResult:= mrOk;
  btnOK.Width:= 90;
  btnOK.Height:= 30;
  btnOK.Left:= pnlBottom.Width - btnOK.Width - 5;
  btnOK.Top:= 5;
  btnOK.Anchors:= [akRight,akBottom];

  btnExpand:= TButton.Create(frm);
  btnExpand.Parent:= pnlButton;
  btnExpand.Caption:= 'Details >>';
  btnExpand.ModalResult:= mrNone;
  btnExpand.Width:= 90;
  btnExpand.Height:= 30;
  btnExpand.Left:= 5;
  btnExpand.Top:= 5;
  btnExpand.Anchors:= [akLeft,akBottom];

  Method.Code:= @Expand;
  Method.Data:= btnExpand;
  btnExpand.OnClick:= TNotifyEvent(Method);

  mem:= TMemo.Create(frm);
  mem.Parent:= pnlMemo;
  mem.Align:= alClient;
  mem.Color:= clBtnFace;
  mem.ParentColor:= false;
  mem.ScrollBars:= ssBoth;
  mem.Font.Name:= 'Consolas';
  mem.Font.Size:= 9;
  mem.AlignWithMargins:= true;
  mem.Margins.Left:= 5;
  mem.Margins.Top:= 4;
  mem.Margins.Right:= 5;
  mem.Margins.Bottom:= 0;
  mem.Clear;

  {$IFDEF MSWINDOWS}
  Ico:= TIcon.Create;
  try
    Ico.Handle:= LoadIcon(0, IDI_ERROR);
    if Ico.Handle > 0 then
      Image.Picture.Assign(Ico);
  finally
    Ico.Free;
  end;
  {$ENDIF}
end;

function StrRepeat(const S: string; Count: Integer): string;
var
  Len, Index: Integer;
  Dest, Source: PChar;
begin
  Len := Length(S);
  SetLength(Result, Count * Len);
  Dest := PChar(Result);
  Source := PChar(S);
  if Dest <> nil then
    for Index := 0 to Count - 1 do
    begin
      Move(Source^, Dest^, Len * SizeOf(Char));
      Inc(Dest, Len);
    end;
end;

function StrEnsureSuffix(const Suffix, Text: string): string;
var
  SuffixLen: Integer;
begin
  SuffixLen := Length(Suffix);
  if Copy(Text, Length(Text) - SuffixLen + 1, SuffixLen) = Suffix then
    Result := Text
  else
    Result := Text + Suffix;
end;

procedure AnyExceptionNotify(ExceptObj: TObject; ExceptAddr: Pointer; OSException: Boolean);
var
  LogFile: textfile;
  Str: TStringList;
  s: string;
  slFile, slTemp: TStringList;
  slErrTemp: TStringList;
  I: Integer;
  J: Integer;
  FThreadID: DWORD;
  astr: AnsiString;
  ErrMsg: string;
begin
  ErrMsg:= 'Error';

  if (FExceptAddr = ExceptAddr) and (ExceptAddr <> nil) then Exit;

  if FErrorLogFullPath = '' then
    FErrorLogFullPath:= ExtractFilePath(Application.ExeName)+'Errors.log';

  Str := TStringList.Create;
  try
    FThreadID := MainThreadID;

    Str.Add(Format(sDetailsIntro, [DateTimeToStr(Now), Application.Title, Application.ExeName]));
    Str.Add(StrRepeat('-', 78));
    Str.Add(Format(sExceptionClass, [ExceptObj.ClassName]));

    if ExceptObj is Exception then
    begin
      astr:= Exception(ExceptObj).Message;
      ErrMsg:= astr;
      Str.Add(Format(sExceptionMessage, [StrEnsureSuffix('.', ErrMsg)]));
    end;

    Str.Add(Format(sExceptionAddr, [ExceptAddr]));
    Str.Add(StrRepeat('-', 78));

    Str.Add(sExceptionStack);
    Str.Add(Format(LoadResString(PResStringRec(@sStackList)), [DateTimeToStr(Now)]));

    if FHideModules.Count > 0 then
    begin
      slErrTemp:= TStringList.Create;
      try
        JclLastExceptStackListToStrings(slErrTemp, True, True, True, True);
        if slErrTemp.Count > 0 then
        begin
          for I := slErrTemp.Count - 1 downto 0 do
            for J := 0 to FHideModules.Count - 1 do
              if Pos('] '+FHideModules[J], slErrTemp[I]) > 0 then
              begin
                slErrTemp.Delete(I);
                Break;
              end;
          Str.AddStrings(slErrTemp);
        end;
      finally
        slErrTemp.Free;
      end;
    end else
      JclLastExceptStackListToStrings(Str, True, True, True, True);

    Str.Add(StrRepeat('-', 78));

    slFile:= TStringList.Create;
    try
      if FileExists(FErrorLogFullPath) then
      begin
        slFile.LoadFromFile(FErrorLogFullPath);
        slFile.Add(#13#10);
      end;
      slFile.AddStrings(Str);
      slFile.SaveToFile(FErrorLogFullPath);
    finally
      slFile.Free;
    end;

    if FShowExceptionForm then ShowForm(Str, ErrMsg);

  finally
    Str.Free;
  end;
end;

{ TSubApplication }

procedure TSubApplication.ShowException(E: Exception);
var
  Msg: string;
  SubE: Exception;
begin
  Msg := E.Message;
  while True do
  begin
    SubE := E.GetBaseException;
    if SubE <> E then
    begin
      E := SubE;
      if E.Message <> '' then
        Msg := E.Message;
    end
    else
      Break;
  end;
  if (Msg <> '') and (Msg[Length(Msg)] > '.') then Msg := Msg + '.';
{$IF DEFINED(CLR)}
  MessageBox(Msg, GetTitle,
{$ELSE}
  MessageBox(PChar(Msg), PChar(Application.Title),
{$ENDIF}
     MB_OK + MB_ICONSTOP);
end;

initialization
   FShowExceptionForm:= false;
   FErrorLogFullPath:= '';
   FExceptAddr:= nil;
   FHideModules:= TStringList.Create;
   FHideModules.Text:= 'VirtualTrees'+#13+#10+
                       'Vcl'+#13+#10+
                       'System'+#13+#10+
                       'Windows'+#13+#10+
                       'JclDebug'+#13+#10+
                       'JclHookExcept'+#13+#10+
                       'Data'+#13+#10+
                       'Logger'+#13+#10+
                       'OML'+#13+#10+
                       'xml';
   CreateForm;

   JclStackTrackingOptions := JclStackTrackingOptions + [stRawMode];
   JclStackTrackingOptions := JclStackTrackingOptions + [stDelayedTrace];
   JclStartExceptionTracking;
   JclAddExceptNotifier(AnyExceptionNotify);

finalization
   JclStopExceptionTracking;
   FHideModules.Free;
   FreeAndNil(frm);

end.
