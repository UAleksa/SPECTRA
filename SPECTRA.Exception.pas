unit SPECTRA.Exception;

interface

uses
  {$IFDEF MSWINDOWS}
    Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
      {$IF NOT DECLARED(FireMonkeyVersion)}
        Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
      {$ENDIF}
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Variants, System.Classes;


  {$IFDEF MSWINDOWS}
  procedure ShowExceptionForm(Show: boolean);
  {$ENDIF MSWINDOWS}
  procedure ErrorLog(Enabled: boolean);

var
  FErrorLogFullPath: string;

implementation

uses
  SPECTRA.Consts, SPECTRA.Detour, JclHookExcept, JclDebug;

{$IFDEF MSWINDOWS}
type
  TSubApplication = class(TApplication)
  public
    procedure ShowException(E: Exception);
  end;
{$ENDIF MSWINDOWS}

var
  FHideModules: TStringList;
  FExceptAddr: Pointer;
  ErrorLogEnabled: boolean;
{$IFDEF MSWINDOWS}
  FShowExceptionForm: boolean;
  frm: TForm;
  mem: TMemo;
  lbl: TLabel;
  pnlBottom: TPanel;
  btnExpand: TLabel; //TButton;
{$ENDIF MSWINDOWS}

procedure ErrorLog(Enabled: boolean);
begin
  ErrorLogEnabled:= Enabled;
end;

procedure Show_Exception(E: Exception);
begin
end;

procedure ShowExceptionForm(Show: boolean);
begin
  FShowExceptionForm:= Show;

  if Show then
    RedirectProcedure(@TApplication.ShowException,@Show_Exception)
  else
    RedirectProcedure(@TApplication.ShowException,@TSubApplication.ShowException);
end;

{$IFDEF MSWINDOWS}
const
  cHgt = 240;

procedure Expand(Sender: TObject);
var
  dlg: TSaveDialog;
begin
  if pnlBottom.Height = 42 then
  begin
    pnlBottom.Height:= 280;
    frm.Height:= frm.Height + cHgt;
    frm.Constraints.MinHeight:= 170 + cHgt;
    frm.Constraints.MaxHeight:= frm.Height;
    frm.Width:= frm.Width + 200;
    btnExpand.Caption:= 'Сохранить отчет';  //<<
  end else
  begin
    dlg:= TSaveDialog.Create(nil);
    try
      dlg.Filter:= 'Text files (*.txt)|*.txt';
      dlg.DefaultExt:= '.txt';
      dlg.FileName:= 'Отчет об ошибке';
      if dlg.Execute() then
        if dlg.FileName <> '' then
          mem.Lines.SaveToFile(dlg.FileName);

      frm.BringToFront;
    finally
      dlg.Free;
    end;
  end;
end;

procedure ShowForm(ErrorInfo: TStringList; ErrMsg: string);
begin
  if pnlBottom.Height <> 42 then  //Expand(nil); //btnExpand.Click;
  begin
    pnlBottom.Height:= 42;
    frm.Constraints.MinHeight:= 170;
    frm.Height:= frm.Height - cHgt;
    frm.Constraints.MaxHeight:= frm.Height + 160;
    frm.Width:= frm.Width - 200;
    btnExpand.Caption:= 'Отчет';  //>>
  end;

  frm.Width:= 400;
  frm.Height:= 170;
  frm.Constraints.MinHeight:= 170;
  frm.Constraints.MinWidth:= 400;
  frm.Constraints.MaxWidth:= 600;
  frm.Constraints.MaxHeight:= frm.Height + 160;
  mem.Clear;
  mem.Lines.AddStrings(ErrorInfo);
  lbl.Caption:= ErrMsg;

  MessageBeep(MB_ICONERROR);
  frm.ShowModal;
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
  frm.Position:= poScreenCenter;
  frm.Caption:= Application.Title;
  frm.Icon:= Application.Icon;
//  frm.BorderIcons:= [biSystemMenu];
  frm.BorderStyle:= bsDialog;
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

  btnExpand:= TLabel.Create(frm); //TButton.Create(frm);
  btnExpand.Parent:= pnlButton;
  btnExpand.Caption:= 'Отчет';
  //btnExpand.ModalResult:= mrNone;
//  btnExpand.Width:= 90;
//  btnExpand.Height:= 30;
  btnExpand.Left:= 5;
  btnExpand.Top:= 14; //5;
  btnExpand.Anchors:= [akLeft,akBottom];
  btnExpand.Font.Color:= clBlue;
  btnExpand.Font.Style:= [fsUnderline];
  btnExpand.Cursor:= crHandPoint;

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

  Ico:= TIcon.Create;
  try
    Ico.Handle:= LoadIcon(0, IDI_ERROR);
    if Ico.Handle > 0 then
      Image.Picture.Assign(Ico);
  finally
    Ico.Free;
  end;
end;
{$ENDIF MSWINDOWS}


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

  if not FShowExceptionForm and not ErrorLogEnabled then Exit;

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

    if ErrorLogEnabled then
    begin
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
    end;

   {$IF NOT DECLARED(FireMonkeyVersion)}
     {$IFDEF MSWINDOWS}
       if FShowExceptionForm then ShowForm(Str, ErrMsg);
     {$ENDIF MSWINDOWS}
   {$ENDIF}
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
  MessageBox(Msg, Application.Title,
{$ELSE}
  MessageBox(PChar(Msg), PChar(Application.Title),
{$ENDIF}
     MB_OK + MB_ICONSTOP);
end;

initialization
   ErrorLogEnabled:= true;
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
                       'FireDAC'+#13+#10+
                       'FMX'+#13+#10+
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
