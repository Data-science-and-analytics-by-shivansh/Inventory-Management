let
    Source = Csv.Document(File.Contents("C:\path\to\data\inventory_data.csv"),[Delimiter=",", Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Date", type date}, {"ProductID", type text}, {"ProductName", type text}, {"Category", type text}, {"CurrentStock", Int64.Type}, {"SalesQuantity", Int64.Type}, {"UnitCost", type number}, {"SellingPrice", type number}, {"LeadTimeDays", Int64.Type}}),
    #"Added ReorderFlag" = Table.AddColumn(#"Changed Type", "ReorderFlag", each if [CurrentStock] < 50 then "Reorder Now" else "OK", type text),
    #"Added Turnover" = Table.AddColumn(#"Added ReorderFlag", "TurnoverProxy", each [SalesQuantity] / if [CurrentStock] = 0 then 1 else [CurrentStock], type number)
in
    #"Added Turnover"
