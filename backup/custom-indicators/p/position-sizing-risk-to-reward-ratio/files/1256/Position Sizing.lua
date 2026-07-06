-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=689

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Position Sizing");
    indicator:description("Position Sizing");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addString("Model", "Risk or Volatility or Manual", "", "Risk");
	indicator.parameters:addStringAlternative("Model", "Pips Risk Model", "" , "Risk");
    indicator.parameters:addStringAlternative("Model", "ATR Volatility Model", "" , "Volatility");

	 
	indicator.parameters:addString("Side", "Buy or Sell", "", "Buy");
	indicator.parameters:addStringAlternative("Side", "Buy", "Buy" , "Buy");
    indicator.parameters:addStringAlternative("Side", "Sell", "Sell" , "Sell");
	
	indicator.parameters:addInteger("RiskToReward", "Risk to Reward", "Risk to Reward", 4);
	
	 
	indicator.parameters:addDouble("Level", "Entry Order Level (0 or Value)", "Entry Order", 0);
		
	indicator.parameters:addInteger("Equity", "Manual Account size", "Account size", 10000 );
	indicator.parameters:addInteger("PipsAtRisk", "Pips", "Pips at Risk", 100);
	indicator.parameters:addDouble("RiskPercentage", "Risk Percentage", "Risk Percentage ", 5,0,100);
	
	indicator.parameters:addInteger("Period", "ATR Period", "ATR Period",14);
	
	
	indicator.parameters:addGroup("Position sizing");
    indicator.parameters:addString("Type", "Balance/Equity", "", "Balance");
    indicator.parameters:addStringAlternative("Type", "Equity", "", "Equity");
    indicator.parameters:addStringAlternative("Type", "Balance", "", "Balance");
	indicator.parameters:addStringAlternative("Type", "Manual", "" , "Manual");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Entry", "Entry", "Entry", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Stop", "Stop", "Stop", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Limit", "Limit", "Limit", core.rgb(255, 255, 0));
	indicator.parameters:addColor("Label", "Label", "Label", core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15);
 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Side;
local RiskToReward;
local Period; 
local Level;
local Equity;
local RiskPercentage;
local Model;
local PipsAtRisk;
local N;
local ATR;
local Type;

local font;
local name;
local first;
local source = nil;
local PipCost;
local Size;

 
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Type = instance.parameters.Type;
	Size = instance.parameters.Size;
    Side = instance.parameters.Side;
    RiskToReward = instance.parameters.RiskToReward;
   
    Level = instance.parameters.Level;
    Equity = instance.parameters.Equity;
	RiskPercentage = instance.parameters.RiskPercentage;
	Model = instance.parameters.Model;
	PipsAtRisk = instance.parameters.PipsAtRisk;
	Period = instance.parameters.Period;
	
	
	 font = core.host:execute("createFont", "Arial", Size, true, false);

	
    source = instance.source;
    first = source:first();
	
	 ATR = core.indicators:create("ATR", source, Period);
	
	PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
	ContractSize = core.host:findTable("offers"):find("Instrument", source:instrument()).ContractSize;
	
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   ATR:update(mode);
    

   if period < source:size()-1 then
   return;
   end

	
	 
								
							 
	 local price=0;
     if Level==0 then	
	 price=source.close[period];
	 else
	 price=Level;
	 end 
	
	local Balance;
	local accounts = core.host:findTable("accounts");
    local enum = accounts:enumerator();
	local row = enum:next();
    if row ~= nil then
	
			if Type == "Balance" then
			Balance= row.Balance;
			elseif Type == "Equity" then
			Balance= row.Equity;
			else
			Balance= Equity;
			end
	 end
 
						local Risk= (Balance/100)*RiskPercentage;
						 			
								
						local stop, Pips;
						
						if (Model=="Risk") then 							
								 stop=PipsAtRisk*source:pipSize();		
                                 Pips= 	PipsAtRisk;							 
						 else  						         
								 stop=ATR.DATA[source:size()-1];
								 Pips=ATR.DATA[source:size()-1]/source:pipSize();
						 end
						
					
						local s,l;
											
						local limit=stop*RiskToReward;
				
					if  Side == "Buy" then
					 s=price- stop;
					 l=price + limit;
					 else
					 s=price+ stop;
					 l=price - limit;
					 end
					 
					 local RPC;		
                     local NOC;
					-- ContractSize--- 
					 --RPC =Pips;	
					 RPC =Pips*PipCost;
					 
					 NOC= Risk/RPC; 
				 
					
		
  
					core.host:execute("drawLine", 1, source:date(first), s, source:date(period), s, instance.parameters.Stop);				
					
					core.host:execute("drawLabel1", 2, source:date(period) , core.CR_CHART, s, core.CR_CHART, core.H_Left, core.V_Top,
                    font, instance.parameters.Label, "Stop ("  .. string.format("%." .. 5 .. "f", s  ) .. ")  " );					
					
					core.host:execute("drawLine", 3, source:date(first), l, source:date(period), l, instance.parameters.Limit);
			
					
					core.host:execute("drawLabel1", 4, source:date(period) , core.CR_CHART, l, core.CR_CHART, core.H_Left, core.V_Top,
                    font, instance.parameters.Label,"Limit (" .. l .. ")  ");
											
					core.host:execute("drawLabel1", 5, source:date(period) , core.CR_CHART, l, core.CR_CHART, core.H_Right, core.V_Top,
                    font, instance.parameters.Label, "Number od Contract (".. string.format("%." .. 2 .. "f", NOC  )..")  " );
					
					core.host:execute("drawLabel1", 6, source:date(period) , core.CR_CHART, l, core.CR_CHART, core.H_Right, core.V_Bottom,
                    font, instance.parameters.Label,"Risk per Contract(".. string.format("%." .. 2 .. "f", RPC  ) .." $)  ");
					
			
		
		 core.host:execute("drawLine", 7, source:date(first), price, source:date(period), price, instance.parameters.Entry);		 
		 core.host:execute("drawLabel1", 8, source:date(period) , core.CR_CHART, price, core.CR_CHART, core.H_Left, core.V_Top,
                    font, instance.parameters.Label,"  Entry (" .. price .. ")" );		
 
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
