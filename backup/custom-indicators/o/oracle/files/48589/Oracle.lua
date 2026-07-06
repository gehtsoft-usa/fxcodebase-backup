-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27743
-- Id: 8119

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Oracle");
    indicator:description("Oracle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("CP", "Calculation Period", "Calculation Period", 55);
    indicator.parameters:addInteger("SP", "Signal Period", "Signal Period", 8);
	indicator.parameters:addString("Method", "Signal MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 3);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Oracle_color", "Color of Oracle", "Color of Oracle", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CP;
local SP;
local Shift;

local first;
local source = nil;
local Method;
-- Streams block
local Oracle = nil;
local Signal = nil;
local MA;
local RawOracle, RawSignal;
local FIRST;
local CCI,RSI;
local Period;
-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
	Period=CP;
    SP = instance.parameters.SP;
	Method = instance.parameters.Method;
    Shift = instance.parameters.Shift;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(SP).. ", " .. tostring(Method) .. ", " .. tostring(Shift) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		CCI  = core.indicators:create("CCI", source, CP);
		RSI  = core.indicators:create("RSI", source.close, CP);
		first = math.max(CCI.DATA:first(), RSI.DATA:first())+Period;
	
		if  Shift > 0 then
			FIRST= first + Shift*2;
			else
			FIRST= first;
			end
	    RawOracle= instance:addInternalStream(0, 0);
        Oracle = instance:addStream("Oracle", core.Line, name .. ".Oracle", "Oracle", instance.parameters.Oracle_color, FIRST, Shift);
    Oracle:setPrecision(math.max(2, instance.source:getPrecision()));
		Oracle:setWidth(instance.parameters.width1);
        Oracle:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, RawOracle, SP);
		
		RawSignal= instance:addInternalStream(0, 0);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, FIRST+MA.DATA:first(), Shift);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	RSI:update(mode);
	CCI:update(mode);
	
	if period < first   then
	return;	
	end
	
	local i;
	
	if period <= source:size() -1-Period then	
    Calculate (period, mode);
	else
	   for i = period - Period, period, 1 do
	   Calculate (period, mode);
	   end
	end
	
	
	 Shifted (period);
end

function Calculate (period, mode)

    local div1, div2, div3, div4;
	local X1, X2, X3, X4;
  
	--div1 = (iCCI(NULL,0,period,PRICE_CLOSE,i) - iRSI(NULL,0,period,PRICE_CLOSE,i));
      div1 = CCI.DATA[period]- RSI.DATA[period];	  
    --div2 = (iCCI(NULL,0,period,PRICE_CLOSE,i - 1) - iRSI(NULL,0,period,PRICE_CLOSE,i + 1)) - (iCCI(NULL,0,period,PRICE_CLOSE,i) - iRSI(NULL,0,period,PRICE_CLOSE, i));
	
	 if CCI.DATA:hasData(period+1)  then
	 X1= CCI.DATA[period+1];
	 else
   	 X1 =0;
	 end
	 
	 X2= RSI.DATA[period-1];	 
	 div2 = X1- X2 - div1;	  
	  
	 --  div3 = (iCCI(NULL,0,period,PRICE_CLOSE,i - 2) - iRSI(NULL,0,period,PRICE_CLOSE,i + 2)) - (iCCI(NULL,0,period,PRICE_CLOSE,i - 1) - iRSI(NULL,0,period,PRICE_CLOSE, i + 1));
	
	 if CCI.DATA:hasData(period+2)  then
     X1= CCI.DATA[period+2];
	 else
	 X1 =0;
	 end
	 
	 X2= RSI.DATA[period-2];
	 
	 if CCI.DATA:hasData(period+1)  then
	 X3=CCI.DATA[period+1];
	 else
	 X3=0;
	 end
	 
	 X4=RSI.DATA[period-1];
	 
	div3 = X1- X2- (X3- X4);	  
	  
	  
    --    div4 = (iCCI(NULL,0,period,PRICE_CLOSE,i - period) - iRSI(NULL,0,period,PRICE_CLOSE,i + period)) - (iCCI(NULL,0,period,PRICE_CLOSE,i - (period - 1)) - iRSI(NULL,0,period,PRICE_CLOSE, i+(period - 1)));
	
	 if CCI.DATA:hasData(period+Period)  then
	 X1= CCI.DATA[period+Period];
	 else
	 X1 =0;
	 end
	 
	 X2= RSI.DATA[period-Period];
	 
	if CCI.DATA:hasData(period+(Period-1))  then
	 X3=CCI.DATA[period+(Period-1)];
	 else
	 X3=0;
	 end
	 
	 X4=RSI.DATA[period-(Period-1)];
	div4 =  X1-X2 - ( X3- X4);
	local min, max;
	
	    if(div1 > div2 and div1 > div3 and div1 > div4) then
            max = div1;
		end	
        if(div2 > div1 and div2 > div3 and div2 > div4) then
            max = div2;
		end	
        if(div3 > div1 and div3 > div2 and div3 > div4) then
            max = div3;
		end	
        if(div4 > div1 and div4 > div2 and div4 > div3) then
            max = div4;
        end
        if(div1 < div2 and div1 < div3 and div1 < div4) then
            min = div1;
		end	
        if(div2 < div1 and div2 < div3 and div2 < div4) then
            min = div2;
		end	
        if(div3 < div1 and div3 < div2 and div3 < div4) then
            min = div3;
		end
        if(div4 < div1 and div4 < div3 and div4 < div3) then
            min = div4;
        end
    
	
	
        RawOracle[period]= max + min;
		
		MA:update(mode);
		
		if period < MA.DATA:first()   then
		return;
		end
        RawSignal[period] = MA.DATA[period];
		

end


function Shifted (period)

   local p= period+Shift;	
   
	if  Shift < 0 then	
	
	   if  period+Shift < FIRST then
	   return;
	   end
	
	end
	 
    Signal[p]= RawSignal[period];
    Oracle[p]= RawOracle[period];
end

