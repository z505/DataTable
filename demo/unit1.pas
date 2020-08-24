unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uDataTableStringDebug, StdCtrls;

type
  TfrmMain = class(TForm)
    mStatus: TMemo;
    bAddItems: TButton;
    bAccessData: TButton;
    Button1: TButton;
    GroupBox1: TGroupBox;
    bAddRows: TButton;
    Label2: TLabel;
    bShowData: TButton;
    bAddMoreRows: TButton;
    bAdd10000: TButton;
    procedure bAddItemsClick(Sender: TObject);
    procedure bAccessDataClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure bAddRowsClick(Sender: TObject);
    procedure bShowDataClick(Sender: TObject);
    procedure bAddMoreRowsClick(Sender: TObject);
    procedure bAdd10000Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TMyRow = record
    col1: integer;
    col2: integer;
  end;


var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

var
  HT: TDataTable;
  WideHT: TDataTable;

procedure status(s: string);
begin
  frmMain.mStatus.lines.add(s);
end;

procedure TfrmMain.bAddItemsClick(Sender: TObject);
var
  sdata: string;
begin
 //
  sdata := 'item1';
  HT.AddData('test1', pointer(sdata));

  sdata := 'bad data out of scope';
end;

procedure TfrmMain.bAccessDataClick(Sender: TObject);
var
  datastr: string;
begin
  HT.GetData('test1', pointer(datastr));
  status(datastr);
end;

procedure GetData(key: string; var v: array of TVarRec);
begin
  //

end;

procedure SetData(key: string; v: array of TVarRec);
begin
  //

end;

// gets a row of data as separate result params instead of one record
procedure GetDataStrongTypes(var vr: array of TVarRec;
                             var ColString: string;
                             var ColInteger: integer);
begin

end;

procedure GetDataRec(var vr: array of TVarRec; var row: TMyRow);
begin
  //vr.
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  vr: TVarRec;
begin
  GetData('field1', vr);
  SetData('field50', ['test50', 50]);
end;

procedure TfrmMain.bAddRowsClick(Sender: TObject);
begin
  // TODO: or add it the first time you set the data
  //WideHT.ColCount := 2;
  WideHT.AddRow('key1', 5, 1);
  WideHT.AddRow('key2', 6, 2);

  status('Two rows added to the table.');
end;

function GetRow(TableVarRec: TDataTableRow): TMyRow;
begin
  //if Length(TableVarRec) < 2 then exit;
  //Status('Length of record:' +IntToStr(length(TableVarRec)));
//  if TableVarRec[0].VType = vtString then status('other string found');
//  if TableVarRec[0].VType = vtAnsistring then status('ansistring found');
//  if TableVarRec[1].VType = vtInteger then status('integer found');
  result.col1 := TableVarRec.col1;
  result.col2 := TableVarRec.col2;
//  showmessage(TableVarRec.col2);
end;

procedure TfrmMain.bShowDataClick(Sender: TObject);
var
  i: integer;
  Row: TMyRow;
begin
  status('Data:');
  status('Num of items: '+inttostr(WideHT.NumOfItems));
  //mStatus.Lines.BeginUpdate;
  for i := 0 to WideHT.NumOfItems-1 do begin
    Row := GetRow(WideHT.items[i]);
    Status('Item data: '+ inttostr(Row.col1) + ',' + IntToStr(Row.col2));
  end;
  //mStatus.Lines.EndUpdate;
end;

procedure TfrmMain.bAddMoreRowsClick(Sender: TObject);
begin
  WideHT.AddRow('key3', 8, 3);
  WideHT.AddRow('key4', 9, 4);
end;

procedure TfrmMain.bAdd10000Click(Sender: TObject);
var
  i: integer;
begin
  for i := 1 to 10000 do begin
    WideHT.AddRow('key'+inttostr(i), pchar('item'+inttostr(i)), i);
  end;
end;

initialization
  HT := TDataTable.create;
  WideHT := TDataTable.create;

finalization
  HT.free; HT := nil;
  WideHT.free; WideHT := nil;
end.
