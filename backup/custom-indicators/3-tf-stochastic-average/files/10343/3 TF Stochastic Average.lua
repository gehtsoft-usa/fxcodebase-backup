-- Id: 3811
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4124

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


function Init()
    indicator:name("3 TF Stochastic Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

    
	
	Parameters (1 , "H1");
	Parameters (2 , "H8");
	Parameters (3 , "D1");
  
	
	
	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
  
 
	 indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "MT4","", "FS");
    
 
	
	indicator.parameters:addGroup("Stochastic Style");
	
	indicator.parameters:addInteger("widthFirst", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addColor("Color", "Stochastic Line Color", "", core.rgb(0, 255, 0));
	
	 indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
    
	
	
end


function Parameters (id , FRAME )  	  
  
	indicator.parameters:addGroup(id..". Stochastic");
	 indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end


local source;
local day_offset, week_offset;
local host;
local first;

local K;
local indicator={};

local Number=3;
local Source ={};
local  TF={}; 
local loading={}; 
function Prepare(nameOnly) 
	
   
	source = instance.source;
	first= source:first();
    host = core.host;
	
	 local name =  profile:id() .. ","  .. instance.source:name() ;
	
	 local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
       

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	
	
     
	local i;
	for i= 1, 3, 1 do
		s1, e1 = core.getcandle(instance.parameters:getString ("TF"..i), core.now(), 0, 0);
		assert ((e - s) <= (e1 - s1), i..". Time Frame  must be bigger than the chart time frame!");
		
		name = name..", ("  .. instance.parameters.K..", " .. instance.parameters.SD ..", " .. instance.parameters.KS ..", ".. instance.parameters:getString ("TF"..i) .. ")";      
	end
	instance:name(name);
	if nameOnly then
		return;
	end
	
    local Test = core.indicators:create("STOCHASTIC", source , instance.parameters.K, instance.parameters.SD, instance.parameters.D, instance.parameters.KS , instance.parameters.DS  );  
	first= Test.DATA:first() ; 
	 
		for i = 1, 3 , 1 do	 
		
		 TF[i]= instance.parameters:getString("TF" .. i);
		 Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(300,first*2), 200+i, 100+i);		 
		 loading[i]=true;
 
		 indicator[i] = core.indicators:create("STOCHASTIC",  Source[i], instance.parameters.K, instance.parameters.SD, instance.parameters.D, instance.parameters.KS , instance.parameters.DS);			
		end
	
	K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.Color, first);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
	K:addLevel(0);
    K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    K:addLevel(100);
 
 
end


function Update(period,mode)

  local Flag=false;

   local p={};
   for i= 1, Number, 1 do
	p[i]= Initialization(period,i)	
		if loading[i] or p[i]== false  then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
  
	local i;
	local Sum=0;
			
		for i = 1, 3, 1  do
		  
		    indicator[i]:update(mode);
						
			 
			if indicator[i].DATA:hasData(p[i]) then
			Sum= Sum+  indicator[i].DATA[p[i]];			
			end
			 
	    end
	 
	 K[period] =  Sum/3;
     
	
 
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
   end
   
   
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end
 


