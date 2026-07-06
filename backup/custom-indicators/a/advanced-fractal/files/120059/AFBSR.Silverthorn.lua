-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=724
-- Id: 

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

function Init()
    indicator:name("Advanced Fractal Based Support/Resistance lines")
    indicator:description("Predicts a reversal in the current trend.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("Fractals", "Number of fractals", "", 2, 1,99);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5)
end

local source
local S, R
local Fractals = 0
local Rez = 0
local Size
local bid;
local ask;

function Prepare(nameOnly)
    source = instance.source
    Size = instance.parameters.Size
    Fractals = instance.parameters.Fractals

 

    first = source:first() +Fractals

    local name = profile:id() .. " ( " .. Fractals .. " )"
    instance:name(name)
    if nameOnly then
        return;
    end

    bid = core.host:execute("getSyncHistory", source:instrument(), source:barSize(), true, 0, 201, 101);
    ask = core.host:execute("getSyncHistory", source:instrument(), source:barSize(), false, 0, 200, 100);

    R = instance:addStream("R", core.Dot, name .. ".R", "R", instance.parameters.R_color, first)
    S = instance:addStream("S", core.Dot, name .. ".S", "S", instance.parameters.S_color, first)

    R:setWidth(instance.parameters.widthLinReg)
    S:setWidth(instance.parameters.widthLinReg)
end

local source_1_loaded = false;
local source_2_loaded = false;

function Update(period, mode)

    if period <= first 
	or not source_1_loaded
	or not source_2_loaded
	then
        return
    end
 
 


	local x = period - Fractals;
	
	if  not ask.high:hasData(x)
	or not bid.high:hasData(x)
	then
	return;
	end
       
       local test=true;		
         for i= 1, Fractals, 1 do
		
		     if  ask.high[x]  < ask.high[x+i]
			 or  ask.high[x] < ask.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
 
    

        if test then 
            R[period] = ask.high[x]
        else
            R[period] = R[period - 1] 
        end

        test = true
        for i= 1, Fractals, 1 do
		
		     if  bid.low[x] > bid.low[x+i]
			 or  bid.low[x] > bid.low[x-i]
			 then
			 test=false;
			 end
			
		 end	

        if test then 
        S[period] = bid.low[x]
        else
        S[period] = S[period - 1]
        end
   
end

function UpdateIfNeeded()
    if source_1_loaded and source_2_loaded then
        instance:updateFrom(0);
    end
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        source_1_loaded = false;
    elseif cookie == 101 then
        source_2_loaded = false;
    elseif cookie == 200 then
        source_1_loaded = true;
        UpdateIfNeeded();
    elseif cookie == 201 then
        source_2_loaded = true;
        UpdateIfNeeded();
    end
end