unit SPECTRA.Async;

interface

uses
  {$IFDEF MSWINDOWS}
  Vcl.ExtCtrls,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Messaging, SPECTRA.Messages, System.Classes,
  System.Threading, System.Types, System.SyncObjs;

type
  TAsync = class;

  TAsyncMain = class(TObject)
  strict private
    type
      TMsg = record
        FAsyncProc: TProc;
        FAwaitProc: TProc;
        IsWorking: boolean;
        FMsgID: NativeUInt;
      end;
  strict private
    FStart: boolean;
    FAsyncProc: TProc;
    FAwaitProc: TProc;
    IsWorking: boolean;
    FSubID: NativeUInt;
    FMsgID: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Async_Invoke(const AsyncProc: TProc; AwaitProc: TProc);
  end;

  IAsync = interface
  ['{C6AFD1EC-7D91-4BFE-AF95-E948BA87BDAE}']
    function Done(AwaitProc: TProc): IAsync; overload;
    {$IFDEF MSWINDOWS}
    function Await: IAsync;
    {$ENDIF MSWINDOWS}
    procedure Run;
    procedure RunMain;
  end;

  TAsync = class(TInterfacedObject, IAsync)
  strict private
    FAsyncMain: TAsyncMain;
    FAsyncProc: TProc;
    FAwaitProc: TProc;
    FAwait: boolean;
    FWorkingThread: TThread;

    procedure WaitFor;
  protected
    function Done(AwaitProc: TProc): IAsync;
    {$IFDEF MSWINDOWS}
    function Await: IAsync;
    {$ENDIF MSWINDOWS}

    constructor Create(AsyncProc: TProc);
    destructor Destroy; override;
  public
    procedure Run;
    procedure RunMain;
  end;

  TWorkMsgBase = class abstract;
  TWorkMsg = TWorkMsgBase;

  TWorkMsg<T> = class(TWorkMsg)
  protected
    FValue: T;
  public
    constructor Create(const AValue: T);
    destructor Destroy; override;
    property Value: T read FValue;
  end;

  TWorkerState = (wsCreated, wsWaitingToRun, wsRunning, wsComplete, wsCanceled);

  IWorkerReport = interface
  ['{216D4CA1-20EF-4F37-85FA-77C6E1309EFD}']
  //private
    function GetState: TWorkerState;
  //public
    procedure ReportProgress(PercentDone: NativeUInt; Wait: boolean=false);
    procedure ReportFeedback(FeedbackID: NativeInt; FeedbackValue: TWorkMsg;
      Wait: boolean=false);
    procedure Synchronize(Method: TProc);

    property State: TWorkerState read GetState;
  end;

  TWorkMethod = reference to procedure(Worker: IWorkerReport);
  TWorkProgressMethod = reference to procedure(PercentDone: NativeUInt);
  TWorkCompleteMethod = reference to procedure(Cancelled: Boolean);
  TWorkFeedbackMethod = reference to procedure(FeedbackID: NativeInt; FeedbackValue: TWorkMsg);

  IWorker = interface
  ['{93601A52-9780-4EA1-84F5-5F5EE60D1A05}']
  //private
    function GetWorking: boolean;
    function GetThreadID: NativeUInt;
  //public
    procedure Cancel;
    procedure CleanUp;

    function Work(WorkProc: TWorkMethod): IWorker;
    function Progress(ProgressProc: TWorkProgressMethod): IWorker;
    function Complete(CompleteProc: TWorkCompleteMethod): IWorker;
    function Feedback(FeedbackProc: TWorkFeedbackMethod): IWorker;

    procedure Start;
    procedure WaitFor;

    property IsWorking: Boolean read GetWorking;
    property ThreadID: NativeUInt read GetThreadID;
  end;

  TWorker = class(TComponent, IWorker, IWorkerReport)
  private
    type
       TWorkerThread = class(TThread)
      private
        FWorker: IWorkerReport;
        FProc: TWorkMethod;
      protected
        procedure Execute; override;
      public
        constructor Create(const aProc: TWorkMethod; aWorker: TWorker);
      end;
  private
    FMsgID: Integer;
    FState: TWorkerState;
    FSubID: NativeUInt;
    FThread: TWorkerThread;
    FWorkMethod: TWorkMethod;
    FWorkProgressMethod: TWorkProgressMethod;
    FWorkCompleteMethod: TWorkCompleteMethod;
    FWorkFeedbackMethod: TWorkFeedbackMethod;
    {$IFDEF MSWINDOWS}
    FPriority: TThreadPriority;
    {$ENDIF MSWINDOWS}

    function GetState: TWorkerState;
    function GetWorking: boolean;
    function GetThreadID: NativeUInt;
    function CallBack(const MessageID: NativeUInt; const Msg: TMessage): NativeInt;
    procedure ThreadTerminate(Sender: TObject);
  protected
    procedure ReportProgress(PercentDone: NativeUInt; Wait: boolean=false);
    procedure ReportFeedback(FeedbackID: NativeInt; FeedbackValue: TWorkMsg;
      Wait: boolean=false);
    procedure Synchronize(Method: TProc);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CleanUp;

    function Work(WorkProc: TWorkMethod): IWorker;
    function Progress(ProgressProc: TWorkProgressMethod): IWorker;
    function Complete(CompleteProc: TWorkCompleteMethod): IWorker;
    function Feedback(FeedbackProc: TWorkFeedbackMethod): IWorker;

    procedure Cancel;
    procedure Start;
    procedure WaitFor;

    property IsWorking: Boolean read GetWorking;
    {$IFDEF MSWINDOWS}
    property Priority: TThreadPriority read FPriority write FPriority;
    {$ENDIF MSWINDOWS}
    property State: TWorkerState read GetState;
    property ThreadID: NativeUInt read GetThreadID;
  end;

  E_SPECTRA_WorkerException = class(Exception);

  function Async(AsyncProc: TProc): IAsync;

implementation

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Vcl.Forms,
  {$ENDIF MSWINDOWS}
  SPECTRA.Helpers, SPECTRA.GC, SPECTRA.Collections, FMX.Dialogs,
  SPECTRA.Consts;

const
  CM_ASYNC_START = WM_USER + 1;
  CM_ASYNC_END = WM_USER + 2;
  CM_ASYNC_FREE = WM_USER + 3;

  CM_WORKER_PROGRESS = WM_USER + 10;
  CM_WORKER_PROGRESS_WAIT  = WM_USER + 11;
  CM_WORKER_FEEDBACK = WM_USER + 12;
  CM_WORKER_FEEDBACK_WAIT = WM_USER + 13;
  CM_WORKER_COMPLETE = WM_USER + 14;


function Async(AsyncProc: TProc): IAsync;
begin
  Result:= TAsync.Create(AsyncProc);
end;

{ TAsyncMain }

procedure TAsyncMain.Async_Invoke(const AsyncProc: TProc;
  AwaitProc: TProc);
var
  Msg: TMsg;
begin
  if not IsWorking and Assigned(AsyncProc) and FStart then
  begin
    FAsyncProc:= AsyncProc;
    FAwaitProc:= AwaitProc;
    IsWorking:= true;

    FMsgID:= Msgs.GetHashCode(Self);
    FSubID:= Msgs.SubscribeDesc(FMsgID,
      function (const MessageID: NativeUInt; const Msg: TMessage): NativeInt
      var
        aAsyncProc: TProc;
        aAwaitProc: TProc;
      begin
        case MessageID of
          CM_ASYNC_START:
              begin
                if not (Msg is TMessage<TMsg>) then Exit;

                aAsyncProc:= (Msg as TMessage<TMsg>).Value.FAsyncProc;
                if Assigned(aAsyncProc) then
                begin
                  FStart:= false;
                  try
                    aAsyncProc;
                  finally
                    aAsyncProc:= nil;
                  end;

                  aAwaitProc:= (Msg as TMessage<TMsg>).Value.FAwaitProc;
                  if Assigned(aAwaitProc) then
                    Msgs.PostMessage((Msg as TMessage<TMsg>).Value.FMsgID, CM_ASYNC_END, Msg)
                  else
                  begin
                    IsWorking:= false;
                    Msgs.PostMessage((Msg as TMessage<TMsg>).Value.FMsgID, CM_ASYNC_FREE, 0, 0);
                  end;
                end;
              end;
          CM_ASYNC_END:
              begin
                if not (Msg is TMessage<TMsg>) then Exit;

                try
                  aAwaitProc;
                  IsWorking:= false;
                  Msgs.PostMessage((Msg as TMessage<TMsg>).Value.FMsgID, CM_ASYNC_FREE, 0, 0);
                finally
                  aAwaitProc:= nil;
                end;
              end;
          CM_ASYNC_FREE:
              Msgs.UnSubscribeDecs(FMsgID);
        end;
      end);

    Msg.FAsyncProc:= FAsyncProc;
    Msg.FAwaitProc:= FAwaitProc;
    Msg.IsWorking:= IsWorking;
    Msg.FMsgID:= FMsgID;

    Msgs.PostMessage(FMsgID, CM_ASYNC_START, TMessage<TMsg>.Create(Msg,0));
  end;
end;

constructor TAsyncMain.Create;
begin
  FStart:= true;
  FAsyncProc:= nil;
  FAwaitProc:= nil;
  IsWorking:= false;
end;

destructor TAsyncMain.Destroy;
begin

  inherited;
end;

{ TAsync }

{$IFDEF MSWINDOWS}
function TAsync.Await: IAsync;
begin
  FAwait:= true;
  Result:= Self;
end;
{$ENDIF MSWINDOWS}

constructor TAsync.Create(AsyncProc: TProc);
begin
  FAsyncMain:= nil;
  FAwait:= false;
  FAsyncProc:= AsyncProc;
end;

destructor TAsync.Destroy;
begin
  FAsyncProc:= nil;
  FAwaitProc:= nil;
  if Assigned(FAsyncMain) then FreeAndNil(FAsyncMain);

  inherited;
end;

function TAsync.Done(AwaitProc: TProc): IAsync;
begin
  FAwaitProc:= AwaitProc;
  Result:= Self;
end;

procedure TAsync.Run;
var
  Tasks: TArray<ITask>;
  I: Integer;
  AwaitProc: TProc;
  AsyncProc: TProc;
  Proc: TProc;
begin
  if not FAwait then
  begin
    if not Assigned(FAwaitProc) then
    begin
      FWorkingThread:= TThread.CreateAnonymousThread(FAsyncProc);
      FWorkingThread.Start;
    end else
    begin
      AwaitProc:= FAwaitProc;
      AsyncProc:= FAsyncProc;

      Proc:= procedure
             var
               LocThread: TThread;
             begin
               AsyncProc;

               LocThread:= FWorkingThread;
               LocThread.Queue(nil,
                 procedure
                 begin
                   AwaitProc
                 end);
             end;

      FWorkingThread:= TThread.CreateAnonymousThread(Proc);
      FWorkingThread.Start;

//      TTask.Run(
//        procedure
//        begin
//          AsyncProc;
//
//          TThread.Queue(nil,
//            procedure
//            begin
//              AwaitProc;
//            end);
//        end);
    end;
  end else
  begin
    FWorkingThread:= TThread.CreateAnonymousThread(FAsyncProc);
    FWorkingThread.Start;
    if FAwait then WaitFor;
    if Assigned(FAwaitProc) then
      FAwaitProc;
  end;
end;

procedure TAsync.RunMain;
begin
  FAsyncMain:= TAsyncMain.Create;
  FAsyncMain.Async_Invoke(FAsyncProc, FAwaitProc);
end;

procedure TAsync.WaitFor;
begin
{$IFDEF ANDROID}
  raise E_SPECTRA_Worker.CreateRes(@sWaitNotRealized);
{$ENDIF ANDROID}

{$IFDEF MSWINDOWS}
  while not FWorkingThread.Started do
  begin
    Sleep(10);
    Application.ProcessMessages;
  end;

  while not FWorkingThread.Finished do
  begin
    Sleep(10);
    Application.ProcessMessages;
  end;
{$ENDIF MSWINDOWS}
end;

{ TWorker }

function TWorker.CallBack(const MessageID: NativeUInt;
  const Msg: TMessage): NativeInt;
begin
  case MessageID of
    CM_WORKER_PROGRESS,
    CM_WORKER_PROGRESS_WAIT:
        begin
          if Assigned(FWorkProgressMethod) then
            FWorkProgressMethod((Msg as TMessage<NativeUInt>).Value);
        end;
    CM_WORKER_FEEDBACK,
    CM_WORKER_FEEDBACK_WAIT:
        begin
          if Assigned(FWorkFeedbackMethod) then
          try
            FWorkFeedbackMethod((Msg as TMessage<TWorkMsg>).Param,
                                (Msg as TMessage<TWorkMsg>).Value)
          finally
            (Msg as TMessage<TWorkMsg>).Value.Free;
          end;
        end;
    CM_WORKER_COMPLETE:
        begin
          if Assigned(FWorkCompleteMethod) then
            FWorkCompleteMethod(FState = wsCanceled);
          CleanUp;
          FState:= wsComplete;
        end;
  end;
end;

procedure TWorker.Cancel;
begin
  if IsWorking then
    FState:= wsCanceled;
end;

procedure TWorker.CleanUp;
begin
  if IsWorking then
  begin
    FThread.Terminate;
    repeat
    until FThread.Finished;
  end;

  if Assigned(FThread) then
  begin
    FThread.Free;
    FThread:= nil;
  end;

  Msgs.UnSubscribe(FSubID,true);
end;

function TWorker.Complete(CompleteProc: TWorkCompleteMethod): IWorker;
begin
  FWorkCompleteMethod:= CompleteProc;
  Result:= Self;
end;

constructor TWorker.Create(AOwner: TComponent);
begin
  FThread:= nil;
  FSubID:= 0;
  FMsgID:= 0;
  FState:= wsCreated;
  {$IFDEF MSWINDOWS}
  FPriority:= tpNormal;
  {$ENDIF MSWINDOWS}
end;

destructor TWorker.Destroy;
begin
  CleanUp;
  inherited;
end;

function TWorker.Feedback(FeedbackProc: TWorkFeedbackMethod): IWorker;
begin
  FWorkFeedbackMethod:= FeedbackProc;
  Result:= Self;
end;

function TWorker.GetState: TWorkerState;
begin
  Result:= FState;
end;

function TWorker.GetThreadID: NativeUInt;
begin
  Result:= 0;
  if not Assigned(FThread) then Exit;
  Result:= FThread.ThreadID;
end;

function TWorker.GetWorking: boolean;
begin
  Result:= false;

  if not Assigned(FThread) then Exit;
  Result:= FThread.Started and not FThread.Finished;
end;

function TWorker.Progress(ProgressProc: TWorkProgressMethod): IWorker;
begin
  FWorkProgressMethod:= ProgressProc;
  Result:= Self;
end;

procedure TWorker.ReportFeedback(FeedbackID: NativeInt;
  FeedbackValue: TWorkMsg; Wait: boolean);
begin
  if Wait then
    FThread.Synchronize(nil,
      procedure
      begin
        Msgs.SendMessage<TWorkMsg>(FMsgID, CM_WORKER_FEEDBACK_WAIT, FeedbackValue, FeedbackID);
      end)
  else
    Msgs.PostMessage<TWorkMsg>(FMsgID, CM_WORKER_FEEDBACK, FeedbackValue, FeedbackID);
end;

procedure TWorker.ReportProgress(PercentDone: NativeUInt; Wait: boolean);
begin
  if Wait then
    FThread.Synchronize(nil,
      procedure
      begin
        Msgs.SendMessage(FMsgID, CM_WORKER_PROGRESS_WAIT, PercentDone, 0)
      end)
  else
    Msgs.PostMessage(FMsgID, CM_WORKER_PROGRESS, PercentDone, 0);
end;

procedure TWorker.Start;
begin
  if not IsWorking then
  begin
    FMsgID:= Msgs.GetHashCode(Self);
    FSubID:= Msgs.SubscribeDesc(FMsgID, CallBack);

    if Assigned(FWorkMethod) then
    begin
      FThread:= TWorkerThread.Create(FWorkMethod, Self);
      FThread.OnTerminate:= ThreadTerminate;
      FState:= wsRunning;
      FThread.Start;
    end else
      raise E_SPECTRA_WorkerException.CreateResFmt(@sWorkIsNil,[Name]);
  end else
    raise E_SPECTRA_WorkerException.CreateResFmt(@sInvalidStart,[Name]);
end;

procedure TWorker.Synchronize(Method: TProc);
begin
  FThread.Synchronize(nil,
    procedure
    begin
      Method;
    end)
end;

procedure TWorker.ThreadTerminate(Sender: TObject);
begin
  Msgs.PostMessage(FMsgID, CM_WORKER_COMPLETE, 0, 0);
end;

procedure TWorker.WaitFor;
begin
{$IFDEF ANDROID}
  raise E_SPECTRA_Worker.CreateRes(@sWaitNotRealized);
{$ENDIF ANDROID}

{$IFDEF MSWINDOWS}
  while IsWorking do
  begin
    Sleep(10);
    Application.ProcessMessages;
  end;
{$ENDIF MSWINDOWS}
end;

function TWorker.Work(WorkProc: TWorkMethod): IWorker;
begin
  FWorkMethod:= WorkProc;
  if Assigned(FWorkMethod) then FState:= wsWaitingToRun;
  Result:= Self;
end;

{ TWorkMsg<T> }

constructor TWorkMsg<T>.Create(const AValue: T);
begin
  FValue := AValue;
end;

destructor TWorkMsg<T>.Destroy;
begin

  inherited;
end;

{ TWorker.TWorkerThread }

constructor TWorker.TWorkerThread.Create(const aProc: TWorkMethod;
  aWorker: TWorker);
begin
  inherited Create(True);
  {$IFDEF MSWINDOWS}
  Priority:= aWorker.Priority;
  {$ENDIF MSWINDOWS}
  FWorker:= aWorker as IWorkerReport;
  FProc:= aProc;
end;

procedure TWorker.TWorkerThread.Execute;
begin
  inherited;
  FProc(FWorker);
end;

end.
