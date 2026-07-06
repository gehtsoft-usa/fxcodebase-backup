-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62592
-- Id: 14726

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stochastic Price Overlay");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "MT4","", "MT");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA");
	
	indicator.parameters:addString("Type", "Type", "Type", "K/D");
    indicator.parameters:addStringAlternative("Type", "K/D", "K/D", "K/D");
	indicator.parameters:addStringAlternative("Type", "K/(OB/OS)", "K/(OB/OS)", "K/(OB/OS)");
    indicator.parameters:addStringAlternative("Type", "K/Central", "K/Central", "K/Central");
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "Overbought Level","", 80);
    indicator.parameters:addDouble("OS","Oversold Level","", 20);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local OB,OS;
local first;
local source = nil;
local Up,Down;
local DS,KS;
local K,SD,D;
local Type;
local Size;
local Stochastic=nil;

function Prepare(nameOnly)

     DS = instance.parameters.DS;
	 KS = instance.parameters.KS;
     K = instance.parameters.K;
	 SD = instance.parameters.SD;
	 D = instance.parameters.D;
	 Type= instance.parameters.Type;
	 Size= instance.parameters.Size;
	 Up= instance.parameters.Up;
	 Down= instance.parameters.Down;
	 OB= instance.parameters.OB;
	 OS= instance.parameters.OS;
  
	source = instance.source;     
		
    local name = profile:id() .. "(" .. source:name() ..", ".. source:barSize() ..", ".. K..", " .. SD .. ", " .. D ..", ".. KS.. ", ".. DS.. ", ".. Type.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	font  = core.host:execute("createFont", "Wingdings", Size, false, false);
	Stochastic=core.indicators:create("STOCHASTIC",  source, K,SD,D,KS,DS);
	first= Stochastic.DATA:first();
end

-- Indicator calculation routine
function Update(period, mode)			
			
	 Stochastic:update(mode);	

      core.host:execute ("removeLabel", source:serial(period));		 
			
			if period< first then
			return;
			end
			
				
						if Stochastic.K[period] > Stochastic.D[period] 
						and Stochastic.K[period-1] <= Stochastic.D[period-1]		
                        and Type=="K/D" 						
						then 	
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Up, "\225");
					    elseif Stochastic.K[period] < Stochastic.D[period] 
						and Stochastic.K[period-1] >= Stochastic.D[period-1]		
                        and Type=="K/D" 						
						then 
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Down, "\226");
						end
						
						if Stochastic.K[period] > OB 
						and Stochastic.K[period-1] <= OB						
                        and Type=="K/(OB/OS)" 	
						then
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Up, "\225");
						elseif Stochastic.K[period] < OB 
						and Stochastic.K[period-1] >= OB						
                        and Type=="K/(OB/OS)" 	
						then
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Down, "\226");
						end
						
						
						if Stochastic.K[period] > OS 
						and Stochastic.K[period-1] <= OS						
                        and Type=="K/(OB/OS)" 	
						then
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Up, "\225");
						elseif Stochastic.K[period] < OS 
						and Stochastic.K[period-1] >= OS						
                        and Type=="K/(OB/OS)" 	
						then
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Down, "\226"); 
						end
						
						if Stochastic.K[period] > 50 
						and Stochastic.K[period-1] <= 50						
                        and Type=="K/Central" 
                        then						
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Up, "\225");
						elseif Stochastic.K[period] < 50 
						and Stochastic.K[period-1] >= 50
						and Type=="K/Central" 
						then
						core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top , font , Down, "\226"); 
						end
						
		 
		
 end


