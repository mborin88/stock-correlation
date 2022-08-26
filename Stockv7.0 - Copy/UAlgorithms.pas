unit UAlgorithms;

interface

type TAlgorithm = class
  private
  {Private declarations}
  Success: Boolean;

  public
  {Public Declarations}
  constructor Create();
  function correlationCoeffcient(A, B: array of real; line: integer): real;
end;

implementation

{ TAlgorithm }

function TAlgorithm.correlationCoeffcient(A, B: array of real; line: integer): real;
var
  i: integer;
begin
for i := 0 to length do
  begin

  end;

end;

constructor TAlgorithm.Create;
begin

end;

end.
