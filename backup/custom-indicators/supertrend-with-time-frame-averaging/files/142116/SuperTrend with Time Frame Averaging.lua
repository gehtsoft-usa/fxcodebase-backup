-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71196

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

--[[Time Frame Averaging can have up to 5 Indicators drawn,
each for a different time frame.
Average value of all selected Indicators is also drawn.]]




function Add(id,  TF)
    indicator.parameters:addGroup(id.. ". Pair" );
	indicator.parameters:addBoolean("On"..id , "Show This Time Frame", "", true);	
	indicator.parameters:addString("TF" .. id, id.. ". Time Frame", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS );
	
	indicator.parameters:addInteger("N".. id, "Number of periods", "", 10);
    indicator.parameters:addDouble("M".. id, "Multiplier", "", 1.5);
	
end

function Init()
    indicator:name("SuperTrend with Time Frame Averaging");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
    
     Add(1,"H6");	
     Add(2,"H8");	
     Add(3,"D1");	
     Add(4,"W1");
     Add(5, "M1");
	 
	 
	
    indicator.parameters:addGroup("Style");
  indicator.parameters:addColor("LineColor", "Average Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("MaxColor", "Max Line Color", "", core.rgb(255, 0, 0));
		indicator.parameters:addColor("MinColor", "Min Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
	 indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Components" ); 
	indicator.parameters:addBoolean("Show",  "Show Components", "" , true);	
	indicator.parameters:addBoolean("ShowMinMax",  "Show Min Max", "" , true);	
		indicator.parameters:addBoolean("ShowOBOS",  "Show OBOS", "" , true);	

	indicator.parameters:addColor("Color1", "1. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color2", "2. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color3", "3. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color4", "4. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color5", "5. Component Color", "", core.rgb(128, 128, 128));
  
end

-- list of streams
local Show;
local ShowOBOS;
local source;
local day_offset, week_offset;
 
local Source={};
 
local TF={};
local Indicator ={};
local Out;
local In={}; 
local Number;
local loading={};
local Color={};
local ShowMinMax;
local N={};
local M={};
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	Show=instance.parameters.Show;
	ShowMinMax=instance.parameters.ShowMinMax;
	ShowOBOS=instance.parameters.ShowOBOS;
    source = instance.source;
    host = core.host;
 
	
	assert(core.indicators:findIndicator("ST") ~= nil, "Please, download and install ST.LUA indicator");

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
  
    local i;
	Number=0;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);    
	
  
    for i = 1, 5, 1 do	    
	
          s2, e2 = core.getcandle(instance.parameters:getString("TF" .. i), 0, 0, 0);    	
		  if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then 
		  Number=Number+1;
		  Color[Number]= instance.parameters:getColor("Color" .. i);
		  TF[Number]= instance.parameters:getString("TF" .. i);
		  N[Number]= instance.parameters:getString("N" .. i);
		  M[Number]= instance.parameters:getString("M" .. i);
		  end 
    end
     
	Out = instance:addStream("CRS", core.Line, name , "CRS", instance.parameters.LineColor, source:first());
	Out:setWidth(instance.parameters.width);
    Out:setStyle(instance.parameters.style); 
    Out:setPrecision(math.max(2, instance.source:getPrecision())); 



	
   local id=0;
   for i = 1, Number, 1 do
	id=id+1;
		if Show then	 
		In[i]= instance:addStream("CRS".. i, core.Line, name ,   TF[i], Color[i], source:first());
		In[i]:setPrecision(math.max(2, instance.source:getPrecision())); 	
	     end
	 
	
	Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(),  300, 200+id, 100+id);	 
	loading[i]= true;
    Indicator[i] = core.indicators:create("ST", Source[i], N[i], M[i]);   
    end	
	
	
	 if ShowOBOS then	

    OB = instance:addStream("OB", core.Line, name , "OB", instance.parameters.MinColor, source:first());
	OB:setWidth(instance.parameters.width);
    OB:setStyle(instance.parameters.style); 
    OB:setPrecision(math.max(2, instance.source:getPrecision())); 
	
	OS = instance:addStream("OS", core.Line, name , "OS", instance.parameters.MaxColor, source:first());
	OS:setWidth(instance.parameters.width);
    OS:setStyle(instance.parameters.style); 
    OS:setPrecision(math.max(2, instance.source:getPrecision())); 	 
	
	  end
    if ShowMinMax then	 	
	Min = instance:addStream("Min", core.Line, name , "Min", instance.parameters.level_overboughtsold_color, source:first());
	Min:setWidth(instance.parameters.width);
    Min:setStyle(instance.parameters.style); 
    Min:setPrecision(math.max(2, instance.source:getPrecision())); 
	
	Max = instance:addStream("Max", core.Line, name , "Max", instance.parameters.level_overboughtsold_color, source:first());
	Max:setWidth(instance.parameters.width);
    Max:setStyle(instance.parameters.style); 
    Max:setPrecision(math.max(2, instance.source:getPrecision())); 
	
    end
end



function Update(period, mode)
    local i, p; 	
	local Sum = 0;
	local Count=0;
   
    for i = 1, Number, 1 do
 
	            Indicator[i]:update(mode);	   
		        p= Initialization(period,i);	
			
				
				if  p~= false then 
				
							if Indicator[i].DATA:hasData(p) and p < (source:size()-1) and p > (source:first()) then 
							
							if Show then
							In[i][period] =  Indicator[i].DATA[p];
							end
							
							Sum= Sum+ Indicator[i].DATA[p];
							Count=Count+1;
							Out[period] =  Sum /Count;
							end 
         	end		
        
   end
   local min,max;
   
    for i = 1, Number, 1 do
		if i== 1 then 
		min = In[i][period];
		max = In[i][period]
		else
		min = math.min(In[i][period],min);
		max =  math.max(In[i][period],max);
		end
	
    end
	
	Max[period]=max;
	Min[period]=min;
	
	local Range=(max-min)/100;
	
	
	OB[period]=min+Range*instance.parameters.overbought;
	OS[period]=min+Range*instance.parameters.oversold;
end



function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local id=0;
		
    for j = 1, Number, 1 do
		id=id+1;
			  if cookie == (100+id) then
			  loading[j] = true;
		      elseif  cookie == (200+id) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		end
			     
        
		return core.ASYNC_REDRAW ;
end

 