-- Id: 13723
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61967

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
function Init()
    indicator:name("Dashboard of indicators");
    indicator:description("Dashboard of indicators");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	--local IndicatorList={"RSI", "SSD", "SFK", "CCI", "CMO", "DMI", "ADX", "ATR", "MACD"};
	
	indicator.parameters:addGroup("RSI Calculation");     
	indicator.parameters:addInteger("11", "Period", "", 14);	
	
	indicator.parameters:addGroup("SSD Calculation");     
	indicator.parameters:addInteger("21", "K Period", "", 5);
    indicator.parameters:addInteger("22", "D slowing Period", "", 3);
	indicator.parameters:addInteger("23", "D Period", "", 3);	
	
	indicator.parameters:addGroup("SFK Calculation");     
	indicator.parameters:addInteger("31", "K Period", "", 5);
    indicator.parameters:addInteger("32", "D Period", "", 5);
	
	indicator.parameters:addGroup("CCI Calculation");    
	indicator.parameters:addInteger("41", "Period", "", 14);
	
	indicator.parameters:addGroup("CMO Calculation");    
	indicator.parameters:addInteger("51", "Period", "", 9);
	
	indicator.parameters:addGroup("DMI Calculation");    
	indicator.parameters:addInteger("61", "Period", "", 14);
	
	indicator.parameters:addGroup("ADX Calculation");    
	indicator.parameters:addInteger("71", "Period", "", 14);
	
	indicator.parameters:addGroup("ATR Calculation");    
	indicator.parameters:addInteger("81", "Period", "", 14);
	
	indicator.parameters:addGroup("MACD Calculation");    
	indicator.parameters:addInteger("91", "Fast Period", "", 12);
	indicator.parameters:addInteger("92", "Slow Period", "", 26);
	indicator.parameters:addInteger("93", "Signal Period", "", 9);
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));


    indicator.parameters:addDouble("minusX", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusY", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 


end


function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    if id <= 5 then	
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
    else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source;
local Pair={};
local  Count; 
local Type;  
local Dodaj={};   
local Point={};
local Num=9; 
local Up,  Down,Neutral ;
local minusX, minusY;  
local Indicator={};
local IndicatorList={"RSI", "SSD", "SFK", "CCI", "CMO", "DMI", "ADX", "ATR", "MACD"};
local Max={};
local Parameter={};
local Decimal={2,2,2,2,2,2,2,5,5};
local Label={};
Label[2]={"K","D"};
Label[3]={"K","D"};
Label[9]={"M","S", "H"};
Label[6]={"DI+","DI-"};

-- Routine
function Prepare(nameOnly)   
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;    
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
	source = instance.source; 
	
	  local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name); 
	if   (nameOnly) then
        return;
    end
	
	for j= 1,Num, 1 do
	Parameter[j]={};
	end
	
	Parameter[1][1]= instance.parameters:getInteger ("11");
	
    Parameter[2][1]= instance.parameters:getInteger ("21");
    Parameter[2][2]= instance.parameters:getInteger ("22");
    Parameter[2][3]= instance.parameters:getInteger ("23");	
	
	Parameter[3][1]= instance.parameters:getInteger ("31");
    Parameter[3][2]= instance.parameters:getInteger ("32");
	
	Parameter[4][1]= instance.parameters:getInteger ("41");
	Parameter[5][1]= instance.parameters:getInteger ("51");
	Parameter[6][1]= instance.parameters:getInteger ("61");
	Parameter[7][1]= instance.parameters:getInteger ("71");
	Parameter[8][1]= instance.parameters:getInteger ("81");
	
	Parameter[9][1]= instance.parameters:getInteger ("91");
    Parameter[9][2]= instance.parameters:getInteger ("92");
    Parameter[9][3]= instance.parameters:getInteger ("93");	
	
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 end
				   
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;
	end 
	
	
	local first =  source:first(); 
		
	for j = 1, Num, 1 do	

	
		  if j== 1 then
    assert(core.indicators:findIndicator(IndicatorList[j]) ~= nil, IndicatorList[j] .. " indicator must be installed");
			Temp = core.indicators:create(IndicatorList[j], source.close, Parameter[j][1] );	    
		  end
		  
		   if j== 2 then
			  Temp = core.indicators:create(IndicatorList[j], source , Parameter[j][1] , Parameter[j][2], Parameter[j][3]);	    
		  end
		  
		  if j== 3 then
			  Temp = core.indicators:create(IndicatorList[j], source , Parameter[j][1] , Parameter[j][2] );	    
		  end
		  
		   if j== 4 then
			  Temp = core.indicators:create(IndicatorList[j], source , Parameter[j][1]   );	    
		  end
		  
		  
			if j== 5 then
			  Temp = core.indicators:create(IndicatorList[j], source.close , Parameter[j][1]   );	    
		   end
		  
		   if j== 6 then
			  Temp = core.indicators:create(IndicatorList[j], source  , Parameter[j][1]   );	    
		   end
		   
		    if j== 7 then
			  Temp = core.indicators:create(IndicatorList[j], source  , Parameter[j][1]   );	    
		   end
		   
		     if j== 8 then
			  Temp = core.indicators:create(IndicatorList[j], source  , Parameter[j][1]   );	    
		   end
		   
		      if j== 9 then
			  Temp = core.indicators:create(IndicatorList[j], source.close  ,   Parameter[j][1] , Parameter[j][2], Parameter[j][3]   );	    
		   end
		  
			Max[j]= Temp:getStreamCount ();
			first=math.max(first, Temp:getStream(Max[j]-1):first()*2)+1;
	
	end
		
	
	 for i = 1, Count, 1 do	
	  
	  Indicator[i]={};
	  
	  Source[i]= core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(),first,20000 + i , 10000 +i);
	  loading [i]=true;
	  	   
     
	       for j = 1, Num, 1 do				
		    
		   if j== 1 then
			 Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i].close, Parameter[j][1] );	    
		  end
		  
		   if j== 2 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i] , Parameter[j][1] , Parameter[j][2], Parameter[j][3]);	    
		  end
		  
		  if j== 3 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i] , Parameter[j][1] , Parameter[j][2] );	    
		  end
		  
		   if j== 4 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i] , Parameter[j][1]   );	    
		  end
		  
		  
			if j== 5 then
			   Indicator [i][j]= core.indicators:create(IndicatorList[j],  Source[i].close , Parameter[j][1]   );	    
		   end
		  
		   if j== 6 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i]  , Parameter[j][1]   );	    
		   end
		   
		    if j== 7 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i]  , Parameter[j][1]   );	    
		   end
		   
		     if j== 8 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j],  Source[i]  , Parameter[j][1]   );	    
		   end
		   
		      if j== 9 then
			   Indicator [i][j] = core.indicators:create(IndicatorList[j], Source[i].close  ,   Parameter[j][1] , Parameter[j][2], Parameter[j][3]   );	    
		   end
		   
		 
		   end  		  
		
	 end 
	  

  
	 
	 instance:ownerDrawn(true); 
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
		     
			  if cookie == ( 10000 +  i) then
			  loading[i]  = true;
		      elseif  cookie == (20000+ i) then
			  loading[i]  = false;  
			  end
			  
		      
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

local top, bottom;
local left, right;
local xGap;	 
local yGap; 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode) 
	 
 end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 local Loading=false; 
	
	 
	 for i= 1, Count,1 do 		
                 if loading [i] then
				 Loading= true; 
				 end		  
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
	
			
			 context:createPen(11, context.SOLID, 1, Up); 
            context:createSolidBrush(12, Up);
			
			 context:createPen(21, context.SOLID, 1, Down); 
            context:createSolidBrush(22, Down);
		 		 			
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (bottom-top)/(Count+1);
				
 
		if xGap> 250 then
		xGap= 250;
		end
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 

            
			 Calculate (context,i, j);
		 
			end
		end
 
end	


 function Calculate (context,i, j )
   
     
	Indicator[i][j]:update(core.UpdateLast); 
	  
     if    not   Indicator[i][j]:getStream(Max[j]-1):hasData(Indicator[i][j]:getStream(Max[j]-1):size()-2)  
     then
     return;
     end
	 
	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
		y0=y1 +yGap*3/2;
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size);
		
		context:createFont (8, "Arial",iwidth, iheight , 0);
	
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size)/2;
		
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
		
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size)/3;
		
	
		context:createFont (9, "Arial",iwidth, iheight , 0);
 
		
		if j== Num then 
		width, height = context:measureText (8, Pair[i], context.CENTER  ); 
		context:drawText (8, Pair[i], Color, -1, x1, y0-height/2, x2, y0+height/2, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (8, IndicatorList[j], 0); 
		context:drawText (8,  IndicatorList[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
        

		
		if j== 2 or j== 3 or j== 6 then
			   for k=1, 2, 1 do
			   
					Value = Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1]
					Value= Label[j][k] .. ":".. string.format("%." .. Decimal[j] .. "f", Value); 
					 
					if  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] > Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then					  
					context:drawText (7, Value, Up, -1, x1+xGap, y1+yGap+yGap/2*(k-1), x2+xGap, y2+yGap+yGap/2*(k-1), context.CENTER); 
					elseif  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] < Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then
					context:drawText (7, Value, Down, -1, x1+xGap, y1+yGap+yGap/2*(k-1), x2+xGap, y2+yGap+yGap/2*(k-1), context.CENTER); 
					else		
					context:drawText (7, Value, Neutral, -1, x1+xGap, y1+yGap+yGap/2*(k-1), x2+xGap, y2+yGap+yGap/2*(k-1), context.CENTER); 
					end		
			   
			   end
		elseif  j== 9 then
		
		         for k=1, 3, 1 do
			   
					Value = Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1]
					Value= Label[j][k] .. ":".. string.format("%." .. Decimal[j] .. "f", Value); 
					 
					if  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] > Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then					  
					context:drawText (9, Value, Up, -1, x1+xGap, y1+yGap+yGap/3*(k-1), x2+xGap, y2+yGap+yGap/3*(k-1), context.CENTER); 
					elseif  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] < Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then
					context:drawText (9, Value, Down, -1, x1+xGap, y1+yGap+yGap/3*(k-1), x2+xGap, y2+yGap+yGap/3*(k-1), context.CENTER); 
					else		
					context:drawText (9, Value, Neutral, -1, x1+xGap, y1+yGap+yGap/3*(k-1), x2+xGap, y2+yGap+yGap/3*(k-1), context.CENTER); 
					end		
			   
			   end
		else 
		
		    Value = Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1];  
		    Value= string.format("%." .. Decimal[j] .. "f", Value); 
		
			if  Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1] >  Indicator[i][j].DATA[Indicator[i][j].DATA:size()-2] then					  
			context:drawText (8, Value, Up, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
			elseif  Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1] < Indicator[i][j].DATA[Indicator[i][j].DATA:size()-2] then
			context:drawText (8, Value, Down, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
			else		
			context:drawText (8, Value, Neutral, -1, x1+xGap, y1+yGap, x2+xGap, y2+yGap, context.CENTER); 
			end		
		end
	  
 end
 
 
 