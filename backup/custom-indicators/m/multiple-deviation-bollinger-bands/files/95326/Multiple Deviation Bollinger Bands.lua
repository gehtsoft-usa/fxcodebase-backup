-- Id: 12276
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61026

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
    indicator:name("Multiple Deviation Bollinger Bands");
    indicator:description("Provides a relative definition of high and low based on standard deviations and a simple moving average.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 20, 1, 10000);
	
	Add(1, 0.1);
	Add(2, 0.2);
	Add(3, 0.3);
	Add(4, 0.4);
	Add(5, 0.5);
	Add(6, 0.6);
	Add(7, 0.7);
	Add(8, 0.8);
	Add(9, 0.9)
	Add(10, 1)
	Add(11, 1.1)
	Add(12, 1.2)
	Add(13, 1.3)
	Add(14, 1.4)
	Add(15, 1.5)
	Add(16, 1.6)
	Add(17, 1.7)
	Add(18, 1.8)
	Add(19, 1.9)
	Add(20, 2)
 
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBBP", "Bands Line Color","", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("clrMarker", "Marker Bands Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthBBB", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);
     indicator.parameters:addBoolean("Show", "Show Labels","", false);
    indicator.parameters:addBoolean("HideAve", "Hide average line","", false);
    indicator.parameters:addColor("clrBBA", "Central Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);
end

function Add(id, Dev)

indicator.parameters:addDouble("Dev".. id, id ..  ". Standard deviation","Number of Standard deviations", Dev, 0.0001, 1000.0);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D={};

local firstPeriod;
local source = nil;
local Show;
-- Streams block
local TL = {};
local BL = {};
local AL = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
	Show = instance.parameters.Show;
    
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local Color;
	for i= 1 , 20, 1 do
	
	if i% 5 == 0 then 
	Color= instance.parameters.clrMarker;
	else
	Color= instance.parameters.clrBBP;
	end
	
	D[i] = instance.parameters:getDouble("Dev" .. i)
    TL[i] = instance:addStream("TL".. i, core.Line, name .. ".TL", "TL", Color, firstPeriod)
    TL[i]:setWidth(instance.parameters.widthBBB);
    TL[i]:setStyle(instance.parameters.styleBBB);
    BL[i] = instance:addStream("BL".. i, core.Line, name .. ".BL", "BL", Color, firstPeriod)
    BL[i]:setWidth(instance.parameters.widthBBB);
    BL[i]:setStyle(instance.parameters.styleBBB);
	end
	
	
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, firstPeriod)
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
    end
end

-- Indicator calculation routine
function Update(period)
    if period < firstPeriod then
	return;
	end
        local ml = mathex.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);
        local Db;
		
		local date=nil;
		local Text1="";
		local Text2="";
		local Text3="";
		if Show  and period== source:size()-1 then
		date= source:date(period)+ (source:date(period)-source:date(period-2)) ;
		end
		
		
		if Show and date~=nil then
		Text1= "Price : " .. string.format("%." .. source:getPrecision() .. "f", ml);
		 
		
		
		core.host:execute ("drawLabel", 1000, date, ml, Text1);
		end
        for i= 1, 20, 1 do     
			if D[i]~= 0 then		
			Dd = D[i] * d;
			TL[i][period] = ml + Dd;			
			BL[i][period] = ml - Dd;
			
			Text2=tostring(i) .. ".";
			Text2=Text2 .. "  Price : " .. string.format("%." .. source:getPrecision() .. "f", TL[i][period]);
		    Text2= Text2 ..   "   Deviation : " .. string.format("%." .. source:getPrecision() .. "f",Dd);
			
			Text3=tostring(i) ..".";
			Text3= Text3 .. "  Price : " .. string.format("%." .. source:getPrecision() .. "f", BL[i][period]);
		    Text3= Text3 ..   "   Deviation : " .. string.format("%." .. source:getPrecision() .. "f",Dd);
		
		
				if Show and  date~=nil   then 
				core.host:execute ("drawLabel", i, date,  TL[i][period], Text2)
				core.host:execute ("drawLabel", 2000+i, date, BL[i][period], Text3)
				end
			end
		end
		
		
        if AL ~= nil then
            AL[period] = ml;
        end
    
end





