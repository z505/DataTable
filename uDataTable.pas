{ Also known as a wide hash list, wide associative array

  for Delphi and Freepascal

  Todo:
    - no key required when added, self generating key
  }

unit uDataTable;

interface

uses
  Sysutils, Dialogs; // Debugging ONLY, remove after done

type
  THashIndex = LongWord;
  THashFunction = function(const Key: AnsiString): THashIndex;

  THashMode = (hmTesting,hmNormal);
  TDataMode = (dmDeleteData,dmIterateData,dmTestingData);

  TDataTableRow = array of Variant;

  TOnData = procedure(const Key: AnsiString; var Data: Pointer; DataMode: TDataMode) of object;
  TOnRowData = procedure(const Key: AnsiString; var RowData: TDataTableRow; DataMode: TDataMode) of object;

  PHashTableNode = ^TDataTableNode;
  TDataTableNode = packed record
    Key: AnsiString; // should be shortstring ?
    Data: Pointer;
    RowData: TDataTableRow;
    PriorNode: PHashTableNode;
    NextNode: PHashTableNode;
  end;

  TDataTable = class
  private
    FNumOfItems: Integer;
    FHashMode: THashMode;
    FOnData: TOnData;
    FOnRowData: TOnRowData;
    FHashTableLength: Integer;
    FHashFunction: THashFunction;
    FHashTable: array of PHashTableNode;
  protected
    procedure SetHashMode(AHashMode: THashMode);
    function GetNode(Key: AnsiString; var Index: THashIndex): PHashTableNode;
    procedure DeleteNode(var Node: PHashTableNode);
    function GetDataTableRow(Index: integer): TDataTableRow;
  public
    constructor Create(AHashTableLength: LongWord = 383);
    destructor Destroy; override;

    procedure SetHashFunction(AHashFunction: THashFunction);

    procedure Clear;
    procedure IterateData;
    procedure AddData(Key: AnsiString; Data: Pointer);
    // wide table row addition
    procedure AddRow(key: AnsiString; data: array of TVarRec);

    function GetData(Key: AnsiString; var Data: Pointer): Boolean;
    function DeleteData(Key: AnsiString): Boolean;

    property HashTableLength: Integer read FHashTableLength;
    property NumOfItems: Integer read FNumOfItems;
    property HashMode: THashMode read FHashMode write SetHashMode;
    property OnData: TOnData read FOnData write FOnData;
    property OnRowData: TOnRowData read FOnRowData write FOnRowData;
    property Items[Index: Integer]: TDataTableRow read GetDataTableRow;
  end;

function SimpleHash(const Key: AnsiString): THashIndex;
function SimpleXORHash(const Key: AnsiString): THashIndex;
function ElfHash(const Key: AnsiString): THashIndex;

implementation

function SimpleHash(const Key: AnsiString): THashIndex;
const
  Multiplier = 65599; // a prime number
var
  i: Integer;
begin
  Result := 0;

  for i := 1 to Length(Key) do
  begin
    Result := Result * Multiplier + Ord(Key[i]);
  end;
end;

function SimpleXORHash(const Key: AnsiString): THashIndex;
const
  Multiplier = 65599; // a prime number
var
  i: Integer;
begin
  Result := 0;

  for i := 1 to Length(Key) do
  begin
    Result := Result * Multiplier xor Ord(Key[i]);
  end;
end;

function ElfHash(const Key: AnsiString): THashIndex;
var
  i, x: Integer;
begin
  Result := 0;
  for i := 1 to Length(Key) do
  begin
    Result := (Result shl 4) + Ord(Key[i]);
    x := Result and $F0000000;
    if (x <> 0) then
      Result := Result xor (x shr 24);
    Result := Result and (not x);
  end;
end;

constructor TDataTable.Create(AHashTableLength: LongWord = 383);
begin
  inherited Create;

  FHashMode := hmNormal;
  FOnData := nil;
  FOnRowData := nil;
  FHashTableLength := AHashTableLength;

  SetLength(FHashTable,FHashTableLength);

  SetHashFunction(SimpleHash);

  //  make all the hash table pointers to nil
  FillChar(FHashTable[0],SizeOf(FHashTable),0);
end;

destructor TDataTable.Destroy;
begin
  Clear;

  inherited Destroy;
end;

procedure TDataTable.SetHashFunction(AHashFunction: THashFunction);
begin
  if(Assigned(AHashFunction))then
    FHashFunction := AHashFunction;
end;

procedure TDataTable.SetHashMode(AHashMode: THashMode);
begin
  if(FNumOfItems = 0)then
    FHashMode := AHashMode;
end;

function TDataTable.GetNode(Key: AnsiString; var Index: THashIndex): PHashTableNode;
begin
  Result := Nil;

  if(FHashMode = hmTesting)then
    Exit;

  Index := FHashFunction(Key) mod FHashTableLength;

  Result :=  FHashTable[Index];

  while(Result <> nil)do
  begin
    if(Result^.Key = Key)then
    begin
      Break;
    end;

    Result := Result^.NextNode;
  end;
end;

function TDataTable.GetData(Key: AnsiString; var Data: Pointer): Boolean;
var
  Node: PHashTableNode;
  Index: THashIndex;
begin
  Result := False;

  Node :=  GetNode(Key,Index);

  if(Node <> nil)then
  begin
    Data := Node^.Data;
    Result := True;
  end;
end;

procedure TDataTable.DeleteNode(var Node: PHashTableNode);
begin
  if(Node = nil)then
    Exit;

  while(Node^.NextNode <> nil)do
  begin
    DeleteNode(Node^.NextNode);
  end;

  if Assigned(FOnData) then
    FOnData(Node^.Key, Node^.Data,dmDeleteData);

  if Assigned(FOnRowData) then
    FOnRowData(Node^.Key, Node^.RowData, dmDeleteData);

  Dec(FNumOfItems);
  
  Dispose(Node);
  Node := nil;
end;

function GetDataTableRow(idx: integer): TDataTableRow;
begin

end;

procedure TDataTable.Clear;
var
  i: Integer;
begin
  if(FHashMode = hmTesting)then
    Exit;

  for i := Low(FHashTable) to High(FHashTable) do
  begin
    DeleteNode(FHashTable[i]);
  end;

  FNumOfItems := 0;
end;

procedure TDataTable.IterateData;
var
  i: Integer;
  Node: PHashTableNode;
begin
  for i := Low(FHashTable) to High(FHashTable) do
  begin
    Node := FHashTable[i];

    if(FHashMode = hmTesting)then
    begin
      if Assigned(FOnData) then
        FOnData('',Pointer(Node),dmTestingData);

      if Assigned(FOnRowData) then
        FOnRowData('', Node.RowData , dmTestingData);

    end
    else begin
      while(Node <> nil)do
      begin
        if Assigned(FOnData) then
          FOnData(Node^.Key, Node^.Data,dmIterateData);

        if Assigned(FOnRowData) then
          FOnRowData(Node^.Key, Node^.RowData, dmIterateData);

        Node := Node^.NextNode;
      end;
    end;
  end;
end;

procedure TDataTable.AddData(Key: AnsiString; Data: Pointer);
var
  Index: THashIndex;
  Node: PHashTableNode;
begin
  Node := GetNode(Key,Index);

  if(FHashMode = hmTesting)then
  begin
    Inc(FNumOfItems);
    FHashTable[Index] := Pointer(Integer(FHashTable[Index])+1);
    Exit;
  end;

  if(Node = nil)then
  //  not found, so create a new Node and add to the beginning of the
  //  linked list at the hash table index
  begin
    Inc(FNumOfItems);

    New(Node);

    Node^.Key := Key;
    Node^.PriorNode := nil;
    Node^.NextNode := FHashTable[Index];
    Node^.Data := Data;
    FHashTable[Index] := Node;

    if(Node^.NextNode <> nil)then
      Node^.NextNode^.PriorNode := Node;
  end
  else
    Node^.Data := Data;
end;

procedure VarRecArrToVariantArr(const vr: array of TVarRec; var rslt: TDataTableRow);
var
  i: integer;
begin
  setlength(rslt, length(vr));
  for i := 0 to length(vr) do begin
    case vr[i].VType of
      vtInteger: rslt[i] := vr[i].VInteger;
      vtAnsistring: rslt[i] := ansistring(vr[i].VAnsistring);
    end;

  end;
end;

procedure TDataTable.AddRow(Key: AnsiString; data: array of TVarRec);
var
  Index: THashIndex;
  Node: PHashTableNode;
  i, j: integer;
begin
  if length(data) < 1 then exit;;
  Node := GetNode(Key, Index);

  if(FHashMode = hmTesting)then
  begin
    Inc(FNumOfItems);
    FHashTable[Index] := Pointer(Integer(FHashTable[Index])+1);
    Exit;
  end;

  if(Node = nil)then
  //  not found, so create a new Node and add to the beginning of the
  //  linked list at the hash table index
  begin
    Inc(FNumOfItems);

    New(Node);

    Node^.Key := Key;
    Node^.PriorNode := nil;
    Node^.NextNode := FHashTable[Index];
    // Node^.RowData := Data; // instead use code below
    SetLength(Node^.RowData, length(data));
    for i := 0 to length(data)-1 do begin
      case data[i].VType of
        vtInteger: Node^.RowData[i] := data[i].VInteger;
        vtAnsistring: Node^.RowData[i] := ansistring(data[i].VAnsistring);
      end;
    end;

    FHashTable[Index] := Node;

    if(Node^.NextNode <> nil)then
      Node^.NextNode^.PriorNode := Node;
  end
  else begin
    // Node^.RowData := Data; // instead use code below
    SetLength(Node^.RowData, length(data));
    for i := 0 to length(data)-1 do begin
     //  Node^.RowData[i] := data[i];
      case data[i].VType of
        vtInteger: Node^.RowData[i] := data[i].VInteger;
        vtAnsistring: Node^.RowData[i] := ansistring(data[i].VAnsistring);
      end;

    end;

  end;
end;

function TDataTable.DeleteData(Key: AnsiString): Boolean;
var
  Index: THashIndex;
  Node: PHashTableNode;
begin
  Result := False;

  if(FHashMode = hmTesting)then
    Exit;

  Node := GetNode(Key,Index);

  if(Node <> nil)then
  begin
    Result := True;

    if(Node^.PriorNode = nil)and(Node^.NextNode = nil)then
    //  node being deleted is at the beginning of the list...
    begin
      FHashTable[Index] := nil;
    end
    else
    if(Node^.PriorNode <> nil)and(Node^.NextNode <> nil)then
    //  node being deleted is somewhere in the middle of the list...
    begin
      Node^.PriorNode^.NextNode := Node^.NextNode;
      Node^.NextNode^.PriorNode := Node^.PriorNode;
    end
    else
    if(Node^.PriorNode = nil)and(Node^.NextNode <> nil)then
    //  node being deleted is at the beginning of the list...
    begin
      Node^.NextNode^.PriorNode := nil;

      FHashTable[Index] := Node^.NextNode;
    end
    else
    if(Node^.PriorNode <> nil)and(Node^.NextNode = nil)then
    //  node being deleted is at the end of the list...
    begin
      Node^.NextNode^.PriorNode := nil;
    end;

    if Assigned(FOnData) then
      FOnData(Node^.Key,Node^.Data,dmDeleteData);

    if Assigned(FOnRowData) then
      FOnRowData(Node^.Key, Node^.RowData, dmDeleteData);

    Dec(FNumOfItems);

    Finalize(Node^);
    Dispose(Node);
  end;
end;

function TDataTable.GetDataTableRow(Index: integer): TDataTableRow;
var
  i, found: Integer;
  Node: PHashTableNode;
begin
  // This line does not work so use the code further down
  //result := FHashTable[Index].RowData;

  found := 0;
  for i := Low(FHashTable) to High(FHashTable) do
  begin
    Node := FHashTable[i];
 {
    while (Node <> nil) do
    begin
      inc(found);

      if found = Index then begin
        result := Node^.RowData;
        Node := Node^.NextNode;
        break;  // exit the loop when the count is equal to index paramater fed in
      end;

    end;       }

    if Node <> nil then begin
      inc(found);
      result := Node^.RowData;
      Node := Node^.NextNode;
      if found = Index then
        break;  // exit the loop when the count is equal to index paramater fed in
    end;

  end;
end;

end.
