unit SPECTRA.Utils;

interface


  procedure FreeObject(var Obj);

implementation

uses
  Winapi.Windows, SPECTRA.ObjectEx;


procedure FreeObject(var Obj);
{$IFNDEF AUTOREFCOUNT}
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ELSE}
begin
  TObject(Obj) := nil;
end;
{$ENDIF}



end.
