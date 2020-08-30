unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  uDataTableMultiHashVariant, StdCtrls;

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
    bAdd10000Data: TButton;
    bShowPointerData: TButton;
    procedure bAddRowsClick(Sender: TObject);
    procedure bShowDataClick(Sender: TObject);
    procedure bAddMoreRowsClick(Sender: TObject);
    procedure bAdd10000Click(Sender: TObject);
    procedure bAdd10000DataClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TMyRow = record
    col1: integer;
    col2: string;
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

procedure TfrmMain.bAddRowsClick(Sender: TObject);
begin
  // TODO: or add it the first time you set the data
  //WideHT.ColCount := 2;
  WideHT.AddRow('key1', [5, 'string data 5']);
  WideHT.AddRow('key2', [6, 'string data 6']);

  status('Two rows added to the table.');
end;

function GetRow(TableVarRec: TRowData): TMyRow;
begin
  // optional initialization
  result.col1 := 0;
  result.col2 := '';
  // optional checks just in case
  if Length(TableVarRec) < 2 then exit;
  if Length(TableVarRec) > 2 then exit;

  Status('Length of row record:' +IntToStr(length(TableVarRec)));
  result.col1 := strtoint(TableVarRec[0]);
  result.col2 := string(TableVarRec[1]);

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
    Status('Item data: '+ inttostr(Row.col1) + ',' +Row.col2);
  end;
  //mStatus.Lines.EndUpdate;
end;

procedure TfrmMain.bAddMoreRowsClick(Sender: TObject);
begin
  WideHT.AddRow('key3', [8, 'string 8']);
  WideHT.AddRow('key4', [9, 'string 9']);
end;

procedure TfrmMain.bAdd10000Click(Sender: TObject);
var
  i: integer;
  AErr: integer;
begin
  for i := 1 to 1000 do begin
    AErr := WideHT.AddRow('key'+inttostr(i), [i, 'string' +inttostr(i+2)]);
    case AErr of
      ERR_HASH_LENGTH_TOO_SMALL: status('Error: hash length too small');
      ERR_HASH_DUPLICATE: status('Error: hash duplicate');
    end;

  end;
end;

procedure TfrmMain.bAdd10000DataClick(Sender: TObject);
var
  i: integer;
  AErr: integer;
begin
{
  for i := 1 to 10 do begin
    AErr := WideHT.AddData('key'+inttostr(i), PInteger(i));
    case AErr of
      ERR_HASH_LENGTH_TOO_SMALL: status('Error: hash length too small');
      ERR_HASH_DUPLICATE: status('Error: hash duplicate');
    end;
  end;

 }
end;

initialization
  HT := TDataTable.create;
  WideHT := TDataTable.create(5000);

finalization
  HT.free; HT := nil;
  WideHT.free; WideHT := nil;
end.
