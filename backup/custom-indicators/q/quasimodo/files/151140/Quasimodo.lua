-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73798

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Quasimodo");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  	indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addInteger("NumberOf", "Max Fractal Number", "", 2, 1, 100);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 
	 
	 
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 

local High;
local Low;

-- Routine
 function Prepare(nameOnly)   
 
    
	NumberOf=instance.parameters.NumberOf
	Signal=instance.parameters.Signal;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	first=source:first() ; 
	
	
	up = instance:addInternalStream(0, 0);
 	down = instance:addInternalStream(0, 0);
 
 	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	Up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    Down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end
function BullishQuasimodo()
 

    if   source.low[Low[1]] > source.low[Low[2]]  and source.low[Low[3]] > source.low[Low[2]]  and source.high[High[1]] > source.high[High[2]]   then
 
	Bar[Low[1]]= 1;
    Up:set(Low[1], source.low[Low[1]], "\217");	 
    end
end

function BearishQuasimodo()
    local top = source.high[High[2]]
    local bottom =  source.low[Low[2]]
    local left = source.high[High[1]]
    local right = source.low[Low[1]]
    local middle = (left + right) / 2
	
    local top = source.high[High[2]]
    local bottom = source.low[Low[2]]
    local left = source.low[Low[1]]
    local right = source.high[High[1]]
    local middle = (left + right) / 2	

    if  source.high[High[1]] > source.high[High[2]]  and source.high[High[3]] > source.high[High[2]]  and source.low[Low[1]] < source.low[Low[2]]   then
 	Down:set(High[1], source.high[High[1]], "\218");	
	Bar[High[1]]= -1;
    end
end

function Update(period, mode)

	 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	period=period-NumberOf
	
    if period < source:first()+NumberOf then
	return;
	end
	

    local test=0;   
	local i;
	local count=NumberOf;
 
	     x = period;
	
        local curr = source.high[x];
	
		
		
         for i= 1, count, 1 do
		
		     if  curr > source.high[x + i] and curr > source.high[x  - i]  then
			 test=test+1;
			 else
			 break;
			 end
			
		 end	
		 
		 if test  ==NumberOf  then
		   up[x]=1;
		 end

        test=0;		 
		
 	     x = period;      
	     curr = source.low[x];
		
		  
          for i= 1 , count, 1 do
		
		     if  curr < source.low[x + i] and curr < source.low[x  - i]  then
			 test=test+1;
			  else
			 break;
			 end
			
		 end	
	   
	     if test ==NumberOf then
		   down[x]=1;
		end
		
		
		
    Last(period)    

    if table.getn(Low)< 4 or table.getn(High) < 4 then
    return;
    end	
	  	
    BullishQuasimodo();
    BearishQuasimodo();	
	
    
end

function Last(period)
        High={};
	    Low={};
	
    for i= period, 1 , -1 do

        if up[i]==1 then
        High[table.getn(High)+1]=i
		end	

        if down[i]==1 then
        Low[table.getn(Low)+1]=i
		end	
		
			if table.getn(High) >=  4 and table.getn(Low) >=  4 then	
			break
			end 	
	end
	
end

 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+