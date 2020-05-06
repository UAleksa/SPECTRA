unit SPECTRA.ObjectEx;

interface

uses SPECTRA.Messages, System.SysUtils, SPECTRA.List;

type
  TObjectHelper = class helper for TObject
  private
    class var WeakObjects: IList<NativeUInt>;
    class constructor Create;

    function WeakIndex: Integer;
  public
    procedure Free;
    /// <summary>
    ///  Создает полный клон объекта
    /// </summary>
    function Clone: System.TObject;
    /// <summary>
    ///  Ссылка на объект удаляется из сборщика мусора (только для Strong)
    /// </summary>
    procedure CollectableDisable;

    function IsCollectable(Tag: string=''): boolean;
    /// <summary>
    ///  Возврщает признак подписания объекта
    /// </summary>
    function IsSubscribed: boolean; overload;
    /// <summary>
    ///  Возврщает признак подписания объекта
    /// </summary>
    function IsSubscribed(const MessageID: NativeUInt): boolean; overload;
    /// <summary>
    ///  Помещает объект в список удаляемых автоматически объектов (объект удаляется по окончании работы программы)
    /// </summary>
    procedure Strong(Tag: string=''); overload;
    /// <summary>
    ///  Помещает объект в список удаляемых автоматически объектов. aOwner - объект-владелец.
    /// </summary>
    procedure Strong(aOwner: TObject); overload;
    /// <summary>
    ///  Подписывает объект
    /// </summary>
    function Subscribe(const aMessageClass: TClass; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    /// <summary>
    ///  Подписывает объект
    /// </summary>
    function Subscribe(const MessageID: NativeUInt; const ListenerMethod: TMessageFunc): NativeUInt; overload;
    /// <summary>
    ///  Подписывает объект
    /// </summary>
    function Subscribe(const ListenerMethod: TMessageFunc): NativeUInt; overload;
    /// <summary>
    ///  Отписывает объект
    /// </summary>
    procedure UnSubscribe(Immediate: boolean=false); overload;
    /// <summary>
    ///  Отписывает объект
    /// </summary>
    procedure UnSubscribe(const MessageID: NativeUInt; Immediate: boolean=false); overload;
    /// <summary>
    ///  Объект оборачвается в смарт поинтер и будет удален при выходе из зоны видимости
    /// </summary>
    function Weak: IInterface;
  end;

implementation

uses SPECTRA.GC, Data.DBXJSON, Data.DBXJSONReflect, System.JSON,
  SPECTRA.Detour, SPECTRA.Consts, Winapi.Windows;

const
  cMarkedObject = 'The object has already been marked for removal';

{ TObjectHelper }

procedure TObjectHelper.Strong(Tag: string);
begin
  if WeakIndex > -1 then
    raise Exception.Create(cMarkedObject);

  if Tag.IsEmpty then
    GC.Add(Self, Self.GetHashCode.ToString)
  else
    GC.Add(Self, Tag);

  WeakObjects.Add(NativeUInt(Self.GetHashCode));
end;

procedure TObjectHelper.CollectableDisable;
begin
  GC.Remove(Self.GetHashCode.ToString);
end;

class constructor TObjectHelper.Create;
begin
  WeakObjects:= TList<NativeUInt>.Create;
end;

procedure TObjectHelper.Free;
var
  i: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  if Self <> nil then
  begin
    {$IFDEF MSWINDOWS}
    //сообщение сборщику мусора на освобождение зависимых объектов
    if GCHash <> Self.GetHashCode then
      Send_Message(GCHash, CM_DESTROING, NativeUInt(Self.GetHashCode), 0);
    {$ENDIF MSWINDOWS}

    i:= WeakObjects.IndexOf(NativeUInt(Self.GetHashCode));
    if i > -1 then
      WeakObjects.Delete(i);

    Destroy;
  end;
{$ENDIF}
end;

function TObjectHelper.Weak: IInterface;
begin

  if WeakIndex > -1 then
    raise Exception.Create(cMarkedObject);

  Result:= TFreeTheValue.Create(Self);

  WeakObjects.Add(NativeUInt(Self.GetHashCode));
end;

function TObjectHelper.Clone: System.TObject;
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

function TObjectHelper.IsCollectable(Tag: string): boolean;
begin
  if Tag.IsEmpty then
    Result:= (GC.ObjectByTag(Self.GetHashCode.ToString) <> nil)
  else
    Result:= (GC.ObjectByTag(Tag) <> nil);

  if not Result then
    Result:= WeakObjects.Contains(NativeUInt(GetHashCode));
end;

function TObjectHelper.IsSubscribed(const MessageID: NativeUInt): boolean;
begin
  Result:= Msgs.IsSubscribed(Self, MessageID);
end;

function TObjectHelper.WeakIndex: Integer;
begin
  Result:= WeakObjects.IndexOf(NativeUInt(GetHashCode));
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

procedure TObjectHelper.Strong(aOwner: TObject);
begin
  if aOwner = Self then Exit;


  if WeakIndex > -1 then
    raise Exception.Create(cMarkedObject);

  GC.Add(Self, aOwner, Self.GetHashCode.ToString);

  WeakObjects.Add(NativeUInt(Self.GetHashCode));
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

end.
