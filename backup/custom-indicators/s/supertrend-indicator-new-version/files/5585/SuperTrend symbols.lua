
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2527

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



-- original version: Jason Robinson (jnrtrading)
-- http://codebase.mql4.com/4725

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("SuperTrend Indicator (dot version)");
    indicator:description("The indicator (dot version) displays the buying and selling with the colors. The indicator is initially developed by Jason Robinson for MT4");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("N", "Number of periods", "No description", 10);
    indicator.parameters:addDouble("M", "Multiplier", "No description", 1.5);
	
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Symbol Size", "Size", 10);
	
	 indicator.parameters:addString("UpS", "Up Symbol", "Symbol", "159");
	 indicator.parameters:addString("DownS", "Down Symbol", "Symbol", "159");
	 
	 	indicator.parameters:addGroup("Selector"); 
	
	indicator.parameters:addBoolean("Show", "Show Historical", "", true);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local M;
local Show;

local first;
local source = nil;
local ATR = nil;

-- Streams block
local TrUP = nil;
local TrDN = nil;
local UP = nil;
local DN = nil;
local TR = nil;
local up,down;
local Size, UpS,DownS;
-- Routine
function Prepare()
    N = instance.parameters.N;
    M = instance.parameters.M;
	Show= instance.parameters.Show;
	
	Size = instance.parameters.Size;
	UpS =  string.char (instance.parameters.UpS);
	DownS = string.char ( instance.parameters.DownS);
	
    source = instance.source;
    ATR = core.indicators:create("ATR", source, N);
    first = ATR.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. "," .. N .. "," .. M .. ")";
    instance:name(name);
    UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
    TR = instance:addInternalStream(first, 0);
     
    TrDN = instance:addStream("TrDN", core.Line, name .. ".TrDN", "TrDN", instance.parameters.DN_color, first);
	TrDN:setStyle(core.LINE_NONE);
    TrUP = instance:addStream("TrUP", core.Line, name .. ".TrUP", "TrUP", instance.parameters.UP_color, first );   
    TrUP:setStyle(core.LINE_NONE);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.UP_color, first);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.DN_color, first);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);
    TR[period] = 1;
    if period <= first then
	return;
	end
	
	
        local median, atr;
        atr = ATR.DATA[period];
        median = (source.high[period] + source.low[period]) / 2;
        UP[period] = median + atr * M;
        DN[period] = median - atr * M;

        if period >= first + 1 then
            if source.close[period] > UP[period - 1] then
                TR[period] = 1;
            elseif source.close[period] < DN[period - 1] then
                TR[period] = -1;
            else
                TR[period] = TR[period - 1];
            end

            local flag, flagh;

            if TR[period] < 0 and TR[period - 1] > 0 then
               flag = 1;
            else
               flag = 0;
            end

            if TR[period] > 0 and TR[period - 1] < 0 then
               flagh = 1;
            else
               flagh = 0;
            end

            if TR[period] > 0 and DN[period] < DN[period - 1] then
                DN[period] = DN[period - 1];
            end

            if TR[period] < 0 and UP[period] > UP[period - 1] then
                UP[period] = UP[period - 1];
            end

            if flag == 1 then
                UP[period] = median + atr * M;
            end

            if flagh == 1 then
                DN[period] = median - atr * M;
            end

            if TR[period] == 1 then
                TrUP[period] = DN[period];
                TrDN[period] = nil;
            end

            if TR[period] == -1 then
                TrDN[period] = UP[period];
                TrUP[period] = nil;
            end
        end
     
	 
	         up:setNoData(period);
			 down:setNoData(period);
			 if Show  then
				 if TrUP[period]~= nil then
				 up:set(period, TrUP[period], UpS ,TrUP[period]);
				 end
				 if TrDN[period]~= nil then
				 down:set(period, TrDN[period] , DownS ,  TrDN[period]);
				 end
				else
			  
			   if period < source:size()-1 then
			   return;
			   end
			   
			     up:setNoData(period);
			    down:setNoData(period);
			 
			   up:setNoData(period-1);
			   down:setNoData(period-1);
			   
			     if TrUP[period]~= nil then
				 up:set(period, TrUP[period], UpS ,TrUP[period]);
				 end
				 if TrDN[period]~= nil then
				 down:set(period, TrDN[period] , DownS ,  TrDN[period]);
				 end
			end	 
				 
end

