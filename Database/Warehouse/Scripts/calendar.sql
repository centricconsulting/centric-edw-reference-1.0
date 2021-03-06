use warehouse
GO

IF OBJECT_ID('calendar') is not null
  drop table calendar
GO

CREATE TABLE dbo.calendar (
  date_key int NOT NULL

, [date] date NULL
, day_of_week int NULL
, day_of_month int NULL
, day_of_quarter int NULL
, day_of_year int NULL
, day_desc_01 varchar(20) NULL
, day_desc_02 varchar(20) NULL
, day_desc_03 varchar(20) NULL
, day_desc_04 varchar(20) NULL
, weekday_desc_01 varchar(20) NULL
, weekday_desc_02 varchar(20) NULL
, day_weekday_ct varchar(20) NULL

, week_key int NULL
, week_start_dt date NULL
, week_end_dt date NULL
, week_day_ct int NULL
, week_weekday_ct int NULL

, month_key int NULL
, month_start_dt date NULL
, month_end_dt date NULL
, month_of_quarter int NULL
, month_of_year int NULL
, month_desc_01 varchar(20) NULL
, month_desc_02 varchar(20) NULL
, month_desc_03 varchar(20) NULL
, month_desc_04 varchar(20) NULL
, month_day_ct int NULL
, month_weekday_ct int NULL

, quarter_key int NULL
, quarter_start_dt date NULL
, quarter_end_dt date NULL
, quarter_of_year int NULL
, quarter_desc_01 varchar(20) NULL
, quarter_desc_02 varchar(20) NULL
, quarter_desc_03 varchar(50) NULL
, quarter_desc_04 varchar(50) NULL
, quarter_month_ct int NULL
, quarter_day_ct int NULL
, quarter_weekday_ct int NULL

, year_key int NULL
, [year] int NULL
, year_start_dt date NULL
, year_end_dt date NULL
, year_desc_01 varchar(20) NULL
, year_month_ct int NULL
, year_quarter_ct int NULL
, year_day_ct int NULL
, year_weekday_ct int NULL

)
GO


create unique clustered index calendar_uxc on calendar (date_key);

GO

-- calendar_rebuild
-- select * from calendar order by date_key
if  exists (select * from sys.objects where object_id = object_id('calendar_rebuild') and type in ('P', 'PC'))
drop procedure calendar_rebuild
go

CREATE PROCEDURE calendar_rebuild
  @start_year int = 2010
, @end_year int = 2020
AS
BEGIN

  SET NOCOUNT ON

  declare
    @source_key int
  , @current_dt date
  , @last_dt date
  , @date_uid char(8)

  declare @unknown_text varchar(20)
  set @unknown_text = 'Unknown'
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE calendar;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert zero key

  
	INSERT INTO calendar (
	  date_key
	, weekday_desc_01
	, weekday_desc_02
	, month_desc_01
	, month_desc_02
	, month_desc_03
	, month_desc_04
	, quarter_desc_01
	, quarter_desc_02
	, quarter_desc_03
	, quarter_desc_04
	, year_desc_01
	, week_key
	, month_key
	, quarter_key
	, year_key
	) VALUES (
	  0 -- date_key
	, @unknown_text -- weekday_desc_01
	, @unknown_text -- weekday_desc_02
	, @unknown_text -- month_desc_01
	, @unknown_text -- month_desc_02
	, @unknown_text -- month_desc_03
	, @unknown_text -- month_desc_04
	, @unknown_text -- quarter_desc_01
	, @unknown_text -- quarter_desc_02
	, @unknown_text -- quarter_desc_03
	, @unknown_text -- quarter_desc_04
	, @unknown_text -- year_desc_01
	, 0 -- week_key
	, 0 -- month_key
	, 0 -- quarter_key
	, 0 -- year_key
	)

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year from start and end...should be cleaned up at end

  set @current_dt = CONVERT(date,CAST(@start_year-1 as CHAR(4)) + '-01-01')
  set @last_dt = CONVERT(date,CAST(@end_year+1 as CHAR(4)) + '-12-31')
  
  select @source_key = 1 -- x.source_key from source x where x.source_uid = 'STD'

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- loop and load basic values into calendar table
    
  WHILE @current_dt <= @last_dt
  BEGIN

    SET @date_uid = CONVERT(char(8),@current_dt,112) 

    INSERT INTO calendar (
      date_key
    , [date]
    , day_of_week
    , day_of_month
    , day_of_quarter
    , day_of_year
    , day_desc_01
    , day_desc_02
    , day_desc_03
    , day_desc_04
    , weekday_desc_01
    , weekday_desc_02
    , day_weekday_ct
    , week_key
    , week_start_dt
    , week_end_dt
    , week_day_ct
    , week_weekday_ct
    , month_key
    , month_start_dt
    , month_end_dt
    , month_of_quarter
    , month_of_year
    , month_desc_01
    , month_desc_02
    , month_desc_03
    , month_desc_04
    , month_day_ct
    , month_weekday_ct
    , quarter_key
    , quarter_start_dt
    , quarter_end_dt
    , quarter_of_year
    , quarter_desc_01
    , quarter_desc_02
    , quarter_desc_03
    , quarter_desc_04
    , quarter_month_ct
    , quarter_day_ct
    , quarter_weekday_ct
    , year_key
    , [year]
    , year_start_dt
    , year_end_dt
    , year_desc_01
    , year_month_ct
    , year_quarter_ct
    , year_day_ct
    , year_weekday_ct
    ) VALUES (
      CONVERT(int,@date_uid) -- date_key
    , @current_dt -- date
    , DATEPART(weekday,@current_dt) -- day_of_week
    , DATEPART(day,@current_dt) -- day_of_month
    , NULL -- day_of_quarter
    , DATEPART(dayofyear,@current_dt) -- day_of_year
    , CONVERT(char(10),@current_dt,101) -- day_desc_01 "12/31/2010"
    , SUBSTRING(@date_uid,7,2) + '-' + SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + SUBSTRING(@date_uid,1,4) -- day_desc_02 "31-Dec-2010"
    , SUBSTRING(@date_uid,1,4) + '.' + SUBSTRING(@date_uid,5,2) + '.' + SUBSTRING(@date_uid,7,2) -- day_desc_03 "2010.12.31"   
    , DATENAME(month,@current_dt) + ' ' + CAST(DAY(@current_dt) as varchar(2)) + ', ' + CAST(YEAR(@current_dt) as varchar(4)) -- day_desc_04 "December 31, 2010"
    , SUBSTRING(DATENAME(weekday,@current_dt),1,3) -- weekday_desc_01 "Wed"    
    , DATENAME(weekday,@current_dt) -- weekday_desc_02 "Wednesday"
    , CASE WHEN DATEPART(weekday,@current_dt) IN (1,7) THEN 0 ELSE 1 END -- day_weekday_ct
    , CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt),112) -- week_key
    , DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt) -- week_start_dt
    , DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt) -- week_end_dt
    , 7 -- week_day_ct
    , 5 -- week_weekday_ct
    , YEAR(@current_dt)*100 + MONTH(@current_dt) -- month_key
    , NULL -- month_start_dt
    , NULL -- month_end_dt
    , CONVERT(int,(MONTH(@current_dt)-1)/3) + 1 -- month_of_quarter
    , MONTH(@current_dt) -- month_of_year
    , SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_01
    , DATENAME(month,@current_dt) + ' ' + CAST(YEAR(@current_dt) as varchar(4)) -- month_desc_02
    , SUBSTRING(DATENAME(month,@current_dt),1,3) -- month_desc_03
    , DATENAME(month,@current_dt) -- month_desc_04
    , NULL -- month_day_ct
    , NULL -- month_weekday_ct
    , YEAR(@current_dt)*100
	    + CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_key
    , NULL -- quarter_start_dt
    , NULL -- quarter_end_dt
    ,  CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_of_year
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END + '.' + CAST(YEAR(@current_dt) as varchar(4)) -- quarter_desc_01
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END -- quarter_desc_02
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter, ' + CAST(YEAR(@current_dt) as varchar(4))-- quarter_desc_03
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter' -- quarter_desc_04
    , 3 -- quarter_month_ct
    , NULL -- quarter_day_ct
    , NULL -- quarter_weekday_ct
    , YEAR(@current_dt)  -- year_key
    , YEAR(@current_dt)  -- year  
    , NULL -- year_start_dt
    , NULL -- year_end_dt
    , CAST(YEAR(@current_dt) as varchar(4)) -- year_desc_01
    , 12 -- year_month_ct
    , 4 -- year_quarter_ct
    , NULL -- year_day_ct
    , NULL -- year_weekday_ct        
    );
        
    SET @current_dt = DATEADD(d,1,@current_dt)
    
  END
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update standard calendar counts and positions

  update cal set
    month_day_ct = x.month_day_ct
  , month_weekday_ct = x.month_weekday_ct
  , month_start_dt = x.month_start_dt
  , month_end_dt = x.month_end_dt
  , day_of_quarter = x.day_of_quarter
  , quarter_day_ct = x.quarter_day_ct
  , quarter_weekday_ct = x.quarter_weekday_ct
  , quarter_start_dt = x.quarter_start_dt
  , quarter_end_dt = x.quarter_end_dt  
  , year_day_ct = x.year_day_ct
  , year_weekday_ct = x.year_weekday_ct
  , year_start_dt = x.year_start_dt
  , year_end_dt = x.year_end_dt
  FROM
  calendar cal
  inner join (
  
    select
      date_key

    , COUNT(date_key) OVER (partition by month_key) as month_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by month_key) as month_weekday_ct
    , MIN([date]) over (partition by month_key) as month_start_dt
    , MAX([date]) over (partition by month_key) as month_end_dt  
    
    , ROW_NUMBER() over (partition by quarter_key order by date_key) as day_of_quarter
    , COUNT(date_key) OVER (partition by quarter_key) as quarter_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by quarter_key) as quarter_weekday_ct  
    , MIN([date]) over (partition by quarter_key) as quarter_start_dt
    , MAX([date]) over (partition by quarter_key) as quarter_end_dt
      
    , COUNT(date_key) OVER (partition by year_key) as year_day_ct
    , COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (partition by year_key) as year_weekday_ct
    , MIN([date]) over (partition by year_key) as year_start_dt
    , MAX([date]) over (partition by year_key) as year_end_dt
    
    from
    calendar
    
  ) x on x.date_key = cal.date_key
  WHERE
  cal.date_key != 0;
  

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- delete extra calendar years expanded earlier
  
  delete from calendar where
  (year = @start_year - 1 or year = @end_year + 1 )
  and date_key != 0
       
END
go


exec calendar_rebuild
GO

select * from calendar

select @@VErSION

Microsoft SQL Server 2014 - 12.0.2000.8 (X64) 
	Feb 20 2014 20:04:26 
	Copyright (c) Microsoft Corporation
	Business Intelligence Edition (64-bit) on Windows NT 6.3 <X64> (Build 9600: ) (Hypervisor)

