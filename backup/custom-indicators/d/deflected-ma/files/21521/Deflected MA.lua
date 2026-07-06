-- Id: 5377
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10339

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Deflected MA");
    indicator:description("Deflected MA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

   
	indicator.parameters:addGroup("Top Line Calculation");
	indicator.parameters:addInteger("HShiftTop", "Horizontal Shift", "", 0);
	indicator.parameters:addDouble("VShiftTop", "Vertical Shift", "", 0);
	
	 indicator.parameters:addString("BaseTop", "Base of Calculation", "", "Central");
    indicator.parameters:addStringAlternative("BaseTop", "Cental", "", "Central");
    indicator.parameters:addStringAlternative("BaseTop", "Top", "", "Top");
	
	 indicator.parameters:addInteger("PeriodTop", "Periods for Moving Average", "", 14);
    indicator.parameters:addString("TypeTop", "Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("TypeTop", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("TypeTop", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TypeTop", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TypeTop", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TypeTop", "Vidya", "", "VIDYA");
    indicator.parameters:addStringAlternative("TypeTop", "Wilders", "", "WMA");
	indicator.parameters:addStringAlternative("TypeTop", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("TypeTop", "KAMA", "", "KAMA");
	
	indicator.parameters:addGroup("Cental Line Calculation");
	indicator.parameters:addInteger("HShiftCentral", "Horizontal Shift", "", 0);
	indicator.parameters:addDouble("VShiftCentral", "Vertical Shift", "", 0);
	
		 indicator.parameters:addInteger("PeriodCental", "Periods for Moving Average", "", 14);
    indicator.parameters:addString("TypeCental", "Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("TypeCental", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("TypeCental", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TypeCental", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TypeCental", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TypeCental", "Vidya", "", "VIDYA");
    indicator.parameters:addStringAlternative("TypeCental", "Wilders", "", "WMA");
	indicator.parameters:addStringAlternative("TypeCental", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("TypeCental", "KAMA", "", "KAMA");
	
	indicator.parameters:addGroup("Bottom Line Calculation");
	indicator.parameters:addInteger("HShiftBottom", "Horizontal Shift", "", 0);
	indicator.parameters:addDouble("VShiftBottom", "Vertical Shift", "", 0);
	
	 indicator.parameters:addString("BaseBottom", "Base of Calculation", "", "Central");
    indicator.parameters:addStringAlternative("BaseBottom", "Cental", "", "Central");
    indicator.parameters:addStringAlternative("BaseBottom", "Bottom", "", "Bottom");
	
	indicator.parameters:addInteger("PeriodBottom", "Periods for Moving Average", "", 14);
    indicator.parameters:addString("TypeBottom", "Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("TypeBottom", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("TypeBottom", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TypeBottom", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TypeBottom", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TypeBottom", "Vidya", "", "VIDYA");
    indicator.parameters:addStringAlternative("TypeBottom", "Wilders", "", "WMA");
	indicator.parameters:addStringAlternative("TypeBottom", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("TypeBottom", "KAMA", "", "KAMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BOTTOM_color", "Color of TOP", "Color of TOP", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("BOTTOM_style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("BOTTOM_style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("BOTTOM_width", "Line Width", "", 3, 1, 5);
    indicator.parameters:addColor("CENTRAL_color", "Color of CENTRAL", "Color of CENTRAL", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("CENTRAL_style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("CENTRAL_style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("CENTRAL_width", "Line Width", "", 3, 1, 5);
    indicator.parameters:addColor("TOP_color", "Color of BOTTOM", "Color of BOTTOM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("TOP_style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("TOP_style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("TOP_width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local TOP = nil;
local CENTRAL = nil;
local BOTTOM = nil;

local  HShift={};
local  VShift={};
local Type={};
local Period ={};
local Indicator={};
local Raw={};
local Base={};
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first();
	
	Base["Top"]= instance.parameters.BaseTop;
	Base["Bottom"]= instance.parameters.BaseBottom;
	
	HShift["Top"]= instance.parameters.HShiftTop;
	HShift["Central"]= instance.parameters.HShiftCentral;
	HShift["Bottom"]= instance.parameters.HShiftBottom;
	
	VShift["Top"]= instance.parameters.VShiftTop;
	VShift["Central"]= instance.parameters.VShiftCentral;
	VShift["Bottom"]= instance.parameters.VShiftBottom;
	
	Type["Top"]= instance.parameters.TypeTop;
	Type["Central"]= instance.parameters.TypeCental;
	Type["Bottom"]= instance.parameters.TypeBottom;
	
	Period["Top"]= instance.parameters.PeriodTop;
	Period["Central"]= instance.parameters.PeriodCental;
	Period["Bottom"]= instance.parameters.PeriodBottom;

    local name = profile:id() .. "(" .. source:name() 
	                                                  .. ",( "  .. tostring(Period["Top"]).. ", " .. tostring(Type["Top"]).. ", " .. tostring(HShift["Top"]) .. ", " .. tostring(VShift["Top"])
	                                                  .. "),( "  .. tostring(Period["Central"]).. ", " .. tostring(Type["Central"]).. ", " .. tostring(HShift["Central"]).. ", " .. tostring(VShift["Central"])
													  .. "),( " .. tostring(Period["Bottom"]) .. ", " .. tostring(Type["Bottom"]).. ", " .. tostring(HShift["Bottom"]) .. ", " .. tostring(VShift["Bottom"]) 
													  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Raw["Top"] = instance:addInternalStream(0, 0);
	Raw["Central"] = instance:addInternalStream(0, 0);
	Raw["Bottom"] = instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Type["Top"]) ~= nil, Type["Top"] .. " indicator must be installed");
	  Indicator["Top"] = core.indicators:create(Type["Top"], source, Period["Top"]);
    assert(core.indicators:findIndicator(Type["Central"]) ~= nil, Type["Central"] .. " indicator must be installed");
	   Indicator["Central"] = core.indicators:create(Type["Central"], source, Period["Central"]);
    assert(core.indicators:findIndicator(Type["Bottom"]) ~= nil, Type["Bottom"] .. " indicator must be installed");
	    Indicator["Bottom"] = core.indicators:create(Type["Bottom"], source, Period["Bottom"]);
		
		
		first = math.max(  Indicator["Top"].DATA:first(), Indicator["Central"].DATA:first(), Indicator["Bottom"].DATA:first());

 
        TOP = instance:addStream("TOP", core.Line, name .. ".TOP", "TOP", instance.parameters.TOP_color, first);
		TOP:setWidth(instance.parameters.TOP_width);
        TOP:setStyle(instance.parameters.TOP_style);
        CENTRAL = instance:addStream("CENTRAL", core.Line, name .. ".CENTRAL", "CENTRAL", instance.parameters.CENTRAL_color, first);
		CENTRAL:setWidth(instance.parameters.CENTRAL_width);
        CENTRAL:setStyle(instance.parameters.CENTRAL_style);
        BOTTOM = instance:addStream("BOTTOM", core.Line, name .. ".BOTTOM", "BOTTOM", instance.parameters.BOTTOM_color, first);
		BOTTOM:setWidth(instance.parameters.BOTTOM_width);
        BOTTOM:setStyle(instance.parameters.BOTTOM_style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period  <  first or not  source:hasData(period) then 
	return;
	end
	
	Indicator["Top"]:update(mode);
	Indicator["Central"]:update(mode);
	Indicator["Bottom"]:update(mode);
	
	
	
		if HShift["Central"] >= 0  then
	Raw["Central"][period]= Indicator["Central"].DATA[period - HShift["Central"]];
	elseif  HShift["Central"] < 0 and  (period- HShift["Central"] <=  source:size() -1 ) then	   
	Raw["Central"][period]= Indicator["Central"].DATA[period - HShift["Central"]];
	else
	Raw["Central"][period] =0;
	end
	
		
	if Base["Top"] == "Central" then	
			if HShift["Top"] >= 0  and   Indicator["Central"].DATA:hasData(period-HShift["Top"]- HShift["Central"])  then
			Raw["Top"][period] = Indicator["Central"].DATA[period - HShift["Top"]] ;	
			elseif  HShift["Top"] < 0 and (period- HShift["Top"] <=  source:size() -1 )   and   Indicator["Central"].DATA:hasData(period-HShift["Top"]- HShift["Central"])  then		
			Raw["Top"][period] =Indicator["Central"].DATA[period - HShift["Top"]] ;	
			else
			Raw["Top"][period] =0;
			end
	else   
	       if HShift["Top"] >= 0 and Indicator["Top"].DATA:hasData(period-HShift["Top"]) then
			Raw["Top"][period] = Indicator["Top"].DATA[period - HShift["Top"]] ;	
			elseif  HShift["Top"] < 0 and (period- HShift["Top"] <=  source:size() -1 ) and Indicator["Top"].DATA:hasData(period-HShift["Top"])then		
			Raw["Top"][period] = Indicator["Top"].DATA[period - HShift["Top"]] ;	
			else
			Raw["Top"][period] =0;
			end
	end
	
	
	
	
	

	
   if Base["Bottom"] == "Central" then	
				if HShift["Bottom"] >= 0  and  Indicator["Central"].DATA:hasData(period-HShift["Bottom"]- HShift["Central"]) then
				Raw["Bottom"][period ]=Indicator["Central"].DATA[period-HShift["Bottom"]-HShift["Central"]];  
				elseif HShift["Bottom"] < 0  and (period- HShift["Bottom"] <=  source:size() -1) and  Indicator["Central"].DATA:hasData(period-HShift["Bottom"]- HShift["Central"]) then	
				Raw["Bottom"][period ]= Indicator["Central"].DATA[period-HShift["Bottom"]-HShift["Central"]];  
				else
				Raw["Bottom"][period] =0;
				end
	else     
	          if HShift["Bottom"] >= 0  and Indicator["Bottom"].DATA:hasData(period-HShift["Bottom"])   then
				Raw["Bottom"][period ]= Indicator["Bottom"].DATA[period-HShift["Bottom"]];  
				elseif HShift["Bottom"] < 0  and (period- HShift["Bottom"] <=  source:size() -1) and Indicator["Bottom"].DATA:hasData(period-HShift["Bottom"]) then	
				Raw["Bottom"][period ]= Indicator["Bottom"].DATA[period-HShift["Bottom"]];  
				else
				Raw["Bottom"][period] =0;
				end
	end
		
		
 
	
        if  Raw["Central"][period] ~=0 then
        CENTRAL[period]= Raw["Central"][period] +VShift["Central"]*source:pipSize();
		else
		CENTRAL[period]=nil;
		end
		

		
		if Raw["Top"][period] ~=0 		
		then		  
			 TOP[period] = Raw["Top"][period] + VShift["Top"]*source:pipSize();		
		else
		TOP[period]=nil;
		end
		
	
	
			if Raw["Bottom"][period] ~=0			
			then
		
			BOTTOM[period]= Raw["Bottom"][period] +VShift["Bottom"]*source:pipSize();		
			else
			BOTTOM[period]=nil;
			end
 
  end

