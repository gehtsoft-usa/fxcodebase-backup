-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=35469
-- Id: 9042

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

function AddParam(id,  Def)
    indicator.parameters:addGroup(id.. ". Pair" );
	indicator.parameters:addBoolean("On"..id , "Show This Pair", "", true);	
	indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", Def);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
end

function Init()
    indicator:name("Comparative Moving Average Convergence/Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("Calculation" ); 
	 
	 
	 indicator.parameters:addGroup("Type"); 
    indicator.parameters:addString("Type", "Method", "" , "Relativ");
    indicator.parameters:addStringAlternative("Type", "Absolute", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "Relativ" , "Relativ");
	 
	 indicator.parameters:addInteger("SP","Short Period", "", 12);
	 indicator.parameters:addInteger("LP","Long Period", "", 26);
	 indicator.parameters:addInteger("SignalPeriod","Signal Period", "", 9);
	 
	 indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
    
     AddParam(1, "EUR/USD");	
     AddParam(2, "GBP/USD");	
     AddParam(3,  "AUD/USD");	
     AddParam(4,  "USD/CHF");
     AddParam(5,  "USD/JPY");
	 
	 
	
    indicator.parameters:addGroup("Style");

	indicator.parameters:addColor("Color", "MACD Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addColor("SignalColor", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("HISTOGRAM_color", "Histogram Color", "", core.rgb(0, 0, 255));
	
	
	indicator.parameters:addGroup("Components" ); 
	indicator.parameters:addBoolean("Show",  "Show Components", "" , true);	

	indicator.parameters:addColor("C1", "1. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C2", "2. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C3", "3. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C4", "4. Component Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C5", "5. Component Color", "", core.rgb(128, 128, 128));
  
end
local Type;
-- list of streams
 
local Show;
-- the indicator source
local source;
local day_offset, week_offset;
local dummy;
local host;
local Source={};
local LP, SP;
local Pair={};
local Indicator = {};
local Out;
local In={};
local On={};
local SignalPeriod;
local Price;
local  MVAI;
local Signal, HISTOGRAM;
local   EMAL={};
local Number=5;
local loading={};
function Prepare(nameOnly)
	Show=instance.parameters.Show;
	Type=instance.parameters.Type;
	SignalPeriod=instance.parameters.SignalPeriod;
	Price=instance.parameters.Price;
    source = instance.source;
    host = core.host;
	LP=instance.parameters.LP;
	SP=instance.parameters.SP;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	
	 if (LP <= SP) then
       error("The short EMA period must be smaller than long EMA period");
    end

     local precision = math.max(2, source:getPrecision());
	 
    local i;
    local name = profile:id() .. "(" .. source:name() .. "," .. SP .. ", " .. LP.. ", " .. SignalPeriod.. ", " .. Type;
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
		In[1]= instance:addStream("MACD".. 1, core.Line, name ,  Pair[1], instance.parameters.C1, source:first());
    In[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
		if On[2] then
		In[2]= instance:addStream("MACD".. 2, core.Line, name , Pair[2], instance.parameters.C2, source:first());
    In[2]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
		if On[3] then
		In[3]= instance:addStream("MACD".. 3, core.Line, name , Pair[3], instance.parameters.C3, source:first());
    In[3]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
		if On[4] then
		In[4]= instance:addStream("MACD".. 4, core.Line, name , Pair[4], instance.parameters.C4, source:first());
    In[4]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
		if On[5] then
		In[5]= instance:addStream("MACD".. 5, core.Line, name , Pair[5], instance.parameters.C5, source:first());
    In[5]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
	end
	
	Out = instance:addStream("MACD", core.Line, name , "MACD", instance.parameters.Color, source:first());
	Out:setWidth(instance.parameters.width);
    Out:setStyle(instance.parameters.style);
	Out:setPrecision(precision);
	 
	 
	 Signal = instance:addStream("SIGNAL", core.Line, name , "Signal", instance.parameters.SignalColor, source:first());
	 Signal:setWidth(instance.parameters.width2);
     Signal:setStyle(instance.parameters.style2);
	 Signal:setPrecision(precision);
	 HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color,source:first());
	 HISTOGRAM:setPrecision(precision);
	 
	     for i = 1, Number, 1 do
		    if On[i] then 
			
			Source[i] = core.host:execute("getSyncHistory",Pair[i],source:barSize(), source:isBid(), LP, 200+i, 100+i); 
			loading[i]=true;
            Indicator[i] = core.indicators:create("MACD", Source[i][Price], SP, LP);   
            EMAL[i] = core.indicators:create("EMA", Source[i][Price],  LP);      	
            end			
		end
end



function Update(period, mode)
    local i;
	local p={};
	local Sum = 0;
	local Count=0;
	
	
	local Flag=false;
  
	for i= 1, Number, 1 do
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
	
				--p, loading = getPeriod(i, period);		
			
				
				 
					Indicator[i]:update(mode);
					EMAL[i]:update(mode);
					
					
					   
					
							if Indicator[i].DATA:hasData(p[i])   then 
							
							 if Type == "Absolute" then
							
								if Show then
								In[i][period] =  Indicator[i].DATA[p[i]];								
								end
								
								Sum= Sum+ Indicator[i].DATA[p[i]];
								Count=Count+1;
							
							
							Out[period] =  Sum /Count;
							
							
						
  
									 
									   Signal[period]=  mathex.avg(Out, period- SignalPeriod+1, period) ;
									  HISTOGRAM[period]= Out[period] - Signal[period]; 
									 
                            else
							
										if Show then
									In[i][period] =  Indicator[i].DATA[p[i]]/ ( EMAL[i].DATA[p[i]]/100);									
									end
								
								Sum= Sum+ (Indicator[i].DATA[p[i]]/ ( EMAL[i].DATA[p[i]]/100));
								Count=Count+1;

									
								Out[period] =  Sum /Count;
								
							 
										   Signal[period]=  mathex.avg(Out, period- SignalPeriod+1, period) ;
										  HISTOGRAM[period]= Out[period] - Signal[period]; 
										 

							end
							end 
         	 	  end
   end
   
   
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
 