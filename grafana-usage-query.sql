-- This query will return data that Grafana can use to display changes from one measurement to the next

-- Select a.Date as StartTime, 
--        b.Date as EndTime, 
--        DATEDIFF(minute,a.date,b.Date) as TimeChange, 
--        a.Usage as StartUsage, 
--        b.Usage as EndUsage, 
--        b.Usage - a.Usage as ValueChange
-- FROM WaterMeterUsage a, WaterMeterUsage b
-- WHERE b.Date = (Select MIN(c.Date) FROM WaterMeterUsage c WHERE c.Date > a.Date)

Select a.Date as [time],
       b.Usage - a.Usage as [value],
       N'Water Usage' as metric
FROM WaterMeterUsage a, WaterMeterUsage b
WHERE b.Date = (Select MIN(c.Date) FROM WaterMeterUsage c WHERE c.Date > a.Date)
