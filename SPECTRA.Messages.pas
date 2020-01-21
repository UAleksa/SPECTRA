unit SPECTRA.Messages;

interface

uses
  {$IFDEF MSWINDOWS}
  Vcl.ExtCtrls,
  {$ELSE}
  FMX.Types,
  {$ENDIF MSWINDOWS}
  System.Classes, SPECTRA.Collections,
  System.SysUtils;

type
  TMessageBase = class abstract;
  TMessage = TMessageBase;

  TMessage<T> = class(TMessage)
  protected
    FParam: NativeInt;
    FValue: T;
  public
    constructor Create(const Value: T; const Param: NativeInt);
    destructor Destroy; override;

    property Param: NativeInt read FParam;
    property Value: T read FValue;
  end;

  TMessageFunc = reference to function(const MessageID: NativeUInt; const Msg: TMessage): NativeInt;

  TMessages = class
  private type
    TListener = record
      FID: NativeUInt;
      FDescriptor: NativeUInt;
      FMessageID: NativeUInt;
      FMessageClass: TClass;
      FSender: NativeInt;
      FThread: TThread;
      FMessageMethod: TMessageFunc;
    public
      constructor Create(const Descriptor, MessageID: NativeUInt; const MessageMethod: TMessageFunc); overload;
      constructor Create(const Sender: TObject; const aMessageClass: TClass; const MessageMethod: TMessageFunc); overload;
      constructor Create(const Sender: TObject; const MessageID: NativeUInt; const MessageMethod: TMessageFunc); overload;

      procedure Init;
    end;

    TMessageCount = record
    strict private
      FMessage: TMessage;
      FProcs: TArray<TProc>;

      function GetCount: Integer;
    public
      FDescriptor, FMsgID: NativeUInt;

      constructor Create(aMessage: TMessage; Proc: TProc);
      constructor CreateDebug(aMessage: TMessage; Proc: TProc; Descriptor, MsgID: NativeUInt);

      procedure AddProc(const Proc: TProc);
      procedure Free;

      property Count: Integer read GetCount;
      property Msg: TMessage read FMessage write FMessage;
      property Procs: TArray<TProc> read FProcs;
    end;

    TMessageQueue = record
      FMessage: TMessage;
      FDescriptor: NativeUInt;
      FMessageID: NativeUInt;
      FDisposeMessage: boolean;
      FSender: NativeInt;
      FAsync: boolean;
      FCallBack: TProc;
    public
      constructor Create(const Threaded: boolean; const Sender: TObject;
        const Descriptor, MessageID: NativeUInt; const AMessage: TMessage;
        const DisposeMessage: boolean; CallBack: TProc=nil);

      function IsEqual(const Msg: TMessageQueue): boolean;
    end;
  private
    FSendResult: NativeInt;
    FSendDone: boolean;
    FUnSubscribeList: TSubList<Integer>;
    FPostQueue: ILinkedList<TMessageQueue>; //TSubList<TMessageQueue>;
    FMessageCountList: TSubList<TMessageCount>;
    FPostPriority: boolean;
    FProcessing: boolean;
    FProcessMessages: TTimer;
    FLastID: Integer;
    FListenersList: TSubList<TListener>;

    procedure BuildProcs(Listener: TListener; const MessageID: NativeUInt;
      const Async: boolean; const Sender: NativeInt; const AMessage: TMessage;
      const DisposeMessage: boolean);
    procedure IterateAndPostMessage(const Descriptor, MessageID: NativeUInt;
      const Async: boolean; const Sender: NativeInt; const AMessage: TMessage;
      const DisposeMessage: boolean; CallBack: TProc=nil);
    procedure AddToQueue(Item: TMessageQueue);
    procedure ProcessMessages(Sender: TObject);
    function InnerSendMessage(MessageItem: TMessageQueue): NativeInt;
    procedure InnerUnSubscribe(Listener: TListener; Immediate: boolean);
  private
    class var FMessagesManager: TMessages;

    class function GetMessagesManager: TMessages; static;
    class constructor Create;
    class destructor Destroy;
  protected
    constructor Create;
    destructor Destroy; override;

    class property MessagesManager: TMessages read GetMessagesManager;
  public
    class function GetHashCode(Obj: TObject): Integer; static;

    function IsSubscribed(const Sender: TObject): boolean; overload;
    function IsSubscribed(const Sender: TObject; const MessageID: NativeUInt): boolean; overload;
    function IsSubscribed(const Descriptor: NativeUInt): boolean; overload;
    function IsSubscribed(const Descriptor: NativeUInt; const MessageID: NativeUInt): boolean; overload;

    function Subscribe(const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const MessageID: NativeUInt; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const Sender: TObject; const aMessageClass: TClass; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const Sender: TObject; const MessageID: NativeUInt; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const Sender: TObject; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function SubscribeDesc(const Descriptor: NativeUInt; const ListenerMethod: TMessageFunc): NativeUInt;

    procedure UnSubscribe(const ID: NativeUInt; Immediate: boolean=false); overload;
    procedure UnSubscribe(const Sender: TObject; Immediate: boolean=false); overload;
    procedure UnSubscribe(const Sender: TObject; const MessageID: NativeUInt; Immediate: boolean=false); overload;
    procedure UnSubscribeDecs(const Descriptor: NativeUInt; Immediate: boolean=false);

    procedure PostMessage(const Descriptor, MessageID: NativeUInt; WPararm: NativeUInt; LPararm: NativeInt); overload;
    procedure PostMessage(const Descriptor, MessageID: NativeUInt; AMessage: TMessage; DisposeMessage: boolean=true); overload;
    procedure PostMessage<T>(const Descriptor, MessageID: NativeUInt; WPararm: T; LPararm: NativeInt); overload;
    procedure PostMessage<T>(const Descriptor, MessageID: NativeUInt; WPararm: T; LPararm: NativeInt; CallBack: TProc); overload;
    procedure PostMessage(const MessageID: NativeUInt; AMessage: TMessage; DisposeMessage: boolean=true); overload;
    procedure PostMessage(AMessage: TMessage; DisposeMessage: boolean=true); overload;
    procedure PostMessage(MessageID: NativeUInt; WPararm: NativeUInt; LPararm: NativeInt); overload;
    procedure PostMessage<T>(MessageID: NativeUInt; WPararm: T; LPararm: NativeInt); overload;
    procedure PostMessage<T>(MessageID: NativeUInt; WPararm: T; LPararm: NativeInt; CallBack: TProc); overload;

    function SendMessage(const Descriptor, MessageID: NativeUInt; WPararm: NativeUInt; LPararm: NativeInt): NativeInt; overload;
    function SendMessage(const Descriptor, MessageID: NativeUInt; AMessage: TMessage; DisposeMessage: boolean=true): NativeInt; overload;
    function SendMessage<T>(const Descriptor, MessageID: NativeUInt; WPararm: T; LPararm: NativeInt): NativeInt; overload;
    function SendMessage(AMessage: TMessage; DisposeMessage: boolean=true): NativeInt; overload;
    function SendMessage(MessageID: NativeUInt; AMessage: TMessage; DisposeMessage: boolean=true): NativeInt; overload;
    function SendMessage(MessageID: NativeUInt; WPararm: NativeUInt; LPararm: NativeInt): NativeInt; overload;
    function SendMessage<T>(MessageID: NativeUInt; WPararm: T; LPararm: NativeInt): NativeInt; overload;

    property PostPriority: boolean read FPostPriority write FPostPriority;
  end;

var
  Msgs: TMessages;

implementation

uses
  System.Types, System.Generics.Defaults, System.SyncObjs;

{ TMessageEx<T> }

constructor TMessage<T>.Create(const Value: T; const Param: NativeInt);
begin
  FParam:= Param;
  FValue:= Value;
end;

destructor TMessage<T>.Destroy;
begin

  inherited;
end;

{ TMessages }

procedure TMessages.AddToQueue(Item: TMessageQueue);
begin
  FProcessMessages.Enabled:= false;
  try
    if not FPostQueue.Contains(
       function(aItem: TMessageQueue): boolean
       begin
         Result:= aItem.IsEqual(Item);
       end)
    then
//      FPostQueue.Insert(0, Item)
      FPostQueue.Add(Item, amFirst);

  finally
    FProcessMessages.Enabled:= true;
  end;
end;

constructor TMessages.Create;
begin
  FPostPriority:= true;
  FProcessing:= false;
  FLastID:= 0;

  FProcessMessages:= TTimer.Create(nil);
  FProcessMessages.Interval:= 1;
  FProcessMessages.OnTimer:= ProcessMessages;

  FListenersList:= TSubList<TListener>.Create;
  FListenersList.Threaded:= true;
  FListenersList.Duplicates:= dupIgnore;

  FMessageCountList:= TSubList<TMessageCount>.Create;
  FMessageCountList.DefaultFreeItem(
    procedure(Item: TMessageCount)
    begin
      Item.Free
    end);

  FPostQueue:= TLinkedList<TMessageQueue>.Create; //TSubList<TMessageQueue>.Create;
  FPostQueue.Threaded:= true;


  FUnSubscribeList:= TSubList<Integer>.Create;
  FUnSubscribeList.Threaded:= true;
  FUnSubscribeList.Duplicates:= dupIgnore;

  FProcessMessages.Enabled:= true;
end;

destructor TMessages.Destroy;
begin
  FProcessMessages.Free;

  FListenersList.Clear;
  FMessageCountList.Clear;

  FPostQueue.DefaultFreeNode(
    procedure(Item: TMessageQueue)
    begin
      if Assigned(Item.FMessage) then
        FreeAndNil(Item.FMessage);
    end);
  FPostQueue.Clear;

//  FPostQueue.Clear(
//    procedure(Item: TMessageQueue)
//    begin
//      if Assigned(Item.FMessage) then
//        FreeAndNil(Item.FMessage);
//    end);
//  FPostQueue.Free;

  FUnSubscribeList.Free;
  FListenersList.Free;
  FMessageCountList.Free;
  inherited;
end;

class constructor TMessages.Create;
begin
  Msgs:= TMessages.GetMessagesManager;
end;

class destructor TMessages.Destroy;
begin
  FreeAndNil(FMessagesManager);
end;

class function TMessages.GetHashCode(Obj: TObject): Integer;
begin
{$IFDEF CPUX64}
  Result := Integer(IntPtr(Obj)) xor Integer(IntPtr(Obj) shr 32);
{$ELSE !CPUX64}
  Result := Integer(IntPtr(Obj));
{$ENDIF !CPUX64}
end;

class function TMessages.GetMessagesManager: TMessages;
begin
  if FMessagesManager = nil then
    FMessagesManager := TMessages.Create;

  Result:= FMessagesManager;
end;

procedure TMessages.BuildProcs(Listener: TListener;
  const MessageID: NativeUInt; const Async: boolean; const Sender: NativeInt;
  const AMessage: TMessage; const DisposeMessage: boolean);
var
  //dumThread: TThread;
  Index: Integer;
  Item: TMessageCount;
  NewProc: TProc;
begin
  //dumThread:= TThread.CurrentThread;

  NewProc:=
    procedure
    var
      aListener: TListener;
      aSender: NativeInt;
      aMsg: TMessage;
      aMessageID: NativeUInt;
    begin
      aListener:= Listener;
      aSender:= Sender;
      aMsg:= AMessage;
      aMessageID:= MessageID;

      if aSender > 0 then
      begin
        if Assigned(aListener.FMessageMethod) then
          FSendResult:= aListener.FMessageMethod(aMessageID, aMsg)
      end else
        if aMessageID > 0 then
          if Assigned(aListener.FMessageMethod) then
            FSendResult:= aListener.FMessageMethod(aMessageID, aMsg);
    end;

  Index:= FMessageCountList.IndexOf(
            function(aItem: TMessageCount): boolean
            begin
              Result:= aItem.Msg = AMessage;
            end);
  if Index > -1 then
  begin
    Item:= FMessageCountList[Index];
    Item.AddProc(NewProc);
    FMessageCountList[Index]:= Item;

//    Winapi.Windows.SendMessage(MainHandle, CM_BuildTasks, 0, Listener.FHWND);
  end else
  begin
//    Winapi.Windows.SendMessage(MainHandle, CM_BuildTasks, 1, Listener.FHWND);

//    FMessageCountList.Add(TMessageCount.Create(AMessage, NewProc));
    FMessageCountList.Add(TMessageCount.CreateDebug(AMessage, NewProc, Listener.FDescriptor, MessageID));
  end;
end;

function TMessages.InnerSendMessage(MessageItem: TMessageQueue): NativeInt;
begin
  Result:= -1;
  FSendResult:= -1;
  FProcessing:= true;
  IterateAndPostMessage(MessageItem.FDescriptor,
                        MessageItem.FMessageID,
                        MessageItem.FAsync,
                        MessageItem.FSender,
                        MessageItem.FMessage,
                        MessageItem.FDisposeMessage);
  Result:= FSendResult;
end;

procedure TMessages.InnerUnSubscribe(Listener: TListener; Immediate: boolean);
var
  Index: Integer;
  aListener: TListener;
begin
  if not Assigned(FListenersList) then Exit;

  aListener:= Listener;

  Index:= FListenersList.IndexOf(
    function(aItem: TListener): boolean
    begin
      Result:= (
                 (aItem.FID = aListener.FID) and
                 (aListener.FID > 0)
               ) or
               (
                 (aItem.FSender = aListener.FSender) and
                 (aListener.FMessageID = 0) and
                 (aListener.FSender > 0)
               ) or
               (
                 (aItem.FSender = aListener.FSender) and
                 (aItem.FMessageID = aListener.FMessageID) and
                 (aListener.FMessageID > 0)
               ) or
               (
                 (aItem.FDescriptor = aListener.FDescriptor) and
                 (aListener.FDescriptor > 0)
               );
    end);

  if Index > -1 then
    if Immediate then
      FListenersList.Delete(Index)
    else
      if Assigned(FUnSubscribeList) then
        FUnSubscribeList.Add(Index);
end;

function TMessages.IsSubscribed(const Descriptor: NativeUInt): boolean;
begin
  Result:= FListenersList.Contains(
     function (Item: TListener): boolean
     begin
       Result:= Item.FDescriptor = Descriptor
     end);
end;

function TMessages.IsSubscribed(const Sender: TObject;
  const MessageID: NativeUInt): boolean;
var
  aSender: Integer;
  aMessageID: NativeUInt;
begin
  aSender:= GetHashCode(Sender);
  aMessageID:= MessageID;

  Result:= FListenersList.Contains(
     function (Item: TListener): boolean
     begin
       Result:= (Item.FSender = aSender) and
                (Item.FMessageID = aMessageID)
     end);
end;

function TMessages.IsSubscribed(const Sender: TObject): boolean;
var
  aSender: Integer;
begin
  aSender:= GetHashCode(Sender);
  Result:= FListenersList.Contains(
     function (Item: TListener): boolean
     begin
       Result:= Item.FSender = aSender
     end);
end;

procedure TMessages.IterateAndPostMessage(const Descriptor, MessageID: NativeUInt;
  const Async: boolean; const Sender: NativeInt; const AMessage: TMessage;
  const DisposeMessage: boolean; CallBack: TProc);
var
  I: Integer;
  Item: TListener;
  bFind: boolean;
  Index: Integer;
  ItemMsg: TMessageCount;
  Proc: TProc;
  s: string;
begin
  bFind:= false;

  for I := 0 to FListenersList.Count - 1 do
  begin
    if MessageID > 0 then
    begin
      if (FListenersList[I].FMessageID = MessageID) or
         (
           (FListenersList[I].FMessageID = 0) and
           (FListenersList[I].FDescriptor > 0)
         )
      then
      begin
        if Descriptor > 0 then
        begin
          if (FListenersList[I].FDescriptor = Descriptor) or (FListenersList[I].FDescriptor = 0) then
          begin
//            Winapi.Windows.SendMessage(MainHandle, CM_IterateAndPostMessage, hWnd, MessageID);

            BuildProcs(FListenersList[I], MessageID, Async, Sender, AMessage, DisposeMessage);
            bFind:= true;
          end
        end else
          if FListenersList[I].FDescriptor = 0 then
          begin
//            Winapi.Windows.SendMessage(MainHandle, CM_IterateAndPostMessage, 0, MessageID);

            BuildProcs(FListenersList[I], MessageID, Async, Sender, AMessage, DisposeMessage);
            bFind:= true;
          end
      end else
        if {(Sender > 0) and} (FListenersList[I].FMessageID = 0) then
//          if (FListenersList[I].FSender = Sender) or
//             (FListenersList[I].FSender = 0)
//          then
            if Assigned(FListenersList[I].FMessageMethod) then
            begin
//              Winapi.Windows.SendMessage(MainHandle, CM_IterateAndPostMessage, Integer(Pointer(Sender)), 0);

              BuildProcs(FListenersList[I], MessageID, Async, Sender, AMessage, DisposeMessage);
              bFind:= true;
            end;
    end else
      {if Sender > 0 then}
      begin
//        if (FListenersList[I].FSender = Sender) or
//           (FListenersList[I].FSender = 0)
//        then
          if Assigned(FListenersList[I].FMessageMethod) and
             (FListenersList[I].FMessageClass = AMessage.ClassType)
          then
          begin
//            Winapi.Windows.SendMessage(MainHandle, CM_IterateAndPostMessage, Integer(Pointer(Sender)), 0);

            BuildProcs(FListenersList[I], MessageID, Async, Sender, AMessage, DisposeMessage);
            bFind:= true;
          end;
      end;
  end;

  if not bFind then
  begin
    if DisposeMessage then
      if Assigned(AMessage) then
        AMessage.DisposeOf;

    FProcessing:= false;
  end else
  begin
    Index:= FMessageCountList.IndexOf(
              function(aItem: TMessageCount): boolean
              begin
                Result:= aItem.Msg = AMessage;
              end);

    if Index > -1 then
    begin
      ItemMsg:= FMessageCountList[Index];
      if ItemMsg.Count > 0 then
      begin
        if Async then
        begin
           try
             for I := 0 to Length(ItemMsg.Procs)-1 do
             begin
               Proc:= ItemMsg.Procs[I];
               Proc;
             end;

              if Assigned(FMessageCountList) then
              begin
//                s:= Integer(FMessageCountList[Index].FHWnd).ToString + ' - ' + Integer(FMessageCountList[Index].FMsgID).ToString;
//                Winapi.Windows.SendMessage(MainHandle, CM_RunTasks, 3, Integer(PChar(s)));

                FMessageCountList.Delete(Index);
              end;

              if Assigned(CallBack) then CallBack;
           finally
             FProcessing:= false;
           end;
        end else
        begin
//          Winapi.Windows.SendMessage(MainHandle, CM_RunTasks, 4, 0);
          try
            for I := 0 to Length(ItemMsg.Procs)-1 do
            begin
              Proc:= ItemMsg.Procs[I];
              Proc;
            end;
          finally
            FProcessing:= false;
          end;
//          Winapi.Windows.SendMessage(MainHandle, CM_RunTasks, 5, 0);
        end;
      end;
    end
  end;
end;

procedure TMessages.PostMessage(const MessageID: NativeUInt;
  AMessage: TMessage; DisposeMessage: boolean);
begin
  AddToQueue(TMessageQueue.Create(true, nil, 0, MessageID, AMessage, DisposeMessage));
end;

procedure TMessages.PostMessage(AMessage: TMessage;
  DisposeMessage: boolean);
begin
  AddToQueue(TMessageQueue.Create(true, nil, 0, 0, AMessage, DisposeMessage));
end;

procedure TMessages.ProcessMessages(Sender: TObject);
var
  Item: TMessageQueue;
begin
  if not FProcessing or not FPostPriority then
  begin
    if not FUnSubscribeList.IsEmpty then
    begin
      FListenersList.Delete(FUnSubscribeList.ToArray);
      FUnSubscribeList.Clear;
    end;

    if FPostQueue.IsEmpty then Exit;

    FProcessing:= true;

    Item:= FPostQueue.ExtractLast;  //FPostQueue.Extract(FPostQueue.Count-1);
    IterateAndPostMessage(Item.FDescriptor,
                          Item.FMessageID,
                          Item.FAsync,
                          Item.FSender,
                          Item.FMessage,
                          Item.FDisposeMessage,
                          Item.FCallBack);
  end;
end;

procedure TMessages.PostMessage(const Descriptor, MessageID: NativeUInt;
  AMessage: TMessage; DisposeMessage: boolean);
begin
  AddToQueue(TMessageQueue.Create(true, nil, Descriptor, MessageID, AMessage, DisposeMessage));
end;

procedure TMessages.PostMessage(const Descriptor, MessageID: NativeUInt;
  WPararm: NativeUInt; LPararm: NativeInt);
var
  Msg: TMessage<NativeUInt>;
begin
  Msg:= TMessage<NativeUInt>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, Descriptor, MessageID, Msg, true));
end;

procedure TMessages.PostMessage(MessageID,
  WPararm: NativeUInt; LPararm: NativeInt);
var
  Msg: TMessage<NativeUInt>;
begin
  Msg:= TMessage<NativeUInt>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, 0, MessageID, Msg, true));
end;

procedure TMessages.PostMessage<T>(const Descriptor, MessageID: NativeUInt;
  WPararm: T; LPararm: NativeInt; CallBack: TProc);
var
  Msg: TMessage<T>;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, Descriptor, MessageID, Msg, true, CallBack));
end;

procedure TMessages.PostMessage<T>(MessageID: NativeUInt; WPararm: T;
  LPararm: NativeInt; CallBack: TProc);
var
  Msg: TMessage<T>;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, 0, MessageID, Msg, true, CallBack));
end;

procedure TMessages.PostMessage<T>(MessageID: NativeUInt;
  WPararm: T; LPararm: NativeInt);
var
  Msg: TMessage<T>;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, 0, MessageID, Msg, true));
end;

procedure TMessages.PostMessage<T>(const Descriptor, MessageID: NativeUInt;
  WPararm: T; LPararm: NativeInt);
var
  Msg: TMessage<T>;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);

  AddToQueue(TMessageQueue.Create(true, nil, Descriptor, MessageID, Msg, true));
end;

function TMessages.SendMessage(const Descriptor, MessageID: NativeUInt;
  WPararm: NativeUInt; LPararm: NativeInt): NativeInt;
var
  Msg: TMessage<NativeUInt>;
  Item: TMessageQueue;
begin
  Msg:= TMessage<NativeUInt>.Create(WPararm, LPararm);
  Item:= TMessageQueue.Create(false, nil, Descriptor, MessageID, Msg, true);
  Result:= InnerSendMessage(Item);
end;

function TMessages.SendMessage(const Descriptor, MessageID: NativeUInt;
  AMessage: TMessage; DisposeMessage: boolean): NativeInt;
var
  Item: TMessageQueue;
begin
  Item:= TMessageQueue.Create(false, nil, Descriptor, MessageID, AMessage, DisposeMessage);
  Result:= InnerSendMessage(Item);
end;

function TMessages.SendMessage(AMessage: TMessage;
  DisposeMessage: boolean): NativeInt;
var
  Item: TMessageQueue;
begin
  Item:= TMessageQueue.Create(false, nil, 0, 0, AMessage, DisposeMessage);
  Result:= InnerSendMessage(Item);
end;

function TMessages.SendMessage(MessageID: NativeUInt;
  AMessage: TMessage; DisposeMessage: boolean): NativeInt;
var
  Item: TMessageQueue;
begin
  Item:= TMessageQueue.Create(false, nil, 0, MessageID, AMessage, DisposeMessage);
  Result:= InnerSendMessage(Item);
end;

function TMessages.Subscribe(const Sender: TObject;
  const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
  aSender: Integer;
begin
  aSender:= GetHashCode(Sender);
  dumListener:= TListener.Create(Sender, 0, ListenerMethod);
  aListener:= TListener.Create(Sender, 0, ListenerMethod);
  FListenersList.DuplicateProc:= function(Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FSender = NewItem.FSender)
                                 end;

  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(
      function (Item: TListener): boolean
      begin
        Result:= (Item.FSender = aListener.FSender)
      end);
end;

function TMessages.Subscribe(const Sender: TObject; const MessageID: NativeUInt;
  const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
  aSender: Integer;
begin
  aSender:= GetHashCode(Sender);
  dumListener:= TListener.Create(Sender, MessageID, ListenerMethod);
  aListener:= TListener.Create(Sender, MessageID, ListenerMethod);
  FListenersList.DuplicateProc:= function(Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FSender = NewItem.FSender) and
                                            (Item.FMessageID = NewItem.FMessageID)
                                 end;

  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(
      function (Item: TListener): boolean
      begin
        Result:= (Item.FSender = aListener.FSender) and
                 (Item.FMessageID = aListener.FMessageID)
      end);
end;

function TMessages.Subscribe(const MessageID: NativeUInt;
  const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
begin
  dumListener:= TListener.Create(0, MessageID, ListenerMethod);
  aListener:= TListener.Create(0, MessageID, ListenerMethod);
  FListenersList.DuplicateProc:= function (Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FMessageID = NewItem.FMessageID) and
                                            (Item.FMessageMethod = NewItem.FMessageMethod)
                                 end;
  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(dumListener,
      TComparer<TListener>.Construct(
        function(const Left, Right: TListener): Integer
        begin
          Result:= 1;
          if (Left.FMessageID = Right.FMessageID) and
             (Left.FMessageMethod = Right.FMessageMethod)
          then
            Result:= 0;
        end));
end;

function TMessages.SubscribeDesc(const Descriptor: NativeUInt;
  const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
begin
  dumListener:= TListener.Create(Descriptor, 0, ListenerMethod);
  aListener:= TListener.Create(Descriptor, 0, ListenerMethod);
  FListenersList.DuplicateProc:= function (Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FDescriptor = NewItem.FDescriptor) and
                                            (Item.FMessageMethod = NewItem.FMessageMethod)
                                 end;
  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(dumListener,
      TComparer<TListener>.Construct(
        function(const Left, Right: TListener): Integer
        begin
          Result:= 1;
          if (Left.FDescriptor = Right.FDescriptor) and
             (Left.FMessageMethod = Right.FMessageMethod)
          then
            Result:= 0;
        end));
end;

procedure TMessages.UnSubscribe(const Sender: TObject; Immediate: boolean);
var
  dumListener: TListener;
begin
  dumListener.Init;
  dumListener.FSender:= GetHashCode(Sender);
  InnerUnSubscribe(dumListener, Immediate);
end;

procedure TMessages.UnSubscribe(const ID: NativeUInt; Immediate: boolean);
var
  dumListener: TListener;
begin
  dumListener.Init;
  dumListener.FID:= ID;
  InnerUnSubscribe(dumListener, Immediate);
end;

function TMessages.Subscribe(const Sender: TObject;
  const aMessageClass: TClass;
  const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
begin
  dumListener:= TListener.Create(Sender, aMessageClass, ListenerMethod);
  aListener:= TListener.Create(Sender, aMessageClass, ListenerMethod);
  FListenersList.DuplicateProc:= function (Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FMessageID = NewItem.FMessageID) and
                                            (Item.FSender = NewItem.FSender)
                                 end;

  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(
      function (Item: TListener): boolean
      begin
        Result:= (Item.FMessageID = aListener.FMessageID) and
                 (Item.FSender = aListener.FSender)
      end);
end;

function TMessages.Subscribe(const ListenerMethod: TMessageFunc): NativeUInt;
var
  dumListener: TListener;
  Index: Integer;
  aListener: TListener;
begin
  dumListener:= TListener.Create(0, 0, ListenerMethod);
  aListener:= TListener.Create(0, 0, ListenerMethod);
  FListenersList.DuplicateProc:= function (Item: TListener; NewItem: TListener): boolean
                                 begin
                                   Result:= (Item.FMessageMethod = NewItem.FMessageMethod)
                                 end;
  Index:= FListenersList.Add(dumListener);
  if Index > -1 then
  begin
    TInterlocked.Increment(FLastID);
    dumListener.FID:= FLastID;
    FListenersList[Index]:= dumListener;
    Result:= FLastID;
  end else
    Result:= FListenersList.IndexOf(dumListener,
      TComparer<TListener>.Construct(
        function(const Left, Right: TListener): Integer
        begin
          Result:= 1;
          if (Left.FMessageMethod = Right.FMessageMethod) then
            Result:= 0;
        end));
end;

procedure TMessages.UnSubscribe(const Sender: TObject;
  const MessageID: NativeUInt; Immediate: boolean);
var
  dumListener: TListener;
begin
  dumListener.Init;
  dumListener.FSender:= GetHashCode(Sender);
  dumListener.FMessageID:= MessageID;
  InnerUnSubscribe(dumListener, Immediate);
end;

procedure TMessages.UnSubscribeDecs(const Descriptor: NativeUInt; Immediate: boolean);
var
  dumListener: TListener;
begin
  dumListener.Init;
  dumListener.FDescriptor:= Descriptor;
  InnerUnSubscribe(dumListener, Immediate);
end;

function TMessages.SendMessage(MessageID,
  WPararm: NativeUInt; LPararm: NativeInt): NativeInt;
var
  Msg: TMessage<NativeUInt>;
  Item: TMessageQueue;
begin
  Msg:= TMessage<NativeUInt>.Create(WPararm, LPararm);
  Item:= TMessageQueue.Create(false, nil, 0, MessageID, Msg, true);
  Result:= InnerSendMessage(Item);
end;

function TMessages.SendMessage<T>(const Descriptor, MessageID: NativeUInt; WPararm: T;
  LPararm: NativeInt): NativeInt;
var
  Msg: TMessage<T>;
  Item: TMessageQueue;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);
  Item:= TMessageQueue.Create(false, nil, Descriptor, MessageID, Msg, true);
  Result:= InnerSendMessage(Item);
end;

function TMessages.SendMessage<T>(MessageID: NativeUInt;
  WPararm: T; LPararm: NativeInt): NativeInt;
var
  Msg: TMessage<T>;
  Item: TMessageQueue;
begin
  Msg:= TMessage<T>.Create(WPararm, LPararm);
  Item:= TMessageQueue.Create(false, nil, 0, MessageID, Msg, true);
  Result:= InnerSendMessage(Item);
end;

function TMessages.IsSubscribed(const Descriptor, MessageID: NativeUInt): boolean;
begin
  Result:= FListenersList.Contains(
     function (Item: TListener): boolean
     begin
       Result:= (Item.FDescriptor = Descriptor) and
                (Item.FMessageID = MessageID)
     end);
end;

{ TMessages.TListener }

constructor TMessages.TListener.Create(const Descriptor, MessageID: NativeUInt;
  const MessageMethod: TMessageFunc);
begin
  FID:= 0;
  FDescriptor:= Descriptor;
  FMessageID:= MessageID;
  FMessageMethod:= MessageMethod;
  FMessageClass:= nil;
  FSender:= 0;
  FThread:= nil;
end;

constructor TMessages.TListener.Create(const Sender: TObject;
  const aMessageClass: TClass; const MessageMethod: TMessageFunc);
begin
  FID:= 0;
  FDescriptor:= 0;
  FMessageID:= 0;
  FMessageMethod:= MessageMethod;
  FMessageClass:= aMessageClass;
  FSender:= GetHashCode(Sender);
  FThread:= nil;
end;

constructor TMessages.TListener.Create(const Sender: TObject;
  const MessageID: NativeUInt; const MessageMethod: TMessageFunc);
begin
  FID:= 0;
  FDescriptor:= 0;
  FMessageID:= MessageID;
  FMessageMethod:= MessageMethod;
  FMessageClass:= nil;
  FSender:= GetHashCode(Sender);
  FThread:= nil;
end;

procedure TMessages.TListener.Init;
begin
  FID:= 0;
  FDescriptor:= 0;
  FMessageID:= 0;
  FMessageClass:= nil;
  FSender:= 0;
  FThread:= nil;
  FMessageMethod:= nil;
end;

{ TMessages.TMessageRef }

procedure TMessages.TMessageCount.AddProc(const Proc: TProc);
begin
  SetLength(FProcs, High(FProcs)+2);
  FProcs[High(FProcs)]:= Proc;
end;

constructor TMessages.TMessageCount.Create(aMessage: TMessage; Proc: TProc);
begin
  FMessage:= aMessage;
  AddProc(Proc);
end;

constructor TMessages.TMessageCount.CreateDebug(aMessage: TMessage; Proc: TProc;
  Descriptor, MsgID: NativeUInt);
begin
  FMessage:= aMessage;
  AddProc(Proc);
  FDescriptor:= Descriptor;
  FMsgID:= MsgID;
end;

procedure TMessages.TMessageCount.Free;
var
  I: Integer;
begin
  FreeAndNil(FMessage);
  for I := Low(FProcs) to High(FProcs) do
    FProcs[I]:= nil;
end;

function TMessages.TMessageCount.GetCount: Integer;
var
  I: Integer;
begin
  Result:= 0;
  for I := Low(FProcs) to High(FProcs) do
    if Assigned(FProcs) then
      Inc(Result);
end;

{ TMessages.TMessageQueue }

constructor TMessages.TMessageQueue.Create(const Threaded: boolean;
  const Sender: TObject; const Descriptor, MessageID: NativeUInt;
  const AMessage: TMessage; const DisposeMessage: boolean;
  CallBack: TProc);
begin
  FMessage:= AMessage;
  FDescriptor:= Descriptor;
  FMessageID:= MessageID;
  FDisposeMessage:= DisposeMessage;
  if Assigned(Sender) then
    FSender:= GetHashCode(Sender)
  else
    FSender:= 0;
  FAsync:= Threaded;
  FCallBack:= CallBack;
end;

function TMessages.TMessageQueue.IsEqual(const Msg: TMessageQueue): boolean;
begin
  Result:= (Msg.FMessage = FMessage) and
           (Msg.FDescriptor = FDescriptor) and
           (Msg.FMessageID = FMessageID) and
           (Msg.FSender = FSender) and
           (Msg.FAsync = FAsync) and
           TEqualityComparer<TProc>.Default.Equals(Msg.FCallBack, FCallBack)
end;

end.

