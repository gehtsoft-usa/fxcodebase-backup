-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3005

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function AddParam(id, frame , Flag)

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", Flag);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
	 indicator.parameters:addInteger("Period"..id, "Period", "", 14);

end


function Init()
    indicator:name("MTF_MCP RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
	
    AddParam(1, "m1", false);	
    AddParam(2, "m5", false);	
    AddParam(3, "m15", false);	
    AddParam(4, "m30", false);
    AddParam(5, "H1", true);
	AddParam(6, "H2", false);	
    AddParam(7, "H3", false);	
    AddParam(8, "H4", false);	
    AddParam(9, "H6", false);
    AddParam(10, "H8", true);
	AddParam(11, "D1", true);	
    AddParam(12, "W1", true);
    AddParam(13, "M1", true);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	
	 indicator.parameters:addColor("UPOB", "Color for Up Trend OB Zone", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNOB", "Color for Down Trend OB Zone", "", core.rgb(255, 0, 0));	
	
	indicator.parameters:addColor("UPOS", "Color for Up Trend OS Zone", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNOS", "Color for Down Trend OS Zone", "", core.rgb(255, 0, 0));	
	
	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addDouble("HSize", "Horizontal indicator size as % of screen", "", 50, 50, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local UP, DN, NO, DNOB, UPOB, DNOS, UPOS;
	local source = nil;
	local TF={};
	local Pair={};
	local L={};	
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};  
	local Size;
	local HSize;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
 
	
local Indicator={};
local Period={};

-- Routine
function Prepare(nameOnly)
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	UPOB=instance.parameters.UPOB;
	DNOB=instance.parameters.DNOB;
	UPOS=instance.parameters.UPOS;
	DNOS=instance.parameters.DNOS;
	
	NO=instance.parameters.NO;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	HSize=instance.parameters.HSize;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
   
	
    local i;
    local name = profile:id() .. "(" .. source:name() ;
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		     Period[Number]=instance.parameters:getInteger (" Period"..i);		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:name();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end
	     
		
			
			  TF[Number]= instance.parameters:getString("TF" .. i);	
			  
		
			 
		   
		   L[Number] = TF[Number] .. ", ".. Pair[Number];
		   name = name ..", " .."(" .. TF[Number] .. ", ".. Pair[Number] ..")";
		 
		 end   
		   
	  
    end
    name = name .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   	 
    for i = 1, Number, 1 do	 
	
	    	local Test = core.indicators:create("RSI", source.close , Period[i]);   
	        first= Test.DATA:first()*2 ; 		  
	  	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  first , 200+i, 100+i);	   
		Indicator[i] = core.indicators:create("RSI", SourceData[i].close,Period[i]);
		loading[i]= true;		
		
		 
    end
    
	instance:ownerDrawn(true);

end


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		else
		Indicator[j]:update(core.UpdateLast);
		end	 
 
	end    
	
	local Symbol="\149";
	
     	if Flag then
		return;
		end
      
	    local xCell =( (context:right () -context:left ())/100 )* (HSize/Number);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 	
			local Color;
					

			if 	 Indicator[i].DATA[Indicator[i].DATA:size()-1] > 70  then
			
				if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > Indicator[i].DATA[Indicator[i].DATA:size()-2] 			 
				then
				Color=UPOB;
				Symbol="\217";
				elseif Indicator[i].DATA[Indicator[i].DATA:size()-1]  < Indicator[i].DATA[Indicator[i].DATA:size()-2] 		 
				then
				Color=DNOB;
				Symbol="\218";
				else
				Symbol="\149";
				Color=NO;
				end		
			elseif 	 Indicator[i].DATA[Indicator[i].DATA:size()-1] > 30  then
			
				if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > Indicator[i].DATA[Indicator[i].DATA:size()-2] 			 
				then
				Color=UP;
				Symbol="\217";
				elseif Indicator[i].DATA[Indicator[i].DATA:size()-1]  < Indicator[i].DATA[Indicator[i].DATA:size()-2] 			 
				then
				Color=DN;
				Symbol="\218";
				else
				Symbol="\149";
				Color=NO;
				end		
			
			else
			
				
				if Indicator[i].DATA[Indicator[i].DATA:size()-1]  > Indicator[i].DATA[Indicator[i].DATA:size()-2] 			 
				then
				Color=UPOS;
				Symbol="\217";
				elseif Indicator[i].DATA[Indicator[i].DATA:size()-1]  < Indicator[i].DATA[Indicator[i].DATA:size()-2] 			 
				then
				Color=DNOS;
				Symbol="\218";
				else
				Symbol="\149";
				Color=NO;
				end	
            end				
					    
			        		
			context:createFont (11, "Wingdings", (xCell/10)*(Size/100)*2, yCell*(Size/100), 0);	
           
			 width, height = context:measureText (11, tostring(Symbol), 0)			
			 context:drawText (11,  tostring(Symbol), Color, -1, context:right ()-(i)*xCell    , context:top ()+yCell*2, context:right ()-(i-1)*xCell + width, context:top ()+yCell*2 + height, 0);
			 
			 
			 context:createFont (2, "Arial", (xCell/10)*(Size/100), yCell*(Size/100), 0);	
			  width, height = context:measureText (2, tostring(TF[i]), 0)				
		    context:drawText (2, tostring(TF[i]), Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell, context:right ()-(i-1)*xCell + width, context:top ()+yCell + height, 0);
			
			
			 local Value= string.format("%." .. 2 .. "f", Indicator[i].DATA[Indicator[i].DATA:size()-1] );
			
             width, height = context:measureText (2, Value, 0)			
			 
			 if Indicator[i].DATA[Indicator[i].DATA:size()-1] > 50 then
			 context:drawText (2,  Value, UP, -1, context:right ()-(i)*xCell    , context:top ()+yCell*3, context:right ()-(i-1)*xCell + width, context:top ()+yCell*3 + height, 0);
			else
			 context:drawText (2,  Value, DN, -1, context:right ()-(i)*xCell    , context:top ()+yCell*3, context:right ()-(i-1)*xCell + width, context:top ()+yCell*3 + height, 0);
			end
			
			
			if not Chart then
			
						
             width, height = context:measureText (2, Pair[i], 0)			
			 context:drawText (2,  Pair[i], Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell*4, context:right ()-(i-1)*xCell + width, context:top ()+yCell*4 + height, 0);
			 
			end
			
			
		 end
	 
         		 
 
		
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	local ID=0;
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  			 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;		
		end	 
 
	end    
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);		 
		end
   
        
		return core.ASYNC_REDRAW ;
   
end

