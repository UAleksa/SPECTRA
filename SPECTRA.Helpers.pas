unit SPECTRA.Helpers;

interface

uses SPECTRA.Messages, System.Generics.Collections, System.SysUtils,
  System.Types, System.Generics.Defaults, SPECTRA.Consts, SPECTRA.Enumerable;

type
  TObjectHelper = class helper for TObject
  public
    procedure Auto(Tag: string='');
    procedure AutoDisable;
    function AutoLocal: IInterface;
    function Clone: TObject;
    function IsAuto(Tag: string=''): boolean;
    function IsSubscribed: boolean; overload;
    function IsSubscribed(const MessageID: NativeUInt): boolean; overload;
    function Subscribe(const aMessageClass: TClass; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const MessageID: NativeUInt; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    function Subscribe(const ListenerMethod: TMessageFunc): NativeUInt; overload;
    procedure UnSubscribe(Immediate: boolean=false); overload;
    procedure UnSubscribe(const MessageID: NativeUInt; Immediate: boolean=false); overload;
  end;

  TArrayHelper = class helper for TArray
  public
    class procedure Add<T>(var Source: TArray<T>; Element: T); static;
    class procedure AddRange<T>(var Source: TArray<T>; const Range: TArray<T>); static;
    class function Contains<T>(const Source: TArray<T>; const Predicate: TPredicate<T>): boolean; static;
    class procedure Delete<T>(var Source: TArray<T>; Index: Integer); static;
    class function IndexOf<T>(const Source: TArray<T>;
      const Predicate: TPredicate<T>;
      Direction: TDirection=FromBeginning): Integer; overload; static;
    class function IndexOf<T>(const Source: TArray<T>; const Element: T;
      AComparer: IComparer<T>;
      Direction: TDirection=FromBeginning): Integer; overload; static;
    class procedure Insert<T>(var Source: TArray<T>; Index: Integer; Element: T); static;
    class procedure InsertRange<T>(var Source: TArray<T>; Index: Integer; const Range: TArray<T>); static;
    class function IsEmpty<T>(const Source: TArray<T>): boolean; static;
  end;

  TEnumHelper = class
    class function GetEnumByName<T>(Name: string): T;
    class function GetNameByEnum<T>(Enum: T): string;
    class function GetIndexByEnum<T>(Enum: T): integer;
    class function GetEnumByIndex<T>(Index: integer): T;
  end;

implementation

uses SPECTRA.GC, System.TypInfo, System.SysConst, Data.DBXJSON,
  Data.DBXJSONReflect, System.JSON;

{ TObjectHelper }

procedure TObjectHelper.Auto(Tag: string);
begin
  if Tag.IsEmpty then
    GC.Add(Self, Self.GetHashCode.ToString)
  else
    GC.Add(Self, Tag);
end;

procedure TObjectHelper.AutoDisable;
begin
  GC.Remove(Self.GetHashCode.ToString);
end;

function TObjectHelper.AutoLocal: IInterface;
begin
  Result:= TFreeTheValue.Create(Self);
end;

function TObjectHelper.Clone: TObject;
var
  MarshalObj: TJSONMarshal;
  UnMarshalObj: TJSONUnMarshal;
  JSONValue: TJSONValue;
begin
  Result:= nil;

  MarshalObj:= TJSONMarshal.Create;
  try
    UnMarshalObj:= TJSONUnMarshal.Create;
    try
      JSONValue:= MarshalObj.Marshal(Self);
      try
        if Assigned(JSONValue) then
          Result:= UnMarshalObj.Unmarshal(JSONValue);
      finally
        JSONValue.Free;
      end;
    finally
      UnMarshalObj.Free;
    end;
  finally
    MarshalObj.Free;
  end;
end;

function TObjectHelper.IsAuto(Tag: string): boolean;
begin
  if Tag.IsEmpty then
    Result:= (GC.ObjectByTag(Self.GetHashCode.ToString) <> nil)
  else
    Result:= (GC.ObjectByTag(Tag) <> nil);
end;

function TObjectHelper.IsSubscribed(const MessageID: NativeUInt): boolean;
begin
  Result:= Msgs.IsSubscribed(Self, MessageID);
end;

function TObjectHelper.IsSubscribed: boolean;
begin
  Result:= Msgs.IsSubscribed(Self);
end;

function TObjectHelper.Subscribe(const MessageID: NativeUInt;
  const ListenerMethod: TMessageFunc): NativeUInt;
begin
  Result:= Msgs.Subscribe(Self, MessageID, ListenerMethod);
end;

function TObjectHelper.Subscribe(
  const ListenerMethod: TMessageFunc): NativeUInt;
begin
  Result:= Msgs.Subscribe(Self, ListenerMethod);
end;

procedure TObjectHelper.UnSubscribe(const MessageID: NativeUInt;
  Immediate: boolean);
begin
  Msgs.UnSubscribe(Self, MessageID, Immediate);
end;

procedure TObjectHelper.UnSubscribe(Immediate: boolean);
begin
  Msgs.UnSubscribe(Self, Immediate);
end;

function TObjectHelper.Subscribe(const aMessageClass: TClass;
  const ListenerMethod: TMessageFunc): NativeUInt;
begin
  Result:= Msgs.Subscribe(Self, aMessageClass, ListenerMethod);
end;

{ TEnumHelper }

class function TEnumHelper.GetEnumByIndex<T>(Index: integer): T;
begin
  case PTypeInfo(TypeInfo(T))^.Kind of
    tkEnumeration:
      case GetTypeData(TypeInfo(T))^.OrdType of
        otUByte, otSByte: PByte(@Result)^ := Index;
        otUWord, otSWord: PWord(@Result)^ := Index;
        otULong, otSLong: PInteger(@Result)^ := Index;
      end;
  else
    raise EInvalidCast.CreateRes(@SInvalidCast);
  end;
end;

class function TEnumHelper.GetEnumByName<T>(Name: string): T;
begin
  case PTypeInfo(TypeInfo(T))^.Kind of
    tkEnumeration:
      case GetTypeData(TypeInfo(T))^.OrdType of
        otUByte, otSByte: PByte(@Result)^ := GetEnumValue(TypeInfo(T), Name);
        otUWord, otSWord: PWord(@Result)^ := GetEnumValue(TypeInfo(T), Name);
        otULong, otSLong: PInteger(@Result)^ := GetEnumValue(TypeInfo(T), Name);
      end;
  else
    raise EInvalidCast.CreateRes(@SInvalidCast);
  end;
end;

class function TEnumHelper.GetIndexByEnum<T>(Enum: T): integer;
begin
  case PTypeInfo(TypeInfo(T))^.Kind of
    tkEnumeration:
      case GetTypeData(TypeInfo(T))^.OrdType of
        otUByte, otSByte: Result := PByte(@Enum)^;
        otUWord, otSWord: Result := PWord(@Enum)^;
        otULong, otSLong: Result := PInteger(@Enum)^;
      end;
  else
    raise EInvalidCast.CreateRes(@SInvalidCast);
  end;
end;

class function TEnumHelper.GetNameByEnum<T>(Enum: T): string;
var
  I: Integer;
begin
  case PTypeInfo(TypeInfo(T))^.Kind of
    tkEnumeration:
      case GetTypeData(TypeInfo(T))^.OrdType of
        otUByte, otSByte: I := PByte(@Enum)^;
        otUWord, otSWord: I := PWord(@Enum)^;
        otULong, otSLong: I := PInteger(@Enum)^;
      end;
  else
    raise EInvalidCast.CreateRes(@SInvalidCast);
  end;
  Result := GetEnumName(TypeInfo(T), I);
end;

{ TArrayHelper }

class procedure TArrayHelper.Add<T>(var Source: TArray<T>; Element: T);
begin
  System.SetLength(Source, Length(Source)+1);
  Source[High(Source)]:= Element;
end;

class procedure TArrayHelper.AddRange<T>(var Source: TArray<T>;
  const Range: TArray<T>);
var
  I: Integer;
  aHigh: Integer;
begin
  if Length(Range) > 0 then
  begin
    aHigh:= High(Source)+1;
    SetLength(Source, Length(Source)+Length(Range));

    for I := Low(Range) to High(Range) do
      Source[aHigh+I]:= Range[I];
  end;
end;

class function TArrayHelper.Contains<T>(const Source: TArray<T>;
  const Predicate: TPredicate<T>): boolean;
var
  I: Integer;
begin
  Result:= false;
  if Length(Source) > 0 then
  begin
    for I := Low(Source) to High(Source) do
      if Predicate(Source[I]) then
      begin
        Result:= true;
        Break;
      end;
  end;
end;

class procedure TArrayHelper.Delete<T>(var Source: TArray<T>; Index: Integer);
var
  FCount: Integer;
  I: Integer;
begin
  if (Index < 0) or (Index >= Length(Source)) then
    raise Exception.CreateRes(@sOutOfRange);

  FCount:= Length(Source)-1;
  for I := 0 to FCount-Index-1 do
    Source[I+Index]:= Source[I+Index+1];

  SetLength(Source, FCount);
end;

class function TArrayHelper.IndexOf<T>(const Source: TArray<T>;
  const Predicate: TPredicate<T>; Direction: TDirection): Integer;
var
  I: Integer;
begin
  Result:= -1;
  if Length(Source) = 0 then Exit;
  if not Assigned(Predicate) then Exit;

  case Direction of
   FromBeginning:
      for I:= 0 to Length(Source)-1 do
        if Predicate(Source[I]) then
        begin
          Result:= I;
          Break;
        end;
   FromEnd:
      for I:= Length(Source)-1 downto 0 do
        if Predicate(Source[I]) then
        begin
          Result:= I;
          Break;
        end;
  end;
end;

class function TArrayHelper.IndexOf<T>(const Source: TArray<T>;
  const Element: T; AComparer: IComparer<T>;
  Direction: TDirection): Integer;
var
  I: Integer;
begin
  Result:= -1;
  if Length(Source) = 0 then Exit;
  if AComparer = nil then
    AComparer:= TComparer<T>.Default;

  case Direction of
   FromBeginning:
      for I:= 0 to Length(Source)-1 do
        if AComparer.Compare(Source[I], Element) = 0 then
        begin
          Result:= I;
          Break;
        end;
   FromEnd:
      for I:= Length(Source)-1 downto 0 do
        if AComparer.Compare(Source[I], Element) = 0 then
        begin
          Result:= I;
          Break;
        end;
  end;
end;

class procedure TArrayHelper.Insert<T>(var Source: TArray<T>; Index: Integer;
  Element: T);
var
  I: Integer;
begin
  if (Index < 0) then
    raise Exception.CreateRes(@sOutOfRange);

  if Index >= Length(Source) then
  begin
    TArray.Add<T>(Source, Element);
    Exit;
  end;

  SetLength(Source, Length(Source)+1);
  if index < Length(Source) then
  begin
    for I := Length(Source)-1 downto Index do
    begin
      Source[I]:= Source[I-1];
      if I-2 < 0 then Break;
    end;
    Source[Index]:= Element;
  end;
end;

class procedure TArrayHelper.InsertRange<T>(var Source: TArray<T>;
  Index: Integer; const Range: TArray<T>);
var
  I: Integer;
begin
  if (Index < 0) then
    raise Exception.CreateRes(@sOutOfRange);

  if Index >= Length(Source) then
  begin
    TArray.AddRange<T>(Source, Range);
    Exit;
  end;

  if Length(Range) > 0 then
    for I := High(Range) downto Low(Range) do
      TArray.Insert<T>(Source, Index, Range[I]);
end;

class function TArrayHelper.IsEmpty<T>(const Source: TArray<T>): boolean;
begin
  Result:= Length(Source) = 0;
end;

end.
