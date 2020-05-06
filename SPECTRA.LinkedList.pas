unit SPECTRA.LinkedList;

interface

uses
  SPECTRA.Enumerable, System.Generics.Defaults, System.SysUtils;

type
  TAttachMode = (amLast, amFirst, amAfter, amBefore);

  TLinkedList<T> = class
  public type
    PLinkedNode = ^TLinkedNode;
    TLinkedNode = record
    private
      FOwnedList: Pointer;
      FValue: T;
      FNextNode: PLinkedNode;
      FPrevNode: PLinkedNode;
      FFreeValue: boolean;

      function GetNext: PLinkedNode;
      function GetPrev: PLinkedNode;

      property FreeValue: boolean read FFreeValue write FFreeValue;
    public
      constructor Create(const Value: T; List: Pointer);
      procedure Assign(const Value: T; List: Pointer);
      procedure Free;

      property Next: PLinkedNode read GetNext;
      property Prev: PLinkedNode read GetPrev;

      property Value: T read FValue;
    end;
  private type
    TLinkedListEnumerator<T> = class(TInterfacedObject, ISPEnumerator<T>)
    private
      FList: TLinkedList<T>;
      FIndex: Integer;
      FCurrent: T;
      FCurrentNode: PLinkedNode;

      function Clone: ISPEnumerator<T>;
      procedure Reset;
      function GetCurrent: T;
      function GetCurrentIndex: Integer;
    public
      constructor Create(const AList: TLinkedList<T>);
      destructor Destroy; override;

      function MoveNext: Boolean;
      property Current: T read GetCurrent;
    end;
  private
    FCount: Integer;
    FHead: PLinkedNode;
    FFirst: PLinkedNode;
    FLast: PLinkedNode;
    FComparer: IComparer<T>;
    FLockObject: TObject;
    FThreaded: boolean;
    FDefaultFreeProc: TProc<T>;

    procedure Lock;
    procedure UnLock;
    function EnsureNode(const Node: PLinkedNode): boolean;
    function GetCount: Integer;
    function GetFirst: PLinkedNode;
    function GetLast: PLinkedNode;
    function GetEnumerable: ISPEnumerable<T>;
    function GetThreaded: boolean;
    procedure SetThreaded(const Threaded: boolean);
    procedure InnerAdd(const NewNode: PLinkedNode;
      AttachMode: TAttachMode = amLast; const Node: PLinkedNode = nil;
      bLock: boolean = false);
    procedure InnerDelete(Node: PLinkedNode; bLock: boolean = false);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const NewNode: PLinkedNode; AttachMode: TAttachMode = amLast; const Node: PLinkedNode = nil); overload;
    function Add(const Value: T; AttachMode: TAttachMode = amLast; const Node: PLinkedNode = nil): PLinkedNode; overload;
    procedure AddRange(InArray: TArray<T>; AttachMode: TAttachMode = amLast; const Node: PLinkedNode = nil);

    function Cast(Node: Pointer): PLinkedNode;
    procedure Clear;
    function Contains(const AValue: T): Boolean; overload;
    function Contains(const Node: PLinkedNode): Boolean; overload;
    function Contains(const Predicate: TPredicate<T>): boolean; overload;
    procedure DefaultFreeNode(Proc: TProc<T>);
    procedure Delete(const Node: PLinkedNode); overload;
    procedure Delete(const Predicate: TPredicate<T>); overload;
    function ExtractFirst: T;
    function ExtractLast: T;

    function Find(const Value: T): PLinkedNode; overload;
    function Find(const Predicate: TPredicate<T>): PLinkedNode; overload;
    function FindLast(const Value: T): PLinkedNode; overload;
    function FindLast(const Predicate: TPredicate<T>): PLinkedNode; overload;
    function IsEmpty: boolean;
    procedure MoveTo(Source, Target: PLinkedNode; Mode: TAttachMode);

    function Nodes(const Predicate: TPredicate<T>): TArray<PLinkedNode>;

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;

    function ToArray: TArray<T>; overload;
    function ToArray(const Predicate: TPredicate<T>): TArray<T>; overload;
    procedure ToCustom(Proc: TProc<T>);

    function GetEnumerator: ISPEnumerator<T>;

    property Count: Integer read GetCount;
    property Enumerable: ISPEnumerable<T> read GetEnumerable;
    property First: PLinkedNode read GetFirst;
    property Last: PLinkedNode read GetLast;
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

  E_SPECTRA_LinkedListException = class(Exception);

implementation

uses
  SPECTRA.Consts, System.Rtti;

{ TLinkedList<T> }

procedure TLinkedList<T>.Add(const NewNode: PLinkedNode;
  AttachMode: TAttachMode; const Node: PLinkedNode);
begin
  InnerAdd(NewNode,AttachMode,Node,true);
end;

function TLinkedList<T>.Add(const Value: T; AttachMode: TAttachMode;
  const Node: PLinkedNode): PLinkedNode;
var
  NewNode: PLinkedNode;
begin
  Lock;
  try
    New(NewNode);
    NewNode^.Assign(Value, Self);
    InnerAdd(NewNode, AttachMode, Node);
    Result:= NewNode;
  finally
    UnLock;
  end;
end;

procedure TLinkedList<T>.AddRange(InArray: TArray<T>;
  AttachMode: TAttachMode; const Node: PLinkedNode);
var
  NewNode: PLinkedNode;
  I: Integer;
begin
  Lock;
  try
    for I := Low(InArray) to High(InArray) do
    begin
      New(NewNode);
      NewNode^.Assign(InArray[I], Self);
      InnerAdd(NewNode, AttachMode, Node);
    end;
  finally
    UnLock;
  end;
end;

function TLinkedList<T>.Cast(Node: Pointer): PLinkedNode;
begin
  Result:= PLinkedNode(Node);
end;

procedure TLinkedList<T>.Clear;
var
  Node: PLinkedNode;
  Dummy: PLinkedNode;
begin
  Lock;
  try
    Node:= FFirst;
    while Node <> nil do
    begin
      Dummy:= Node;
      Node:= Node.Next;

      InnerDelete(Dummy);
    end;
    FCount:= 0;

    FFirst:= nil;
    FLast:= nil;
  finally
    UnLock;
  end;
end;

function TLinkedList<T>.Contains(const Predicate: TPredicate<T>): boolean;
var
  Node: PLinkedNode;
begin
  Result:= false;

  if not Assigned(Predicate) then Exit;

  Node:= FFirst;
  while Node <> nil do
  begin
    if Predicate(Node.Value) then
    begin
      Result:= true;
      Break;
    end;

    Node:= Node.Next;
  end;
end;

function TLinkedList<T>.Contains(const Node: PLinkedNode): Boolean;
var
  aNode: PLinkedNode;
begin
  Result:= false;

  if not Assigned(Node) then Exit;

  aNode:= FFirst;
  while aNode <> nil do
  begin
    if aNode = Node then
    begin
      Result:= true;
      Break;
    end;

    aNode:= aNode.Next;
  end;
end;

constructor TLinkedList<T>.Create;
begin
  FCount:= 0;
  FFirst:= nil;
  FLast:= nil;
  FThreaded:= false;
  FDefaultFreeProc:= nil;
  New(FHead);
  FHead.Assign(Default(T),Self);
  FComparer:= TComparer<T>.Default;
  FLockObject:= TObject.Create;
end;

function TLinkedList<T>.Contains(const AValue: T): Boolean;
var
  Node: PLinkedNode;
begin
  Result:= false;

  Node:= FFirst;
  while Node <> nil do
  begin
    if FComparer.Compare(Node.Value, AValue) = 0 then
    begin
      Result:= true;
      Break;
    end;

    Node:= Node.Next;
  end;
end;

procedure TLinkedList<T>.DefaultFreeNode(Proc: TProc<T>);
begin
  FDefaultFreeProc:= Proc;
end;

procedure TLinkedList<T>.Delete(const Predicate: TPredicate<T>);
var
  Node: PLinkedNode;
  DelNode: PLinkedNode;
begin
  Lock;
  try
    Node:= FLast;
    while Node <> nil do
    begin
      if Predicate(Node.Value) then
      begin
        DelNode:= Node;
        Node:= Node.Prev;
        InnerDelete(DelNode);
      end else
        Node:= Node.Prev;
    end;
  finally
    UnLock;
  end;
end;

procedure TLinkedList<T>.Delete(const Node: PLinkedNode);
begin
  InnerDelete(Node, true)
end;

function TLinkedList<T>.ExtractFirst: T;
begin
  Lock;
  try
    Result:= Default(T);

    if FFirst = nil then
      raise E_SPECTRA_LinkedListException.CreateRes(@sNodeNotAssigned);

    Result:= FFirst.Value;
    FFirst.FValue:= Default(T);
    InnerDelete(FFirst);
  finally
    UnLock;
  end;
end;

function TLinkedList<T>.ExtractLast: T;
begin
  Lock;
  try
    Result:= Default(T);

    if FLast = nil then
      raise E_SPECTRA_LinkedListException.CreateRes(@sNodeNotAssigned);

    Result:= FLast.Value;
    FLast.FValue:= Default(T);
    InnerDelete(FLast);
  finally
    UnLock;
  end;
end;

destructor TLinkedList<T>.Destroy;
begin
  Clear;
  FHead.Free;
  Dispose(FHead);
  FLockObject.Free;

  inherited;
end;

function TLinkedList<T>.EnsureNode(const Node: PLinkedNode): boolean;
begin
  Result:= false;

  if Assigned(Node.FOwnedList) then
    if (TLinkedList<T>(Node.FOwnedList) = Self) then
      raise E_SPECTRA_LinkedListException.CreateRes(@sNodeIsAttached)
    else
      if Node.FOwnedList <> nil then
        raise E_SPECTRA_LinkedListException.CreateRes(@sNodeIsAttachedAnother);

  Result:= true;
end;

function TLinkedList<T>.Find(const Value: T): PLinkedNode;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FFirst;
  while Node <> nil do
  begin
    if FComparer.Compare(Node.Value, Value) = 0 then
    begin
      Result:= Node;
      Break;
    end;

    Node:= Node.Next;
  end;
end;

function TLinkedList<T>.Find(const Predicate: TPredicate<T>): PLinkedNode;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FFirst;
  while Node <> nil do
  begin
    if Predicate(Node.Value) then
    begin
      Result:= Node;
      Break;
    end;

    Node:= Node.Next;
  end;
end;

function TLinkedList<T>.FindLast(const Value: T): PLinkedNode;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FLast;
  while Node <> nil do
  begin
    if FComparer.Compare(Node.Value, Value) = 0 then
    begin
      Result:= Node;
      Break;
    end;

    Node:= Node.Prev;
  end;
end;

function TLinkedList<T>.FindLast(const Predicate: TPredicate<T>): PLinkedNode;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FLast;
  while Node <> nil do
  begin
    if Predicate(Node.Value) then
    begin
      Result:= Node;
      Break;
    end;

    Node:= Node.Prev;
  end;
end;

function TLinkedList<T>.GetCount: Integer;
begin
  Result:= FCount;
end;

function TLinkedList<T>.GetEnumerable: ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(GetEnumerator);
end;

function TLinkedList<T>.GetEnumerator: ISPEnumerator<T>;
var
  AContext: TRttiContext;
begin
  AContext:= TRttiContext.Create;
  try
    if AContext.GetType(TypeInfo(T)).TypeKind = tkClass then
      ISPEnumerator<T>(Result):= TLinkedListEnumerator<T>.Create(Self)
    else
      Result:= TLinkedListEnumerator<T>.Create(Self)
  finally
    AContext.Free;
  end;
end;

function TLinkedList<T>.GetFirst: PLinkedNode;
begin
  Result:= FFirst;
end;

function TLinkedList<T>.GetLast: PLinkedNode;
begin
  Result:= FLast;
end;

function TLinkedList<T>.GetThreaded: boolean;
begin
  Result:= FThreaded;
end;

procedure TLinkedList<T>.InnerAdd(const NewNode: PLinkedNode;
  AttachMode: TAttachMode; const Node: PLinkedNode; bLock: boolean);
var
  Dummy: PLinkedNode;
begin
  if bLock then Lock;
  try
    case AttachMode of
     amLast:
         begin
           if (FFirst = nil) or (FLast = nil) then
           begin
             FFirst:= NewNode;
             FLast:= NewNode;

             FFirst.FNextNode:= nil;
             FFirst.FPrevNode:= FHead;
             FFirst.FOwnedList:= Self;

             FLast.FNextNode:= nil;
             FLast.FPrevNode:= FHead;
             FLast.FOwnedList:= Self;
           end else
           begin
             Dummy:= FLast;
             Dummy.FNextNode:= NewNode;
             FLast:= NewNode;
             FLast.FPrevNode:= Dummy;
             FLast.FNextNode:= nil;
             FLast.FOwnedList:= Self;
           end;
         end;
     amFirst:
         begin
           if (FFirst = nil) or (FLast = nil) then
           begin
             FFirst:= NewNode;
             FLast:= NewNode;

             FFirst.FNextNode:= nil;
             FFirst.FPrevNode:= FHead;
             FFirst.FOwnedList:= Self;

             FLast.FNextNode:= nil;
             FLast.FPrevNode:= FHead;
             FLast.FOwnedList:= Self;
           end else
           begin
             Dummy:= FFirst;
             Dummy.FPrevNode:= NewNode;
             FFirst:= NewNode;
             FFirst.FPrevNode:= nil;
             FFirst.FNextNode:= Dummy;
             FFirst.FOwnedList:= Self;
           end;
         end;
     amAfter:
         begin
           if Node = nil then
             raise E_SPECTRA_LinkedListException.CreateRes(@sNodeNotSpecified);

           if Node = FLast then FLast:= NewNode;

           Dummy:= Node.FNextNode;

           Node.FNextNode:= NewNode;
           if Dummy <> nil then
             Dummy.FPrevNode:= NewNode;

           NewNode.FNextNode:= Dummy;
           NewNode.FPrevNode:= Node;
           NewNode.FOwnedList:= Self;
         end;
     amBefore:
         begin
           if Node = nil then
             raise E_SPECTRA_LinkedListException.CreateRes(@sNodeNotSpecified);

           if Node = FFirst then
           begin
             FFirst:= NewNode;
             NewNode.FPrevNode:= FHead;
           end;

           Dummy:= Node.FPrevNode;

           Node.FPrevNode:= NewNode;
           if Dummy <> nil then
             if Dummy <> FHead then
               Dummy.FNextNode:= NewNode;

           NewNode.FPrevNode:= Dummy;
           NewNode.FNextNode:= Node;
           NewNode.FOwnedList:= Self;
         end;
    end;

    Inc(FCount);
  finally
    if bLock then UnLock;
  end;
end;

procedure TLinkedList<T>.InnerDelete(Node: PLinkedNode;
  bLock: boolean);
var
  Dummy: PLinkedNode;
begin
  if bLock then Lock;
  try
    if Node = FFirst then
    begin
      Dummy:= FFirst;

      if FFirst = FLast then
        FLast:= nil;

      if FFirst.FNextNode <> nil then
      begin
        FFirst:= FFirst.FNextNode;
        FFirst.FPrevNode:= FHead;
      end else
        FFirst:= nil;

      if Assigned(FDefaultFreeProc) then
      begin
        Dummy.FreeValue:= false;
        FDefaultFreeProc(Dummy.Value);
      end;

      Dummy.Free;
      Dispose(Dummy);
      Dummy:= nil;
      Dec(FCount);
    end else
      if Node = FLast then
      begin
        Dummy:= FLast;

        if FFirst = FLast then
          FLast:= nil;

        if (FLast.FPrevNode <> nil) and (FLast.FPrevNode <> FHead) then
        begin
          FLast:= FLast.FPrevNode;
          FLast.FNextNode:= nil;
        end else
          FLast:= nil;

        if Assigned(FDefaultFreeProc) then
        begin
          Dummy.FreeValue:= false;
          FDefaultFreeProc(Dummy.Value);
        end;

        Dummy.Free;
        Dispose(Dummy);
        Dummy:= nil;
        Dec(FCount);
      end else
      begin
        Dummy:= Node.FPrevNode;
        if (Dummy <> nil) and (Dummy <> FHead) then
          Dummy.FNextNode:= Node.FNextNode;

        Dummy:= Node.FNextNode;
        if Dummy <> nil then
          Dummy.FPrevNode:= Node.FPrevNode;

        if Assigned(FDefaultFreeProc) then
        begin
          Node.FreeValue:= false;
          FDefaultFreeProc(Node.Value);
        end;

        Node.Free;
        Dispose(Node);
        Node:= nil;
        Dec(FCount);
      end;
  finally
    if bLock then UnLock;
  end;
end;

function TLinkedList<T>.IsEmpty: boolean;
begin
  Result:= FCount = 0;
end;

procedure TLinkedList<T>.Lock;
begin
  if FThreaded then
    System.TMonitor.Enter(FLockObject);
end;

procedure TLinkedList<T>.MoveTo(Source, Target: PLinkedNode; Mode: TAttachMode);
var
  PrevNode: PLinkedNode;
  NextNode: PLinkedNode;
begin
  if not Contains(Source) or not Contains(Target) then
    raise E_SPECTRA_LinkedListException.CreateRes(@sListNoContainsNode);

  if Count <= 1 then Exit;

  case Mode of
   amLast: raise E_SPECTRA_LinkedListException.CreateResFmt(@sModeNotSupported,['amLast','MoveTo']);
   amFirst: raise E_SPECTRA_LinkedListException.CreateResFmt(@sModeNotSupported,['amFirst','MoveTo']);
  end;

  Lock;
  try
    //disconnect source
    PrevNode:= Source^.FPrevNode;
    NextNode:= Source^.FNextNode;
    if Source = FFirst then
    begin
      PrevNode:= FHead;
      FFirst:= NextNode;
    end;

    Source^.FPrevNode:= nil;
    Source^.FNextNode:= nil;
    Dec(FCount);

    if PrevNode <> nil then
      PrevNode.FNextNode:= NextNode;
    if NextNode <> nil then
      NextNode.FPrevNode:= PrevNode;
    if Source = FLast then
      FLast:= PrevNode;

    //connect source
    InnerAdd(Source, Mode, Target);
  finally
    UnLock;
  end;
end;

function TLinkedList<T>.Nodes(
  const Predicate: TPredicate<T>): TArray<PLinkedNode>;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FFirst;
  while Node <> nil do
  begin
    if Predicate(Node.Value) then
    begin
      SetLength(Result, Length(Result)+1);
      Result[High(Result)]:= Node;
    end;

    Node:= Node.Next;
  end;
end;

procedure TLinkedList<T>.SetThreaded(const Threaded: boolean);
begin
  FThreaded:= Threaded;
end;

procedure TLinkedList<T>.Sort(const AComparer: IComparer<T>);
var
  I: Integer;
  bSwap: Boolean;
  Dummy: PLinkedNode;
  aLeft: PLinkedNode;
  aRight: PLinkedNode;
  aLeftP: PLinkedNode;
  aRightN: PLinkedNode;
  aLeftN: PLinkedNode;
  aRightP: PLinkedNode;
begin
  Lock;
  try
    for I := 0 to FCount-1 do
    begin
      bSwap:= false;

      Dummy:= FFirst;
      while Dummy <> nil do
      begin
        aLeft:= Dummy;
        aRight:= Dummy.Next;

        if (aLeft <> nil) and (aRight <> nil) then
          if AComparer.Compare(aRight.Value, aLeft.Value) < 0 then
          begin
            if (aLeft.Next = aRight) then
            begin
              if aRight = FLast then FLast:= aLeft;
              if aLeft = FFirst then FFirst:= aRight;

              aLeftP:= aLeft.Prev;
              aRightN:= aRight.Next;

              aLeft.FNextNode:= aRightN;
              if aRightN <> nil then
                aRightN.FPrevNode:= aLeft;

              aRight.FPrevNode:= aLeftP;
              if aLeftP <> nil then
                aLeftP.FNextNode:= aRight;

              aRight.FNextNode:= aLeft;
              aLeft.FPrevNode:= aRight;
            end else
            begin
              aLeftP:= aLeft.Prev;
              aLeftN:= aLeft.Next;
              aRightP:= aRight.Prev;
              aRightN:= aRight.Next;

              if aLeftP <> nil then
                aLeftP.FNextNode:= aRight;
              if aLeftN <> nil then
                aLeftN.FPrevNode:= aRight;

              aLeft.FNextNode:= aRightN;
              aLeft.FPrevNode:= aRightP;

              if aRightP <> nil then
                aRightP.FNextNode:= aLeft;
              if aRightN <> nil then
                aRightN.FPrevNode:= aLeft;

              aRight.FNextNode:= aLeftN;
              aRight.FPrevNode:= aLeftP;

              if aLeft.Next = nil then FLast:= aLeft;
              if aLeft = FFirst then FFirst:= aRight;
            end;

            bSwap:= true;
          end;

        Dummy:= Dummy.Next;
      end;

      if not bSwap then Break;
    end;
  finally
     UnLock;
  end;
end;

procedure TLinkedList<T>.Sort;
begin
  Sort(TComparer<T>.Default)
end;

function TLinkedList<T>.ToArray: TArray<T>;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FFirst;
  while Node <> nil do
  begin
    SetLength(Result, Length(Result)+1);
    Result[High(Result)]:= Node.Value;

    Node:= Node.Next;
  end;
end;

function TLinkedList<T>.ToArray(const Predicate: TPredicate<T>): TArray<T>;
var
  Node: PLinkedNode;
begin
  Result:= nil;

  Node:= FFirst;
  while Node <> nil do
  begin
    if Predicate(Node.Value) then
    begin
      SetLength(Result, Length(Result)+1);
      Result[High(Result)]:= Node.Value;
    end;

    Node:= Node.Next;
  end;
end;

procedure TLinkedList<T>.ToCustom(Proc: TProc<T>);
var
  Node: PLinkedNode;
begin
  if not Assigned(Proc) then Exit;

  Node:= FFirst;
  while Node <> nil do
  begin
    Proc(Node.Value);

    Node:= Node.Next;
  end;
end;

procedure TLinkedList<T>.UnLock;
begin
  if FThreaded then
    System.TMonitor.Exit(FLockObject);
end;

{ TLinkedList<T>.TLinkedListEnumerator<T> }

function TLinkedList<T>.TLinkedListEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TLinkedListEnumerator<T>.Create(FList);
end;

constructor TLinkedList<T>.TLinkedListEnumerator<T>.Create(
  const AList: TLinkedList<T>);
begin
  inherited Create;
  FList:= AList;
  FCurrent:= Default(T);
  FCurrentNode:= FList.FFirst;
end;

destructor TLinkedList<T>.TLinkedListEnumerator<T>.Destroy;
begin
  FList:= nil;
  inherited;
end;

function TLinkedList<T>.TLinkedListEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TLinkedList<T>.TLinkedListEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= -1;
end;

function TLinkedList<T>.TLinkedListEnumerator<T>.MoveNext: Boolean;
begin
  Result:= false;

  if Assigned(FCurrentNode) then
  begin
    FCurrent:= FCurrentNode.Value;
    FCurrentNode:= FCurrentNode.Next;
    Result:= true;
  end;
end;

procedure TLinkedList<T>.TLinkedListEnumerator<T>.Reset;
begin
  FCurrent:= Default(T);
  FCurrentNode:= FList.FFirst;
end;

{ TLinkedList<T>.TLinkedNode }

procedure TLinkedList<T>.TLinkedNode.Assign(const Value: T; List: Pointer);
begin
  FValue:= Value;
  FOwnedList:= List;
  FFreeValue:= true;
end;

constructor TLinkedList<T>.TLinkedNode.Create(const Value: T; List: Pointer);
begin
  FValue:= Value;
  FOwnedList:= List;
  FFreeValue:= true;
end;

procedure TLinkedList<T>.TLinkedNode.Free;
begin
  if FFreeValue then
    Finalize(FValue);
end;

function TLinkedList<T>.TLinkedNode.GetNext: PLinkedNode;
begin
  if Assigned(FNextNode) then
    Result:= FNextNode
  else
    Result:= nil;
end;

function TLinkedList<T>.TLinkedNode.GetPrev: PLinkedNode;
begin
  if Assigned(FPrevNode) then
    if Addr(TLinkedList<T>(FOwnedList).FHead) = FPrevNode then
      Result:= nil
    else
      Result:= FPrevNode
  else
    Result:= nil;
end;

end.
