-- Id: 8769


-- Indicator-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33582


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
    indicator:name("cyclical indicator");
    indicator:description("cyclical indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "4");
    indicator.parameters:addStringAlternative("Method", "1", "1" , "1");
    indicator.parameters:addStringAlternative("Method", "2", "2" , "2");
	indicator.parameters:addStringAlternative("Method", "3", "3" , "3");
    indicator.parameters:addStringAlternative("Method", "4", "4" , "4");
    indicator.parameters:addStringAlternative("Method", "All", "All" , "All");
	indicator.parameters:addStringAlternative("Method", "Average", "Average" , "Average");
	
	
	indicator.parameters:addInteger("Period", "Period" , "", 12)

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("C1U", "1. Line Color Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("C1D", "1. Line Color Down Color", "", core.rgb(0, 255, 0));
	
    indicator.parameters:addColor("C2U", "2. Line Color Up Color", "", core.rgb(255,0 , 0));
	indicator.parameters:addColor("C2D", "2. Line Color Down Color", "", core.rgb(255,0 , 0));
	
	indicator.parameters:addColor("C3U", "3. Line Color Up Color", "", core.rgb(0,  0, 255));
	indicator.parameters:addColor("C3D", "3. Line Color Down Color", "", core.rgb(0,  0, 255));
	
	indicator.parameters:addColor("C4U", "4. Line Color Up Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("C4D", "4. Line Color Down Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;
local CI={};
-- Streams block
local A, B, C, D, E, F, G,H, I, J; 
local C1U, C2U, C3U, C4U;
local C1D, C2D, C3D, C4D;
local CMA1, CMA2, CMA3, CMA4, CMA5;
-- Routine
function Prepare(nameOnly)

     C1U = instance.parameters.C1U;
	 C2U = instance.parameters.C2U;
	 C3U = instance.parameters.C3U;
	 C4U = instance.parameters.C4U;
	 C1D = instance.parameters.C1D;
	 C2D = instance.parameters.C2D;
	 C3D = instance.parameters.C3D;
	 C4D = instance.parameters.C4D;
	 
	 
	 Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	Method = instance.parameters.Method;
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.BIN indicator");
	
	CMA1 = core.indicators:create("CMA", source, Period);
	CMA2 = core.indicators:create("CMA", source, Period*2);
	
	

   
		  A =instance:addInternalStream(0, 0);	  
		  B =instance:addInternalStream(CMA1.DATA:first(), 0);
		  C =instance:addInternalStream(CMA2.DATA:first(), 0);
		  D =instance:addInternalStream(CMA2.DATA:first(), 0);
		  CMA3 = core.indicators:create("CMA", D, Period);
		  
		  E =instance:addInternalStream(CMA3.DATA:first(), 0);
		  F =instance:addInternalStream(CMA3.DATA:first(), 0);
		  CMA4 = core.indicators:create("CMA", F, Period);
		  
		  G =instance:addInternalStream(CMA4.DATA:first(), 0);
		  H  =instance:addInternalStream(CMA4.DATA:first(), 0);
		  CMA5 = core.indicators:create("CMA", H, Period);
		  
		  I  =instance:addInternalStream(CMA5.DATA:first(), 0);
		  J =instance:addInternalStream(CMA5.DATA:first(), 0);
		 
		if Method == "All" then
		CI["1"] = instance:addStream("CI1", core.Line, name .. ".1", "1", C1U, first);
		CI["2"] = instance:addStream("CI2", core.Line, name .. ".2", "2", C2U, first);
		CI["3"] = instance:addStream("CI3", core.Line, name .. ".3", "3", C3U, first);
		CI["4"] = instance:addStream("CI4", core.Line, name .. ".4", "4", C4U, first);
		
		CI["1"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["2"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["3"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["4"]:setPrecision(math.max(2, instance.source:getPrecision()));
		else	
		CI["All"] = instance:addStream("CI", core.Line, name .. ".CI", "CI", C1U, first);		
		CI["All"]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values



function Update(period, mode)
    if period < source:first() + Period   then
	return;
	end
	
 local i;
 
 
    if period == source:size()-1  then
            for i= (source:size()-1 - Period) , source:size()-1, 1 do
			
		 
	
			CMA1:update(core.UpdateAll);	
			if i  < CMA1.DATA:first()  then
			return;
			end
			
			B[i] = CMA1.DATA[i]; 
			
			
			
			CMA2:update(core.UpdateAll);
			if i  < CMA2.DATA:first()  then
			return;
			end
			
			C[i] = CMA2.DATA[i] ;
			D[i] = B[i]-C[i];
			
			
			CMA3:update(core.UpdateAll);
			if i  <  CMA3.DATA:first()  then
			return;
			end
			
			
			E[i] = CMA3.DATA[i];--D
			F[i] = E[i]-E[i-1];
			
			
			CMA4:update(core.UpdateAll);
			if i  <  CMA4.DATA:first()  then
			return;
			end
			
			G[i] =CMA4.DATA[i]-- F);
			H[i] = (G[i]-G[i-1])*(-100);
			
			
			CMA5:update(core.UpdateAll);
			if i  <  CMA5.DATA:first()   then
			return;
			end
			
			   I[period] =  CMA5.DATA[period]-- H);
			   J[period] =  (I[period]-I[period-1])*(10);
				
		end	
		
		
			
	
	else
	
			
				
				CMA1:update(mode);	
				if period  < CMA1.DATA:first() then
				return;
				end
				
				B[period] = CMA1.DATA[period]; 
				
				
				
				CMA2:update(mode);
				if period  < CMA2.DATA:first() then
				return;
				end
				
				C[period] = CMA2.DATA[period] ;
				D[period] = B[period]-C[period];
				
				
				CMA3:update(mode);
				if period  <  CMA3.DATA:first() then
				return;
				end
				
				
				E[period] = CMA3.DATA[period];--D
				F[period] = E[period]-E[period-1];
				
				
				CMA4:update(mode);
				if period  <  CMA4.DATA:first() then
				return;
				end
				
				G[period] =CMA4.DATA[period]-- F);
				H[period] = (G[period]-G[period-1])*(-100);
				
				
				CMA5:update(mode);
				if period  <  CMA5.DATA:first()  then
				return;
				end
				
				I[period] =  CMA5.DATA[period]-- H);
				J[period] =  (I[period]-I[period-1])*(10);
				
			
	
	end

	 if period == source:size()-1  then
            for i= (source:size()-1 - Period) , source:size()-1, 1 do
			--************************
	            period=i;
	
			if  Method == "1" then 
			CI["All"][period] = E[period];		
                    if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
			elseif Method == "2" then
			CI["All"][period] = H[period];
			        if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
			elseif Method == "3" then
			CI["All"][period] = I[period]; 
			        if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
				   
			elseif Method == "4" then
			CI["All"][period] = J[period];
			         if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
				   
			elseif Method == "All" then
			CI["1"][period] = E[period];
			CI["2"][period] = H[period];
			CI["3"][period] = I[period];
			CI["4"][period] = J[period];
			
			
			        if CI["1"][period] > CI["1"][period-1] then 
				   CI["1"]:setColor(period, C1U);
				   else
					CI["1"]:setColor(period, C1D);
				   end
				   
				    if CI["2"][period]  >CI["2"][period-1] then 
				   CI["2"]:setColor(period, C2U);
				   else
					CI["2"]:setColor(period, C2D);
				   end
				   
				   
				    if CI["3"][period] > CI["3"][period-1] then 
				   CI["3"]:setColor(period, C3U);
				   else
					CI["3"]:setColor(period, C3D);
				   end
				   
				    if CI["4"][period]  >CI["4"][period-1] then 
				   CI["4"]:setColor(period, C4U);
				   else
					CI["4"]:setColor(period, C4D);
				   end
				   
				 
			else
			CI["All"][period] = ( E[period]+ H[period] + I[period]+  J[period]) /4 ;
				  if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
			end
			
			end
			
	 else 
	 
	 
	     	
			if  Method == "1" then 
			CI["All"][period] = E[period];		
                    if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
			elseif Method == "2" then
			CI["All"][period] = H[period];
			        if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
			elseif Method == "3" then
			CI["All"][period] = I[period]; 
			        if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
				   
			elseif Method == "4" then
			CI["All"][period] = J[period];
			         if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
				   
				   
			elseif Method == "All" then
			CI["1"][period] = E[period];
			CI["2"][period] = H[period];
			CI["3"][period] = I[period];
			CI["4"][period] = J[period];
			
			
			        if CI["1"][period] > CI["1"][period-1] then 
				   CI["1"]:setColor(period, C1U);
				   else
					CI["1"]:setColor(period, C1D);
				   end
				   
				    if CI["2"][period]  >CI["2"][period-1] then 
				   CI["2"]:setColor(period, C2U);
				   else
					CI["2"]:setColor(period, C2D);
				   end
				   
				   
				    if CI["3"][period] > CI["3"][period-1] then 
				   CI["3"]:setColor(period, C3U);
				   else
					CI["3"]:setColor(period, C3D);
				   end
				   
				    if CI["4"][period]  >CI["4"][period-1] then 
				   CI["4"]:setColor(period, C4U);
				   else
					CI["4"]:setColor(period, C4D);
				   end
				   
				 
			else
			CI["All"][period] = ( E[period]+ H[period] + I[period]+  J[period]) /4 ;
				  if CI["All"][period] >CI["All"][period-1] then 
				   CI["All"]:setColor(period, C1U);
				   else
					CI["All"]:setColor(period, C1D);
				   end
			end

    end	 
 end
 