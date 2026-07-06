-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3479

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Biger Time Frame LRMA indicator");
    indicator:description("Biger Time Frame LRMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period", "Period", "", 34);
    indicator.parameters:addInteger("Signal", "Signal", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LRMAclr", "Color of LRMA", "Color of LRMA", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SIGNALclr", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Signal;
local LRMA=nil;
local SigBuff=nil;

local TF; 
local SourceData;
local loading = false;  

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Signal=instance.parameters.Signal;
    TF = instance.parameters.TF;
	
	assert(core.indicators:findIndicator("LRMA") ~= nil, "Please, download and install LRMA.LUA indicator");    
	
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
 
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Signal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,Period) , 100, 101);
	loading=true;
  
    Indicator = core.indicators:create("LRMA", SourceData.close, Period, Signal);
    
    LRMA = instance:addStream("LRMA", core.Line, name .. ".LRMA", "LRMA", instance.parameters.LRMAclr, source:first());
    SigBuff = instance:addStream("SigBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.SIGNALclr, source:first());
    
    LRMA:setWidth(instance.parameters.widthLinReg);
    LRMA:setStyle(instance.parameters.styleLinReg);
    SigBuff:setWidth(instance.parameters.widthLinReg);
    SigBuff:setStyle(instance.parameters.styleLinReg);
end



function Update(period, mode)

       
		  
       local p =  core.findDate(SourceData, source:date(period), false);
     
	    if  p < 0 then
		return;
		end
		
		
		
   
    Indicator:update(mode);
     
 
	if Indicator.DATA:hasData(p) then
	
			LRMA[period]=Indicator.LRMA[p];
			 	
			 
			
			if   Indicator.SigBuff:hasData(p)   then			
			SigBuff[period]=Indicator.SigBuff[p];
	        end
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

