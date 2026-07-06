-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71956

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name(" Waddah Attar Buy Sell Vol Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "M1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS); 
	
	 indicator.parameters:addGroup("Line Style");	 
	
	indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Volume Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local TF;
local SourceData, loading;	
-- Routine
 function Prepare(nameOnly)   
 
    
	TF=instance.parameters.TF;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  TF  .. ")";
    instance:name(name); 




    if   (nameOnly) then
        return;
    end



    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset"); 
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

	
	first=source:first() ; 
	
 
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(),300, 100, 101);
	loading=true;	
	
    Line1 = instance:addStream("Line1", core.Bar, name, "Up", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Bar, name, "Down", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line2:addLevel(0);	

    Line3 = instance:addStream("Line3", core.Bar, name, "Volume", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line3:addLevel(0);		
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

local Last;
function Update(period, mode)

	 

	 if period < first then
	 return;
	 end
 
    Line1[period]=Line1[period-1];
    Line2[period]=Line2[period-1];
 
	
    local p1 =  Initialization(period-1) 
    local p2 =  Initialization(period)     
	    if not p1 or not p2 then
		return;
		end
		
	if p1~=p2 then
			if source.close[period]> source.close[period-1] then
			Line1[period]= source.volume[period];
			elseif source.close[period]< source.close[period-1] then
			Line2[period]= -source.volume[period];
			else
			Line1[period]= source.volume[period]/2;
			Line2[period]= -source.volume[period]/2;
			end
			

    else
        	if source.close[period]> source.close[period-1] then
			Line1[period]=Line1[period-1]+ source.volume[period];
			elseif source.close[period]< source.close[period-1] then
			Line2[period]=Line2	[period-1]- source.volume[period];	
			else
			Line1[period]=Line1[period-1]+ source.volume[period]/2;	
			Line2[period]=Line2[period-1]-  source.volume[period]/2;		
			end
			
 
	end
	
 
				Line3[period]= Line1[period]+Line2[period]    
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

 