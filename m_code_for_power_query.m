let
    Source = Csv.Document(Web.Contents("your-csv-url-or-local"),[Delimiter=",", Encoding=1252]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {{"Date", type date}, {"ProductID", type text}, {"CurrentStock", Int64.Type}, {"SalesQuantity", Int64.Type}, {"UnitCost", type number}}),
    #"Added LowStock" = Table.AddColumn(#"Changed Type", "LowStockAlert", each if [CurrentStock] < 50 then "Low" else "OK", type text),
    #"Added ReorderQty" = Table.AddColumn(#"Added LowStock", "SuggestedReorder", each if [CurrentStock] < 50 then 100 else 0, Int64.Type)  // Placeholder
in
    #"Added ReorderQty"
