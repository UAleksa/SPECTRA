unit SPECTRA.List;

interface

uses
  System.Types, SPECTRA.Enumerable, System.Generics.Defaults, System.SysUtils;

type
  TDuplicateFunc<T> = reference to function (Item: T; NewItem: T): Boolean;

  IList<T> = interface
  ['{6CBAD8B4-819D-4BF1-8520-2A522C6D7C6B}']
  //private
    function GetItem(Index: Integer): T;
    function GetCount: Integer;
    function GetDuplicates: TDuplicates;
    function GetDuplicateProc: TDuplicateFunc<T>;
    procedure SetItem(Index: Integer; const Value: T);
    procedure SetDuplicates(const Value: TDuplicates);
    procedure SetDuplicateProc(DuplicateProc: TDuplicateFunc<T>);
    function GetEnumerable: ISPEnumerable<T>;
    function GetSorted: boolean;
    procedure SetSorted(const Sorted: boolean);
    function GetThreaded: boolean;
    procedure SetThreaded(const Threaded: boolean);
    function GetReversed: boolean;
    procedure SetReversed(const Reversed: boolean);
    function GetAllocBy: Integer;
    procedure SetAllocBy(const AllocBy: Integer);
    procedure SetSortComparer(const Comparer: IComparer<T>);
    function GetComparer: IComparer<T>;
  //public
      /// <summary>
      ///  Добавляет элемент в список
      /// </summary>
    function Add(const Value: T): integer;
       /// <summary>
       ///  Добавляет массив элементов в список
       /// </summary>
    procedure AddRange(Range: TArray<T>);
       /// <summary>
       ///  Очищает список
       /// </summary>
    procedure Clear; overload;
       /// <summary>
       ///  Очищает список применяя к каждому элементу процедуру Proc и DefaultFreeItem, если доступны
       /// </summary>
    procedure Clear(Proc: TProc<T>); overload;
       /// <summary>
       ///  Возвращает true, если элемент Value найден в списке, иначе false
       /// </summary>
    function Contains(const Value: T): boolean; overload;
       /// <summary>
       ///  Возвращает true, если Predicate вернул true, иначе false
       /// </summary>
    function Contains(const Predicate: TPredicate<T>): boolean; overload;
       /// <summary>
       ///  Задает процедуру Proc для освобождения элементов в списке
       /// </summary>
    procedure DefaultFreeItem(Proc: TProc<T>);
       /// <summary>
       ///  Удаляет элемент с индексом из списка, применяя DefaultFreeItem, если доступна
       /// </summary>
    procedure Delete(index: Integer); overload;
       /// <summary>
       ///  Удаляет элементы с индексами indexes из списка, применяя DefaultFreeItem, если доступна
       /// </summary>
    procedure Delete(indexes: TArray<Integer>); overload;
       /// <summary>
       ///  Удаляет элемент с индексом из списка, применяя процедуры Proc и DefaultFreeItem, если доступны
       /// </summary>
    procedure Delete(index: Integer; Proc: TProc<T>); overload;
       /// <summary>
       ///  Удаляет из списка элементы, которые удовлетворяют условию Predicate,
       ///  применяя процедуры Proc и DefaultFreeItem, если доступны
       /// </summary>
    procedure Delete(Predicate: TPredicate<T>; Proc: TProc<T>); overload;
       /// <summary>
       ///  Меняет местами элементы с индексами Index1 и Index2
       /// </summary>
    procedure Exchange(Index1, Index2: integer);
       /// <summary>
       ///  Извлекает из списка элемент с порядковым номером Index
       /// </summary>
    function Extract(Index: Integer): T;
       /// <summary>
       ///  Возвращает массив индексов элементов, которые удовлетворяют условию Predicate
       /// </summary>
    function FilteredIndexes(Predicate: TPredicate<T>): TArray<Integer>;
       /// <summary>
       ///  Возвращает true, если найден элемент удовлетворяющий условию Predicate, иначе false
       /// </summary>
       /// <param name="Item">
       ///   Найденный элемент
       /// </param>
    function FindItem(var Item: T; const Predicate: TPredicate<T>): boolean;
       /// <summary>
       ///  Ищет в списке элемент удовлетворяющий условию Predicate.
       ///  Если элемент найден, возвращает его порядковый номер, иначе -1.
       ///  Direction задает направление поиска: FromBeginning (по умолчанию) - с начала списка; FromEnd - с конца списка.
       /// </summary>
    function IndexOf(const Predicate: TPredicate<T>; Direction: TDirection=FromBeginning): Integer; overload;
       /// <summary>
       ///  Ищет Value в списке с применением компаратора AComparer.
       ///  Value - правый параметр в компатараторе
       ///  Если элемент найден, возвращает его порядковый номер, иначе -1.
       /// </summary>
    function IndexOf(const Value: T; const AComparer: IComparer<T>): integer; overload;
       /// <summary>
       ///  Ищет Value в списке. Если элемент найден, возвращает его порядковый номер, иначе -1.
       ///  Direction задает направление поиска: FromBeginning (по умолчанию) - с начала списка; FromEnd - с конца списка.
       /// </summary>
    function IndexOf(const Value: T; Direction: TDirection=FromBeginning): integer; overload;
       /// <summary>
       ///  Вставляет элемент в список в позицию index
       /// </summary>
    procedure Insert(index: Integer; Value: T);
       /// <summary>
       ///  Вставляет массив элементов в список начиная с позиции index
       /// </summary>
    procedure InsertRange(index: Integer; Range: TArray<T>);
       /// <summary>
       ///  Возвращает true если список пустой
       /// </summary>
    function IsEmpty: boolean;
       /// <summary>
       ///  Ищет в списке первый элемент OldItem и заменяет его на NewItem
       /// </summary>
    procedure Replace(const OldItem: T; const NewItem: T); overload;
       /// <summary>
       ///  Ищет в списке элементы удовлетворяющие условию Predicate и заменяет их на NewItem
       /// </summary>
    procedure Replace(Predicate: TPredicate<T>; const NewItem: T); overload;
       /// <summary>
       ///  Ищет в списке элемент с номером Index и заменяет его на NewItem
       /// </summary>
    procedure ReplaceByIndex(const Index: Integer; const NewItem: T);
       /// <summary>
       ///  Перемешивает элементы в списке
       /// </summary>
    procedure Shuffle;
       /// <summary>
       ///  Сортирует список
       /// </summary>
    procedure Sort; overload;
       /// <summary>
       ///  Сортирует список с применением компаратора AComparer
       /// </summary>
    procedure Sort(const AComparer: IComparer<T>); overload;
       /// <summary>
       ///  Возвращает массив элементов
       /// </summary>
    function ToArray: TArray<T>; overload;

    function ToArray(const Predicate: TPredicate<T>): TArray<T>; overload;
       /// <summary>
       ///  Проходит все элементы в списке, применяя к каждому процедуру Proc
       /// </summary>
    procedure ToCustom(Proc: TProc<T>);

       /// <summary>
       ///  Возвращает перечислитель используемый для итерации элементов списка
       /// </summary>
    function GetEnumerator: ISPEnumerator<T>;

       /// <summary>
       ///  Задает количество элементов, на которое должен увеличиваться список. По умолчанию равно 0.
       /// </summary>
    property AllocBy: Integer read GetAllocBy write SetAllocBy;
       /// <summary>
       ///  Возвращает количество элементов в списке
       /// </summary>
    property Count: Integer read GetCount;
       /// <summary>
       ///  Условие, по которому будут выявляться дубликаты в списке
       /// </summary>
    property DuplicateProc: TDuplicateFunc<T> read GetDuplicateProc write SetDuplicateProc;
       /// <summary>
       ///  Указывает, то как список должен работать с повторяющимися элементами:
       ///  dupIgnore - игнорирует добавление дубликатов в список;
       ///  dupAccept - позволяет добавлять дубликаты в список;
       ///  dupError - вызывает исключение при попытке добавления дубликатов в список.
       ///  Изменение значения свойства влияет только на вновь добавляемые элементы.
       /// </summary>
    property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
       /// <summary>
       ///  Возвращает ссылку на IULAEnumerable<T>
       /// </summary>
    property Enumerable: ISPEnumerable<T> read GetEnumerable;
       /// <summary>
       ///  Возвращает ссылки на элементы списка по их позиции
       /// </summary>
    property Items[I: Integer]: T read GetItem write SetItem; default;
       /// <summary>
       ///  Указывает порядок элементов в списке: true - обратный; false(по умолчанию) - прямой.
       /// </summary>
    property Reversed: boolean read GetReversed write SetReversed;
       /// <summary>
       ///  Задает компаратор по умолчанию для сортировки элементов списка
       /// </summary>
    property SortComparer: IComparer<T> read GetComparer write SetSortComparer;
       /// <summary>
       ///  Указывает, следует ли автоматически сортировать строки в списке
       /// </summary>
    property Sorted: boolean read GetSorted write SetSorted;
       /// <summary>
       ///  Указывает, следует ли списку работать в потокобезопасном режиме
       /// </summary>
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

  TList<T> = class(TInterfacedObject, IList<T>)
  private type
    TIListEnumerator<T> = class(TInterfacedObject, ISPEnumerator<T>)
    private
      FList: TList<T>;
      FIndex: Integer;
      FCurrent: T;
      FCurrentIndex: Integer;

      function Clone: ISPEnumerator<T>;
      procedure Reset;
      function GetCurrent: T;
      function GetCurrentIndex: Integer;
    public
      constructor Create(const AList: TList<T>);

      function MoveNext: Boolean;
      property Current: T read GetCurrent;
      property CurrentIndex: Integer read GetCurrentIndex;
    end;
  private
    FCount: Integer;
    FCapacity: Integer;
    FItems: TArray<T>;
    FComparer: IComparer<T>;
    FDuplicates: TDuplicates;
    FDefaultFreeProc: TProc<T>;
    FAllocBy: Integer;
    FDuplicateProc: TDuplicateFunc<T>;
    FSorted: boolean;
    FThreaded: boolean;
    FLockObject: TObject;
    FReversed: boolean;
    FTypeInfo: Pointer;

    function GrowCollection(OldCapacity, NewCount: Integer): Integer;
    procedure Grow;
    function GetEnumerable: ISPEnumerable<T>;
    procedure Lock;
    procedure UnLock;
    function InnerAdd(const Value: T; bLock: boolean=false): integer;
    procedure InnerDelete(index: Integer; Proc: TProc<T>; bLock: boolean=false);
    function InnerExtract(index: Integer; bLock: boolean=false): T;
    procedure InnerInsert(index: Integer; Value: T; bLock: boolean=false);
    procedure DoInsert(Index: Integer; Value: T);
    procedure DoDelete(Index: Integer);
    procedure InnerSort(bLock: boolean=false);
    procedure InnerExchange(Index1, Index2: integer; bLock: boolean=false);
    function GetSortedPos(Value: T): Integer;
    function CalcIndex(Index: Integer): Integer; inline;
  protected
    function GetItem(Index: Integer): T;
    function GetCount: Integer;
    function GetDuplicates: TDuplicates;
    function GetDuplicateProc: TDuplicateFunc<T>;
    procedure SetItem(Index: Integer; const Value: T);
    procedure SetDuplicates(const Value: TDuplicates);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetDuplicateProc(DuplicateProc: TDuplicateFunc<T>);
    function CheckDuplicates(const Item: T): boolean;
    function GetSorted: boolean;
    procedure SetSorted(const Sorted: boolean);
    function GetThreaded: boolean;
    procedure SetThreaded(const Threaded: boolean);
    function GetReversed: boolean;
    procedure SetReversed(const Reversed: boolean);
    function GetAllocBy: Integer;
    procedure SetAllocBy(const AllocBy: Integer);
    procedure SetSortComparer(const Comparer: IComparer<T>);
    function GetComparer: IComparer<T>;
  public
    constructor Create;
    destructor Destroy; override;

    function Add(const Value: T): integer;
    procedure AddRange(Range: TArray<T>);
    procedure DefaultFreeItem(Proc: TProc<T>);
    procedure Clear; overload;
    procedure Clear(Proc: TProc<T>); overload;
    procedure Delete(index: Integer); overload;
    procedure Delete(indexes: TArray<Integer>); overload;
    procedure Delete(index: Integer; Proc: TProc<T>); overload;
    procedure Delete(Predicate: TPredicate<T>; Proc: TProc<T>); overload;
    function Extract(Index: Integer): T;
    procedure Exchange(Index1, Index2: integer);
    procedure Replace(const OldItem: T; const NewItem: T); overload;
    procedure Replace(Predicate: TPredicate<T>; const NewItem: T); overload;
    procedure ReplaceByIndex(const Index: Integer; const NewItem: T);
    procedure Insert(index: Integer; Value: T);
    procedure InsertRange(index: Integer; Range: TArray<T>);
    function IndexOf(const Predicate: TPredicate<T>; Direction: TDirection=FromBeginning): Integer; overload;
    function IndexOf(const Value: T; Direction: TDirection=FromBeginning): integer; overload;
    function IndexOf(const Value: T; const AComparer: IComparer<T>): integer; overload;
    function Contains(const Value: T): boolean; overload;
    function Contains(const Predicate: TPredicate<T>): boolean; overload;
    function IsEmpty: boolean;
    procedure Shuffle;
    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    function FilteredIndexes(Predicate: TPredicate<T>): TArray<Integer>;
    function FindItem(var Item: T; const Predicate: TPredicate<T>): boolean;

    function ToArray: TArray<T>; overload;
    function ToArray(const Predicate: TPredicate<T>): TArray<T>; overload;
    procedure ToCustom(Proc: TProc<T>);

    function GetEnumerator: ISPEnumerator<T>;

    property AllocBy: Integer read GetAllocBy write SetAllocBy;
    property Count: Integer read GetCount;
    property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
    property DuplicateProc: TDuplicateFunc<T> read GetDuplicateProc write SetDuplicateProc;
    property Enumerable: ISPEnumerable<T> read GetEnumerable;
    property Items[I: Integer]: T read GetItem write SetItem; default;
    property Reversed: boolean read GetReversed write SetReversed;
    property Sorted: boolean read GetSorted write SetSorted;
    property SortComparer: IComparer<T> read GetComparer write SetSortComparer;
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

  TSubList<T> = class(TList<T>)
  public
    destructor Destroy; override;
    procedure Free;
  end;

  E_SPECTRA_ListException = class(Exception);

implementation

uses
  System.Generics.Collections, SPECTRA.Consts, System.Rtti;

function TList<T>.Add(const Value: T): integer;
begin
  Result:= InnerAdd(Value, true);
end;

procedure TList<T>.AddRange(Range: TArray<T>);
var
  I: Integer;
begin
  Lock;
  try
    if Length(Range) > 0 then
      for I := Low(Range) to High(Range) do
        InnerAdd(Range[I]);
  finally
    UnLock;
  end;
end;

function TList<T>.CalcIndex(Index: Integer): Integer;
begin
  if FReversed then
    Result:= FCount - Index - 1
  else
    Result:= Index;
end;

function TList<T>.CheckDuplicates(const Item: T): boolean;
var
  aItem: T;
  I: Integer;
begin
  Result:= false;

  if Assigned(FDuplicateProc) then
  begin
    if FCount > 0 then
      for I := 0 to FCount-1 do
        if FDuplicateProc(FItems[I], Item) then
        begin
          case FDuplicates of
            dupIgnore: Exit;
            dupError: raise E_SPECTRA_ListException.CreateRes(@sDuplicatesNotAllowed);
          end;

          Break;
        end;
  end else
    if IndexOf(Item) > -1 then
      case FDuplicates of
        dupIgnore: Exit;
        dupError: raise E_SPECTRA_ListException.CreateRes(@sDuplicatesNotAllowed);
      end;

  Result:= true;
end;

procedure TList<T>.Clear;
begin
  Clear(nil);
end;

procedure TList<T>.Clear(Proc: TProc<T>);
var
  I: Integer;
begin
  Lock;
  try
    if FCount > 0 then
      if Assigned(Proc) or Assigned(FDefaultFreeProc) then
        for I := 0 to FCount-1 do
        begin
          if Assigned(Proc) then Proc(FItems[I]);
          if Assigned(FDefaultFreeProc) then FDefaultFreeProc(FItems[I]);
        end;

    FCount:= 0;
    SetCapacity(0);
  finally
    UnLock;
  end;
end;

function TList<T>.Contains(const Value: T): boolean;
begin
  Result:= IndexOf(Value) > -1;
end;

function TList<T>.Contains(const Predicate: TPredicate<T>): boolean;
var
  I: Integer;
begin
  Result:= false;
  if FCount > 0 then
  begin
    for I := 0 to FCount-1 do
      if Predicate(FItems[I]) then
      begin
        Result:= true;
        Break;
      end;
  end;
end;

constructor TList<T>.Create;
begin
  inherited Create;

  FAllocBy:= 0;
  FCount:= 0;
  FCapacity:= 0;
  FDuplicateProc:= nil;
  FDefaultFreeProc:= nil;
  FDuplicates:= dupAccept;
  FComparer:= TComparer<T>.Default;
  FItems:= nil;
  FSorted:= false;
  FThreaded:= false;
  FLockObject:= TObject.Create;
  FReversed:= false;
  FTypeInfo:= TypeInfo(TArray<T>);
end;

procedure TList<T>.DefaultFreeItem(Proc: TProc<T>);
begin
  FDefaultFreeProc:= Proc;
end;

procedure TList<T>.Delete(indexes: TArray<Integer>);
var
  I: Integer;
  aIndexes: TArray<Integer>;
begin
  if Length(indexes) = 0 then Exit;

  Lock;
  try
    SetLength(aIndexes, Length(indexes));
    TArray.Copy<Integer>(indexes, aIndexes, Length(indexes));
    TArray.Sort<Integer>(aIndexes);

    for I := High(aIndexes) to Low(aIndexes) do
      InnerDelete(aIndexes[I], nil);
  finally
    UnLock;
  end;
end;

procedure TList<T>.Delete(index: Integer; Proc: TProc<T>);
begin
  InnerDelete(index, Proc, true);
end;

procedure TList<T>.Delete(Predicate: TPredicate<T>; Proc: TProc<T>);
var
  I: Integer;
begin
  Lock;
  try
    if not Assigned(Predicate) then Exit;

    for I := FCount-1 downto 0 do
      if Predicate(FItems[I]) then
        InnerDelete(I,Proc)
  finally
    UnLock;
  end;
end;

procedure TList<T>.Delete(index: Integer);
begin
  InnerDelete(index, nil, true);
end;

destructor TList<T>.Destroy;
begin
  Lock;
  try
    FItems:= nil;
    FCount:= 0;
    inherited;
  finally
    UnLock;
    FLockObject.Free;
  end;
end;

procedure TList<T>.DoDelete(Index: Integer);
var
  ElemSize: NativeInt;
  aItems: Pointer;
  TypeKind: TTypeKind;
  ElType: Pointer;
begin
  aItems:= FItems;
  ElemSize:= SizeOf(T);

  if IsManagedType(T) then
  begin
    TypeKind:= GetTypeKind(T);
    case TypeKind of
      TTypeKind.tkUString,
      TTypeKind.tkDynArray,
      TTypeKind.tkInterface,
      TTypeKind.tkLString,
      TTypeKind.tkWString:
        begin
          PPointer(@FItems[Index])^:= nil;
          Move(FItems[Index + 1], FItems[Index], (FCount - Index) * SizeOf(Pointer));
        end;
      TTypeKind.tkVariant:
        begin
          FillChar(FItems[Index], SizeOf(Variant), 0);
          Move(FItems[Index + 1], FItems[Index], (FCount - Index) * SizeOf(Variant));
        end;
    else
      begin
        Finalize(FItems[Index]);
        FTypeInfo:= TypeInfo(TArray<T>);
        ElType:= PDynArrayTypeInfo(PByte(FTypeInfo) + PDynArrayTypeInfo(FTypeInfo).Name).elType^;
        FillChar(PByte(aItems)[Index * ElemSize], ElemSize, 0);
        Move(PByte(aItems)[(Index + 1) * ElemSize], PByte(aItems)[Index * ElemSize], (FCount - Index) * ElemSize);
      end;
    end;
  end else
  begin
    //Finalize(FItems[Index]);
    FillChar(FItems[Index], ElemSize, 0);
    Move(FItems[Index + 1], FItems[Index], (FCount - Index) * ElemSize);
  end;
end;

procedure TList<T>.DoInsert(Index: Integer; Value: T);
var
  ElemSize: NativeInt;
  aItems: Pointer;
  TypeKind: TTypeKind;
  ElType: Pointer;
begin
  aItems:= FItems;
  ElemSize:= SizeOf(T);

  if IsManagedType(T) then
  begin
    TypeKind:= GetTypeKind(T);
    case TypeKind of
      TTypeKind.tkUString,
      TTypeKind.tkDynArray,
      TTypeKind.tkInterface,
      TTypeKind.tkLString,
      TTypeKind.tkWString:
        begin
          Move(FItems[Index], FItems[Index + 1], (FCount - Index) * SizeOf(Pointer));
          PPointer(@FItems[Index])^:= nil;
          FItems[Index]:= Value;
        end;
      TTypeKind.tkVariant:
        begin
          Move(FItems[Index], FItems[Index + 1], (FCount - Index) * SizeOf(Variant));
          FillChar(FItems[Index], SizeOf(Variant), 0);
          FItems[Index]:= Value;
        end;
    else
      begin
        FTypeInfo:= TypeInfo(TArray<T>);
        ElType:= PDynArrayTypeInfo(PByte(FTypeInfo) + PDynArrayTypeInfo(FTypeInfo).Name).elType^;
        Move(PByte(aItems)[Index * ElemSize], PByte(aItems)[(Index + 1) * ElemSize], (FCount - Index) * ElemSize);
        FillChar(PByte(aItems)[Index * ElemSize], ElemSize, 0);
        System.CopyArray(@PByte(aItems)[Index * ElemSize], @Value, ElType, 1);
      end;
    end;
  end else
  begin
    Move(FItems[Index], FItems[Index + 1], (FCount - Index) * ElemSize);
    FItems[Index]:= Value;
  end;
end;

procedure TList<T>.Exchange(Index1, Index2: integer);
begin
  InnerExchange(Index1, Index2, true);
end;

function TList<T>.Extract(Index: Integer): T;
begin
  Result:= InnerExtract(Index, true);
end;

function TList<T>.FilteredIndexes(Predicate: TPredicate<T>): TArray<Integer>;
var
  I: Integer;
  Index: Integer;
begin
  Result:= nil;

  if FCount > 0 then
    for I := 0 to FCount-1 do
    begin
      Index:= CalcIndex(I);

      if Predicate(FItems[I]) then
      begin
        SetLength(Result, High(Result)+2);
        Result[High(Result)]:= I;
      end;
    end;
end;

function TList<T>.FindItem(var Item: T; const Predicate: TPredicate<T>): boolean;
var
  I: Integer;
  Index: Integer;
begin
  Result:= false;
  if FCount > 0 then
  begin
    for I := 0 to FCount-1 do
    begin
      Index:= CalcIndex(I);

      if Predicate(FItems[Index]) then
      begin
        Item:= FItems[Index];
        Result:= true;
        Break;
      end;
    end;
  end;
end;

function TList<T>.GetAllocBy: Integer;
begin
  Result:= FAllocBy;
end;

function TList<T>.GetComparer: IComparer<T>;
begin
  Result:= FComparer;
end;

function TList<T>.GetCount: Integer;
begin
  Result:= FCount;
end;

function TList<T>.GetDuplicateProc: TDuplicateFunc<T>;
begin
  Lock;
  try
    Result:= FDuplicateProc;
  finally
    UnLock;
  end;
end;

function TList<T>.GetDuplicates: TDuplicates;
begin
  Result:= FDuplicates;
end;

function TList<T>.GetEnumerable: ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(Self as TList<T>);
end;

function TList<T>.GetEnumerator: ISPEnumerator<T>;
var
  AContext: TRttiContext;
begin
  AContext:= TRttiContext.Create;
  try
    if AContext.GetType(TypeInfo(T)).TypeKind = tkClass then
      ISPEnumerator<T>(Result):= TIListEnumerator<T>.Create(Self)
    else
      Result:= TIListEnumerator<T>.Create(Self)
  finally
    AContext.Free;
  end;
end;

function TList<T>.GetItem(Index: Integer): T;
var
  I: Integer;
begin
  if (Index < 0) or (Index >= FCount) then
    raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

  I:= CalcIndex(Index);
  Result:= FItems[I];
end;

function TList<T>.GetReversed: boolean;
begin
  Result:= FReversed;
end;

function TList<T>.GetSorted: boolean;
begin
  Result:= FSorted;
end;

function TList<T>.GetSortedPos(Value: T): Integer;
var
  aPos: Integer;
  First: Integer;
  Last: Integer;
Begin
  First:= 0;
  Last:= FCount - 1;

  while First <= Last do
  Begin
    aPos:= (Last + First) div 2;

    if FComparer.Compare(FItems[aPos], Value) = 0 then
    begin
      Result:= aPos;
      Exit;
    end;

    if FReversed then
      if FComparer.Compare(Value, FItems[aPos]) < 0 then
        First:= aPos + 1
      else
        Last:= aPos - 1
    else
      if FComparer.Compare(Value, FItems[aPos]) < 0 then
        Last:= aPos - 1
      else
        First:= aPos + 1;
  end;

  if FReversed then
    Result:= First
  else
    Result:= Last + 1
end;

function TList<T>.GetThreaded: boolean;
begin
  Result:= FThreaded;
end;

procedure TList<T>.Grow;
begin
  if FAllocBy <= 0 then
    SetCapacity(GrowCollection(FCapacity, FCount + 1))
  else
    SetLength(FItems, FCount + FAllocBy);
end;

function TList<T>.GrowCollection(OldCapacity, NewCount: Integer): Integer;
begin
  Result := OldCapacity;
  repeat
    if Result > 64 then
      Result := (Result * 3) div 2
    else
      if Result > 8 then
        Result := Result + 16
      else
        Result := Result + 4;
    if Result < 0 then
      OutOfMemoryError;
  until Result >= NewCount;
end;

function TList<T>.IndexOf(const Value: T; Direction: TDirection): integer;
var
  I: Integer;
  Index: Integer;
begin
  Result:= -1;
  if FCount = 0 then Exit;

  if Sorted then
  begin
    if TArray.BinarySearch<T>(FItems, Value, Index, FComparer) then
      Result:= CalcIndex(Index);
  end else
    case Direction of
     FromBeginning: for I:= 0 to FCount-1 do
                    begin
                      Index:= CalcIndex(I);

                      if FComparer.Compare(FItems[Index], Value) = 0 then
                      begin
                        Result:= Index;
                        Break;
                      end;
                    end;
     FromEnd: for I:= FCount-1 downto 0 do
              begin
                Index:= CalcIndex(I);

                if FComparer.Compare(FItems[Index], Value) = 0 then
                begin
                  Result:= Index;
                  Break;
                end;
              end;
    end;
end;

function TList<T>.IndexOf(const Value: T;
  const AComparer: IComparer<T>): integer;
var
  I: Integer;
  Index: Integer;
begin
  Result:= -1;

  if AComparer = nil then Exit;

  if Sorted then
  begin
    if TArray.BinarySearch<T>(FItems, Value, I, AComparer) then
      Result:= CalcIndex(I);

  end else
    for I:= 0 to FCount-1 do
    begin
      Index:= CalcIndex(I);

      if AComparer.Compare(FItems[Index], Value) = 0 then
      begin
        Result:= Index;

        Break;
      end;
    end;
end;

function TList<T>.IndexOf(const Predicate: TPredicate<T>;
  Direction: TDirection): Integer;
var
  I: Integer;
  Index: Integer;
begin
  Result:= -1;
  if FCount = 0 then Exit;
  if not Assigned(Predicate) then Exit;



  case Direction of
   FromBeginning: for I:= 0 to FCount-1 do
                  begin
                    Index:= CalcIndex(I);

                    if Predicate(FItems[Index]) then
                    begin
                      Result:= Index;
                      Break;
                    end;
                  end;
   FromEnd: for I:= FCount-1 downto 0 do
            begin
              Index:= CalcIndex(I);

              if Predicate(FItems[Index]) then
              begin
                Result:= Index;
                Break;
              end;
            end;
  end;
end;

function TList<T>.InnerAdd(const Value: T; bLock: boolean): integer;
var
  InsertIndex: Integer;
begin
  if bLock then Lock;
  try
    Result:= -1;

    if FSorted then
    begin
      InsertIndex:= GetSortedPos(Value);
      InnerInsert(InsertIndex, Value);
    end else
//      if FReversed then
//      begin
//        InnerInsert(0, Value);
//
////        Inc(FCount);
////        if FCount > 0 then
////        begin
////          for I := FCount-1 downto 0 do
////          begin
////            FItems[I]:= FItems[I-1];
////            if I-2 < 0 then Break;
////          end;
////          FItems[0]:= Value;
////        end;
//
//      end else
        InnerInsert(FCount, Value);

    Result:= FCount;

  finally
    if bLock then UnLock;
  end;
end;

procedure TList<T>.InnerDelete(index: Integer; Proc: TProc<T>; bLock: boolean);
var
  I: Integer;
  InnerIndex: Integer;
begin
  if bLock then Lock;
  try
    if (Index < 0) or (Index >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    InnerIndex:= CalcIndex(index);

    if Assigned(Proc) then
      Proc(FItems[InnerIndex])
    else
      if Assigned(FDefaultFreeProc) then
        FDefaultFreeProc(FItems[InnerIndex]);

    DoDelete(InnerIndex);
    Dec(FCount);

//    Dec(FCount);
//    for I := 0 to FCount-InnerIndex-1 do
//      FItems[I+InnerIndex]:= FItems[I+InnerIndex+1];
//
//    Finalize(FItems[FCount]);
  finally
    if bLock then UnLock;
  end;
end;

procedure TList<T>.InnerExchange(Index1, Index2: integer; bLock: boolean);
var
  Temp: T;
  InnerIndex1, Innerindex2: Integer;
begin
  if bLock then Lock;
  try
    if FSorted then
      raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['Exchange']);

    if (index1 < 0) or (index1 >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);
    if (index2 < 0) or (index2 >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    InnerIndex1:= CalcIndex(Index1);
    Innerindex2:= CalcIndex(Index2);

    Temp := FItems[InnerIndex1];
    FItems[InnerIndex1] := FItems[Innerindex2];
    FItems[Innerindex2] := Temp;
  finally
    if bLock then UnLock;
  end;
end;

function TList<T>.InnerExtract(index: Integer; bLock: boolean): T;
var
  I: Integer;
  InnerIndex: Integer;
begin
  if bLock then Lock;
  try
    Result:= Default(T);

    if (Index < 0) or (Index >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    InnerIndex:= CalcIndex(index);

//    if Assigned(Proc) then
//      Proc(FItems[InnerIndex])
//    else
//      if Assigned(FDefaultFreeProc) then
//        FDefaultFreeProc(FItems[InnerIndex]);

    Result:= FItems[InnerIndex];

    InnerDelete(index, nil);
//    Dec(FCount);
//    for I := 0 to FCount-InnerIndex-1 do
//      FItems[I+InnerIndex]:= FItems[I+InnerIndex+1];
//
//    Finalize(FItems[FCount]);
  finally
    if bLock then UnLock;
  end;
end;

procedure TList<T>.InnerInsert(index: Integer; Value: T; bLock: boolean);
var
  I: Integer;
  InnerIndex: Integer;
begin
  if bLock then Lock;
  try
    if (Index < 0) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    if FDuplicates <> dupAccept then
      if not CheckDuplicates(Value) then Exit;

    if (FCount + 1) >= FCapacity then Grow;

    if FReversed then
    begin
      if index >= FCount then
        InnerIndex:= 0
      else
        InnerIndex:= (FCount - index)
    end else
      InnerIndex:= index;

    if InnerIndex < 0 then InnerIndex:= 0;

    if InnerIndex >= FCount then
      //if not FReversed then
      begin
//        InnerAdd(Value);
        FItems[FCount]:= Value;
        Inc(FCount);
        Exit;
      end;

    Inc(FCount);
    if InnerIndex < FCount then
    begin
      DoInsert(InnerIndex, Value);

//      for I := FCount-1 downto InnerIndex do
//      begin
//        FItems[I]:= FItems[I-1];
//        if I-2 < 0 then Break;
//      end;
//      FItems[InnerIndex]:= Value;
    end;
  finally
    if bLock then UnLock;
  end;
end;

procedure TList<T>.InnerSort(bLock: boolean);
begin
  if bLock then Lock;
  try
    TArray.Sort<T>(FItems, FComparer, 0, Count);
  finally
    if bLock then UnLock;
  end;
end;

procedure TList<T>.Insert(index: Integer; Value: T);
begin
  if FSorted then
   raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['Insert']);

  InnerInsert(index, Value, true);
end;

procedure TList<T>.InsertRange(index: Integer; Range: TArray<T>);
var
  I: Integer;
begin
  Lock;
  try
    if FSorted then
      raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['InsertRange']);

    if Length(Range) = 0 then Exit;

    for I := High(Range) downto Low(Range) do
      InnerInsert(Index, Range[I]);
  finally
    UnLock;
  end;
end;

function TList<T>.IsEmpty: boolean;
begin
  Result:= FCount = 0;
end;

procedure TList<T>.Lock;
begin
  if FThreaded then
    System.TMonitor.Enter(FLockObject);
end;

procedure TList<T>.Replace(const OldItem, NewItem: T);
var
  I: Integer;
begin
  if FSorted then
    raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['Replace']);

  Lock;
  try
    I:= IndexOf(OldItem);

    if FReversed and (I > -1) then
      I:= FCount - I - 1;

    if I > -1 then
    begin
      InnerDelete(I, nil);
      InnerInsert(I, NewItem);
    end// else
      //InnerAdd(NewItem);
  finally
    UnLock;
  end;
end;

procedure TList<T>.Replace(Predicate: TPredicate<T>; const NewItem: T);
var
  I: Integer;
  J: Integer;
begin
  if FSorted then
    raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['Replace']);

  Lock;
  try
    if not Assigned(Predicate) then Exit;

    I := 0;
    while I < FCount do
    begin
      if Predicate(FItems[I]) then
      begin
        J:= I; //IndexOf(FItems[I]);

//        if FReversed and (J > -1) then
//          J:= FCount - J - 1;

//        if J > -1 then
//        begin
          InnerDelete(J, nil);
          InnerInsert(J, NewItem);
//        end
      end;

      Inc(I);
    end;
  finally
    UnLock;
  end;
end;

procedure TList<T>.ReplaceByIndex(const Index: Integer; const NewItem: T);
var
  I: Integer;
begin
  if FSorted then
    raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['ReplaceByIndex']);

  Lock;
  try
//    if FReversed then
//      I:= FCount - Index - 1
//    else
//      I:= Index;

    if (I < 0) or (I >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    InnerDelete(Index, nil);
    InnerInsert(Index, NewItem);
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetAllocBy(const AllocBy: Integer);
begin
  Lock;
  try
    FAllocBy:= AllocBy;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity < FCount then
    raise E_SPECTRA_ListException.CreateResFmt(@sCapacityError, [NewCapacity]);

  if NewCapacity <> FCapacity then
  begin
    SetLength(FItems, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TList<T>.SetDuplicateProc(DuplicateProc: TDuplicateFunc<T>);
begin
  Lock;
  try
    FDuplicateProc:= DuplicateProc;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetDuplicates(const Value: TDuplicates);
begin
  Lock;
  try
    FDuplicates:= Value;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetItem(Index: Integer; const Value: T);
begin
  Lock;
  try
    if (Index < 0) or (Index >= FCount) then
      raise E_SPECTRA_ListException.CreateRes(@sOutOfRange);

    if FReversed then
      FItems[FCount - Index - 1]:= Value
    else
      FItems[Index]:= Value;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetReversed(const Reversed: boolean);
begin
  Lock;
  try
    FReversed:= Reversed;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetSortComparer(const Comparer: IComparer<T>);
begin
  FComparer:= Comparer;
end;

procedure TList<T>.SetSorted(const Sorted: boolean);
begin
  Lock;
  try
    FSorted:= Sorted;
    if Sorted then Sort;
  finally
    UnLock;
  end;
end;

procedure TList<T>.SetThreaded(const Threaded: boolean);
begin
  FThreaded:= Threaded;
end;

procedure TList<T>.Shuffle;
var
  I: Integer;
  RandIndex: Integer;
begin
  Lock;
  try
    if FSorted then
      raise E_SPECTRA_ListException.CreateResFmt(@sListIsSorted,['Shuffle']);

    Randomize;

    for I := 0 to FCount-1 do
    begin
      RandIndex:= (Random(FCount) * 2 + 7) mod 3;
      if RandIndex >= FCount then
        RandIndex:= Random(FCount-1);

      InnerExchange(I, RandIndex);
    end;
  finally
    UnLock;
  end;
end;

procedure TList<T>.Sort;
begin
  InnerSort(true);
end;

procedure TList<T>.Sort(const AComparer: IComparer<T>);
begin
  Lock;
  try
    TArray.Sort<T>(FItems, AComparer, 0, Count);
  finally
    UnLock;
  end;
end;

function TList<T>.ToArray: TArray<T>;
var
  I: Integer;
begin
  Result:= nil;

  SetLength(Result, FCount);
  for I := 0 to FCount-1 do
    if FReversed then
      Result[I]:= FItems[FCount - I - 1]
    else
      Result[I]:= FItems[I];
end;

function TList<T>.ToArray(const Predicate: TPredicate<T>): TArray<T>;
var
  I: Integer;
  Index: Integer;
begin
  Result:= nil;

  for I := 0 to FCount-1 do
  begin
    Index:= CalcIndex(I);

    if Predicate(FItems[Index]) then
    begin
      SetLength(Result, Length(Result)+1);
      Result[High(Result)]:= FItems[Index];
    end;
  end;
end;

procedure TList<T>.ToCustom(Proc: TProc<T>);
var
  I: Integer;
begin
  if FCount > 0 then
    if Assigned(Proc) then
      for I := 0 to FCount-1 do
        if FReversed then
          Proc(FItems[FCount - I - 1])
        else
          Proc(FItems[I]);
end;

procedure TList<T>.UnLock;
begin
  if FThreaded then
    System.TMonitor.Exit(FLockObject);
end;

{ TSubList<T> }

destructor TSubList<T>.Destroy;
begin
  inherited;
end;

procedure TSubList<T>.Free;
begin
  if Self <> nil then Destroy;
end;

{ TList<T>.TListListEnumerator<T> }

function TList<T>.TIListEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TIListEnumerator<T>.Create(FList);
end;

constructor TList<T>.TIListEnumerator<T>.Create(const AList: TList<T>);
begin
  FList:= AList;
  FIndex:= -1;
  FCurrent:= Default(T);
end;

function TList<T>.TIListEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TList<T>.TIListEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TList<T>.TIListEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result:= FIndex < FList.Count;

  if (FIndex < FList.Count) then
  begin
    FCurrent:= FList[FIndex];
    FCurrentIndex:= FIndex;
  end else
  begin
    FCurrent:= Default(T);
    FCurrentIndex:= -1;
  end;
end;

procedure TList<T>.TIListEnumerator<T>.Reset;
begin
  FIndex:= -1;
  FCurrent:= Default(T);
end;

end.
