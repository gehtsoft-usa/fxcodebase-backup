-- Id: 10809
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60178

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
    indicator:name("Multi currency pair, Multi Time Frame, Multi Moving Average Table");
    indicator:description("Multi currency pair, Multi Time Frame, Multi Moving Average Table");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    Parameters (1 , "H1", true  );	
	Parameters (2 , "H8", true  );
	Parameters (3 , "D1", true    );

	
	indicator.parameters:addGroup( "Style");
	indicator.parameters:addInteger("Size", "Size", "", 90);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 25);
	
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	 indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
end



function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
   indicator.parameters:addString("Mode"..id, "Mode", "", "Pips");
    indicator.parameters:addStringAlternative("Mode"..id, "Value", "", "Value");
    indicator.parameters:addStringAlternative("Mode"..id, "Pips", "", "Pips");
	
	
	indicator.parameters:addString("Price"..id, "MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period1"..id, "1. MA Period", "", 20);   
    indicator.parameters:addString("Method1"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("Period2"..id, "2. MA Period", "", 50);   
    indicator.parameters:addString("Method2"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period3"..id, "3. MA Period", "", 200);   
    indicator.parameters:addString("Method3"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3"..id, "WMA", "WMA" , "WMA");
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;
local first;
local source = nil;
local Color;
local Method1={};
local Period1={};
local Method2={};
local Period2={};
local Method3={};
local Period3={};
local Price={};
local Mode={};
--local On={};
local Num;
local loading={};
local SourceData={};
local Indicator1={};
local Indicator2={};
local Indicator3={};
local PointSize;
local Pair, Count;
local TF={};
local Normal, Bold;
 
local Value={};
local color={};
local Up, Down;
local Shift;
 
-- Routine
function Prepare(nameOnly)  
    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Shift=instance.parameters.Shift;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
 
	
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;	
	
	for i = 1 , 3 , 1 do   
	
	  -- On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;
	   
	   --On[Num]= true;
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Price[Num]=  instance.parameters:getString ("Price"..i);
	   
       Period1[Num]=  instance.parameters:getInteger ("Period1"..i);	   
	   Period2[Num]=  instance.parameters:getInteger ("Period2"..i);
	   Period3[Num]=  instance.parameters:getInteger ("Period3"..i);
	   
	   Method1[Num]=  instance.parameters:getString ("Method1"..i);
	   Method2[Num]=  instance.parameters:getString ("Method2"..i);
	   Method3[Num]=  instance.parameters:getString ("Method3"..i);
	   Mode[Num]=  instance.parameters:getString ("Mode"..i);	  
	
	  end
	end	
	
	
	Id=0;
	local Test1,Test2,Test3;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 Indicator1[j] = {};	
			 Indicator2[j] = {};
			 Indicator3[j] = {};
             loading[j] = {};	
			 
			  Value[j] = {};	
              color[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		      Value[j][i] = {};	
              color[j][i] = {};	
			  
			  Value[j][i][1]=nil;
		      Value[j][i][2]=nil;
			  Value[j][i][3]=nil;
			  
    assert(core.indicators:findIndicator(Method1[i]) ~= nil, Method1[i] .. " indicator must be installed");
		      Test1 = core.indicators:create(Method1[i], source.close ,Period1[i]);   
    assert(core.indicators:findIndicator(Method2[i]) ~= nil, Method2[i] .. " indicator must be installed");
			  Test2 = core.indicators:create(Method2[i], source.close ,Period2[i]);
    assert(core.indicators:findIndicator(Method3[i]) ~= nil, Method3[i] .. " indicator must be installed");
			  Test3 = core.indicators:create(Method3[i], source.close ,Period3[i]);
	          first= math.max(Test1.DATA:first() ,Test2.DATA:first(),Test3.DATA:first() );
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first) , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   Indicator1[j][i] = core.indicators:create(Method1[i], SourceData[j][i][Price[i]],Period1[i]);
               Indicator2[j][i] = core.indicators:create(Method2[i], SourceData[j][i][Price[i]],Period2[i]);
			   Indicator3[j][i] = core.indicators:create(Method3[i], SourceData[j][i][Price[i]],Period3[i]);

            
		end
	end
    core.host:execute ("setTimer", 1, 1);
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    
  
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + Id) then
			  loading[j][i] = false; 
			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if cookie == 1 and not FLAG then 
		 for j = 1, Count, 1 do				
				for i = 1, Num, 1  do
							Indicator1[j][i]:update(core.UpdateLast);
							Indicator2[j][i]:update(core.UpdateLast);
							Indicator3[j][i]:update(core.UpdateLast);
							
								 
	 
								
                               Calculate(j, i);
								
				 end
		end
	end	

	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	 else
	            
			  instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end

function getPointSize()
    PointSize = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        PointSize[count] = row.PointSize;      
      
        row = enum:next();
    end

end

 

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

	id=0;
	
	local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	
	if FLAG then
	return;
	end
	

	
	 core.host:execute ("setStatus", " Loaded ");
	 
	 
	 
	 	
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (context:bottom()-(context:top()+Shift))/(Count+1);
		
 
		 
		  context:createFont (1, "Arial", ((xGap/100)*Size)/10,  ((yGap/100)*Size), 0);						
          context:createFont (2, "Arial", ((xGap/100)*Size)/25,  ((yGap/100)*Size), 0);				
		
		
		--TF[i]
		for i= 1, Num, 1  do
		
		width, height = context:measureText (1, TF[i], 0);
		context:drawText (1, TF[i], Color, -1, context:left ()+(xGap*(i-1))+xGap, context:top ()+Shift, context:left ()+(xGap*(i-1))+xGap + width, context:top ()+Shift+height,0);
		end
		
		
	 
	 
	 
	 
		for j = 1, Count, 1 do
		 
        
				width, height = context:measureText (1, Pair[j], 0);
	         	context:drawText (1,  Pair[j], Color, -1, context:left (), context:top ()+Shift+yGap*(j), context:left ()+ width, context:top ()+Shift+yGap*(j)+height,0);
		
		        for i = 1, Num, 1 do	
								
                     if Value[j][i][1]~= nil then
								
                     Text=  "1:" .. Value[j][i][1]  
					 width, height = context:measureText (2, Text, 0);	
                    context:drawText (2,  Text, color[j][i][1], -1, context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(0), context:top ()+Shift+yGap*(j), context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(0)+width, context:top ()+Shift+yGap*(j)+height,0);
                 					 
                         
                     Text=  "2:".. Value[j][i][2] ;	
					 width, height = context:measureText (2, Text, 0);	 	 
					 context:drawText (2,  Text, color[j][i][2], -1, context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(1), context:top ()+Shift+yGap*(j), context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(1)+width, context:top ()+Shift+yGap*(j)+height,0);
                         
                     Text=   "3:".. Value [j][i][3] ;
                     width, height = context:measureText (2, Text, 0);	 	
                     context:drawText (2,  Text, color[j][i][3], -1,context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(2), context:top ()+Shift+yGap*(j), context:left ()+(xGap*(i-1))+xGap+(xGap/3)*(2)+width, context:top ()+Shift+yGap*(j)+height,0);					 
					 end	 					 
				 
				 end
		 end
 
 
	
end


function  Calculate(j, i) 
Value[j][i][1]=0;
Value[j][i][2]=0;
Value[j][i][3]=0;


if Mode[1]== "Value" then
Value[j][i][1]=  SourceData[j][i].close[SourceData[j][i].close:size()-1]- Indicator1[j][i].DATA[Indicator1[j][i].DATA:size()-1];
else
Value[j][i][1]=  (SourceData[j][i].close[SourceData[j][i].close:size()-1] -  Indicator1[j][i].DATA[Indicator1[j][i].DATA:size()-1]) /PointSize[j];
end

if Mode[2]== "Value" then
Value[j][i][2]=  SourceData[j][i].close[SourceData[j][i].close:size()-1]- Indicator2[j][i].DATA[Indicator2[j][i].DATA:size()-1];
else
Value[j][i][2]=  (SourceData[j][i].close[SourceData[j][i].close:size()-1] -  Indicator2[j][i].DATA[Indicator2[j][i].DATA:size()-1]) /PointSize[j];
end

if Mode[3]== "Value" then
Value[j][i][3]=  SourceData[j][i].close[SourceData[j][i].close:size()-1]- Indicator3[j][i].DATA[Indicator3[j][i].DATA:size()-1];
else
Value[j][i][3]=  (SourceData[j][i].close[SourceData[j][i].close:size()-1] -  Indicator3[j][i].DATA[Indicator3[j][i].DATA:size()-1]) /PointSize[j];
end



if Value[j][i][1]> 0 then
color[j][i][1]= Up;
else
color[j][i][1]= Down;
end

if Value[j][i][2]> 0 then
color[j][i][2]= Up;
else
color[j][i][2]= Down;
end


if Value[j][i][3]> 0 then
color[j][i][3]= Up;
else
color[j][i][3]= Down;
end


Value[j][i][1]= math.abs(Value[j][i][1]);
Value[j][i][2]= math.abs(Value[j][i][2]);
Value[j][i][3]= math.abs(Value[j][i][3]);


if Mode[1]== "Value" then
Value[j][i][1]= string.format("%." .. 4 .. "f", Value[j][i][1]	) ;
else
Value[j][i][1]= string.format("%." .. 1 .. "f", Value[j][i][1]	) ;
end

if Mode[2]== "Value" then
Value[j][i][2]= string.format("%." .. 4 .. "f", Value[j][i][2]	) ;
else
Value[j][i][2]= string.format("%." .. 1 .. "f", Value[j][i][2]	) ;
end

if Mode[3]== "Value" then
Value[j][i][3]= string.format("%." .. 4 .. "f", Value[j][i][3]	)  ;
else
Value[j][i][3]= string.format("%." .. 1 .. "f", Value[j][i][3]	)  ;
end



end

