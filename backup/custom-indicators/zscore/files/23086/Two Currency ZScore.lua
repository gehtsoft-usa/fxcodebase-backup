-- Id: 5544
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=8619

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Two Currency  ZScore");
    indicator:description("Two Currency  ZScore");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

 	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 20);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addGroup(  "Instruments"); 
	Parameters (1 , "EUR/USD" );
	Parameters (2 , "USD/JPY" );
		
		  
	Style(1 ,core.rgb(0, 255, 0))

	
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 2);
    indicator.parameters:addDouble("oversold","Oversold Level","", -2);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end
function Style(id, Color)
	indicator.parameters:addGroup( "Line Style");
	indicator.parameters:addColor("Color"..id, "Line Color", "", Color);
    indicator.parameters:addInteger("Width"..id, "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("Style" ..id, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LEVEL_STYLE);
end	

function Parameters (id , Instrument)
   
	
	indicator.parameters:addString("Instrument"..id,  id..". Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument"..id, core.FLAG_INSTRUMENTS );
	
 

end
local Period;
local Number=2;
 
local out;
local source; 
local Instrument={};
local first;
local  loading={};
local offset, weekoffset;
local SourceData={};
local Color={};
local Style={};
local Width={};
local MVA={};
local Z={};
local Price;
function Prepare(nameOnly)   
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
    source = instance.source;
	first= source:first();
    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
   
    local name =  profile:id()  ;
	name = name..", (" ..  Period.." )";   
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local i;
	
	Z[1] = instance:addInternalStream(0, 0);
	Z[2] = instance:addInternalStream(0, 0);
	 Color[1]= instance.parameters:getColor("Color" .. 1);
     Style[1]= instance.parameters:getInteger("Style" .. 1);
     Width[1]= instance.parameters:getInteger("Width" .. 1);

	for i = 1 , 2 , 1 do     
	 Instrument[i] = instance.parameters:getString ("Instrument"..i); 
	end	
	 
	
	      for i = 1 , 2 , 1 do    
          
			
			SourceData[i] = core.host:execute("getSyncHistory",Instrument[i], source:barSize(), source:isBid(), Period, 200+i, 100+i); 
			MVA[i]= core.indicators:create("MVA", SourceData[i][Price], Period ); 
			loading[i]=true;	  
			
			
			end
			
			i= 1;
			
			out = instance:addStream("ZSCORE" , core.Line,   " ZSCORE", "ZSCORE", Color[i], MVA[i].DATA:first());
			out:setWidth(Width[i]);
            out:setStyle(Style[i]);
			out:setPrecision(2);
			out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		    out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		 
 
end


function Update(period, mode)


    
		for i=1, 2, 1 do
		Calculation(i, period, mode);
		end
		
		
		if period < Period then
		return;
		end
		
		out[period]=  Z[1][period]-Z[2][period];
			
end

function Calculation(id, period, mode)

    MVA[id]:update(mode);
	
    local p= Initialization(period,id);
	
	if not p then
	 return;
	end
	
	
	Z[id][period] = (SourceData[id][Price][p] - MVA[id].DATA[p])/ mathex.stdev (SourceData[id][Price], p - Period +1 , p);	  
	 
									      
	  
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

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
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
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

 