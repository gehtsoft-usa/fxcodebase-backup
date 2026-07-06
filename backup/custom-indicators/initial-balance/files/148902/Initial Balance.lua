-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Initial Balance");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addDouble("SessionStart", "Session Start", "", 8, 0, 24);
    indicator.parameters:addDouble("NumberOfPeriods", "Session Length (as half hour increments)", "", 2, 1, 48);	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local SessionStart,Hour,NumberOfPeriods; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	SessionStart=instance.parameters.SessionStart ;
	Session=instance.parameters.NumberOfPeriods/2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  SessionStart.. "," ..  Session  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	


    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	first=source:first() ; 
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("m30", 0, 0, 0);
    assert ((e1 - s1) >= (e2 - s2), "Intraday time frame only");
	
  
	SourceData = core.host:execute("getSyncHistory", source:instrument(), "m30", source:isBid(), 0, 100, 101);
	loading=true;
 
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	


    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);	 
end


function Update(period, mode)

	

	 if period <= first then
	 return;
	 end
	 
    --local Table=core.dateToTable (source:date(period));
    --local First=core.datetime (Table.year, Table.month, Table.day, 0, 0, 0)+ ((1/24)*(SessionStart));
    --local Last=core.datetime (Table.year, Table.month, Table.day, 0, 0, 0)+((1/24)*(SessionStart+Session));	
	
	
	
    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(source:date(period) * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t - SessionStart * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t + SessionStart * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom + Session * 3600;   -- end of the session

    First = sfrom / 86400;
    Last = sto / 86400;

	
	
	local p1=Initialization1(First);
	local p2=Initialization1(Last);	
  	
	
	if p1== false or p2 == false then
	return;
	end
	
	local min,max=mathex.minmax(SourceData, p1, p2);
	

   if source:date(period) >=First and source:date(period) <= Last then 	
   
   
   	local p=Initialization2(First);
 
	        if p~= false then
				for i= p, period, 1 do
				   Top[i]= max;
				   Bottom[i]=min;
				end
			end
   else
   Top[period]=Top[period-1];
   Bottom[period]=Bottom[period-1];
   end
  
	
end



function   Initialization1(Date)

    local Candle;
    Candle = core.getcandle("m30", Date, dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if Date < source:date(source:first()) then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function   Initialization2(Date)

    local Candle;
    Candle = core.getcandle(source:barSize(), Date, dayoffset, weekoffset);

  
    if  source:size() == 0 then
        return false ;
    end

    
    if Date < source:date(source:first()) then
        return false;
    end

    local p = core.findDate(source, Candle, false);

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