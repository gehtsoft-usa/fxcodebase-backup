-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68956

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
     indicator.parameters:addInteger("Source_Shift", "Source Shift", "", 1, 0, 1000);
     indicator.parameters:addInteger("Output_Shift", "Output Shift", "", 0);
	 
	 indicator.parameters:addString("Method", "Method", "Method" , "(High+Low+Close+Open)/4");
    indicator.parameters:addStringAlternative("Method", "(High+Low+Close+Open)/4", "(High+Low+Close+Open)/4" , "(High+Low+Close+Open)/4");
    indicator.parameters:addStringAlternative("Method", "(High+Low+Close)/3", "(High+Low+Close)/3" , "(High+Low+Close)/3");
	indicator.parameters:addStringAlternative("Method", "(High+Low+Open)/3", "(High+Low+Open)/3" , "(High+Low+Open)/3");
	indicator.parameters:addStringAlternative("Method", "(High+Low)/2", "(High+Low)/3" , "(High+Low)/2");
	indicator.parameters:addStringAlternative("Method", "(Close+Open)/2", "(Close+Open)/2" , "(Close+Open)/2");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Source_Shift,Output_Shift,Method ; 
local first;
local source = nil;
 
local Line;
-- Routine
 function Prepare(nameOnly)   
 
 
    Source_Shift= instance.parameters.Source_Shift;
	Output_Shift= instance.parameters.Output_Shift;
	Method= instance.parameters.Method;
	
	local Parameters= Source_Shift.. "," .. Output_Shift.. "," .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Output_Shift;
	
	 
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, math.max(source:first(),source:first()+Output_Shift),Output_Shift );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
      local p= period-Source_Shift;	
   
	if period < first
	or period-Output_Shift < source:first()
	or p < first
	or p+Output_Shift < source:first()
	then
	return;
	end
 
		
  

     if Method ==	 "(High+Low+Close+Open)/4" then
     Line[period+Output_Shift]=  (source.high[p]+source.low[p]+source.open[p]+source.close[p])/4 ;
	 elseif Method ==	 "(High+Low+Open)/3" then
	 Line[period+Output_Shift]= (source.high[p]+source.low[p]+source.open[p])/3 ;
	 elseif Method ==	 "(High+Low+Close)/3" then
	 Line[period+Output_Shift]= (source.high[p]+source.low[p]+source.close[p])/3 ;
	 elseif Method ==	 "(High+Low)/2" then
	 Line[period+Output_Shift]= (source.high[p]+source.low[p])/2 ;
	 elseif Method ==	 "(Close+Open)/2" then
	 Line[period+Output_Shift]= (source.open[p]+source.close[p])/2 ;
	 end
				  
end

 
