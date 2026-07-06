 

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62841

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Bollinger Average");
    indicator:description("Bollinger Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
   indicator.parameters:addGroup("Calculation");
   indicator.parameters:addBoolean("Show", "Show Components", "Show Components", false);
	 
	
   AddBollinger(1,24,2,"Chart",core.rgb(128, 128,128));
   AddBollinger(2,120,2,"Chart",core.rgb(128, 128,128));
   AddBollinger(3,200,2,"Chart",core.rgb(128, 128,128));
 
    indicator.parameters:addGroup(  "Style");
    indicator.parameters:addColor("TL_Color" , "Top Line Color", "", core.rgb(0, 255,0));
	indicator.parameters:addColor("BL_Color" , "Bottom Line Color", "", core.rgb(255, 0,0));
	indicator.parameters:addColor("CL_Color" , "Central Line Color", "", core.rgb(0, 0,255));
	indicator.parameters:addInteger("width"..4, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..4, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..4, core.FLAG_LINE_STYLE);
	
end

function AddBollinger(id, BollingerPeriod,DeviationPeriod,TF,color)

	indicator.parameters:addGroup(id.. ". Bollinger");
	
	indicator.parameters:addString("TF"..id, "Time frame", "", TF);
	local iTF={"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1","W1", "M1"};
	for i= 1, 14, 1  do
	indicator.parameters:addStringAlternative("TF"..id, iTF[i], iTF[i] , iTF[i]);
	end 
	
	
    indicator.parameters:addInteger("BollingerPeriod"..id, "Bollinger Bands Period", "", BollingerPeriod);
    indicator.parameters:addDouble("DeviationPeriod"..id, "Deviation Period", "", DeviationPeriod);
	
	indicator.parameters:addColor("color"..id, id ..". Line Color", "", color);
	indicator.parameters:addInteger("width"..id, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Color={};             
local Style={};
local Width={};
local BollingerPeriod={};
local DeviationPeriod={};
local BB={};
local Top={};
local Bottom={};
local Central={};
local first;
local Show;
local Source={};
local loading={};
local TF={};
local dayoffset, weekoffset;
local Number=3;
-- Routine
function Prepare(nameOnly)

    
	Show=instance.parameters.Show;
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	local i;
     
	for i = 1, 3 , 1 do
	Color[i]= instance.parameters:getColor("color".. i);
	Style[i]=instance.parameters:getString("style".. i);
    Width[i]=instance.parameters:getString("width".. i);
	BollingerPeriod[i]=instance.parameters:getInteger("BollingerPeriod".. i);
	DeviationPeriod[i]=instance.parameters:getDouble("DeviationPeriod".. i);
	end
	
 
	Style[4]=instance.parameters:getString("style".. 4);
    Width[4]=instance.parameters:getString("width".. 4);
	
    source = instance.source;
    first = source:first();
		
	
   
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
   
    local s, e, s1, e1;
	s, e = core.getcandle(source:barSize(), core.now(), 0, 0); 
	
	for i=1,3,1 do
	     TF[i]= instance.parameters:getString("TF" .. i);		
			
			 if TF[i]=="Chart" then
			 TF[i]=source:barSize();
			 end
			 
			s1, e1 = core.getcandle(TF[i], core.now(), 0, 0);
			assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
			 
	    Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(300, BollingerPeriod[i]+1), 200+i, 100+i);
		loading[i]= true;
		
    	BB[i] = core.indicators:create("BB", Source[i].close, BollingerPeriod[i],DeviationPeriod[i]);
		
		if Show then
		Top[i] = instance:addStream("Top"..i, core.Line, name .. ".Top"..i, "Top"..i, Color[i],  first);
		Top[i]:setWidth(Width[i]);
		Top[i]:setStyle(Style[i]);
		
		Bottom[i] = instance:addStream("Bottom"..i, core.Line, name .. ".Bottom"..i, "Bottom"..i, Color[i],  first);
		Bottom[i]:setWidth(Width[i]);
		Bottom[i]:setStyle(Style[i]);
		
		Central[i] = instance:addStream("Central"..i, core.Line, name .. ".Central"..i, "Central"..i, Color[i],  first);
		Central[i]:setWidth(Width[i]);
		Central[i]:setStyle(Style[i]);
		else
		
		Top[i] = instance:addInternalStream(first, 0);
		Bottom[i] = instance:addInternalStream(first, 0);
		Central[i] = instance:addInternalStream(first, 0);
		end
		
	end
	
		Top[4] = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.TL_Color,  first);
		Top[4]:setWidth(Width[4]);
		Top[4]:setStyle(Style[4]);
		
		Bottom[4] = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BL_Color,  first);
		Bottom[4]:setWidth(Width[4]);
		Bottom[4]:setStyle(Style[4]);
		
		Central[4] = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.CL_Color,  first);
		Central[4]:setWidth(Width[4]);
		Central[4]:setStyle(Style[4]);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

        local Count=0;
		local p;
		
	    for i= 1 , 3 ,1 do
		BB[i]:update(mode);
		    p= Initialization(period,i)	
     		if p~= false and BB[i].DATA:hasData(p) and not loading[i] then
			Top[i][period]=BB[i].TL[p];
			Bottom[i][period]=BB[i].BL[p];
			Central[i][period]=BB[i].AL[p];
			else
			Count=Count+1;
			end
	    end
		
		if Count==0 then
		Top[4][period]=( Top[1][period]+Top[2][period]+Top[3][period])/3;
		Bottom[4][period]=( Bottom[1][period]+Bottom[2][period]+Bottom[3][period])/3;
		Central[4][period]=( Central[1][period]+Central[2][period]+Central[3][period])/3;
		end
		    
end






function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
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

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		  
		instance:updateFrom(0);
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
 



