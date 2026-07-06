-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73904

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Papadakis Key Levels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("Start", "Session Start", "", 2, 0, 23);
	
 	indicator.parameters:addGroup("Papadakis Key Lines");	
	
 	 indicator.parameters:addDouble("Level1", "1. Line Level", "", 0.618); 
	 indicator.parameters:addDouble("Level2", "2. Line Level", "", 1); 
	 indicator.parameters:addDouble("Level3", "3. Line Level", "", 1.618);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color5", "5. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color6", "6. Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Line={};	
local Level={};
local Start;
-- Routine
 function Prepare(nameOnly)   
 
    Start=instance.parameters.Start;
	Level[1]=instance.parameters.Level1;
	Level[2]=instance.parameters.Level2;
	Level[3]=instance.parameters.Level3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first() ; 
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset"); 
	
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("H1", 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");	

	Source = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 0, 100, 101);
	loading=true;
	 
	
	for i=1, 6, 1 do
    Line[i] = instance:addStream("Line"..i , core.Line, name, i .. ". Line", instance.parameters:getColor("color" .. i), first );
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[i]:setWidth(instance.parameters.width);
    Line[i]:setStyle(instance.parameters.style);
   	end
 
end


function Update(period, mode)

 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    local date = source:date(period);
    local date_as_table = core.dateToTable(date);
	
	local current_data_and_time= core.datetime (date_as_table.year, date_as_table.month, date_as_table.day, date_as_table.hour, 0, 0)	
 	local sesion_data_and_time= core.datetime (date_as_table.year, date_as_table.month, date_as_table.day, Start, 0, 0)	
	
	if sesion_data_and_time  > current_data_and_time then
	data_and_time= sesion_data_and_time-1	
	else
	data_and_time= sesion_data_and_time;	
	end
	
 	local p=Initialization(data_and_time);
	if not p then
	return;
	end	
	
	local High=Source.high[p];
	local Low=Source.low[p];  
	local Range=High-Low;
	

	
	Line[1][period]= High+Level[1]*Range; 
	Line[2][period]= High+Level[2]*Range; 
	Line[3][period]= High+Level[3]*Range; 

	Line[4][period]= Low-Level[1]*Range; 
	Line[5][period]= Low-Level[2]*Range; 
	Line[6][period]= Low-Level[3]*Range;

    if Line[1][period]~= Line[1][period-1] then 
    Line[1]:setBreak (period, true)	
    Line[2]:setBreak (period, true)
    Line[3]:setBreak (period, true)
    Line[4]:setBreak (period, true)
    Line[5]:setBreak (period, true)
    Line[6]:setBreak (period, true)	
	else
    Line[1]:setBreak (period, false)	
    Line[2]:setBreak (period, false)
    Line[3]:setBreak (period, false)
    Line[4]:setBreak (period, false)
    Line[5]:setBreak (period, false)
    Line[6]:setBreak (period, false)	
	end
	
	
	
end

function   Initialization(data_and_time)

    local Candle;
    Candle = core.getcandle("H1", data_and_time, dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end 

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+