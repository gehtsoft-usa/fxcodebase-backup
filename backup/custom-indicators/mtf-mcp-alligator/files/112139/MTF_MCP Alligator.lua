-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64620

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function AddParam(id, frame , Flag)

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", Flag);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	

    indicator.parameters:addInteger("JawN".. id, "Alligator Jaw smoothing periods", "", 13, 1, 300);
    indicator.parameters:addInteger("JawS".. id, "Alligator Jaw shifting periods", "", 8, 0, 300);

    indicator.parameters:addInteger("TeethN".. id, "Alligator Teeth smoothing periods", "", 8, 1, 300);
    indicator.parameters:addInteger("TeethS".. id, "Alligator Teeth shifting periods", "", 5, 0, 300);

    indicator.parameters:addInteger("LipsN".. id, "Alligator Lips smoothing periods", "", 5, 1, 300);
    indicator.parameters:addInteger("LipsS".. id, "Alligator Lips shifting periods", "", 3, 0, 300);

    indicator.parameters:addString("MTH".. id,"Smoothing method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH".. id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH".. id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH".. id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH".. id, "LSMA", "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH".. id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH".. id, "Vidya1995", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH".. id, "Vidya1992", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH".. id, "Wilders", "", "WMA");

end


function Init()
    indicator:name("MTF_MCP Alligator");
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
    indicator.parameters:addColor("JawC", "Jaw Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("TeethC", "Teeth Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("LipsC", "Lips Color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addDouble("HSize", "Horizontal indicator size as % of screen", "", 70, 50, 100);
	indicator.parameters:addDouble("VShift", "Vertical Shift", "", 0);
end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
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
    local VShift;
	
local Indicator={};
local JawN={};
local JawS ={};
local TeethN={};
local TeethS={};
local LipsN={};
local LipsS={};
local MTH={};
-- Routine
function Prepare(nameOnly)
    	
	Chart=instance.parameters.Chart;
    source = instance.source;
 
	
	JawC=instance.parameters.JawC;
	TeethC=instance.parameters.TeethC;
	LipsC=instance.parameters.LipsC;
	VShift=instance.parameters.VShift;
	
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
		 
		   	

			TeethN[Number]=instance.parameters:getInteger ("TeethN"..i);		
			TeethS[Number]=instance.parameters:getInteger ("TeethS"..i);		
			LipsN[Number]=instance.parameters:getInteger ("LipsN"..i);		
			LipsS[Number]=instance.parameters:getInteger ("LipsS"..i);			
			JawN[Number]=instance.parameters:getInteger ("JawN"..i);		
			JawS[Number]=instance.parameters:getInteger ("JawS"..i);	
            MTH[Number] =instance.parameters:getString ("MTH"..i);				
		 
		     assert(core.indicators:findIndicator(MTH[Number]) ~= nil, "Please download and install"  .. MTH[Number] .. ".lua indicator");
			 
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
	
	 if   (nameOnly) then
        return;
    end
   	 
    for i = 1, Number, 1 do	 
	
	    	local Test = core.indicators:create("ALLIGATOR", source ,  JawN[i],JawS[i] ,TeethN[i],TeethS[i],LipsN[i],LipsS[i],MTH[i]);   
	        first= Test.DATA:first()*2 ; 		  
	  	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  math.min(300,first) , 200+i, 100+i);	   
		Indicator[i] = core.indicators:create("ALLIGATOR", SourceData[i],  JawN[i],JawS[i] ,TeethN[i],TeethS[i],LipsN[i],LipsS[i],MTH[i]);
		loading[i]= true;		
		
		 
    end
    
	instance:ownerDrawn(true);
	core.host:execute ("setTimer", 1, 1);

end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
		end	 
 
	end    
	
	local Symbol="\149";
	
     	if Flag then
		return;
		end
      
	    local xCell =( (context:right () -context:left ())/100 )* (HSize/Number);		
        local yCell = (context:bottom () -context:top ())/15;	

		 context:createFont (1, "Arial", (xCell/15)*(Size/100), yCell*(Size/100), 0);	
    
	  
		
		for i = 1, Number, 1 do 	
			
			  if Indicator[i].Jaw:hasData(Indicator[i].Jaw:size()-1)
			  and  Indicator[i].Teeth:hasData(Indicator[i].Teeth:size()-1)
			  and  Indicator[i].Lips:hasData(Indicator[i].Lips:size()-1)
			  then
		
			  width, height = context:measureText (1, tostring(TF[i]), 0)				
		    context:drawText (1, tostring(TF[i]), Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell*2+VShift, context:right ()-(i-1)*xCell + width, context:top ()+yCell*2 + height +VShift, 0);
			
			 local Jaw_Value= Indicator[i].Jaw[Indicator[i].Jaw:size()-1];
			 local Teeth_Value= Indicator[i].Teeth[Indicator[i].Teeth:size()-1];
			  local Lips_Value= Indicator[i].Lips[Indicator[i].Lips:size()-1];
			  
			  max= math.max(Jaw_Value,Teeth_Value,Jaw_Value );
			  min= math.min(Jaw_Value,Teeth_Value,Jaw_Value )  
			  
			  local Jaw_Index=4;
			  local Teeth_Index=4
			  local Lips_Index=4;
			  
			  if Jaw_Value == min then
			  Jaw_Index=5;
			  elseif Teeth_Value == min then
			  Teeth_Index=5;
			  elseif Lips_Value == min then
			  Lips_Index=5;
			  end
			  
			  if Jaw_Value == max then
			  Jaw_Index=3;
			  elseif Teeth_Value == max then
			  Teeth_Index=3;
			  elseif Lips_Value == max then
			  Lips_Index=3;
			  end
			 
			 
			 --Lips			 
			 local Value= "Lips : " .. string.format(  win32.formatNumber(Lips_Value, false, source:getPrecision())  );
             width, height = context:measureText (1, Value, 0)			
			 context:drawText (1,  Value, LipsC, -1, context:right ()-(i)*xCell    , context:top ()+yCell*Lips_Index+VShift, context:right ()-(i-1)*xCell + width, context:top ()+yCell*Lips_Index + height+VShift, 0);

             local Value= "Teeth : " .. string.format(  win32.formatNumber(Teeth_Value, false, source:getPrecision())  );
             width, height = context:measureText (1, Value, 0)			
			 context:drawText (1,  Value, TeethC, -1, context:right ()-(i)*xCell    , context:top ()+yCell*Teeth_Index+VShift, context:right ()-(i-1)*xCell + width, context:top ()+yCell*Teeth_Index + height+VShift, 0);		

            local Value= "Jaw : " .. string.format(  win32.formatNumber(Jaw_Value, false, source:getPrecision())  );
             width, height = context:measureText (1, Value, 0)			
			 context:drawText (1,  Value, JawC, -1, context:right ()-(i)*xCell    , context:top ()+yCell*Jaw_Index+VShift, context:right ()-(i-1)*xCell + width, context:top ()+yCell*Jaw_Index + height+VShift, 0);						 
			
			
			if not Chart then						
             width, height = context:measureText (1, Pair[i], 0)			
			 context:drawText (1,  Pair[i], Label, -1, context:right ()-(i)*xCell    , context:top ()+yCell*6+VShift, context:right ()-(i-1)*xCell + width, context:top ()+yCell*6 + height+VShift, 0);			 
			end
			
			
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
	
		if not Flag and cookie == 1 then	
		 
			for j = 1, Number, 1 do
			Indicator[j]:update(core.UpdateLast); 
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

