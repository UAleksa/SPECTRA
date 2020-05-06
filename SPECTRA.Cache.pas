unit SPECTRA.Cache;

interface

uses
  System.SysUtils, System.Generics.Defaults, SPECTRA.LinkedList,
  SPECTRA.Dictionary;

type
  /// <summary>
  ///  Класс реализующий механизм кэширования, где K - ключ, V - значение
  /// </summary>
  TCache<K,V> = class
  private type
    PChacheElement = ^TChacheElement;
    TChacheElement = record
      Key: K;
      Value: V;
    end;
  private
    FCache: TLinkedList<TChacheElement>;
    FKeys: IDictionary<K,Pointer>;
    FCount: Integer;
    FOwnsValues: boolean;
    FDefaultFreeValue: TProc<V>;
    FComparer: IComparer<V>;

    procedure Add(const Key: K; const Value: V);
    function GetCount: Integer;
    function GetMaxCount: Integer;
    function IsFull: boolean;
    procedure MoveToFirst(Element: Pointer);
    procedure RemoveLast;
  public
    constructor Create(ElementsCount: Integer; OwnsValues: boolean = false);
    destructor Destroy; override;

    /// <summary>
    ///  Задает процедуру для освобождения элементов
    /// </summary>
    procedure FreeValueProc(Proc: TProc<V>);
    /// <summary>
    ///  Извлекает элемент из кэша
    /// </summary>
    function TryGetValue(const Key: K; var Value: V): boolean;
    /// <summary>
    ///  Обновляет значение по ключу, если такого значения нет, то добавляет
    /// </summary>
    procedure UpdateValue(const Key: K; const Value: V);


    /// <summary>
    ///  Текущее количество элементов
    /// </summary>
    property Count: Integer read GetCount;
    /// <summary>
    ///  Количество значений, которое может содержать Кэш
    /// </summary>
    property MaxCount: Integer read GetMaxCount;
    /// <summary>
    ///  Следить за освобождением значений
    /// </summary>
    property OwnsValues: boolean read FOwnsValues;
  end;

implementation

type
  PObject = ^TObject;

{ TCache<K, V> }

procedure TCache<K, V>.Add(const Key: K; const Value: V);
var
  Element: TChacheElement;
begin
  if IsFull then
    RemoveLast;

  Element.Key:= Key;
  Element.Value:= Value;
  FKeys.Add(Key, FCache.Add(Element, amFirst));
end;

constructor TCache<K, V>.Create(ElementsCount: Integer; OwnsValues: boolean);
begin
  FDefaultFreeValue:= nil;
  FCache:= TLinkedList<TChacheElement>.Create;
  FKeys:= TDictionary<K,Pointer>.Create;
  FCount:= ElementsCount;
  FOwnsValues:= OwnsValues;
  FComparer:= TComparer<V>.Default;
end;

destructor TCache<K, V>.Destroy;
begin
  while not FCache.IsEmpty do
    RemoveLast;
  FCache.Free;

  FKeys:= nil;

  inherited;
end;

procedure TCache<K, V>.FreeValueProc(Proc: TProc<V>);
begin
  FDefaultFreeValue:= Proc;
end;

function TCache<K, V>.GetCount: Integer;
begin
  Result:= FCache.Count;
end;

function TCache<K, V>.GetMaxCount: Integer;
begin
  Result:= FCount;
end;

function TCache<K, V>.IsFull: boolean;
begin
  Result:= FCache.Count = FCount;
end;

procedure TCache<K, V>.MoveToFirst(Element: Pointer);
begin
  if FCache.First <> FCache.Cast(Element) then
    FCache.MoveTo(FCache.Cast(Element), FCache.First, amBefore);
end;

procedure TCache<K, V>.RemoveLast;
var
  Last: TChacheElement;
begin
  if FCache.Count > 0 then
  begin
    Last:= FCache.ExtractLast;
    FKeys.Remove(Last.Key);
    if FOwnsValues then
      if Assigned(FDefaultFreeValue) then
        FDefaultFreeValue(Last.Value)
      else
        Finalize(Last.Value);
  end;
end;

function TCache<K, V>.TryGetValue(const Key: K; var Value: V): boolean;
var
  pValue: Pointer;
begin
  Result:= false;

  if FKeys.TryGetValue(Key, pValue) then
    if pValue <> nil then
    begin
      Value:= FCache.Cast(pValue)^.Value.Value;
      MoveToFirst(pValue);
      Result:= true;
    end;
end;

procedure TCache<K, V>.UpdateValue(const Key: K; const Value: V);
var
  pValue: Pointer;
  Element: PChacheElement;
begin
  if FKeys.TryGetValue(Key, pValue) then
  begin
    if pValue <> nil then
    begin
      Element:= @FCache.Cast(pValue)^.Value;
      if FComparer.Compare(Element^.Value, Value) <> 0 then
        Element^.Value:= Value;
    end;
  end else
    Add(Key, Value);
end;

end.
