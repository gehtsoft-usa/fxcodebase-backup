-- Id: 446
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=710

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
    indicator:name("EMA Offset Bands");
    indicator:description("Around the central EMA, donates two EMA Offset line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");
   
	indicator.parameters:addString("P3", "Percentage or PIP", "Percentage or PIP", "PIP");
	indicator.parameters:addStringAlternative("P3", "PIP", "PIP", "PIP");
	indicator.parameters:addStringAlternative("P3", "Percentage", "Percentage", "Percentage");
	
	

    indicator.parameters:addInteger("P1", "Number of periods", "Number of periods", 20);
	
    indicator.parameters:addDouble("P2", "Pip Offset", "Pip Offset", 50);
	indicator.parameters:addDouble("P4", "Percentage", "Percentage", 1);
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("central", "Central Line", "Central Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("top", "Top Line", "Top Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("bottom", "Bottom Line", "Bottom Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

local N;
local D;

local first;
local source = nil;

local MA=nil;

--Bands
local TL = nil;
local BL = nil;
local CL=nil;



-- Routine
function Prepare(nameOnly)
    N = instance.parameters.P1;
    D = instance.parameters.P2;
	P3 = instance.parameters.P3;
    P4 = instance.parameters.P4;
	
	source = instance.source;
   
	local name=nil;
	
	
	name = profile:id() .. " ( " .. source:name() ..", ".. P3 .. ", " .. N.. ", " .. D.. ", " .. P4 .. ")" ;
    instance:name(name);
    if nameOnly then
        return;
    end
    
    MA = core.indicators:create("EMA", source, N);
	
	 first =  MA.DATA:first();
	    
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.top, first);
	TL:setWidth(instance.parameters.width1);
    TL:setStyle(instance.parameters.style1);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.bottom, first);
	BL:setWidth(instance.parameters.width2);
    BL:setStyle(instance.parameters.style2);
    CL = instance:addStream("CL", core.Line, name .. ".CL", "CL", instance.parameters.central, first);
	CL:setWidth(instance.parameters.width3);
    CL:setStyle(instance.parameters.style3);
	
end


-- Indicator calculation routine
function Update(period,mode)

	
    MA:update(mode);
  

	if(period<first) then
	return;
	end
				
				local ml=MA.DATA[period];
				CL[period] = ml;
				
				local Offset;
				local point = source:pipSize();
														
			
								
				if P3== "Percentage" then
				Offset=((CL[period])/100)*P4;
				else
				Offset=D*point;
				end
				
				TL[period] = ml + Offset;
				BL[period] = ml - Offset;
				
  
end
