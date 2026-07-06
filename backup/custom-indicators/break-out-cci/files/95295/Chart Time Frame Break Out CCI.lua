-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61020

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

 
function Init()
    indicator:name("Chart Time Frame Break Out CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

 
	indicator.parameters:addInteger("Period", "Period", "", 14);
	
 
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("VShift", "Vertical Shift", "", 0 );
	indicator.parameters:addInteger("HShift", "Horizontal Shift", "", 0 );
	indicator.parameters:addColor("BreakingOutUpwardsColor", "Breaking Out Upwards Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("BreakingOutDownwardsColor", "Breaking Out Downwards Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("TrendingUpColor", "Trending Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("TrendingDownColor", "Trending Down Color", "", core.rgb(255, 0, 0));
 
 indicator.parameters:addColor("RangeBoundColor", "Range Bound Color", "", core.rgb(0, 0, 255));
 
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
end


function Parameters (id, frame , Def )

    indicator.parameters:addGroup(id..".  Time Frame"); 
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period"..id, "Period", "", 14);
	  
end
 
 
 
local source;  
local first ;
local Up, Down, Neutral;
local HShift,VShift;
 local font1;
local Size;
local Label;
 
local id;
local cci;
local Period;
local bor;
local BreakingOutDownwardsColor,TrendingDownColor,RangeBoundColor,TrendingUpColor,BreakingOutUpwardsColor;

function Prepare(nameOnly)

  	
    source = instance.source;		 
    
	 local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ; 
	instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
    
    BreakingOutDownwardsColor=instance.parameters.BreakingOutDownwardsColor;
	TrendingDownColor=instance.parameters.TrendingDownColor;
	RangeBoundColor=instance.parameters.RangeBoundColor;
	TrendingUpColor=instance.parameters.TrendingUpColor;
	BreakingOutUpwardsColor=instance.parameters.BreakingOutUpwardsColor;
	
	Label=instance.parameters.Label;
    HShift=instance.parameters.HShift;
	VShift=instance.parameters.VShift;
	 Size=instance.parameters.Size; 
	
   	local i;
	 
	Period= instance.parameters.Period; 
	 
      
       assert(core.indicators:findIndicator("BREAK OUT CCI") ~= nil, "Please, download and install BREAK OUT CCI.LUA indicator");    
	
   
	 

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
      
	   
	  
		 
		bor  = core.indicators:create("BREAK OUT CCI", source,Period); 
		cci  = core.indicators:create("CCI", source ,Period);
		
		first =  cci.DATA:first() 
	 
end


function Update(period)


 
   

    core.host:execute ("setStatus", "")
 
    if  period <  source:size() - 1 then	
       return;
	end
	 	
	   local i ;
		id =0; 			 
		
		 Calculation() 
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
   
 end
   
function Calculation (  )
		
		i=1;
				
						cci:update(core.UpdateLast);
						bor:update(core.UpdateLast);
						
				
                     		 
							
							                  local TrendTxt="";
						
											   local Trend = bor .DATA[bor.DATA:size()-1];
									            local CCI = cci.DATA[cci.DATA:size()-1];
											   
											   
												 if (Trend == 2) then												 
													TrendTxt = "Breaking-out_ Upwards";
													TrendColor = BreakingOutUpwardsColor;
												 end
												if (Trend == 1) then
												 
													TrendTxt = "Trending Up";
													TrendColor = TrendingUpColor;
												 end
												if (Trend == 0) then
												 
													TrendTxt = "Range Bound";
													TrendColor = RangeBoundColor;
												 end
												if (Trend == -1) then
												 
													TrendTxt = "Trending Down";
													TrendColor = TrendingDownColor;
												end 
												if (Trend == -2) then
												 
													TrendTxt = "Breaking-out_ Downwards";
													TrendColor = BreakingOutDownwardsColor;
												 end
												 
												if (Trend == 1 or Trend == 2 and CCI >= 0) then
												 
													CCIState = "Favourable";
												 
												elseif (Trend == -1 or  Trend == -2 and CCI < 0) then
												 
													CCIState = "Favourable";
												 
												elseif (Trend == 0) then
												 
													CCIState = "";
											 
												else
													CCIState = "Unfavourable"; 
												end	
											   
												id=id+1;
												core.host:execute("drawLabel1", id, -i*Size*5+HShift, core.CR_RIGHT, Size*5+VShift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, TrendColor, TrendTxt);

                                                id=id+1;
												core.host:execute("drawLabel1", id, -i*Size*5+HShift, core.CR_RIGHT, Size*5+Size+VShift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label, CCIState);												
												
											
												
												
											 
					
				
   
end
 