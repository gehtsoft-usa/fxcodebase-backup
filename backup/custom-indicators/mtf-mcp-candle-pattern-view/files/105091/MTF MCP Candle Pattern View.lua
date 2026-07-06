-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63210

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
    indicator:name("MTF MCP Candle Pattern View");
    indicator:description("MTF MCP Candle Pattern View");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
  
  
   indicator.parameters:addGroup("Doji Calculation");	 
   indicator.parameters:addInteger("Delta", "Open/Close difference (% of body length)", " ", 5);
	indicator.parameters:addInteger("Wick", "Dragonfly / Gravestone Doji max. Wick Size(% of body length)", " ", 5);
	--indicator.parameters:addInteger("Trend", "Trend Period", " ", 1);
	
	
	indicator.parameters:addGroup("Hammer/Hanging Man Calculation");	
	indicator.parameters:addDouble("Ratio", "Minimal Lower Shadow / Body  Ratio", "Minimal Lower Shadow / Body  Ratio", 2);
	indicator.parameters:addDouble("Upper", "Minimal Body / Upper Shadow  Ratio", "Minimal Body / Upper Shadow  Ratio", 10);
	indicator.parameters:addBoolean("Body", "Use Body orientation Filter ", "", false);
	indicator.parameters:addBoolean("Reversal", "Use Trend Reversal Filter ", "", true);
	 indicator.parameters:addInteger("Period", "Trend Reversal Filter Period", "Trend Reversal Filter Period", 5);
	
	
 
	
   indicator.parameters:addGroup("Selector");	 
	indicator.parameters:addString("Live", "Live/End Of Turn", "Live/End Of Turn" , "Live");
    indicator.parameters:addStringAlternative("Live", "Live", "Live" , "Live");
    indicator.parameters:addStringAlternative("Live", "End Of Turn", "End Of Turn" , "End Of Turn");
    
    indicator.parameters:addBoolean("bidask", "Bid/ask", "", false);
    indicator.parameters:setFlag("bidask", core.FLAG_BIDASK);

	for i= 1 ,10, 1 do
        indicator.parameters:addGroup(i..". Currency Pair ");
        Add(i);
	end
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m1", false );
	AddTimeFrame (2 , "m5" , false );
	AddTimeFrame (3 , "m15", false );
	AddTimeFrame (4 , "m30" , false  );
	AddTimeFrame (5 , "H1" , true );
	AddTimeFrame (6 , "H2", false );
	AddTimeFrame (7 , "H3" , false );
	AddTimeFrame (8 , "H4", false );
	AddTimeFrame (9 , "H6" , false  );
	AddTimeFrame (10 , "H8" , true );
    AddTimeFrame (11 , "D1", true );
	AddTimeFrame (12 , "W1" , true );
	AddTimeFrame (13 , "M1", true );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);

    indicator.parameters:addDouble("minusY", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusX", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
end

function AddTimeFrame(id , FRAME , DEFAULT  )
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
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

local Delta, Wick,Trend;
local Ratio, Upper, Body, Reversal, Period;

local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local TF={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source;
local Pair={};
local  Count;  
local Dodaj={};   
local Point={};
local Use={};
local Num; 
local Up,  Down,Neutral ;
local minusX, minusY;  
local Live;
local Height;

local High={};
local Low={};
local Close={};
local Open={};
local SignalLong={};
local SignalShort={};
local HISTORY_LOADING_ID = 1000;

local MaxCount=5;
local Long={"Three White Soldiers (+)" ,"Bullish Three Outside (+)", "Bullish Three Inside (+)", "Dragonfly Doji (+)", "Hammer (+)" };
local Short={"Three Black Crows (-)","Bearish Three Outside (-)", "Bearish Three Inside (-)", "Gravestone Doji (-)", "HangingMan (-)"};

 
 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Delta= instance.parameters.Delta;
	Wick= instance.parameters.Wick;
	
	
	Ratio= instance.parameters.Ratio;
	Upper= instance.parameters.Upper;
	Body= instance.parameters.Body;
	Reversal= instance.parameters.Reversal;
	Period= instance.parameters.Period;

  
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;   
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	Live= instance.parameters.Live;
	Height= instance.parameters.Height;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
 
        Count=0;
        for i= 1, 20 , 1 do	 
            Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
            if Dodaj[i] then
                Count=Count+1;
                Pair[Count]=   instance.parameters:getString ("Pair"..i);	
                Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
            end
        end

	 
	Num=0;
    for i = 1 , 13 , 1 do  
        Use[i]=instance.parameters:getBoolean("Use" .. i);

        if Use[i] then
            Num=Num+1;
            TF[Num]=  iTF[i];	
        end
    end
 
    local ID=0;
    if not nameOnly then
        for i = 1, Count, 1 do
            Source[i] ={};
			High[i]={};
			Low[i]={};
			Close[i]={};
			Open[i]={};
            loading[i] ={}; 
			SignalLong[i] ={}; 
			SignalShort[i] ={}; 
            for j = 1, Num, 1 do
			    SignalLong[i][j] ={}; 
			    SignalShort[i][j] ={}; 
                ID = ID + 1;  
                Source[i][j] = core.host:execute("getHistory", HISTORY_LOADING_ID + ID, Pair[i], TF[j], 0, 0, instance.parameters.bidask);
				High[i][j]=Source[i][j].high;
				Low[i][j]=Source[i][j].low;
				Close[i][j]=Source[i][j].close;
				Open[i][j]=Source[i][j].open; 				
                loading[i][j] = true;
            end
        end
    end

    
    instance:ownerDrawn(true); 
    core.host:execute("subscribeTradeEvents", 999, "offers");
    instance:initView("Dashboard", 0, 1, instance.parameters.bidask, true);
    
    open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0);
    open:setVisible(false);
	
	core.host:execute ("setTimer", 1111, 10);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)



    if cookie== 1111 then 
	  for i= 1, Count,1 do 	
        for j= 1, Num,1 do  
         FindPattern(i,j); 
		end 
	  end
	end	
	 
    if cookie >= HISTORY_LOADING_ID then
        local i;
        local ID = 0;

        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                ID = ID + 1;
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i][j] = false;
                end
            end
        end

        local FLAG=false; 
        local Number=0;
        
        for i = 1, Count, 1 do
            for j = 1, Num, 1 do
                if loading[i][j] then
                    FLAG = true;
                    Number=Number+1;
                end
            end
        end
        
        if FLAG then
            core.host:execute ("setStatus", "Loading ".. (Count*Num - Number) .. " / " ..  Count*Num );	 
        else
            core.host:execute ("setStatus", "Loaded") 
            for i = 0, Source[1][1]:size() - 1 do
                instance:addViewBar(Source[1][1]:date(i));
               
            end
        end
       
        return core.ASYNC_REDRAW;
    elseif cookie == 999 then
        local Loading = false; 
        for i = 1, Count, 1 do 
            for j = 1, Num, 1 do 
                if loading[i][j] then
                    Loading = true; 
                end
            end 
        end
    end
end

local top, bottom;
local left, right;
local xGap;	 
local yGap;
local MaxYHeight;
local IndexMax=4;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
    --shoudn't be called
end

local init = false; 
function Draw(stage, context)
	if stage ~= 2 then
        return;
	end
	
	local Loading=false;
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
            if loading [i][j] then
            Loading=true;      
            end
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
		
		  context:createPen(1, context.SOLID, 1, Color); 
		
		transparency = context:convertTransparency(instance.parameters.transparency);
                        
        init = true;
    end
		
	    
    
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
   
    xGap=  (right-left)/(Num+1);	 
    yGap=  (bottom-top)/(Count+1);
            
  
    
    
    for i= 1, Count,1 do 	
        for j= 1, Num,1 do  
         --FindPattern(i,j);  		
         Calculate (context,i, j); 
        end
    end

end	

function FindPattern(i,j)

for k= 1, MaxCount, 1 do
SignalLong[i][j][k]= false;
SignalShort[i][j][k]= false;
end

local period=Source[i][j].close:size()-1;

if Live~= "Live" then
period=period-1;
end

p0=period;
p1=period-1;
p2=period-2;
p3=period-3;



--Three White Soldiers
 

if Close[i][j][p0]>  Open[i][j][p0]
and Close[i][j][p1]>  Open[i][j][p1]
and Close[i][j][p2]>  Open[i][j][p2]
and Range(  High[i][j][p0] , Low[i][j][p0],  Close[i][j][p0])> 75
and Range(  High[i][j][p1] , Low[i][j][p1],  Close[i][j][p1])> 75 
and Range(  High[i][j][p2] , Low[i][j][p2],  Close[i][j][p2])> 75 
then
SignalLong[i][j][1]= true;
end 

--Three Black Crows 
 
if Close[i][j][p0]<  Open[i][j][p0]
and Close[i][j][p1]<  Open[i][j][p1]
and Close[i][j][p2]<  Open[i][j][p2]
and Range(  High[i][j][p0] , Low[i][j][p0],  Close[i][j][p0])< 25
and Range(  High[i][j][p1] , Low[i][j][p1],  Close[i][j][p1])< 25 
and Range(  High[i][j][p2] , Low[i][j][p2],  Close[i][j][p2])< 25
then
SignalShort[i][j][1]= true;
end 



 
     --BullishThreeOutsideBullishThreeOutside
     if Close[i][j][p0]< Open[i][j][p0]
	 and Close[i][j][p1] >  High[i][j][p0]
	 and Close[i][j][p2] >  High[i][j][p1]
	 then
	 SignalLong[i][j][2]= true
	 end
	 
    --BearishThreeOutside
	 if Close[i][j][p0]> Open[i][j][p0]
	 and Close[i][j][p1] <  Low[i][j][p0]
	 and Close[i][j][p2] < Low[i][j][p1]
	 then
	 SignalShort[i][j][2]= true
	 end
	 
	 --BullishThreeInside
	if Close[i][j][p0]< Open[i][j][p0]
	and High[i][j][p1] <=  High[i][j][p0]
	and Low[i][j][p1] >=  Low[i][j][p0]
	and Close[i][j][p2] >  High[i][j][p1]
	then
	SignalLong[i][j][3]= true
	end
	 
     --BearishThreeInside
	if Close[i][j][p0]> Open[i][j][p0]
	and High[i][j][p1] <=  High[i][j][p0]
	and Low[i][j][p1] >=  Low[i][j][p0]
	and Close[i][j][p2] < Low[i][j][p1]
	then
	SignalShort[i][j][3]= true
	end

	

	local Percentage = (High[i][j][p0]- Low[i][j][p0])/100;
	local Diff = (Open[i][j][p0]- Close[i][j][p0]) / Percentage ;
	
	
	 if  ( High[i][j][p0] - math.max (Open[i][j][p0] ,Close[i][j][p0] )) / Percentage    <  Wick then
	SignalLong[i][j][4]= true
								     
	elseif  (  math.min (Open[i][j][p0] ,Close[i][j][p0] ) -Low[i][j][p0] ) / Percentage    <  Wick then
	SignalShort[i][j][4]= true
	end
	
	FindHammerHangingMan(i,j, p0, p1,p2, p3)
 

end


function FindHammerHangingMan(i,j,p0, p1,p2, p3)

	if  (math.abs(Open[i][j][p0] -Close[i][j][p0]) * Ratio)  > (math.min(Open[i][j][p0], Close[i][j][p0]) -  Low[i][j][p0])  then
	return;
	end
	
	
	if  (math.abs(Open[i][j][p0] -Close[i][j][p0]) )  < ((   High[i][j][p0] - math.max(Open[i][j][p0], Close[i][j][p0])) *Upper )  then
	return;
	end
	
	FindHammer    (i,j,p0, p1,p2, p3);
    FindHangingMan(i,j,p0, p1,p2, p3);
	
end
 
function FindHammer(i,j,p0, p1,p2, p3)

    if Body and Close[i][j][p0] <  Open[i][j][p0]  then
	return;
	end
	
	
	if Reversal then

		local Flag = TEST(i,j,p0, true);
		 
		 
	end
	
	if Flag==0 or Flag == true then
	return;
	end
	
	SignalLong[i][j][5]= true;

end


function FindHangingMan(i,j, p0, p1,p2, p3) 

    if Body and Close[i][j][p0] >  Open[i][j][p0]  then
	return;
	end
	
	
	if Reversal then

		local Flag = TEST(i,j, p0, false);
		 
		 
	end
	
	if Flag==0 or Flag == true then
	return;
	end
	
	SignalShort[i][j][5]= true;
		
end

function TEST (i,j ,p0, Side )



 


 local FLAG= false;
 
   for k = 0, Period,  1 do
   
         
					if Side then
						 
						 if Source[i][j]:hasData(p0-k) 
						 and Source[i][j]:hasData(p0) 
						 then  
						  
							 if Low[i][j][p0] > Low[i][j][p0-k] then
							 FLAG= true;
							 end
						else 

						  FLAG= 0;			
							 
						 end
					
					else 
					
						if Source[i][j]:hasData(p0-k) 
						 and Source[i][j]:hasData(p0) 
						then  
							 if High[i][j][p0] < High[i][j][p0-k] then
							 FLAG= true;
							 end
						 else
						 FLAG= 0;			
						 end
					
					end		   
   
   end


return FLAG;
end



function Range(  Value1, Value2, Value3)
local Percentage= math.abs(Value1 - Value2)/100;
local Return= ((Value3 - math.min ( Value1, Value2))/Percentage);
return Return;

end

 function Calculate (context,i, j )
   
     
	 
     if  not Source[i][j].close:hasData(Source[i][j].close:size()-1)   
     then
     return;
     end
	  
	
	    y1=bottom -(i)*yGap;
		y2=bottom -(i-1 )*yGap;
		
 
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		xMid=x2-(x2-x1)/2
		
		
		iwidth = ((xGap/9)/100)*Size ;
		iheight=  (yGap/100)*Size;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
 
		
		if j== Num then 
		width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		context:drawText (7, Pair[i], Color, -1, x1, y1 , x1+width, y1+height, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap  , y1-yGap ,x2+xGap ,  y1-yGap+height , context.CENTER   );	 
		end
   
       AddNew(context,i, j, x1+xGap, x2+xGap, y1, y2);
	 
 end
 
 function AddNew(context,i, j, X1, X2, Y1, Y2)
 
       context:drawLine (1, X1, Y1, X2, Y1, 0);
	   context:drawLine (1, X1, Y1, X1, Y2, 0);
	   context:drawLine (1, X2, Y1, X2, Y2, 0);
	   context:drawLine (1, X1, Y2, X2, Y2, 0);
	   
	    local subxGap=(X2-X1);
	    local subyGap=(Y2-Y1);
	    iwidth =((subxGap/20)/100)*Size ;
		iheight=((subyGap/4)/100)*Size;
        context:createFont (8, "Arial",iwidth, iheight , 0);
		
 		local period= Source[i][j].close:size()-1;
		local min, max=mathex.minmax(Source[i][j], period-IndexMax+1, period);
		local Range= (max-min)/Point[i];
		
		
	    for Index= 1, IndexMax, 1 do		
		AddCandle(context,i, j ,Index, X1, X2, Y1, Y2, Range,Source[i][j].open[period-IndexMax+1]);
		end
		
		
		local SignalCount=0;

		
		for w= 1 , MaxCount, 1 do
			if SignalLong[i][j][w] then
			SignalCount=SignalCount+1;
			Value = Long[w]; 	    
			width, height = context:measureText (8, Value, 0);  
			context:drawText (8, Value, Color, -1, X1 , Y1+(SignalCount-1)*height , X1+width, Y1+(SignalCount-1)*height+height, context.LEFT); 
			end
			
			if SignalShort[i][j][w] then 
			SignalCount=SignalCount+1;
			Value = Short[w]; 
			width, height = context:measureText (8, Value, 0);  
			context:drawText (8, Value, Color, -1,X1 , Y1+(SignalCount-1)*height , X1+width, Y1+(SignalCount-1)*height+height, context.LEFT); 		
			end 	
			
		end		
		
	
									   
 end
 
 function AddCandle(context,i, j ,Index, X1, X2, Y1, Y2, Range,iOpen) 
 
 
        local subGap=(X2-X1)/IndexMax;
        local x1=X2-(Index)*subGap +subGap*minusX;
		local x2=X2-(Index-1)*subGap - subGap*minusX; 		
		y1=Y1;
		y2=Y2;	
		
		period= (Source[i][j].close:size()-1)-Index+1;
		
 
        local High=Source[i][j].high[period ];
		local Low=Source[i][j].low[ period];
		local Close=Source[i][j].close[ period];
		local Open=Source[i][j].open[ period];
		
			
		MaxYHeight=-math.abs((y1-y2)/2)*(1-minusY);  
		
		
		cHeight=MaxYHeight*((( Close - iOpen)/Point[i])/ Range);
		oHeight=MaxYHeight*((( Open - iOpen)/Point[i])/ Range);
		hHeight=MaxYHeight*((( High - iOpen)/Point[i])/ Range);
		lHeight=MaxYHeight*(((Low - iOpen)/Point[i])/ Range);
		
		yMid=y2-(y2-y1)/2
		xwl=x1 +subGap/3;
		xwr=x2 -subGap/3;
		
		yh=(yMid+hHeight); -- H
        yl=(yMid+lHeight); --L	
		
        yc=(yMid+cHeight); --C 
		yo=(yMid+oHeight); --C 									 
												
		                                     if Close > Open then 
													Code1=11;
													Code2=12;  
											       if math.abs(yo-yc)< 2 then
												   yc=yo+2;
												   end
                                                context:drawRectangle( Code1,  Code2,x1, yc, x2, yo, transparency);	--C	
                                                context:drawRectangle (Code1,  Code2, xwl,  yh                 , xwr,  yc , transparency);	 --H 
		                                         context:drawRectangle (Code1,  Code2, xwl,  yo             ,  xwr,  yl , transparency);   --L 												
											  else
												   Code1=21;
												   Code2=22;	 
												  
                                                  if math.abs(yo-yc)< 2 then
												   yc=yo-2;
												   end												  
												    
												   
											    context:drawRectangle( Code1,  Code2,x1, yo, x2, yc, transparency);	--C			
												context:drawRectangle (Code1,  Code2, xwl,  yh             , xwr,  yo , transparency);	 --H 
		                                        context:drawRectangle (Code1,  Code2, xwl,  yc              , xwr,  yl , transparency);   --L
											  end	
 
 
 end
 
 