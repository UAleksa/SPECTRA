unit SPECTRA.Logger;

interface

uses
  {$IF NOT DECLARED(FireMonkeyVersion)}
    Vcl.StdCtrls,
  {$ELSE}
    FMX.Memo,
  {$IFEND}
  SPECTRA.Consts, SPECTRA.Messages, System.SysUtils, SPECTRA.List;

const
  CM_LOG = WM_USER + 1;

type
  TLogMsgType = (mtNone, mtError, mtInfo, mtWarning);

  TLogAppender = class abstract
  public
    procedure DoLog(const LogMsg: string); virtual; abstract;
  end;

  ILogger = interface
  //private
    function GetLogDescriptor: NativeUInt;
    procedure InnerLog(LogMsgType: TLogMsgType; const LogMsg: string);
    function GetAppenders: IList<TLogAppender>;
  //public
    procedure Text(const LogMsg: string); overload;
    procedure Text(const LogMsg: string; const Args: array of const); overload;

    procedure Error(const LogMsg: string); overload;
    procedure Error(const LogMsg: string; const Args: array of const); overload;

    procedure Info(const LogMsg: string); overload;
    procedure Info(const LogMsg: string; const Args: array of const); overload;

    procedure Warning(const LogMsg: string); overload;
    procedure Warning(const LogMsg: string; const Args: array of const); overload;

    property Appenders: IList<TLogAppender> read GetAppenders;
    property LogDescriptor: NativeUInt read GetLogDescriptor;
  end;

  TLogMsg = record
    Msg: string;
    MsgType: TLogMsgType;

    constructor Create(const aMsg: string; const aMsgType: TLogMsgType = mtNone); overload;
    constructor Create(const aMsgFmt: string; const Args: array of const;
      const aMsgType: TLogMsgType = mtNone); overload;
  end;

  TFileAppender = class(TLogAppender)
  private
    FFileName: string;
    FClearLinesCount: Integer;
  public
    constructor Create(const FileName: string);

    procedure DoLog(const LogMsg: string); override;

    property ClearLinesCount: Integer read FClearLinesCount write FClearLinesCount;
  end;

  TMemoAppender = class(TLogAppender)
  private
    FMemo: TMemo;
    FClearLinesCount: Integer;
  public
    constructor Create(Memo: TMemo);
    destructor Destroy; override;

    procedure DoLog(const LogMsg: string); override;

    property ClearLinesCount: Integer read FClearLinesCount write FClearLinesCount;
  end;

  TDebugAppender = class(TLogAppender)
  public
    procedure DoLog(const LogMsg: string); override;
  end;

  TLogger = class
  private const
    cTimeFormat = 'hh:nn:ss:zzz';
  private
    FLogDescriptor: NativeUInt;
    FMsgSubscribe: NativeUInt;
    FAppenders: IList<TLogAppender>;
    FTimeStamp: boolean;

    function GetLogDescriptor: NativeUInt;
    procedure InnerLog(LogMsgType: TLogMsgType; const LogMsg: string);
    function GetAppenders: IList<TLogAppender>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Text(const LogMsg: string); overload;
    procedure Text(const LogMsg: string; const Args: array of const); overload;

    procedure Error(const LogMsg: string); overload;
    procedure Error(const LogMsg: string; const Args: array of const); overload;

    procedure Info(const LogMsg: string); overload;
    procedure Info(const LogMsg: string; const Args: array of const); overload;

    procedure Warning(const LogMsg: string); overload;
    procedure Warning(const LogMsg: string; const Args: array of const); overload;

    property Appenders: IList<TLogAppender> read GetAppenders;
    property LogDescriptor: NativeUInt read GetLogDescriptor;
    property TimeStamp: boolean read FTimeStamp write FTimeStamp;
  end;

  E_SPECTRA_LoggerException = class(Exception);

implementation

uses
  System.Classes, Winapi.Windows;

var
  vLogMsgType: array [TLogMsgType] of string = ('',
                                                'ERROR:',
                                                'INFO:',
                                                'WARNING:'
                                               );

{ TLog }

constructor TLogger.Create;
begin
  FTimeStamp:= true;
  FMsgSubscribe:= 0;
  FLogDescriptor:= 0;
  FAppenders:= TList<TLogAppender>.Create;
end;

destructor TLogger.Destroy;
begin
  FAppenders.Clear(
    procedure(Item: TLogAppender)
    begin
      Item.Free;
    end);
  Msgs.UnSubscribe(FMsgSubscribe);

  inherited;
end;

procedure TLogger.Error(const LogMsg: string; const Args: array of const);
begin
  InnerLog(mtError, Format(LogMsg,Args));
end;

procedure TLogger.Error(const LogMsg: string);
begin
  InnerLog(mtError, LogMsg);
end;

function TLogger.GetAppenders: IList<TLogAppender>;
begin
  Result:= FAppenders;
end;

function TLogger.GetLogDescriptor: NativeUInt;
begin
  if FLogDescriptor = 0 then
  begin
    FLogDescriptor:= Self.GetHashCode;
    FMsgSubscribe:= Msgs.SubscribeDesc(FLogDescriptor,
      function(const MessageID: NativeUInt; const Msg: TMessage): NativeInt
      begin
        if MessageID = CM_LOG then
          if Msg is TMessage<TLogMsg> then
            InnerLog(TMessage<TLogMsg>(Msg).Value.MsgType, TMessage<TLogMsg>(Msg).Value.Msg);
      end);
  end;
  Result:= FLogDescriptor;
end;

procedure TLogger.Info(const LogMsg: string);
begin
  InnerLog(mtInfo, LogMsg);
end;

procedure TLogger.Info(const LogMsg: string; const Args: array of const);
begin
  InnerLog(mtInfo, Format(LogMsg,Args));
end;

procedure TLogger.InnerLog(LogMsgType: TLogMsgType; const LogMsg: string);
var
  sTime: string;
  sLogMsg: string;
  Appender: TLogAppender;
begin
  if FAppenders.IsEmpty then
    raise E_SPECTRA_LoggerException.CreateRes(@sAppendersListEmpty);

  sTime:= '';

  if FTimeStamp then
    sTime:= FormatDateTime(cTimeFormat, Now) + ' ';

  if LogMsgType = mtNone then
    sLogMsg:= sTime + LogMsg
  else
    sLogMsg:= vLogMsgType[LogMsgType] + sLineBreak + sTime + LogMsg;

  for Appender in FAppenders do
    Appender.DoLog(sLogMsg);
end;

procedure TLogger.Text(const LogMsg: string);
begin
  InnerLog(mtNone, LogMsg);
end;

procedure TLogger.Text(const LogMsg: string; const Args: array of const);
begin
  InnerLog(mtNone, Format(LogMsg,Args));
end;

procedure TLogger.Warning(const LogMsg: string; const Args: array of const);
begin
  InnerLog(mtWarning, Format(LogMsg,Args));
end;

procedure TLogger.Warning(const LogMsg: string);
begin
  InnerLog(mtWarning, LogMsg);
end;

{ TLogMsg }

constructor TLogMsg.Create(const aMsgFmt: string; const Args: array of const;
  const aMsgType: TLogMsgType);
begin
  Msg:= Format(aMsgFmt,Args);
  MsgType:= aMsgType;
end;

constructor TLogMsg.Create(const aMsg: string; const aMsgType: TLogMsgType);
begin
  Msg:= aMsg;
  MsgType:= aMsgType;
end;

{ TFileAppender }

constructor TFileAppender.Create(const FileName: string);
begin
  FFileName:= FileName;
  FClearLinesCount:= 0;
end;

procedure TFileAppender.DoLog(const LogMsg: string);
var
  slLog: TStringList;
begin
  slLog:= TStringList.Create;
  try
    if FileExists(FFileName) then
      slLog.LoadFromFile(FFileName);

    if FClearLinesCount > 0 then
      if slLog.Count >= FClearLinesCount then
        slLog.Clear;

    slLog.Add(LogMsg);
    slLog.SaveToFile(FFileName);
  finally
    slLog.Free;
  end;
end;

{ TMemeAppender }

constructor TMemoAppender.Create(Memo: TMemo);
begin
  FClearLinesCount:= 0;
  FMemo:= Memo;
end;

destructor TMemoAppender.Destroy;
begin
  FMemo:= nil;

  inherited;
end;

procedure TMemoAppender.DoLog(const LogMsg: string);
begin
  if FClearLinesCount > 0 then
    if FMemo.Lines.Count >= FClearLinesCount then
      FMemo.Lines.Clear;

  FMemo.Lines.Add(LogMsg);
end;

{ TDebugAppender }

procedure TDebugAppender.DoLog(const LogMsg: string);
begin
{$IFDEF MSWINDOWS}
  OutputDebugString(PChar(LogMsg));
{$ENDIF}
end;

end.
