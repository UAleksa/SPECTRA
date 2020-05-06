unit SPECTRA.GC;

interface

uses SPECTRA.Messages, System.SysUtils, SPECTRA.Utils, SPECTRA.List;

type
  TCollectPredicate = reference to function (tag: string): Boolean;

  TFreeTheValue = class(TInterfacedObject)
  private
    FObjectToFree: TObject;

  public
    constructor Create(anObjectToFree: TObject);
    destructor Destroy; override;
  end;

  TGC = class
  private const
    DEFAULT_TAG = 'DEFAULT_TAG';
  private type
    TGCPair = record
      Key: string;
      Value: TObject;
      bDispose: boolean;
    public
      constructor Create(aKey: string; aValue: TObject; aDispose: boolean);
    end;

    TOwnerPair = record
      Hash: string;
      Tag: string;
    public
      constructor Create(aHash: string; aTag: string);
    end;
  private
    FSubscribed: boolean;
    FLockObject: TObject;
    FGCPairs: IList<TGCPair>;
    FOwnPairs: IList<TOwnerPair>; //ILinkedList<TOwnerPair>;

    procedure Lock;
    procedure UnLock;
    function Listener(const MessageID: NativeUInt; const Msg: TMessage): NativeInt;
  protected
    constructor Create;
    destructor Destroy; override;
  public
    class function GetInstance: TGC; static;

    /// <summary>
    ///  помещает объект в коллекцию с тэгом tag, если тэг не указан,
    ///  то в качестве тэга используется наименование класса добавляемого объекта
    /// </summary>
    /// <remarks>
    ///   Пример: aList:= TStringList.Create;
    ///           Add&lt;TStringList&gt;(aList);
    /// </remarks>
    procedure Add<T: class>(Item: T; const tag: string = DEFAULT_TAG); overload;

    procedure Add<T: class>(Item: T; aOwner: TObject; const tag: string = DEFAULT_TAG);  overload;
    /// <summary>
    ///  очищает память для объектов с тэгом tag
    /// </summary>
    procedure Collect(const tag: string = DEFAULT_TAG); overload;

    procedure Collect(const tags: TArray<string>); overload;
    /// <summary>
    ///  очищает память для объектов с тэгом tag = ClassName
    /// </summary>
    procedure Collect<T: class>; overload;
    /// <summary>
    ///  очищает память для объектов, которые удовлетворяют условию Predicate
    /// </summary>
    /// <remarks>
    ///  Collect(function(tag: string) boolean
    ///          begin
    ///            Result:= tag = Какое-то значение
    ///          end);
    /// </remarks>
    procedure Collect(const Predicate: TCollectPredicate); overload;
    /// <summary>
    ///  Освобождает объект и удаляет его из коллекции
    /// </summary>
    procedure FreeObject(Obj: TObject);
    /// <summary>
    ///  возвращает true, если Obj находится в коллекции объектов
    /// </summary>
    function IsInCollection(Obj: TObject): boolean;
    /// <summary>
    ///  функция для автоматического освобождения памяти для локальных переменных
    ///  (память переменной будет освобождена при выходе из функции)
    /// </summary>
    /// <remarks>
    ///   Пример: MakeLocal&lt;TStringList&gt;(aList, TStringList.Create);
    /// </remarks>
    function MakeLocal<T: class>(var Variable: T; const Created: T): IInterface;
    /// <summary>
    ///  помещает объект в коллекцию с тэгом tag и возвращет экземпляр объекта, если тэг не указан,
    ///  то в качестве тэга используется наименование класса добавляемого объекта
    /// </summary>
    /// <remarks>
    ///   Пример: aList:= Make&lt;TStringList&gt;(TStringList.Create);
    /// </remarks>
    function Make<T: class>(Item: T; const tag: string = DEFAULT_TAG): T;
    /// <summary>
    ///  выделяет с последующим освобождением память System.New ->  New<T>(Pointer);
    /// </summary>
    procedure New<T>(var AllocPointer: Pointer; const tag: string = DEFAULT_TAG);
    /// <summary>
    ///  Возвращает массив объектов по метке Tag
    /// </summary>
    function ObjectsByTag(Tag: string): TArray<TObject>;
    /// <summary>
    ///  Возвращает объект по метке Tag
    /// </summary>
    function ObjectByTag(Tag: string): TObject;

    procedure Remove(Tag: string);
    /// <summary>
    ///  Возвращает метку объекта Obj в коллекции.
    ///  Если объект не найден, то возвращается пустая строка
    /// </summary>
    function Tag(Obj: TObject): string;
  end;

var
  GC: TGC;
  GCHash: NativeUInt;

implementation

uses
  System.TypInfo, SPECTRA.Consts, Winapi.Windows;

var
  IGC: IInterface;

{ TGarbageCollector }

procedure TGC.Add<T>(Item: T; const tag: string);
var
  fItem: TGCPair;
  sTag: string;
begin
  Lock;
  try
    if tag <> DEFAULT_TAG then
      sTag:= tag
    else
      {$IFDEF MSWINDOWS}
      sTag:= PTypeInfo(TypeInfo(T))^.Name;
      {$ELSE}
      sTag:= PTypeInfo(TypeInfo(T))^.Name.ToString;
      {$ENDIF MSWINDOWS}


    if not FGCPairs.FindItem(fItem,
      function(aItem: TGCPair): boolean
      begin
        Result:= Pointer(aItem.Value) = Pointer(Item)
      end)
    then
      FGCPairs.Add(TGCPair.Create(sTag, Item, false));
  finally
    UnLock;
  end;
end;

procedure TGC.Add<T>(Item: T; aOwner: TObject; const tag: string);
var
  fItem: TGCPair;
  sTag: string;
begin
  Lock;
  try
    if tag <> DEFAULT_TAG then
      sTag:= tag
    else
      {$IFDEF MSWINDOWS}
      sTag:= PTypeInfo(TypeInfo(T))^.Name;
      {$ELSE}
      sTag:= PTypeInfo(TypeInfo(T))^.Name.ToString;
      {$ENDIF MSWINDOWS}


    if not FGCPairs.FindItem(fItem,
      function(aItem: TGCPair): boolean
      begin
        Result:= Pointer(aItem.Value) = Pointer(Item)
      end)
    then
    begin
      if not FSubscribed then
      begin
        Msgs.Subscribe(Self, CM_DESTROING, Listener);
        FSubscribed:= true;
      end;
      FGCPairs.Add(TGCPair.Create(sTag, Item, false));

      if Assigned(aOwner) then
        FOwnPairs.Add(TOwnerPair.Create(aOwner.GetHashCode.ToString,sTag));
    end;
  finally
    UnLock;
  end;
end;

procedure TGC.Collect(const tag: string);
begin
  Lock;
  try
    FGCPairs.Delete(
      function(aItem: TGCPair): boolean
      begin
        Result:= AnsiSameText(aItem.Key, tag);
      end, nil);
  finally
    UnLock;
  end;
end;

procedure TGC.Collect(const Predicate: TCollectPredicate);
var
  I: Integer;
begin
  Lock;
  try
    for I:= FGCPairs.Count-1 downto 0 do
      if Predicate(string(FGCPairs[I].Key)) then
        FGCPairs.Delete(I);
  finally
    UnLock;
  end;
end;

procedure TGC.Collect(const tags: TArray<string>);
var
  I: Integer;
  J: Integer;
begin
  if Length(tags) = 0 then Exit;

  Lock;
  try
    for I:= FGCPairs.Count-1 downto 0 do
      for J := Low(tags) to High(tags) do
        if SameText(FGCPairs[I].Key, tags[J]) then
        begin
          FGCPairs.Delete(I);
          Break;
        end;
  finally
    UnLock;
  end;
end;

procedure TGC.Collect<T>;
begin
  {$IFDEF MSWINDOWS}
  Collect(PTypeInfo(TypeInfo(T)).Name);
  {$ELSE}
  Collect(PTypeInfo(TypeInfo(T))^.Name.ToString);
  {$ENDIF MSWINDOWS}
end;

constructor TGC.Create;
begin
  FSubscribed:= false;
  FLockObject:= TObject.Create;
  FGCPairs:= TList<TGCPair>.Create;
  FOwnPairs:= TList<TOwnerPair>.Create;; //TLinkedList<TOwnerPair>.Create;

  FGCPairs.DefaultFreeItem(
    procedure(aItem: TGCPair)
    begin
      aItem.Key:= '';
      if aItem.bDispose then
        Dispose(Pointer(aItem.Value))
      else
      begin
        if Msgs.IsSubscribed(aItem.Value) then
          Msgs.UnSubscribe(aItem.Value, true);

        if Assigned(aItem.Value) then
          SPECTRA.Utils.FreeObject(aItem.Value);
      end;
    end);

  //FOwnPairs.DefaultFreeNode(
  FOwnPairs.DefaultFreeItem(
    procedure(aItem: TOwnerPair)
    begin
      aItem.Hash:= '';
      aItem.Tag:= '';
    end);
end;

destructor TGC.Destroy;
begin
  Lock;
  try
    FGCPairs.Clear;
    FOwnPairs.Clear;

    inherited;
  finally
    UnLock;
    FLockObject.Free;
  end;
end;

procedure TGC.FreeObject(Obj: TObject);
begin
  Lock;
  try
    FGCPairs.Delete(
      function (aItem: TGCPair): boolean
      begin
        Result:= aItem.Value = Obj;
      end, nil);
  finally
    UnLock;
  end;
end;

class function TGC.GetInstance: TGC;
begin
  Result:= GC;
end;

function TGC.IsInCollection(Obj: TObject): boolean;
var
  Item: TGCPair;
begin
  Result:= FGCPairs.FindItem(Item,
            function (aItem: TGCPair): boolean
            begin
              Result:= aItem.Value = Obj;
            end)
end;

function TGC.Listener(const MessageID: NativeUInt;
  const Msg: TMessage): NativeInt;
var
  Tags: TArray<string>;
  Hash: string;
begin
  if Msg is TMessage<NativeUInt> then
    if MessageID = CM_DESTROING then
    begin
      Hash:= (Msg as TMessage<NativeUInt>).Value.ToString;

      FOwnPairs.ToCustom(procedure(Item: TOwnerPair)
                         begin
                           if SameStr(Item.Hash, Hash) then
                           begin
                             SetLength(Tags, Length(Tags)+1);
                             Tags[High(Tags)]:= Item.Tag;
                           end;
                         end);

      if Length(Tags) > 0 then
        Collect(Tags);
    end;
end;

procedure TGC.Lock;
begin
  TMonitor.Enter(FLockObject);
end;

function TGC.Make<T>(Item: T; const tag: string): T;
var
  fItem: TGCPair;
  sTag: string;
begin
  Lock;
  try
    if tag <> DEFAULT_TAG then
      sTag:= tag
    else
      {$IFDEF MSWINDOWS}
      sTag:= PTypeInfo(TypeInfo(T))^.Name;
      {$ELSE}
      sTag:= PTypeInfo(TypeInfo(T))^.Name.ToString;
      {$ENDIF MSWINDOWS}

    if not FGCPairs.FindItem(fItem,
      function(aItem: TGCPair): boolean
      begin
        Result:= Pointer(aItem.Value) = Pointer(Item)
      end)
    then
    begin
      FGCPairs.Add(TGCPair.Create(sTag, Item, false));
      Result:= Item;
    end;
  finally
    UnLock;
  end;
end;

function TGC.MakeLocal<T>(var Variable: T; const Created: T): IInterface;
begin
  Result:= TFreeTheValue.Create(Created);
  Variable:= Created;
end;

procedure TGC.New<T>(var AllocPointer: Pointer; const tag: string);
type
  P = ^T;
begin
  Lock;
  try
    System.New(P(AllocPointer));
    FGCPairs.Add(TGCPair.Create(tag, AllocPointer, true));
  finally
    UnLock;
  end;
end;

function TGC.ObjectByTag(Tag: string): TObject;
var
  Item: TGCPair;
begin
  Result:= nil;

  if FGCPairs.FindItem(Item,
       function(aItem: TGCPair): boolean
       begin
         Result:= AnsiSameText(aItem.Key, Tag);
       end)
  then
    Result:= Item.Value;
end;

function TGC.ObjectsByTag(Tag: string): TArray<TObject>;
var
  Objs: TArray<TObject>;
  I: Integer;
begin
  Result:= nil;

  FGCPairs.ToCustom(
    procedure (aItem: TGCPair)
    begin
      if AnsiSameStr(aItem.Key, Tag) then
      begin
        SetLength(Objs, High(Objs)+2);
        Objs[High(Objs)]:= aItem.Value;
      end;
    end);

  if Length(Objs) > 0 then
  begin
    SetLength(Result, Length(Objs));
    for I := Low(Objs) to High(Objs) do
      Result[I]:= Objs[I];
  end;
end;

procedure TGC.Remove(Tag: string);
var
  I: Integer;
begin
  I:= FGCPairs.IndexOf(
    function(aItem: TGCPair): boolean
    begin
      Result:= AnsiSameText(aItem.Key, Tag);
    end);

  if I > -1 then
    FGCPairs.Extract(I);
end;

function TGC.Tag(Obj: TObject): string;
var
  Item: TGCPair;
begin
  Result:= '';

  if FGCPairs.FindItem(Item,
       function (aItem: TGCPair): boolean
       begin
         Result:= aItem.Value = Obj;
       end)
  then
    Result:= Item.Key;
end;

procedure TGC.UnLock;
begin
  TMonitor.Exit(FLockObject);
end;

{ TFreeTheValue }

constructor TFreeTheValue.Create(anObjectToFree: TObject);
begin
  FObjectToFree:= anObjectToFree;
end;

destructor TFreeTheValue.Destroy;
begin
  if Msgs.IsSubscribed(FObjectToFree) then
    Msgs.UnSubscribe(FObjectToFree, true);

  if GCHash = FObjectToFree.GetHashCode then
    FreeAndNil(FObjectToFree)
  else
    SPECTRA.Utils.FreeObject(FObjectToFree);
  inherited;
end;

{ TGC.TGCPair }

constructor TGC.TGCPair.Create(aKey: string; aValue: TObject; aDispose: boolean);
begin
  Key:= aKey;
  Value:= aValue;
  bDispose:= aDispose;
end;

{ TGC.TOwnerPair }

constructor TGC.TOwnerPair.Create(aHash, aTag: string);
begin
  Hash:= aHash;
  Tag:= aTag;
end;

initialization
  GC:= TGC.Create;
  GCHash:= GC.GetHashCode;
  IGC:= TFreeTheValue.Create(GC);

end.
