-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72759

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Who's Leading");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
	

	indicator.parameters:addGroup("Selector");
	
    indicator.parameters:addString("Instrument" , "Instrument", "", "EUR/JPY")
    indicator.parameters:setFlag("Instrument" , core.FLAG_INSTRUMENTS)	
	indicator.parameters:addBoolean("Reverse1", "1. Line Reverse", "Use Moving Average", false);
	indicator.parameters:addBoolean("Reverse2", "2. Line Reverse", "Use Moving Average", false);	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("MVA", "MVA", "Use Moving Average", true);
	indicator.parameters:addInteger("Period", "MA Period", "", 3, 1, 2000); 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period,Reverse1, Reverse2,Instrument ; 
local MVA;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	MVA=instance.parameters.MVA;
    Reverse1=instance.parameters.Reverse1;
    Reverse2=instance.parameters.Reverse2;
	Instrument=instance.parameters.Instrument;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period .. "," ..  Instrument .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset"); 
	
 
	
	SourceData = core.host:execute("getSyncHistory", Instrument, source:barSize(), source:isBid(), 300, 100, 101);
	loading=true;
	
 
	
	changeinPrice = instance:addInternalStream(0, 0);
	changeInComparitiveSymbol = instance:addInternalStream(0, 0); 
	
	Indicator1= core.indicators:create("MVA", changeinPrice, Period );
	Indicator2= core.indicators:create("MVA", changeInComparitiveSymbol, Period );	
	
	if MVA then
	FIRST= source:first()+1 +Period;
	else
	FIRST= source:first()+1;
	end
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1,  FIRST );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
 
	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2,  FIRST );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
   
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
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


function Update(period, mode)


	  
        local p =  Initialization(period) 
     
	    if not p  or p <= 1 then
		return;
		end	  

	 if period <= source:first()+1 then
	 return;
	 end
	 
	 
	changeinPrice[period]=((source[period]-source[period-1])/source[period-1])*100;
	changeInComparitiveSymbol[period]=((SourceData.close[p]-SourceData.close[p-1])/SourceData.close[p-1])*100;  
	
	if Reverse1 then
	changeinPrice[period]=-1*changeinPrice[period];
	end
	
	if Reverse2 then
	changeInComparitiveSymbol[period]=-1*changeInComparitiveSymbol[period];	
	end
	
	
 
	
	
	if MVA then 
	
	Indicator1:update(mode); 
 	Indicator2:update(mode);
 
		
		if period <= FIRST then
		return;
		end	
		

	Line1[period]= Indicator1.DATA[period];
	Line2[period]= Indicator2.DATA[period];
	
	
    else
	
		if period <= FIRST then
		return;
		end		
	 
	Line1[period]= changeinPrice[period];
	Line2[period]= changeInComparitiveSymbol[period];	
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