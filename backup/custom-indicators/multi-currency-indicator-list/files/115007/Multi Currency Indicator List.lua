-- Id: 19081
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65102

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
    indicator:name("Multi Currency Indicator List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Override" );
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
	indicator.parameters:addString("TF",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
    indicator.parameters:addGroup("CCI Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "Period", 10);
	indicator.parameters:addGroup("RSI Calculation"); 
	indicator.parameters:addInteger("Period2", "Period", "", 14);
	
	
	indicator.parameters:addGroup("MA Calculation"); 
	indicator.parameters:addInteger("Period3", "Period", "", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("LabelSize", "Font Size (As % of Cell)", "", 80, 0, 100);
	indicator.parameters:addInteger("HSize", "Horizontal Output Size (As % of Screen)", "", 50, 0, 100);
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 50, 0 , 10000);
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Color of Up", "Label Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Label Color", core.rgb(255, 0, 0));
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
local Period1;
local Period2;
local Period3;
local Method;

local Type;
local Dodaj={};   

local first;
local source = nil;
local loading={};
 
local TF;
local Label;
local SourceData={};
local Indicator={};
local Shift, FSize;
local host;
local offset;
local weekoffset;

local HSize;


local CountX=6;
local CountY;  

local Pair={};
local Count={};
--local Point={};
local Digits={};

local CCI={};
local RSI={};
local hMA={};
local lMA={};
local cMA={};

local LabelText={"CCI", "RSI", "MA(high)", "MA(low)", "MA(close)", "Close"};

local Up, Down;
-- Routine
function Prepare(nameOnly)   

	Type= instance.parameters.Type;	 
	Shift = instance.parameters.Shift;
	FSize = instance.parameters.FSize;
	Label = instance.parameters.Label;
	LabelSize = instance.parameters.LabelSize;
	HSize = instance.parameters.HSize;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;  
	
	TF = instance.parameters.TF;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Method= instance.parameters.Method;
	
	
    source = instance.source;
    first = source:first();
	
	 local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
		if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 --Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 Digits[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).Digits;  
					 end
				   
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Digits = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			  -- Point[1]=source:pipSize ();
			   Digits[1]=source:getPrecision();
			   Count=1;
	end
	
	CountY=Count;
	
	local i;
	
	
	for i = 1, Count, 1 do
	SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF, source:isBid(), math.min(300,first*2), 200+i, 100+i);
	loading[i]= true;
	
	CCI[i]=  core.indicators:create("CCI", SourceData[i] ,  Period1);  	
    RSI[i]=  core.indicators:create("RSI", SourceData[i].close ,  Period2);  		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	hMA[i]=  core.indicators:create(Method, SourceData[i].high ,  Period3);  		
	lMA[i]=  core.indicators:create(Method, SourceData[i].low ,  Period3);  		
	cMA[i]=  core.indicators:create(Method, SourceData[i].close ,  Period3);  		
	end

   
	
	 core.host:execute ("setTimer", 1, 1);
	
	instance:ownerDrawn(true);

   
end

 local init = false;


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	
	

end
function Draw(stage, context)

   if stage  ~= 2 then
	return;
	end
	

         if not init then
		 transparency = context:convertTransparency(instance.parameters.transparency); 
		   init = true;
         end

	local i, j;
	
	local FLAG=false;
	
	for i = 1, Count, 1 do
	   if loading[i] then
	   FLAG= true;
	   end
	end
	
	
	  
	
	if FLAG   then	
	return;	
	end
	
 
	
		
        for j= 1, CountY,1 do   
			 for i= 1, CountX,1 do 
         			 
			 DrawLabel (context,i, j); 
			 end
         end
	
	
 

end

function DrawLabel(context,i, j)

	
	top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
   
    xGap= (( (right-left)/100)*HSize)/(CountX);	 
    yGap=  (bottom-(top+Shift))/(CountY+2);
	
	
       y1=top +(j+1)*(yGap); 
	   y0=top +(j)*(yGap);
 
		
		x1=left +(i)*xGap;
		x0=left +(i-1 )*xGap; 
		
		
		iwidth = ((xGap/10)/100)*LabelSize ;
		iheight=  (yGap/100)*LabelSize;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
 
		
		if j== 1 then 
		width, height = context:measureText (7, LabelText[i], context.CENTER  ); 
		context:drawText (7, LabelText[i], Label, -1, x1, y0+Shift-height , x1+width, y0+Shift, context.CENTER, 0);
		end
		
	 
	 
		
		local Color=nil;
		
		  if i== 1 and CCI[j].DATA:hasData(CCI[j].DATA:size()-1) then
		  Text = win32.formatNumber(CCI[j].DATA[CCI[j].DATA:size()-1], false, 2);		  
			  if CCI[j].DATA[CCI[j].DATA:size()-1] > CCI[j].DATA[CCI[j].DATA:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end 		  
		  elseif i== 2 and RSI[j].DATA:hasData(RSI[j].DATA:size()-1) then
		  Text = win32.formatNumber(RSI[j].DATA[RSI[j].DATA:size()-1], false, 2);
		    if RSI[j].DATA[RSI[j].DATA:size()-1] > RSI[j].DATA[RSI[j].DATA:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end 	 
		  elseif i== 3 and hMA[j].DATA:hasData(hMA[j].DATA:size()-1) then
		  Text = win32.formatNumber(hMA[j].DATA[hMA[j].DATA:size()-1], false, Digits[j]);
		      if hMA[j].DATA[hMA[j].DATA:size()-1] > hMA[j].DATA[hMA[j].DATA:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end 
			  
          elseif i== 4 and hMA[j].DATA:hasData(hMA[j].DATA:size()-1) then		  
		  Text = win32.formatNumber(lMA[j].DATA[lMA[j].DATA:size()-1], false, Digits[j]);
		      if lMA[j].DATA[lMA[j].DATA:size()-1] > lMA[j].DATA[lMA[j].DATA:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end      
		  elseif i== 5 and hMA[j].DATA:hasData(hMA[j].DATA:size()-1) then
		  Text = win32.formatNumber(cMA[j].DATA[cMA[j].DATA:size()-1], false, Digits[j]);
		      if cMA[j].DATA[cMA[j].DATA:size()-1] > cMA[j].DATA[cMA[j].DATA:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end 
		  elseif i== 6 and SourceData[j].close:hasData(SourceData[j].close:size()-1) then
		   Text = win32.formatNumber(SourceData[j].close[SourceData[j].close:size()-1], false, Digits[j]);
		      if SourceData[j].close[SourceData[j].close:size()-1] > SourceData[j].close[SourceData[j].close:size()-2] then
			  Color=Up;
			  else
			  Color=Down;
			  end 
		  end
		  
		  if Color~= nil then		  
          width, height = context:measureText (7, tostring(Text), context.CENTER  ); 
		  context:drawText (7, tostring(Text), Color, -1, x1, y1+Shift-height , x1+width, y1+Shift, context.CENTER, 0);
		  end
		  
		 if i== 1 then		 
		 width, height = context:measureText (7, Pair[i], context.CENTER  ); 
		 context:drawText (7, Pair[j], Label, -1, x0, y1+Shift-height , x0+width, y1+Shift, context.CENTER, 0);
         end		 
	 
		
end--pair
 


function getInstrumentList()
    local list={};
	local digi={};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		digi[count]=  row.Digits;  
        row = enum:next();
    end

    return list, count,digi;
end



function AsyncOperationFinished(cookie)

   local i;
   local ItIs=false;
   local Num=0;
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  Num=Num+1;
			  ItIs=true;
		      elseif  cookie == 200+i then
			  loading[i] = false;  
			  end
		  
	end    
	
	
	 
   if cookie== 1 and  not ItIs then
		for j = 1, Count, 1 do
	    RSI[j]:update(core.UpdateLast );   
        CCI[j]:update(core.UpdateLast );
		hMA[j]:update(core.UpdateLast );
		lMA[j]:update(core.UpdateLast );
		cMA[j]:update(core.UpdateLast );
		end    
	end
	
   
   if not ItIs then
   instance:updateFrom(0);
   core.host:execute ("setStatus", "");
   else
    core.host:execute ("setStatus", "  Loading "..((Count) - Num) .. " / " .. (Count) );	 
   end
   
  
   
        
     return core.ASYNC_REDRAW;
end
