unit UStockXV;

interface

uses System.SysUtils;

{type TRecord = record
    Date1: string;
    Open, High, Low, Close: real;
    Vol, unAdjVol: integer;
    Change, changePerc, vwap: real;
    label1: string;
    ChangeOT: real;
  end;
 }
type
  TData= class
  private
    Date: string;
    Open, High, Low, Close,  AdjClose: real;
    Volume: integer;
  public
    constructor Create(Line:string; count: integer); Overload;  //For .txt files
    function GetDate(): string;
    function GetOpen(): real;
    function GetHigh(): real;
    function GetLow(): real;
    function GetClose(): real;
    function GetAdjClose(): real;
    function GetVolume(): integer;
    procedure SetDate(value: string);
    procedure SetOpen(value: real);
    procedure SetHigh(value: real);
    procedure SetLow(value: real);
    procedure SetClose(value: real);
    procedure SetAdjClose(value: real);
    procedure SetVolume(value: integer);
  published
    constructor Create(a: string); Overload;     //For a live data

end;
  TShare= array of TData;

  TStock = class
  private
    FData: TShare;
    FSize: integer;
  public
    constructor Create(fileName: string; arrayLength: integer); Overload; //For .txt files
    function Display(value: integer): string;
    function GetSize(): integer;
    function GetData(var i:integer):TData;
  published
    constructor Create(LiveData: array of string); overload;      // for live data
end;


implementation

{ TStock }

constructor TStock.Create(fileName: string; arrayLength: integer);
var
  i, count: integer;
  line: string;
  myFile: textfile;
begin
FSize:= arrayLength;
SetLength(FData, FSize);            //Sets the length of the data required to store the data

if fileexists(fileName)=True then      //Checks for the files existence in the debug
  begin
    assign(myFile, fileName);         //assigns the file so it can be used
    reset(myFile);                    //reset allows it to be read
    i:=0;
    while not eof(myFile) do         //go through the file
      begin
        readln(myFile, line);        //Getting line by line
        if length(line)>0 then       //don't get empty lines
          begin
            count:=length(line);    //Count the length of the line
            FData[i]:= TData.Create(Line, count);    //Add the data points to their place in the list
            inc(i);
          end;

      end;
    closefile(myFile);          //close the file to stop file corruption
  end;

end;

constructor TStock.Create(LiveData: array of string);
var
  i: integer;
  line: string;
begin
  FSize:= length(LiveData); //Gets the length of the data required
  SetLength(FData, FSize);   //Sets the length of the data required
  for i := 0 to FSize-1 do       //Iterate through the size of the array
    begin
      FData[i]:= TData.Create(LiveData[i]);    // Add the data points to their places in the list
    end;
end;

function TStock.Display(value: integer): string;
begin
  result:=(FData[value].GetDate()+', '+floattostr(FData[value].GetOpen())+', '+
  floattostr(FData[value].GetHigh())+ ', '+floattostr(FData[value].GetLow())+', '+
  floattostr(FData[value].GetClose())+', '+ floattostr(FData[value].GetAdjClose())+ ', '+
  inttostr(FData[value].GetVolume()));  //Display the line of data.
end;

function TStock.GetData(var i: integer): TData;
begin
result := FData[i];                  //Get the desired set of data.
end;

function TStock.GetSize: integer;
begin
result:= FSize;                  //Get the size of the list
end;


{ TData }


constructor TData.Create(Line:string; count: integer);
var
  s,i: integer;
  chunk: string;

begin
  i:=0;
  chunk:='';
  for s := 1 to count do  // for the length of the line
    begin
      if (line[s]=',') or (s=count) then      //if you reach a comma or the end of line
        begin
          case i of
            0:
              Date:= chunk;        //sets the date variable
            1:
              Open:= strtofloat(chunk);         //Sets the open variable
            2:
              High:= strtofloat(chunk);          //Sets the high value
            3:
              Low:= strtofloat(chunk);       //Sets the low   variable
            4:
              Close:= strtofloat(chunk);      //Sets the close  variable
            5:
              AdjClose:= 0;                 //Sets the adjclose variable
            6:
              Volume:= strtoint(chunk);   //Sets the volume
          end;
          inc(i);
          chunk:='';                //Resets chunk
        end
      else
        begin
          chunk:= chunk+line[s];        //Add each character of the line
        end;
    end;
end;

constructor TData.Create(a: string);
var
  s,i, count: integer;
  chunk: string;
begin
count:= length(a);
i:=0;
chunk:= '';
  for s := 1 to count do  //Goes to the length of the string
    begin
      if (a[s]=',') or (s=count) then    //If the character is a comma or end of the line
        begin
          case i of
            0:
              Date:= chunk;       //Sets the date
            1:
              Open:= strtofloat(chunk);     // sets the open
            2:
              High:= strtofloat(chunk);    //sets the high
            3:
              Low:= strtofloat(chunk);   //sets the low
            4:
              Close:= strtofloat(chunk);     //sets the close
            5:
              AdjClose:= 0;              //Sets the adjclose
            6:
              Volume:= strtoint(chunk);   //Sets the volume
          end;
          inc(i);
          chunk:='';                    //resets the chunk
        end
      else
        begin
          chunk:= chunk+a[s];          //Adds the character to the chunk
        end;
    end;
end;

function TData.GetAdjClose(): real;
begin
  result:= AdjClose;                  //Get the adjclose
end;

function TData.GetClose(): real;
begin
  result:= Close;                ///Gets the close
end;

function TData.GetDate(): string;
begin
result:= Date;                      //Gets the date
end;

function TData.GetHigh(): real;
begin
  result:= High;               //Gets the high
end;

function TData.GetLow(): real;
begin
  result:= Low;                   //Gets the low
end;

function TData.GetOpen(): real;
begin
  result:= Open;                    //Gets the open
end;

function TData.GetVolume(): integer;
begin
  result:= Volume;               //Gets the volume
end;

procedure TData.SetAdjClose(value: real);
begin
 //AdjClose:= value;            //Sets adjclose
end;

procedure TData.SetClose(value: real);
begin
  //Close:= value;                     //Sets close
end;

procedure TData.SetDate(value: string);
begin
  //Date:= value;               //Sets date
end;

procedure TData.SetHigh(value: real);
begin
  //High:= value;                        //Sets Date
end;

procedure TData.SetLow(value: real);
begin
  //Low:= value;                       //Sets the low
end;

procedure TData.SetOpen(value: real);
begin
  //pen:= value;                       //Sets the open
end;

procedure TData.SetVolume(value: integer);
begin
  //Volume:= value;                   //Sets the volume
end;

end.
