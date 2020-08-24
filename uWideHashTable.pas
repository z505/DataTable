{ Hash list for Delphi 5 and up, and Freepascal }

unit uWideHashTable;

interface

type
  THashIndex = LongWord;
  THashFunction = function(const Key: AnsiString): THashIndex;

  THashMode = (hmTesting,hmNormal);
  TDataMode = (dmDeleteData,dmIterateData,dmTestingData);

  TOnData = procedure(const Key: AnsiString; var Data: Pointer; DataMode: TDataMode) of object;

  PHashTableNode = ^THashTableNode;
  THashTableNode = packed record
    Key: AnsiString; // should be shortstring ?
    Data: Pointer;
    RowData: array of TVarRec;
    PriorNode: PHashTableNode;
    NextNode: PHashTableNode;
  end;

  THashTable = class
  private
    FNumOfItems: Integer;
    FHashMode: THashMode;
    FOnData: TOnData;
    FHashTableLength: Integer;
    FHashFunction: THashFunction;
    FHashTable: array of PHashTableNode;
  protected
    procedure SetHashMode(AHashMode: THashMode);
    function GetNode(Key: AnsiString; var Index: THashIndex): PHashTableNode;
    procedure DeleteNode(var Node: PHashTableNode);
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

constructor THashTable.Create(AHashTableLength: LongWord = 383);
begin
  inherited Create;

  FHashMode := hmNormal;
  FOnData := nil;
  FHashTableLength := AHashTableLength;

  SetLength(FHashTable,FHashTableLength);

  SetHashFunction(SimpleHash);

  //  make all the hash table pointers to nil
  FillChar(FHashTable[0],SizeOf(FHashTable),0);
end;

destructor THashTable.Destroy;
begin
  Clear;

  inherited Destroy;
end;

procedure THashTable.SetHashFunction(AHashFunction: THashFunction);
begin
  if(Assigned(AHashFunction))then
    FHashFunction := AHashFunction;
end;

procedure THashTable.SetHashMode(AHashMode: THashMode);
begin
  if(FNumOfItems = 0)then
    FHashMode := AHashMode;
end;

function THashTable.GetNode(Key: AnsiString; var Index: THashIndex): PHashTableNode;
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

function THashTable.GetData(Key: AnsiString; var Data: Pointer): Boolean;
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

procedure THashTable.DeleteNode(var Node: PHashTableNode);
begin
  if(Node = nil)then
    Exit;

  while(Node^.NextNode <> nil)do
  begin
    DeleteNode(Node^.NextNode);
  end;

  if Assigned(FOnData) then
    FOnData(Node^.Key,Node^.Data,dmDeleteData);

  Dec(FNumOfItems);
  
  Dispose(Node);
  Node := nil;
end;

procedure THashTable.Clear;
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

procedure THashTable.IterateData;
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
    end
    else
    while(Node <> nil)do
    begin
      if Assigned(FOnData) then
        FOnData(Node^.Key,Node^.Data,dmIterateData);

      Node := Node^.NextNode;
    end;
  end;
end;

procedure THashTable.AddData(Key: AnsiString; Data: Pointer);
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

procedure THashTable.AddRow(Key: AnsiString; data: array of TVarRec);
var
  Index: THashIndex;
  Node: PHashTableNode;
  i: integer;
begin
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
    for i := 0 to length(data) do begin
      Node^.RowData[i] := data[i];
    end;

    FHashTable[Index] := Node;

    if(Node^.NextNode <> nil)then
      Node^.NextNode^.PriorNode := Node;
  end
  else begin
    // Node^.RowData := Data; // instead use code below
    SetLength(Node^.RowData, length(data));
    for i := 0 to length(data) do begin
      Node^.RowData[i] := data[i];
    end;

  end;
end;

function THashTable.DeleteData(Key: AnsiString): Boolean;
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

    Dec(FNumOfItems);

    Finalize(Node^);
    Dispose(Node);
  end;
end;

end.
