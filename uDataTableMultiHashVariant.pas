{ Also known as a wide hash list, wide associative array

  for Delphi and Freepascal

  Todo:
    - no key required when added, self generating key
    - memory management for pchars, freemem on Delete and other
  }

unit uDataTableMultiHashVariant;

interface

uses
  Sysutils, Dialogs; // Debugging ONLY, remove after done

type
  THashIndex = LongWord;
  THashFunction = function(const Key: AnsiString): THashIndex;

  THashMode = (hmTesting,hmNormal);
  TDataMode = (dmDeleteData,dmIterateData,dmTestingData);

  TRowData = array of Variant;

  TOnData = procedure(const Key: AnsiString; var Data: Pointer; DataMode: TDataMode) of object;
  TOnRowData = procedure(const Key: AnsiString; var RowData: TRowData; DataMode: TDataMode) of object;

  PHashTableNode = ^TDataTableNode;
  TDataTableNode = packed record
    Key: Ansistring; // should be shortstring ?
    Data: Pointer;
    RowData: TRowData;
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
    function GetNode(Key: AnsiString; var Index: THashIndex; var err: integer): PHashTableNode;
    procedure DeleteNode(var Node: PHashTableNode);
    function GetDataTableRow(Index: integer): TRowData;
  public
    constructor Create(AHashTableLength: LongWord = 383);
    destructor Destroy; override;

    procedure SetHashFunction(AHashFunction: THashFunction);

    procedure Clear;
    procedure IterateData;
    function AddRow(Key: AnsiString; ARowData: array Of TVarRec): integer;

    function GetData(Key: AnsiString; var Data: Pointer): Boolean;
    function DeleteData(Key: AnsiString): Boolean;

    property HashTableLength: Integer read FHashTableLength;
    property NumOfItems: Integer read FNumOfItems;
    property HashMode: THashMode read FHashMode write SetHashMode;
    property OnData: TOnData read FOnData write FOnData;
    property OnRowData: TOnRowData read FOnRowData write FOnRowData;
    property Items[Index: Integer]: TRowData read GetDataTableRow;
  end;

const
  ERR_HASH_LENGTH_TOO_SMALL = 1;
  ERR_HASH_DUPLICATE = 2;
  ERR_INVALID_TYPE_ADDED = 3;

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

function TDataTable.GetNode(Key: AnsiString; var Index: THashIndex; var err: integer): PHashTableNode;
begin
  Result := Nil;
  err := 0;

  if(FHashMode = hmTesting)then
    Exit;

  Index := FHashFunction(Key) mod FHashTableLength;

  if Index > FHashTableLength then begin
    err := ERR_HASH_LENGTH_TOO_SMALL;
    exit;
  end;

  Result :=  FHashTable[Index];

  while (Result <> nil) do
  begin
    if Result^.Key <> Key then
    begin
      // duplicate hash with different keys
      err := ERR_HASH_DUPLICATE;
      Break;
    end;

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
  AErr: integer;
begin
  Result := False;

  Node :=  GetNode(Key,Index, AErr);

  if AErr > 0 then begin
    Data := nil;
    exit;
  end;

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

function GetDataTableRow(idx: integer): TRowData;
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

// returns error if hashlist too small (1) or duplicate (2)
function TDataTable.AddRow(Key: AnsiString; ARowData: array of TVarRec): integer;
var
//  rd: TRowData;
  Index: THashIndex;
  Node: PHashTableNode;
  k: integer;
  AErr: integer;
  VariantData: TRowData;

  procedure AddData;
  var
    j: integer;
  begin
    SetLength(Node^.RowData, Length(ARowData));
    for j := 0 to length(ARowData)-1 do begin
      Node^.RowData[j] := VariantData[j];
    end;
  end;

begin
  // rd := CopyRowData(ARowData);
  Node := GetNode(Key, Index, AErr);

  if AErr > 0 then begin
    result := AErr;
    exit;
  end;

  SetLength(VariantData, Length(ARowData));
  for k := 0 to length(ARowData)-1 do begin
    case ARowData[k].VType of
      vtInteger:
      begin
        VariantData[k] := ARowData[k].VInteger;
      end;

      vtBoolean:
      begin
        VariantData[k] := char(ARowData[k].VBoolean);
      end;

      vtChar:
      begin
        VariantData[k] := char(ARowData[k].VChar);
      end;

      vtExtended:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtString:
      begin
        VariantData[k] := string(ARowData[k].vString);
      end;

      vtPointer:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtPChar:
      begin
        Node^.RowData[k] := string(ARowData[k].vPChar);
      end;

      vtObject:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtClass:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtWideChar:
      begin
        VariantData[k] := char(ARowData[k].vWideChar);
      end;

      vtPWideChar:
      begin
        VariantData[k] := string(ARowData[k].vPWideChar);
      end;

      vtAnsistring:
      begin
        VariantData[k] := string(ARowData[k].vAnsistring);
      end;

      vtCurrency:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtVariant:
      begin
        VariantData[k] := string(ARowData[k].vVariant);
      end;

      vtInterface:
      begin
        result := ERR_INVALID_TYPE_ADDED;
        exit;
      end;

      vtWideString:
      begin
        VariantData[k] := string(ARowData[k].vWideString);
      end;

      vtInt64:
      begin
        VariantData[k] := integer(ARowData[k].VInt64);
      end;

      vtUnicodeString:
      begin
        VariantData[k] := string(ARowData[k].vUnicodeString);
      end;

   end;

  end;


  if (FHashMode = hmTesting) then
  begin
    Inc(FNumOfItems);
    FHashTable[Index] := Pointer(Integer(FHashTable[Index])+1);
    Exit;
  end;

  if (Node = nil) then
  //  not found, so create a new Node and add to the beginning of the
  //  linked list at the hash table index
  begin
    Inc(FNumOfItems);

    New(Node);

    Node^.Key := Key;
    Node^.PriorNode := nil;
    Node^.NextNode := FHashTable[Index];

    AddData;

    FHashTable[Index] := Node;

    if(Node^.NextNode <> nil)then
      Node^.NextNode^.PriorNode := Node;
  end
  else begin
    AddData;
  end;
end;

{
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
}


function TDataTable.DeleteData(Key: AnsiString): Boolean;
var
  Index: THashIndex;
  Node: PHashTableNode;
  AErr: integer;
begin
  Result := False;

  if(FHashMode = hmTesting)then
    Exit;

  Node := GetNode(Key,Index, AErr);

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

function TDataTable.GetDataTableRow(Index: integer): TRowData;
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
      //setlength(result, 2);
      result := Node^.RowData;
      Node := Node^.NextNode;
      if found = Index then
        break;  // exit the loop when the count is equal to index paramater fed in
    end;

  end;
end;

end.
