-- Id: 12894
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61405

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Investor Preference Index");
    indicator:description("Investor Preference Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Instrument", "Instrument", "", "USD/JPY");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS );
    indicator.parameters:addInteger("ROCPeriod", "ROC Period", "ROC Period", 24);
    indicator.parameters:addInteger("MA1", "1. MA Period", "1. MA Period", 15);
    indicator.parameters:addInteger("MA2", "2. MA Period", "2. MA Period", 38);
    indicator.parameters:addInteger("MA3", "3. MA Period", "3. MA Period", 54);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("IPI_color", "Color of IPI", "Color of IPI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ROCPeriod;
local MA1;
local MA2;
local MA3;
local Instrument;
local source = nil;

-- Streams block
local IPI = nil;
local Raw1, Raw2, Raw3;
local loading;
local dayoffset, weekoffset;
local Source;

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	
-- Routine
function Prepare(nameOnly)
    ROCPeriod = instance.parameters.ROCPeriod;
	Instrument= instance.parameters.Instrument;
    MA1 = instance.parameters.MA1;
    MA2 = instance.parameters.MA2;
    MA3 = instance.parameters.MA3;
    source = instance.source;
	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ROCPeriod) .. ", " .. tostring(MA1) .. ", " .. tostring(MA2) .. ", " .. tostring(MA3) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Source = core.host:execute("getSyncHistory", Instrument, source:barSize(), source:isBid(), 0 , 100, 101);
        loading=true;
        
        Raw1 = instance:addInternalStream(ROCPeriod, 0);
        Raw2 = instance:addInternalStream(ROCPeriod +math.max(MA2, MA1), 0);
        IPI = instance:addStream("IPI", core.Line, name, "IPI", instance.parameters.IPI_color, math.max(Raw1:first(), Raw2:first()));
    IPI:setPrecision(math.max(2, instance.source:getPrecision()));
		IPI:setWidth(instance.parameters.width);
        IPI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if not  source:hasData(period) then
	return;
	end
	
	if period < Raw1:first() then
	return;
	end
	
	local p1 =  Initialization(period) 
    local p2 =  Initialization(period-ROCPeriod+1)  
	
	if not p1 or not p2 then
	return;
	end
	
	Raw1[period]=ROC(source.close,period, period-ROCPeriod+1)-ROC(Source.close,p1, p2);
	
	if period < Raw2:first() then
	return;
	end
	
	Raw2[period]=mathex.avg(Raw1, period-MA1+1, period)-mathex.avg(Raw1, period-MA2+1, period);
	
	if period < Raw2:first()+ MA3 then
	return;
	end
        IPI[period] = ( mathex.sum(Raw2,period-MA3+1, period)+1)*100;
    
end

function ROC(Data, Index1, Index2)
 if    math.log(Data[Index2]) ~= 0 then
 return  math.log(Data[Index1] -math.log(Data[Index2])) /(math.log(Data[Index2]) /100)
 else
 return 0 ;
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

