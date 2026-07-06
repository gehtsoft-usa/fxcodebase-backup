-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73931

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
 
function Init()
    indicator:name("G-Channel Trend Detection");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 100, 1, 2000);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);  

	
	indicator.parameters:addGroup("Line Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
	
	 indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , true); 
	 indicator.parameters:addBoolean("Lines", "Show Lines", "" , true); 	 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 
	 

	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
     indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up,Down, Neutral;

local first;
local source = nil;

local Period; 

local Cloud,Lines;
local Transparency;

local Top=nil;
local Bottom=nil;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;

   Signal=instance.parameters.Signal;
	
   Cloud= instance.parameters.Cloud;
   Lines= instance.parameters.Lines;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
			
	Period= instance.parameters.Period;

			
			
			
    source = instance.source;
    first=source:first()+1;
	 
	 
	if Lines then 
    a = instance:addStream("a", core.Line, name, "a", Neutral, first +Period );
    a:setPrecision(math.max(2, instance.source:getPrecision()));
    a:setWidth(instance.parameters.width);
    a:setStyle(instance.parameters.style);

    b = instance:addStream("b", core.Line, name, "b", Neutral, first +Period );
    b:setPrecision(math.max(2, instance.source:getPrecision()));
    b:setWidth(instance.parameters.width);
    b:setStyle(instance.parameters.style); 
     
    Close=instance:addStream("Close", core.Line, name, "Close", Neutral, first);
    Average=instance:addStream("Average", core.Line, name, "Average", Neutral, first);
	
    Close:setWidth(instance.parameters.width);
    Close:setStyle(instance.parameters.style); 
    Average:setWidth(instance.parameters.width);
    Average:setStyle(instance.parameters.style); 	
	
	else
	a = instance:addInternalStream(0, 0);
	b = instance:addInternalStream(0, 0);
	Close = instance:addInternalStream(0, 0);
	Average = instance:addInternalStream(0, 0);	
	end
   
	
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
    Average:setPrecision(math.max(2, instance.source:getPrecision()));	
	if Cloud then
	instance:createChannelGroup("Group","Group" , Close, Average, Neutral, Transparency);
	end
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", Neutral, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 	
	
	
end

-- Indicator calculation routine
function Update(period, mode)
      
    --Indicator[1]:update(mode); 
	a[period]= 0;
	b[period]= 0;
	Close[period]= source[period];
		
	if  not source:hasData(period)  or period <= first then 
		return;
	end
	
	a[period]= math.max(source[period],a[period-1]) - (a[period-1] - b[period-1])/Period
	b[period]= math.min(source[period],b[period-1]) + (a[period-1] - b[period-1])/Period
	Average[period]=(a[period]+b[period])/2;
	
	if  not source:hasData(period)  or period <= first+Period then 
		return;
	end	
		
      
				if Close[period] > Average[period] then 
				Close:setColor(period, Up);
				elseif Close[period] < Average[period] then 
				Close:setColor(period, Down);	
				else
				Close:setColor(period, Neutral);
				end
		

    up:setNoData(period);
    down:setNoData(period);
	
	
    if Close[period] < Average[period] and Close[period-1] >= Average[period-1] then
	BearCondition = true;
	else
	BearCondition = false;
    end	
 
            
    if Close[period] > Average[period] and Close[period-1] <= Average[period-1] then
	BullCondition = true;
	else
	BullCondition = false;
    end	
	


	if BullCondition
	then
	Bar[period]= 1;
    up:set(period, Average[period], "\217");	
	elseif BearCondition
    then	
    down:set(period,Average[period], "\218");	
	Bar[period]= -1;	
    else
	Bar[period]= 0;	
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