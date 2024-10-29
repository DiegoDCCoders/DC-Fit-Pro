unit uFunctions;

interface

uses FMX.TextLayout, FMX.ListView.Types, System.Types, FMX.Graphics, Data.DB,
     System.Classes, System.SysUtils;

function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
procedure LoadBitmapFromBlob(Bitmap: TBitmap; Blob: TBlobField);
function StringToFloat(vl : string) : double;
function ObterUF(uf : string) : string;

implementation

function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
var
  Layout: TTextLayout;
begin
  // Create a TTextLayout to measure text dimensions
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      // Initialize layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;
    // Get layout height
    Result := Round(Layout.Height);
    // Add one em to the height
    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

procedure LoadBitmapFromBlob(Bitmap: TBitmap; Blob: TBlobField);
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    Blob.SaveToStream(ms);
    ms.Position := 0;
    Bitmap.LoadFromStream(ms);
  finally
    ms.Free;
  end;
end;

function StringToFloat(vl : string) : double;
begin
    // R$ 5.800,00
    vl := StringReplace(vl, ',', '', [rfReplaceAll]); // R$ 5.80000
    vl := StringReplace(vl, '.', '', [rfReplaceAll]); // R$ 580000
    vl := StringReplace(vl, 'R$', '', [rfReplaceAll]); // 580000
    vl := StringReplace(vl, ' ', '', [rfReplaceAll]); // 580000

    try
        Result := StrToFloat(vl) / 100;
    except
        Result := 0;
    end;
end;

function ObterUF(uf : string) : string;
begin
    uf := LowerCase(uf);

    if uf = 'acre' then uf := 'AC' else
    if uf = 'alagoas' then uf := 'AL' else
    if uf = 'amapá' then uf := 'AP' else
    if uf = 'amazonas' then uf := 'AM' else
    if uf = 'bahia' then uf := 'BA' else
    if uf = 'ceará' then uf := 'CE' else
    if uf = 'distrito federal' then uf := 'DF' else
    if uf = 'espírito santo' then uf := 'ES' else
    if uf = 'goiás' then uf := 'GO' else
    if uf = 'maranhão' then uf := 'MA' else
    if uf = 'mato grosso' then uf := 'MT' else
    if uf = 'mato grosso do sul' then uf := 'MS' else
    if uf = 'minas gerais' then uf := 'MG' else
    if uf = 'pará' then uf := 'PA' else
    if uf = 'paraíba' then uf := 'PB' else
    if uf = 'paraná' then uf := 'PR' else
    if uf = 'pernambuco' then uf := 'PE' else
    if uf = 'piauí' then uf := 'PI' else
    if uf = 'rio de janeiro' then uf := 'RJ' else
    if uf = 'rio grande do norte' then uf := 'RN' else
    if uf = 'rio grande do sul' then uf := 'RS' else
    if uf = 'rondônia' then uf := 'RO' else
    if uf = 'roraima' then uf := 'RR' else
    if uf = 'santa catarina' then uf := 'SC' else
    if uf = 'são paulo' then uf := 'SP' else
    if uf = 'sergipe' then uf := 'SE' else
    if uf = 'tocantins' then uf := 'TO';

    Result := uf;
end;

end.
