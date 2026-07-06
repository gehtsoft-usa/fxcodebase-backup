-- Id: 8506
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32052

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
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Buying/Selling Pressure");
    indicator:description("Buying/Selling Pressure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Period", "Smoothing Period", "", 4);
	 
	 indicator.parameters:addString("Type1", "Show", "", "Both");
    indicator.parameters:addStringAlternative("Type1", "Both", "", "Both");
    indicator.parameters:addStringAlternative("Type1", "Buying", "", "Buying");
	indicator.parameters:addStringAlternative("Type1", "Selling", "", "Selling");
	indicator.parameters:addStringAlternative("Type1", "Prevailing", "", "Prevailing");
	
	 indicator.parameters:addString("Type2", "Show", "", "Smoothed");
    indicator.parameters:addStringAlternative("Type2", "Both", "", "Both");
    indicator.parameters:addStringAlternative("Type2", "Unsmoothed", "", "Unsmoothed");
	indicator.parameters:addStringAlternative("Type2", "Smoothed", "", "Smoothed");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BP_color", "Color of Buying pressure", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("SP_color", "Color of Selling pressure", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
	
	indicator.parameters:addColor("SBP_color", "Color of smoothed Buying pressure", " ", core.rgb(0, 200, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("SSP_color", "Color of smoothed Selling pressure", "", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addBoolean("Use"  , "Use Buying/Selling Coloring for Prevailing pressure", "", true);	
	
    indicator.parameters:addColor("PT_color", "Color of Prevailing pressure", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("PS_color", "Color of smoothed Prevailing pressure", "", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local Use;
local first;
local source = nil;
local Type1, Type2;
-- Streams block
local BP = nil;
local SP = nil;
local MA1, MA2, MA3;
local Period;
local SBP, SSP;
local PT, PS;
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	Use = instance.parameters.Use;
	Type1 = instance.parameters.Type1;
	Type2 = instance.parameters.Type2;
    source = instance.source;  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ", " .. tostring(Period).. ", " .. tostring(Type1).. ", " .. tostring(Type2) .. ")";
    instance:name(name);	
	
    if   (nameOnly) then
        return;
    end
   
	
	    if Type1 == "Buying"  or Type1 == "Both" then
			if Type2 == "Unsmoothed" or Type2   == "Both" then
			BP = instance:addStream("BP", core.Line, name .. ".BP", "BP", instance.parameters.BP_color, source:first());
    BP:setPrecision(math.max(2, instance.source:getPrecision()));
			BP:setWidth(instance.parameters.width1);
			BP:setStyle(instance.parameters.style1);
			else			
			BP= instance:addInternalStream(0, 0);
			end
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA1 = core.indicators:create(Method, BP, Period);
		first = MA1.DATA:first();	
			if Type2 == "Smoothed" or Type2   == "Both" then
			SBP = instance:addStream("SBP", core.Line, name .. ".SBP", "SBP", instance.parameters.SBP_color, first);
    SBP:setPrecision(math.max(2, instance.source:getPrecision()));
			SBP:setWidth(instance.parameters.width3);
			SBP:setStyle(instance.parameters.style3); 
			else
			SBP= instance:addInternalStream(0, 0);
			end		
       		
		else
		BP= instance:addInternalStream(0, 0);
		SBP= instance:addInternalStream(0, 0);	
        MA1 = core.indicators:create(Method, BP, Period);
		first = MA1.DATA:first();		
	    end	
		
		
		if Type1 == "Selling"  or Type1 == "Both"  then
			if Type2   == "Unsmoothed" or Type2   == "Both" then				
			 SP = instance:addStream("SP", core.Line, name .. ".SP", "SP", instance.parameters.SP_color, source:first());
			SP:setWidth(instance.parameters.width2);
			SP:setStyle(instance.parameters.style2);	
			else
			SP= instance:addInternalStream(0, 0);
			end
		MA2 = core.indicators:create(Method, SP, Period);		
		first = MA2.DATA:first();	
			if Type2 == "Smoothed" or Type2   == "Both" then		
			SSP = instance:addStream("SSP", core.Line, name .. ".SSP", "SSP", instance.parameters.SSP_color, first);
			SSP:setWidth(instance.parameters.width4);
			SSP:setStyle(instance.parameters.style4);
			else
			SSP= instance:addInternalStream(0, 0);	
			end
		else
		
		SP= instance:addInternalStream(0, 0);
		SSP= instance:addInternalStream(0, 0);	
		
		MA2 = core.indicators:create(Method, SP, Period);		
		first = MA2.DATA:first();	
		end
		
		 
		
		if Type1 == "Prevailing" then
			if Type2  == "Unsmoothed" or Type2   == "Both" then				
			 PT = instance:addStream("PT", core.Line, name .. ".PT", "PT", instance.parameters.PT_color, source:first());
			PT:setWidth(instance.parameters.width5);
			PT:setStyle(instance.parameters.style5);	
			else
			PT= instance:addInternalStream(0, 0);
			end
			
	    	
		
		  
			
			   if Type2  == "Smoothed" or Type2   == "Both" then	
				PS = instance:addStream("PS", core.Line, name .. ".PS", "PS", instance.parameters.PS_color, first);
				PS:setWidth(instance.parameters.width6);
				PS:setStyle(instance.parameters.style6);
				else
				PS= instance:addInternalStream(0, 0);	
				end
		else
		
		PT= instance:addInternalStream(0, 0);
		PS= instance:addInternalStream(0, 0);	
		end
		
	SP:setPrecision(math.max(2, instance.source:getPrecision()));
	SSP:setPrecision(math.max(2, instance.source:getPrecision()));
	PT:setPrecision(math.max(2, instance.source:getPrecision()));
	PS:setPrecision(math.max(2, instance.source:getPrecision())); 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
        BP[period] = source.high[period]-source.open[period];		
        SP[period] = source.open[period]-source.low[period];	
		
		if  BP[period] >  SP[period] then
		PT[period]= BP[period];
		else
		PT[period]= SP[period];
		end
		 
		 
		if  Use then
			if  BP[period] >  SP[period] then
			PT:setColor(period, instance.parameters.BP_color);
			else
			PT:setColor(period, instance.parameters.SP_color);
			end
		end
 		 
		 
		MA1:update(mode);
			if period >  MA1.DATA:first() then
			SBP[period]= MA1.DATA[period];
			end
		 
		
		 
		MA2:update(mode);
			 if  period >  MA2.DATA:first() then
			SSP[period]= MA2.DATA[period];
			end
		 
		
		
				if Type1 == "Prevailing"  then
				
					if  SBP[period] >  SSP[period] then
					PS[period]= SBP[period];
					else
					PS[period]= SSP[period];
					end
					
				
				
					
					if  Use then
						if  SBP[period] >  SSP[period] then
						PS:setColor(period, instance.parameters.SBP_color);
						else
						PS:setColor(period, instance.parameters.SSP_color);
						end
						
					
			     	end
       end
end

