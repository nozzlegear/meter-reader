// Learn more about F# at http://fsharp.org

open System
open System.Data.Sql
open System.Data.SqlClient
open System.Threading.Tasks
open FSharp.Control.Tasks.V2.ContextInsensitive
open FSharp.Data
open FSharp.Data.Runtime.StructuralTypes
open Dapper

type UsageSpreadSheet = CsvProvider<"../water_usage.csv">

let writeWaterUsage () =
    let spreadsheet = UsageSpreadSheet.Load("./water_usage.csv")
    // Map the dates of each row to unix time
    let rows =
        spreadsheet.Rows
        |> Seq.map (fun r ->
            {| date = DateTimeOffset r.``Date and time``
               usage = r.``Meter reading`` |})
        |> List.ofSeq
        
    use conn = new SqlConnection "Server=localhost,3011;Database=master;User=sa;Password=a-BAD_passw0rd"
    let parameters = rows |> Seq.map (fun r -> {| date = r.date; usage = r.usage |})
    let result = conn.Execute("INSERT INTO WaterMeterUsage (Date, Usage) VALUES (@date, @usage)", parameters)
    
    printfn "Inserted %i records" result

[<EntryPoint>]
let main argv =
    writeWaterUsage ()
//    |> Async.AwaitTask
//    |> Async.RunSynchronously
    0 // return an integer exit code
