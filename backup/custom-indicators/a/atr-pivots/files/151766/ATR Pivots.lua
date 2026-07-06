-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73966

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
    indicator:name("ATR Pivots");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
 	indicator.parameters:addGroup("ATR");		
 	 indicator.parameters:addInteger("Period", "Period", "", 14); 
	 
    indicator.parameters:addGroup("Parameters");
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
 	indicator.parameters:addGroup("Papadakis Key Lines");	
	
 	 indicator.parameters:addDouble("Level1", "1. Line Level", "", 0.236); 
	 indicator.parameters:addDouble("Level2", "2. Line Level", "", 0.382); 
	 indicator.parameters:addDouble("Level3", "3. Line Level", "",  0.5);
	 indicator.parameters:addDouble("Level4", "4. Line Level", "", 0.618); 
	 indicator.parameters:addDouble("Level5", "5. Line Level", "",  0.786);
	 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(255, 0, 0));   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Top={};	
local Bottom={};	
local Level={};
local Period; 
-- Routine
 function Prepare(nameOnly)   
 
 
	Level[1]=instance.parameters.Level1;
	Level[2]=instance.parameters.Level2;
	Level[3]=instance.parameters.Level3;
	Level[4]=instance.parameters.Level4;
	Level[5]=instance.parameters.Level5;
	
	Period=instance.parameters.Period;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	first=source:first(); 
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
	L1=e1 - s1;
	L2=e2 - s2;
    assert ((L1) <= (L2), "The chosen time frame must be equal to or bigger than the chart time frame!");

	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	 
	ATR = core.indicators:create("ATR", SourceData, Period);
	
	for i=1, 5, 1 do
    Top[i] = instance:addStream("Top"..i , core.Line, name, i .. ". Top", instance.parameters.Top, first );
    Top[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Top[i]:setWidth(instance.parameters.width);
    Top[i]:setStyle(instance.parameters.style);
	
    Bottom[i] = instance:addStream("Bottom"..i , core.Line, name, i .. ". Bottom", instance.parameters.Bottom, first );
    Bottom[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom[i]:setWidth(instance.parameters.width);
    Bottom[i]:setStyle(instance.parameters.style);	
   	end
 
end


function Update(period, mode)




	
	if period < first  
	then
	return;
	end	 
	
	for i=1, 5, 1 do	
	Top[i][period]= 0
	Bottom[i][period]= 1 
    end		

 
    local p =  Initialization(period) 
     
	if not p 
	then
	return;
	end	
	
	if p < 2
	then
	return;
	end	
	
	
	ATR:update(mode);  	
	

	for i=1, 5, 1 do	
	Top[i][period]=  SourceData.close[p-1]+ATR.DATA[p-1]*Level[i]; 
	Bottom[i][period]= SourceData.close[p-1]-ATR.DATA[p-1]*Level[i]; 
    end	
 

    if Top[1][period]~= Top[1][period-1]  and L1 < L2  then 
    Top[1]:setBreak (period, true)	
    Top[2]:setBreak (period, true)
    Top[3]:setBreak (period, true)
    Top[4]:setBreak (period, true)
    Top[5]:setBreak (period, true)
    Bottom[1]:setBreak (period, true)	
    Bottom[2]:setBreak (period, true)
    Bottom[3]:setBreak (period, true)
    Bottom[4]:setBreak (period, true)
    Bottom[5]:setBreak (period, true)		
	else
    Top[1]:setBreak (period, false)	
    Top[2]:setBreak (period, false)
    Top[3]:setBreak (period, false)
    Top[4]:setBreak (period, false)
    Top[5]:setBreak (period, false)
    Bottom[1]:setBreak (period, false)	
    Bottom[2]:setBreak (period, false)
    Bottom[3]:setBreak (period, false)
    Bottom[4]:setBreak (period, false)
    Bottom[5]:setBreak (period, false)	
	end

end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

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
	
    return core.ASYNC_REDRAW ;	
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