unit SPECTRA.Collections;

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages, Vcl.Graphics, Winapi.ActiveX,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults, System.RTLConsts,
  System.Types, SPECTRA.Enumerable;

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
       ///  Возвращает массив элементов, которые удовлетворяют условию Predicate
       /// </summary>
    function FilteredItems(Predicate: TPredicate<T>): TArray<T>;
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
    function ToArray: TArray<T>;
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

    {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF CompilerVersion < 33.0}
      function GrowCollection(OldCapacity, NewCount: Integer): Integer;
    {$IFEND}
    {$ENDIF}
    procedure Grow;
    function GetEnumerable: ISPEnumerable<T>;
    procedure Lock;
    procedure UnLock;
    function InnerAdd(const Value: T; bLock: boolean=false): integer;
    procedure InnerDelete(index: Integer; Proc: TProc<T>; bLock: boolean=false);
    function InnerExtract(index: Integer; bLock: boolean=false): T;
    procedure InnerInsert(index: Integer; Value: T; bLock: boolean=false);
    procedure InnerSort(bLock: boolean=false);
    procedure InnerExchange(Index1, Index2: integer; bLock: boolean=false);
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
    function FilteredItems(Predicate: TPredicate<T>): TArray<T>;
    function FindItem(var Item: T; const Predicate: TPredicate<T>): boolean;

    function ToArray: TArray<T>;
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
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

  TSubList<T> = class(TList<T>)
  public
    destructor Destroy; override;
    procedure Free;
  end;

  TLinkedNode<T> = class
  private
    FOwnedList: Pointer;
    FValue: T;
    FNextNode: TLinkedNode<T>;
    FPrevNode: TLinkedNode<T>;
    FFreeValue: boolean;

    function GetNext: TLinkedNode<T>;
    function GetPrev: TLinkedNode<T>;
  protected
    property FreeValue: boolean read FFreeValue write FFreeValue;
  public
    constructor Create(const Value: T; List: Pointer);
    destructor Destroy; override;

    property Next: TLinkedNode<T> read GetNext;
    property Prev: TLinkedNode<T> read GetPrev;

    property Value: T read FValue;
  end;

  TAttachMode = (amLast, amFirst, amAfter, amBefore);

  ILinkedList<T> = Interface
    ['{8237C151-836B-446A-9361-D86C1428D991}']
  //private
    function GetCount: Integer;
    function GetFirst: TLinkedNode<T>;
    function GetLast: TLinkedNode<T>;
    function GetEnumerable: ISPEnumerable<T>;
    function GetThreaded: boolean;
    procedure SetThreaded(const Threaded: boolean);
//public
    procedure Add(const NewNode: TLinkedNode<T>; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil); overload;
    function Add(const Value: T; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil): TLinkedNode<T>; overload;
    procedure AddRange(InArray: TArray<T>; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil);

    procedure Clear;
    function Contains(const AValue: T): Boolean; overload;
    function Contains(const Predicate: TPredicate<T>): boolean; overload;
    procedure DefaultFreeNode(Proc: TProc<T>);
    procedure Delete(const Node: TLinkedNode<T>);
    function ExtractFirst: T;
    function ExtractLast: T;

    function Find(const Value: T): TLinkedNode<T>; overload;
    function Find(const Predicate: TPredicate<T>): TLinkedNode<T>; overload;
    function FindLast(const Value: T): TLinkedNode<T>; overload;
    function FindLast(const Predicate: TPredicate<T>): TLinkedNode<T>; overload;
    function IsEmpty: boolean;

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;

    function ToArray: TArray<T>;
    procedure ToCustom(Proc: TProc<T>);

    function GetEnumerator: ISPEnumerator<T>;

    property Count: Integer read GetCount;
    property Enumerable: ISPEnumerable<T> read GetEnumerable;
    property First: TLinkedNode<T> read GetFirst;
    property Last: TLinkedNode<T> read GetLast;
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

  TLinkedList<T> = class(TInterfacedObject, ILinkedList<T>)
  private type
    TLinkedListEnumerator<T> = class(TInterfacedObject, ISPEnumerator<T>)
    private
      FList: TLinkedList<T>;
      FIndex: Integer;
      FCurrent: T;
      FCurrentNode: TLinkedNode<T>;

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
    FHead: TLinkedNode<T>;
    FFirst: TLinkedNode<T>;
    FLast: TLinkedNode<T>;
    FComparer: IComparer<T>;
    FLockObject: TObject;
    FThreaded: boolean;
    FDefaultFreeProc: TProc<T>;

    procedure Lock;
    procedure UnLock;
    function EnsureNode(const Node: TLinkedNode<T>): boolean;
    function GetCount: Integer;
    function GetFirst: TLinkedNode<T>;
    function GetLast: TLinkedNode<T>;
    function GetEnumerable: ISPEnumerable<T>;
    function GetThreaded: boolean;
    procedure SetThreaded(const Threaded: boolean);
    procedure InnerAdd(const NewNode: TLinkedNode<T>;
      AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil;
      bLock: boolean = false);
    procedure InnerDelete(Node: TLinkedNode<T>; bLock: boolean = false);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const NewNode: TLinkedNode<T>; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil); overload;
    function Add(const Value: T; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil): TLinkedNode<T>; overload;
    procedure AddRange(InArray: TArray<T>; AttachMode: TAttachMode = amLast; const Node: TLinkedNode<T> = nil);

    procedure Clear;
    function Contains(const AValue: T): Boolean; overload;
    function Contains(const Predicate: TPredicate<T>): boolean; overload;
    procedure DefaultFreeNode(Proc: TProc<T>);
    procedure Delete(const Node: TLinkedNode<T>);
    function ExtractFirst: T;
    function ExtractLast: T;

    function Find(const Value: T): TLinkedNode<T>; overload;
    function Find(const Predicate: TPredicate<T>): TLinkedNode<T>; overload;
    function FindLast(const Value: T): TLinkedNode<T>; overload;
    function FindLast(const Predicate: TPredicate<T>): TLinkedNode<T>; overload;
    function IsEmpty: boolean;

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;

    function ToArray: TArray<T>;
    procedure ToCustom(Proc: TProc<T>);

    function GetEnumerator: ISPEnumerator<T>;

    property Count: Integer read GetCount;
    property Enumerable: ISPEnumerable<T> read GetEnumerable;
    property First: TLinkedNode<T> read GetFirst;
    property Last: TLinkedNode<T> read GetLast;
    property Threaded: boolean read GetThreaded write SetThreaded;
  end;

//  IDictionary<TKey,TValue> = interface
//  end;

  E_SPECTRA_CollectionException = class(Exception);

implementation

uses
  System.Rtti, System.TypInfo, SPECTRA.Consts;


{ TSubList<T> }

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

    if FSorted then Sort;
  finally
    UnLock;
  end;
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
            dupError: raise E_SPECTRA_CollectionException.CreateRes(@sDuplicatesNotAllowed);
          end;

          Break;
        end;
  end else
    if IndexOf(Item) > -1 then
      case FDuplicates of
        dupIgnore: Exit;
        dupError: raise E_SPECTRA_CollectionException.CreateRes(@sDuplicatesNotAllowed);
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
begin
  Result:= nil;

  if FCount > 0 then
    for I := 0 to FCount-1 do
      if Predicate(FItems[I]) then
      begin
        SetLength(Result, High(Result)+2);
        Result[High(Result)]:= I;
      end;
end;

function TList<T>.FilteredItems(Predicate: TPredicate<T>): TArray<T>;
var
  I: Integer;
begin
  Result:= nil;

  if FCount > 0 then
    for I := 0 to FCount-1 do
      if Predicate(FItems[I]) then
      begin
        SetLength(Result, High(Result)+2);
        Result[High(Result)]:= FItems[I];
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
      if FReversed then
        Index:= I
      else
        Index:= FCount - I - 1;

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
begin
  if (Index < 0) or (Index >= FCount) then
    raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

  if FReversed then
    Result:= FItems[FCount - Index - 1]
  else
    Result:= FItems[Index];
end;

function TList<T>.GetReversed: boolean;
begin
  Result:= FReversed;
end;

function TList<T>.GetSorted: boolean;
begin
  Result:= FSorted;
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

{$IFDEF CONDITIONALEXPRESSIONS}
{$IF CompilerVersion < 33.0}
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
{$IFEND}
{$ENDIF}

function TList<T>.IndexOf(const Value: T; Direction: TDirection): integer;
var
  I: Integer;
  Index: Integer;
begin
  Result:= -1;
  if FCount = 0 then Exit;

  case Direction of
   FromBeginning: for I:= 0 to FCount-1 do
                  begin
                    if FReversed then
                      Index:= FCount - I - 1
                    else
                      Index:= I;

                    if FComparer.Compare(FItems[Index], Value) = 0 then
                    begin
                      Result:= Index;
                      Break;
                    end;
                  end;
   FromEnd: for I:= FCount-1 downto 0 do
            begin
              if FReversed then
                Index:= FCount - I - 1
              else
                Index:= I;

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

  for I:= 0 to FCount-1 do
  begin
    if FReversed then
      Index:= FCount - I - 1
    else
      Index:= I;

    if AComparer.Compare(FItems[Index], Value) = 0 then
    begin
      if FReversed then
        Result:= FCount - Index - 1
      else
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
                    if FReversed then
                      Index:= FCount - I - 1
                    else
                      Index:= I;

                    if Predicate(FItems[Index]) then
                    begin
                      Result:= Index;
                      Break;
                    end;
                  end;
   FromEnd: for I:= FCount-1 downto 0 do
            begin
              if FReversed then
                Index:= FCount - I - 1
              else
                Index:= I;

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
  I: Integer;
begin
  if bLock then Lock;
  try
    Result:= -1;

    if not CheckDuplicates(Value) then Exit;

    if FCount = FCapacity then Grow;

    Result:= FCount;
    if FReversed then
    begin
      Inc(FCount);
      if FCount > 0 then
      begin
        for I := FCount-1 downto 0 do
        begin
          FItems[I]:= FItems[I-1];
          if I-2 < 0 then Break;
        end;
        FItems[0]:= Value;
      end;

    end else
    begin
      FItems[FCount]:= Value;
      Inc(FCount);
    end;

    if FSorted then Sort;
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
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

    if FReversed then
      InnerIndex:= FCount - index - 1
    else
      InnerIndex:= index;

    if Assigned(Proc) then
      Proc(FItems[InnerIndex])
    else
      if Assigned(FDefaultFreeProc) then
        FDefaultFreeProc(FItems[InnerIndex]);

    Dec(FCount);
    for I := 0 to FCount-InnerIndex-1 do
      FItems[I+InnerIndex]:= FItems[I+InnerIndex+1];

    Finalize(FItems[FCount]);
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
    if FSorted then E_SPECTRA_CollectionException.CreateResFmt(@sListIsSorted,['Exchange']);

    if (index1 < 0) or (index1 >= FCount) then
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);
    if (index2 < 0) or (index2 >= FCount) then
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

    if FReversed then
    begin
      InnerIndex1:= FCount - Index1 - 1;
      Innerindex2:= FCount - Index2 - 1;
    end else
    begin
      InnerIndex1:= Index1;
      Innerindex2:= Index2;
    end;

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
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

    if FReversed then
      InnerIndex:= FCount - index - 1
    else
      InnerIndex:= index;

//    if Assigned(Proc) then
//      Proc(FItems[InnerIndex])
//    else
//      if Assigned(FDefaultFreeProc) then
//        FDefaultFreeProc(FItems[InnerIndex]);

    Result:= FItems[InnerIndex];

    Dec(FCount);
    for I := 0 to FCount-InnerIndex-1 do
      FItems[I+InnerIndex]:= FItems[I+InnerIndex+1];

    Finalize(FItems[FCount]);
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
    if FSorted then E_SPECTRA_CollectionException.CreateResFmt(@sListIsSorted,['Insert']);

    if (Index < 0) then
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

    if Index >= FCount then
      if not FReversed then
      begin
        InnerAdd(Value);
        Exit;
      end;

    if not CheckDuplicates(Value) then Exit;

    if FCount = FCapacity then Grow;
    if FReversed then
    begin
      if index >= FCount then
        InnerIndex:= 0
      else
        InnerIndex:= FCount - index
    end else
      InnerIndex:= index;

    Inc(FCount);
    if InnerIndex < FCount then
    begin
      for I := FCount-1 downto InnerIndex do
      begin
        FItems[I]:= FItems[I-1];
        if I-2 < 0 then Break;
      end;
      FItems[InnerIndex]:= Value;
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
  InnerInsert(index, Value, true);
end;

procedure TList<T>.InsertRange(index: Integer; Range: TArray<T>);
var
  I: Integer;
begin
  Lock;
  try
    if FSorted then E_SPECTRA_CollectionException.CreateResFmt(@sListIsSorted,['InsertRange']);

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
  Lock;
  try
    if not Assigned(Predicate) then Exit;

    I := 0;
    while I < FCount do
    begin
      if Predicate(FItems[I]) then
      begin
        J:= I; //IndexOf(FItems[I]);

        if FReversed and (J > -1) then
          J:= FCount - J - 1;

        if J > -1 then
        begin
          InnerDelete(J, nil);
          InnerInsert(J, NewItem);
        end// else
          //InnerAdd(NewItem);
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
  Lock;
  try
    if FReversed then
      I:= FCount - Index - 1
    else
      I:= Index;

    if (I < 0) or (I >= FCount) then
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

    InnerDelete(I, nil);
    InnerInsert(I, NewItem);
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
    raise E_SPECTRA_CollectionException.CreateResFmt(@sCapacityError, [NewCapacity]);
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
      raise E_SPECTRA_CollectionException.CreateRes(@sOutOfRange);

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
    if FSorted then E_SPECTRA_CollectionException.CreateResFmt(@sListIsSorted,['Shuffle']);

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

{ TLinkedNode<T> }

constructor TLinkedNode<T>.Create(const Value: T; List: Pointer);
begin
  FValue:= Value;
  FOwnedList:= List;
  FFreeValue:= true;
end;

destructor TLinkedNode<T>.Destroy;
begin
  if FFreeValue then
    Finalize(FValue);

  inherited;
end;

function TLinkedNode<T>.GetNext: TLinkedNode<T>;
begin
  if Assigned(FNextNode) then
    Result:= FNextNode
  else
    Result:= nil;
end;

function TLinkedNode<T>.GetPrev: TLinkedNode<T>;
begin
  if Assigned(FPrevNode) then
    if TLinkedList<T>(FOwnedList).FHead = FPrevNode then
      Result:= nil
    else
      Result:= FPrevNode
  else
    Result:= nil;
end;

{ TLinkedList<T> }

procedure TLinkedList<T>.Add(const NewNode: TLinkedNode<T>;
  AttachMode: TAttachMode; const Node: TLinkedNode<T>);
begin
  InnerAdd(NewNode,AttachMode,Node,true);
end;

function TLinkedList<T>.Add(const Value: T; AttachMode: TAttachMode;
  const Node: TLinkedNode<T>): TLinkedNode<T>;
begin
  Lock;
  try
    Result:= TLinkedNode<T>.Create(Value, Self);
    InnerAdd(Result, AttachMode, Node);
  finally
    UnLock;
  end;
end;

procedure TLinkedList<T>.AddRange(InArray: TArray<T>;
  AttachMode: TAttachMode; const Node: TLinkedNode<T>);
var
  NewNode: TLinkedNode<T>;
  I: Integer;
begin
  Lock;
  try
    for I := Low(InArray) to High(InArray) do
    begin
      NewNode:= TLinkedNode<T>.Create(InArray[I], Self);
      InnerAdd(NewNode, AttachMode, Node);
    end;
  finally
    UnLock;
  end;
end;

procedure TLinkedList<T>.Clear;
var
  Node: TLinkedNode<T>;
  Dummy: TLinkedNode<T>;
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
  Node: TLinkedNode<T>;
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

constructor TLinkedList<T>.Create;
begin
  FCount:= 0;
  FFirst:= nil;
  FLast:= nil;
  FThreaded:= false;
  FDefaultFreeProc:= nil;
  FHead:= TLinkedNode<T>.Create(Default(T),Self);
  FComparer:= TComparer<T>.Default;
  FLockObject:= TObject.Create;
end;

function TLinkedList<T>.Contains(const AValue: T): Boolean;
var
  Node: TLinkedNode<T>;
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

procedure TLinkedList<T>.Delete(const Node: TLinkedNode<T>);
begin
  InnerDelete(Node, true)
end;

function TLinkedList<T>.ExtractFirst: T;
begin
  Lock;
  try
    Result:= Default(T);

    if FFirst = nil then
      raise E_SPECTRA_CollectionException.CreateRes(@sNodeNotAssigned);

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
      raise E_SPECTRA_CollectionException.CreateRes(@sNodeNotAssigned);

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
  FLockObject.Free;

  inherited;
end;

function TLinkedList<T>.EnsureNode(const Node: TLinkedNode<T>): boolean;
begin
  Result:= false;

  if Assigned(Node.FOwnedList) then
    if (TLinkedList<T>(Node.FOwnedList) = Self) then
      raise E_SPECTRA_CollectionException.CreateRes(@sNodeIsAttached)
    else
      if Node.FOwnedList <> nil then
        raise E_SPECTRA_CollectionException.CreateRes(@sNodeIsAttachedAnother);

  Result:= true;
end;

function TLinkedList<T>.Find(const Value: T): TLinkedNode<T>;
var
  Node: TLinkedNode<T>;
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

function TLinkedList<T>.Find(const Predicate: TPredicate<T>): TLinkedNode<T>;
var
  Node: TLinkedNode<T>;
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

function TLinkedList<T>.FindLast(const Value: T): TLinkedNode<T>;
var
  Node: TLinkedNode<T>;
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

function TLinkedList<T>.FindLast(
  const Predicate: TPredicate<T>): TLinkedNode<T>;
var
  Node: TLinkedNode<T>;
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

function TLinkedList<T>.GetFirst: TLinkedNode<T>;
begin
  Result:= FFirst;
end;

function TLinkedList<T>.GetLast: TLinkedNode<T>;
begin
  Result:= FLast;
end;

function TLinkedList<T>.GetThreaded: boolean;
begin
  Result:= FThreaded;
end;

procedure TLinkedList<T>.InnerAdd(const NewNode: TLinkedNode<T>;
  AttachMode: TAttachMode; const Node: TLinkedNode<T>; bLock: boolean);
var
  Dummy: TLinkedNode<T>;
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
             raise E_SPECTRA_CollectionException.CreateRes(@sNodeNotSpecified);

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
             raise E_SPECTRA_CollectionException.CreateRes(@sNodeNotSpecified);

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

procedure TLinkedList<T>.InnerDelete(Node: TLinkedNode<T>;
  bLock: boolean);
var
  Dummy: TLinkedNode<T>;
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

procedure TLinkedList<T>.SetThreaded(const Threaded: boolean);
begin
  FThreaded:= Threaded;
end;

procedure TLinkedList<T>.Sort(const AComparer: IComparer<T>);
var
  I: Integer;
  bSwap: Boolean;
  Dummy: TLinkedNode<T>;
  aLeft: TLinkedNode<T>;
  aRight: TLinkedNode<T>;
  aLeftP: TLinkedNode<T>;
  aRightN: TLinkedNode<T>;
  aLeftN: TLinkedNode<T>;
  aRightP: TLinkedNode<T>;
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
  Node: TLinkedNode<T>;
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

procedure TLinkedList<T>.ToCustom(Proc: TProc<T>);
var
  Node: TLinkedNode<T>;
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
