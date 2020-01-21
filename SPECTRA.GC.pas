unit SPECTRA.GC;

interface

uses SPECTRA.Collections, System.SysUtils;

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
  private
    FLockObject: TObject;
    FGCPairs: IList<TGCPair>;

    procedure Lock;
    procedure UnLock;
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
    procedure Add<T: class>(Item: T; const tag: string = DEFAULT_TAG);
    /// <summary>
    ///  очищает память для объектов с тэгом tag
    /// </summary>
    procedure Collect(const tag: string = DEFAULT_TAG); overload;
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

implementation

uses
  System.TypInfo, SPECTRA.Messages;

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
  FLockObject:= TObject.Create;
  FGCPairs:= TList<TGCPair>.Create;
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

        FreeAndNil(aItem.Value);
      end;
    end);
end;

destructor TGC.Destroy;
begin
  Lock;
  try
    FGCPairs.Clear;
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

  FreeAndNil(FObjectToFree);
  inherited;
end;

{ TGC.TGCPair }

constructor TGC.TGCPair.Create(aKey: string; aValue: TObject; aDispose: boolean);
begin
  Key:= aKey;
  Value:= aValue;
  bDispose:= aDispose;
end;

initialization
  GC:= TGC.Create;
  IGC:= TFreeTheValue.Create(GC);

end.
