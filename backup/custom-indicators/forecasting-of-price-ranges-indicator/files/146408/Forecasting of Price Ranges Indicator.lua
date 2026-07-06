-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72395

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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
-- Indicator profile initialization routine
 
function Init()
    indicator:name("Forecasting of Price Ranges Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , true); 
	 indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , false); 	 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up,Down, Neutral;

local first;
local source = nil;
 
 
local Lines,Cloud;
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
   
   Lines= instance.parameters.Lines;
   Cloud= instance.parameters.Cloud;
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
 
    source = instance.source; 
    first=source:first();
 
	x= instance:addInternalStream(0, 0);
	 if Lines then
   
   Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first);
   Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);
   else
   Top=instance:addInternalStream(first, 0);     
   Bottom=instance:addInternalStream(first, 0);
   end
	
   if Cloud then
   instance:createChannelGroup("Group","Group" , Top, Bottom, Neutral, Transparency);
   end
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
		
	if  period <= first  then 
		return;
	end
	
	
	local h = source.high[period];
	local l = source.low[period];
	local o = source.open[period];
	local c = source.close[period];
			
	if(c<o) then       x[period]=(h+l+c+l)/2;
    elseif(c>o) then  x[period]=(h+l+c+h)/2;
    elseif(c==o) then  x[period]=(h+l)/2;
	end 
	
	Top[period] = x[period]-l;
	Bottom[period] = x[period]-h; 
	
 
	
				if x[period] > x[period-1]   then 
				Top:setColor(period, Up);
				Bottom:setColor(period, Up);
				elseif x[period] < x[period-1]   then 
				Top:setColor(period, Down);	
				Bottom:setColor(period, Down);				
				else
				Top:setColor(period, Neutral);
				Bottom:setColor(period, Neutral);				
				end
	 	  
end

 
