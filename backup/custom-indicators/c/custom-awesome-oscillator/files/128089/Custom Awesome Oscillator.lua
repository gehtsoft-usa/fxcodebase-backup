-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68824
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
    indicator:name("Custom Awesome Oscillator");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", "Fast Period","", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow Period","", 35, 2, 10000);
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UU","Color of Up in Up Trend","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UD", "Color of Down in Up Trend","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DU","Color of Up in Down Trend","", core.rgb(  255,0, 0));
    indicator.parameters:addColor("DD", "Color of Down in DownTrend","", core.rgb(  200,0, 0));
end

local FM;
local SM;
 
local first;
local source = nil;

-- Streams block
local CL = nil;

local AO;
local UU,UD,DD,DU;


function Prepare(nameOnly)

 
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;  

    assert(FM < SM, "Number of periods for the fast MA must be less than for the slow MA.");

    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	
	UU=instance.parameters.UU;
	UD=instance.parameters.UD;
	DD=instance.parameters.DD;
	DU=instance.parameters.DU;
    -- Create the median stream
    AO = core.indicators:create("AO", source, FM,SM); 
	
	first = AO.DATA:first() ;

    CL = instance:addStream("AO", core.Bar, name .. ".AO", "AO",UU, first);
    CL:addLevel(0);
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
	
	CL:setPrecision(math.max(2, instance.source:getPrecision())); 
end

function Update(period, mode)
    AO:update(mode);

    if (period  <first) then
	return;
	end
        CL[period] = AO.DATA[period];
    
    
    if CL[period]> 0 then
	
	  if CL[period]> CL[period-1] then
	   CL:setColor(period, UU);
	  elseif CL[period]< CL[period-1] then
	   CL:setColor(period, UD);
	  end

    elseif CL[period]< 0 then
	
	   if CL[period]> CL[period-1] then
	   CL:setColor(period, DU);
	  elseif CL[period]< CL[period-1] then
	  CL:setColor(period, DD);
	  end
	
	end
    
    
     
end

