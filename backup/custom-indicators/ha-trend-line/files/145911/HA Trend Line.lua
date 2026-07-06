-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72153

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


-- I have simplified this indicator a bit
--Indicator does not calculate the value of HA for each period alone.
--Values are calculated by External function
--Standard Heiken Ashi Indicator 

function Init()
    indicator:name("Heiken Ashi Trend Line");
    indicator:description("Heiken Ashi Trend Line");
	--Sets the type of the required source of the indicator Bar or Tick 
    indicator:requiredSource(core.Bar);
	--Sets the type - Indicator or Oscillator. 
    indicator:type(core.Indicator);
	indicator.parameters:addColor("Up", "Up Color", "Color", core.rgb(0, 255 , 0));
	indicator.parameters:addColor("Dn", "Down Color", "Color", core.rgb(255,0 , 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

--definition of variables
local source = nil;
local LINE=nil;
local HA=nil;
local Up, Dn;
local first = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
	
	Up = instance.parameters.Up;
	Dn = instance.parameters.Dn;
	
    local name = "Heiken Ashi Trend Line" .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
  	
	--Creates an instance of the indicator
	--Calls Heiken Ashi indicator
	--Heiken Ashi indicator return indicator stream.
	HA = core.indicators:create("HA", source);
	first = HA.DATA:first() + 1;
	--Adds a stream to the indicator output
	LINE = instance:addStream("Line", core.Line, name, "close", Up, first)
	LINE:setWidth(instance.parameters.width);
    LINE:setStyle(instance.parameters.style);
	
end

-- Indicator calculation routine
function Update(period, mode)


   			
            -- Updates call HA indicator for each period 			
			HA:update(mode);
			
			
    if period < first or not  source:hasData(period) then
	return;
	end
--Middle points of upper wicks for green heiken candles
--Middle points of lower wicks for red heiken candles
               
			   local Top= HA.high[period]-math.max(HA.open[period],HA.close[period]) ;
			   local Bottom= math.min(HA.open[period],HA.close[period])-HA.low[period];
			   local TopMiddlePoint=HA.high[period]-Top/2;
			   local BottomMiddlePoint=HA.low[period]+Bottom/2;
				
				 
				if  HA.close[period] > HA.open[period]  then 
				 
					 LINE[period]=TopMiddlePoint;		
					 LINE:setColor(period, Up); 
				  else				
					 
					LINE[period]=BottomMiddlePoint;
					LINE:setColor(period, Dn);  
				 end
				  
                				 
	  
end



