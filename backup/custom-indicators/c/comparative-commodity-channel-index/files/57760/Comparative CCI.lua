-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33996
-- Id: 8846

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Adds AC parameter
function AddParam(id,  Def)
    indicator.parameters:addGroup(id.. ". Pair" );
	indicator.parameters:addBoolean("On"..id , "Show This Pair", "", true);	
	indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", Def);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
end

function Init()
    indicator:name("Comparative Commodity Channel Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("Calculation" ); 
	 indicator.parameters:addString("Period","Period", "", 14);
    
     AddParam(1, "EUR/USD");	
     AddParam(2, "GBP/USD");	
     AddParam(3,  "AUD/USD");	
     AddParam(4,  "USD/CHF");
     AddParam(5,  "USD/JPY");
	 
	 
	
    indicator.parameters:addGroup("Style");

	indicator.parameters:addColor("Color", "CCI Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
	 indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 100, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", -100, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 5, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Components" ); 
	indicator.parameters:addBoolean("Show",  "Show Components", "" , true);	

	indicator.parameters:addColor("C1", "1. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C2", "2. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C3", "3. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C4", "4. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C5", "5. Component Color", "", core.rgb(128, 128, 128));
  
end


local Show;
local source;
local day_offset, week_offset;
local host;
local Source={};
local Period;
local Pair={};
local  Indicator = {};
local Out;
local In={};
local On={};
local loading={};
 
function Prepare(nameOnly)
	Show=instance.parameters.Show;
    source = instance.source;
    host = core.host;
	Period=instance.parameters.Period;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
  
    local i;
    local name = profile:id() .. "(" .. source:name() .. "," .. Period;
    for i = 1, 5, 1 do	     
		  Pair[i]= instance.parameters:getString("Pair" .. i);       
          On[i]= instance.parameters:getBoolean("On" .. i);  
    end
    name = name .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
   
 
	if Show then
		if On[1] then
		In[1]= instance:addStream("CRS".. 1, core.Line, name ,  Pair[1], instance.parameters.C1, source:first());
		end
		if On[2] then
		In[2]= instance:addStream("CRS".. 2, core.Line, name , Pair[2], instance.parameters.C2, source:first());
		end
		if On[3] then
		In[3]= instance:addStream("CRS".. 3, core.Line, name , Pair[3], instance.parameters.C3, source:first());
		end
		if On[4] then
		In[4]= instance:addStream("CRS".. 4, core.Line, name , Pair[4], instance.parameters.C4, source:first());
		end
		if On[5] then
		In[5]= instance:addStream("CRS".. 5, core.Line, name , Pair[5], instance.parameters.C5, source:first());
		end
	end
	
	
	
		for i = 1, 5, 1 do
		    if On[i] then
			
			 Test = core.indicators:create("MVA", source ,Period);  			
			first= Test.DATA:first()*2 ; 
			
            Source[i] = core.host:execute("getSyncHistory",Pair[i], source:barSize(), source:isBid(), math.min(300,first), 200+i, 100+i);
            Indicator[i] = core.indicators:create("CCI", Source[i], Period);   
            loading[i]=true; 			
            end			
		end
		
		
	
	Out = instance:addStream("CRS", core.Line, name , "CRS", instance.parameters.Color, source:first());
	Out:setWidth(instance.parameters.width);
    Out:setStyle(instance.parameters.style);
    Out:addLevel(0);
    Out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
end



function Update(period, mode)
    local i;
	local p ={};	
	local Sum = 0;
	local Count=0;
	
	  local Flag=false;
  
	for i= 1, 5, 1 do
	p[i]= Initialization(period,i)	
		if loading[i] or p[i]== false  then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	 
  
    for i = 1, 5, 1 do
	     if On[i] then
	
				 
					Indicator[i]:update(mode);
					
					
					
					
					
						 
							
							if Show then
							In[i][period] =  Indicator[i].DATA[p[i]];
							end
							
							Sum= Sum+ Indicator[i].DATA[p[i]];
							Count=Count+1;
						 
          	
        end
   end
    				Out[period] =  Sum /Count;
							
  
 
end
--Number


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source [id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, 5, 1 do
		
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
		core.host:execute ("setStatus", " Loading ".. (5-Count) .."/" .. 5);
		else
		core.host:execute ("setStatus", " Loaded ".. (5-Count) .."/" .. 5);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end
 



