unit SPECTRA.Dictionary;

interface

uses
  System.Generics.Collections, System.Rtti, System.Generics.Defaults;

type
  //изменение Grow threshold = 50% в отличае от базового класса (для уменьшения количества коллизий)
//  THackDictionary<TKey, TValue> = class(System.Generics.Collections.TDictionary<TKey, TValue>)
//  private
//    FItemsField: TRttiField;
//    FGrowThresholdField: TRttiField;
//    FParentGrowThreshold: Integer;
//
//    function GetItemsLength: Integer;
//    procedure CalcGrowThreshold;
//  public
//    procedure AfterConstruction; override;
//
//    procedure Add(const Key: TKey; const Value: TValue);
//    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
//    function TryAdd(const Key: TKey; const Value: TValue): Boolean;
//  end;

  IDictionary<TKey,TValue> = interface
  ['{E3894E95-C61C-40C0-833C-3182B86C9AC9}']
  //private
    function GetCount: Integer;
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
  //public
    procedure Add(const Key: TKey; const Value: TValue);
    procedure Remove(const Key: TKey);
    function ExtractPair(const Key: TKey): TPair<TKey,TValue>;
    procedure Clear;
    procedure TrimExcess;
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
    function TryAdd(const Key: TKey; const Value: TValue): Boolean;
    function ContainsKey(const Key: TKey): Boolean;
    function ContainsValue(const Value: TValue): Boolean;
    function ToArray: TArray<TPair<TKey,TValue>>;

    property Items[const Key: TKey]: TValue read GetItem write SetItem;
    property Count: Integer read GetCount;
  end;

  TDictionary<TKey,TValue> = class(TInterfacedObject, IDictionary<TKey,TValue>)
  private
    FDictionary: System.Generics.Collections.TDictionary<TKey, TValue>; //THackDictionary<TKey,TValue>;

    function GetCount: Integer;
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
  public
    constructor Create(ACapacity: Integer = 0); overload;
    constructor Create(const AComparer: IEqualityComparer<TKey>); overload;
    constructor Create(ACapacity: Integer; const AComparer: IEqualityComparer<TKey>); overload;
    destructor Destroy; override;

    procedure Add(const Key: TKey; const Value: TValue);
    procedure Remove(const Key: TKey);
    function ExtractPair(const Key: TKey): TPair<TKey,TValue>;
    procedure Clear;
    procedure TrimExcess;
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
    function TryAdd(const Key: TKey; const Value: TValue): Boolean;
    function ContainsKey(const Key: TKey): Boolean;
    function ContainsValue(const Value: TValue): Boolean;
    function ToArray: TArray<TPair<TKey,TValue>>;

    property Items[const Key: TKey]: TValue read GetItem write SetItem;
    property Count: Integer read GetCount;
  end;

implementation

uses
  System.SysUtils;

{ THackDictionary<TKey, TValue> }

type
  TGrowMethod = procedure of object;

//procedure THackDictionary<TKey, TValue>.Add(const Key: TKey;
//  const Value: TValue);
//begin
//  inherited Add(Key, Value);
//  CalcGrowThreshold;
//end;
//
//procedure THackDictionary<TKey, TValue>.AddOrSetValue(const Key: TKey;
//  const Value: TValue);
//begin
//  inherited AddOrSetValue(Key, Value);
//  CalcGrowThreshold;
//end;
//
//procedure THackDictionary<TKey, TValue>.AfterConstruction;
//var
//  ctx: TRttiContext;
//  flds: TArray<TRttiField>;
//  I: Integer;
//begin
//  inherited;
//
//  FParentGrowThreshold:= -1;
//  FGrowThresholdField:= nil;
//  FItemsField:= nil;
//
//  ctx:= TRTTIContext.Create;
//  try
//    flds:= ctx.GetType(System.Generics.Collections.TDictionary<TKey, TValue>).GetFields;
//    for I := Low(flds) to High(flds) do
//    begin
//      if SameText(flds[i].Name, 'FItems') then
//        FItemsField:= flds[i];
//
//      if SameText(flds[i].Name, 'FGrowThreshold') then
//        FGrowThresholdField:= flds[i];
//
//      if (FItemsField <> nil) and (FGrowThresholdField <> nil) then Break;
//    end;
//
//    if FGrowThresholdField <> nil then
//      FParentGrowThreshold:= FGrowThresholdField.GetValue(Self).AsInteger;
//  finally
//    ctx.Free;
//  end;
//end;
//
//procedure THackDictionary<TKey, TValue>.CalcGrowThreshold;
//var
//  newCap: Integer;
//  aLength: Integer;
//  aGrowThreshold: Integer;
//begin
//  if FGrowThresholdField <> nil then
//    if FParentGrowThreshold <> FGrowThresholdField.GetValue(Self).AsInteger then
//    begin
//      aLength:= GetItemsLength;
//      newCap:= aLength * 2;
//      if newCap = 0 then newCap:= 4;
//
//      if newCap < 0 then
//        OutOfMemoryError;
//
//      aGrowThreshold:= aLength + newCap shr 1; //50%
//      FGrowThresholdField.SetValue(Self, aGrowThreshold);
//      FParentGrowThreshold:= aGrowThreshold;
//    end;
//end;
//
//function THackDictionary<TKey, TValue>.GetItemsLength: Integer;
//var
//  aArray: Pointer;
//  AValue: System.Rtti.TValue;
//begin
//  Result:= -1;
//
//  if FItemsField <> nil then
//  begin
//    aArray:= Pointer(NativeInt(Self) + FItemsField.Offset);
//    System.Rtti.TValue.Make(aArray, FItemsField.FieldType.Handle, AValue);
//
//    Result:= AValue.GetArrayLength;
//  end;
//end;
//
//function THackDictionary<TKey, TValue>.TryAdd(const Key: TKey;
//  const Value: TValue): Boolean;
//begin
//  Result:= inherited TryAdd(Key, Value);
//  CalcGrowThreshold;
//end;

{ TDictionary<TKey, TValue> }

procedure TDictionary<TKey, TValue>.Add(const Key: TKey; const Value: TValue);
begin
  FDictionary.Add(Key, Value);
end;

procedure TDictionary<TKey, TValue>.AddOrSetValue(const Key: TKey;
  const Value: TValue);
begin
  FDictionary.AddOrSetValue(Key, Value);
end;

procedure TDictionary<TKey, TValue>.Clear;
begin
  FDictionary.Clear;
end;

function TDictionary<TKey, TValue>.ContainsKey(const Key: TKey): Boolean;
begin
  Result:= FDictionary.ContainsKey(Key);
end;

function TDictionary<TKey, TValue>.ContainsValue(const Value: TValue): Boolean;
begin
  Result:= FDictionary.ContainsValue(Value);
end;

constructor TDictionary<TKey, TValue>.Create(ACapacity: Integer;
  const AComparer: IEqualityComparer<TKey>);
begin
  FDictionary:= System.Generics.Collections.TDictionary<TKey, TValue>.Create(ACapacity, AComparer);
  //THackDictionary<TKey, TValue>.Create(ACapacity, AComparer);
end;

constructor TDictionary<TKey, TValue>.Create(
  const AComparer: IEqualityComparer<TKey>);
begin
  FDictionary:= System.Generics.Collections.TDictionary<TKey, TValue>.Create(AComparer);
  //THackDictionary<TKey, TValue>.Create(AComparer);
end;

constructor TDictionary<TKey, TValue>.Create(ACapacity: Integer);
begin
  FDictionary:= System.Generics.Collections.TDictionary<TKey, TValue>.Create(ACapacity);
  //THackDictionary<TKey, TValue>.Create(ACapacity);
end;

destructor TDictionary<TKey, TValue>.Destroy;
begin
  FDictionary.Free;

  inherited;
end;

function TDictionary<TKey, TValue>.ExtractPair(
  const Key: TKey): TPair<TKey, TValue>;
begin
  Result:= FDictionary.ExtractPair(Key);
end;

function TDictionary<TKey, TValue>.GetCount: Integer;
begin
  Result:= FDictionary.Count;
end;

function TDictionary<TKey, TValue>.GetItem(const Key: TKey): TValue;
begin
  Result:= FDictionary.Items[Key];
end;

procedure TDictionary<TKey, TValue>.Remove(const Key: TKey);
begin
  FDictionary.Remove(Key);
end;

procedure TDictionary<TKey, TValue>.SetItem(const Key: TKey;
  const Value: TValue);
begin
  FDictionary.Items[Key]:= Value;
end;

function TDictionary<TKey, TValue>.ToArray: TArray<TPair<TKey, TValue>>;
begin
  Result:= FDictionary.ToArray;
end;

procedure TDictionary<TKey, TValue>.TrimExcess;
begin
  FDictionary.TrimExcess;
end;

function TDictionary<TKey, TValue>.TryAdd(const Key: TKey;
  const Value: TValue): Boolean;
begin
  Result:= FDictionary.TryAdd(Key, Value)
end;

function TDictionary<TKey, TValue>.TryGetValue(const Key: TKey;
  out Value: TValue): Boolean;
begin
  Result:= FDictionary.TryGetValue(Key, Value);
end;

end.
