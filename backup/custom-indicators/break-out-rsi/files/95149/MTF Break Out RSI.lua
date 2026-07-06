-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60982

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
    indicator:name("MTF Break Out RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1"  ); 
	Parameters (2 , "H4"  );
	Parameters (3 , "H8"  );
    Parameters (4 , "D1"  );
	Parameters (5 , "W1"  );
	
	
 
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
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
 
 
local TF={};
local source; 
local day_offset, week_offset;
local host;
local first={};
local Up, Down, Neutral, Note;
local HShift,VShift;
 local font1;
 local font2;
local Show={};	
 
local SourceData={};
local loading={};
local Size;
local Test={}; 
local Label;
local Note={};
local id;
local rsi={};
local Period={};
local bor={};
local BreakingOutDownwardsColor,TrendingDownColor,RangeBoundColor,TrendingUpColor,BreakingOutUpwardsColor;

function Prepare(nameOnly) 

  	
    source = instance.source;		 
    host = core.host;
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
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
	
    for i= 1, 5, 1 do		 
	 	 
     TF[i]= instance.parameters:getString ("TF"..i);	  
	 Period[i]= instance.parameters:getInteger ("Period"..i); 
	end
      
   
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;
    
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
	 assert(core.indicators:findIndicator("BREAK OUT RSI") ~= nil, "Please, download and install BREAK OUT RSI.LUA indicator");    

	for i= 1, 5, 1 do
	
	 Note[i]= "(" .. TF[i]..", " .. Period[i]..")"; 

   	Test[i] = core.indicators:create("BREAK OUT RSI", source , Period[i]);   

	first[i] =  Test[i].DATA:first() 
	end

	

	

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
      
	   
	 
	   
	 for i = 1, 5, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), math.min(300, first[i]*2) , 200+i, 100+i);
		  loading[i] = true;   
	   
	  
		 
		bor[i] = core.indicators:create("BREAK OUT RSI", SourceData[i] ,Period[i]); 
		rsi[i] = core.indicators:create("RSI", SourceData[i].close ,Period[i]);
	end
end


function Update(period)



 
    if  period <  source:size() - 1 then	
       return;
	end
	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then	
	core.host:execute ("setStatus", "Loading")
	return;	
	else
	core.host:execute ("setStatus", "")
	end
	
	
			
	   local i, color;
		id =0;
		 
		
		for i = 1 ,5 , 1  do			
			
		Calculation( i );	
		
		
		 end 
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
   
 end
   
function Calculation ( i)
		
		
				
						rsi[i]:update(core.UpdateLast);
						bor[i]:update(core.UpdateLast);
						
				
                     							
							
						
							  id=id+1;
							
							   core.host:execute("drawLabel1", id, -i*Size*5*1.1+HShift, core.CR_RIGHT,Size*4*1.1+VShift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,TF[i]);
							 
							 
							
							                  local TrendTxt="";
						
											   local Trend = bor[i].DATA[bor[i].DATA:size()-1];
									            local RSI = rsi[i].DATA[rsi[i].DATA:size()-1];
											   
											   
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
												 
												if (Trend == 1 or Trend == 2 and RSI >= 50) then
												 
													RSIState = "Favourable";
												 
												elseif (Trend == -1 or  Trend == -2 and RSI < 50) then
												 
													RSIState = "Favourable";
												 
												elseif (Trend == 0) then
												 
													RSIState = "";
											 
												else
													RSIState = "Unfavourable"; 
												end	
											   
												id=id+1;
												core.host:execute("drawLabel1", id, -i*Size*5*1.1+HShift, core.CR_RIGHT, Size*5*1.1+VShift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, TrendColor, TrendTxt);

                                                id=id+1;
												core.host:execute("drawLabel1", id, -i*Size*5*1.1+HShift, core.CR_RIGHT, Size*5*1.1+Size+VShift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label, RSIState);												
												
											
												
												
											 
					
				
   
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
    elseif cookie == 202 then
        loading[2] = false; 
    elseif cookie == 203 then
        loading[3] = false; 
    elseif cookie == 204 then
        loading[4] = false; 
    elseif cookie == 205 then
        loading[5] = false;  
    end
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then	
        instance:updateFrom(0);
	end	
		
    return core.ASYNC_REDRAW;
end
