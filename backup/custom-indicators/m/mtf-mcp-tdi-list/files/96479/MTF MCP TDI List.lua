-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61317

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
    indicator:name("Multi Period Multi Time Frame Multi Currency Pair Traders dynamic index List");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation"); 
 
	indicator.parameters:addBoolean("Both", "Majors Only", "", true); 
	
	indicator.parameters:addGroup(" Date Selector (If Majors Only is Set to Yes)");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
	 
	indicator.parameters:addGroup("Time Frame Selector"); 
 
	AddTF(1, "m1"  );
	AddTF(2, "m5"  );
	AddTF(3, "m15"  );
	AddTF(4, "m30"  );
	AddTF(5, "H1"  );
	
	AddTF(6, "H2"  );
	AddTF(7, "H3"  );
	AddTF(8, "H4"  );
	AddTF(9, "H6"  );
	AddTF(10, "H8"  );
	
	
	AddTF(11, "D1"  );
	AddTF(12, "W1"  );
	AddTF(13, "M1"  );
 
	
	indicator.parameters:addGroup("TDI Calculation"); 
    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
	
	indicator.parameters:addDouble("BUYEXITLEVEL", "BUY EXIT LEVEL", "", 70, 0, 100);
	indicator.parameters:addDouble("SELLEXITLEVEL", "SELL EXIT LEVEL", "", 30, 0, 100);
	indicator.parameters:addDouble("BUYENTRYLEVEL", "BUY ENTRY LEVEL", "", 50, 0, 100);
	indicator.parameters:addDouble("SELLENTRYLEVEL", "SELL ENTRY LEVEL", "", 50, 0, 100);

	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",25, 0, 100);
	
 
  
end


function AddTF(id, TF) 
indicator.parameters:addBoolean("Use".. id, "Use " .. TF.. "  Time Frame", "", true);

 
end

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local RSI_N, VB_N, VB_W, RSI_P_N, RSI_P_M, TS_N, TS_M;
local TF={};
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local first;
local source = nil; 
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)"; 
local  Size;
local id; 
	local host;
	local offset;
	local weekoffset;
local Color,Up,Down;
local iNum={};
local Both;
local Indicator={};
local VSpace;

local Num;
local 	BUYEXITLEVEL;
local 	SELLEXITLEVEL;
local 	BUYENTRYLEVEL;
local 	SELLENTRYLEVEL;
local Shift=50;	
-- Routine
function Prepare(nameOnly)

    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
    Size = instance.parameters.Size;
	Both = instance.parameters.Both; 
	Color = instance.parameters.Color;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	VSpace=1+(instance.parameters.VSpace/100);
	
	RSI_N = instance.parameters.RSI_N;
	VB_N = instance.parameters.VB_N
	VB_W = instance.parameters.VB_W
	RSI_P_N = instance.parameters.RSI_P_N
	RSI_P_M = instance.parameters.RSI_P_M
	TS_N = instance.parameters.TS_N
	TS_M = instance.parameters.TS_M;
	
	SELLEXITLEVEL = instance.parameters.SELLEXITLEVEL;
    BUYEXITLEVEL = instance.parameters.BUYEXITLEVEL;
    BUYENTRYLEVEL = instance.parameters.BUYENTRYLEVEL;
    SELLENTRYLEVEL = instance.parameters.SELLENTRYLEVEL;
	

	
	Num=0;
	for i= 1,13   , 1 do
		if   instance.parameters:getBoolean("Use" .. i) then
		Num=Num+1;
		TF[Num]=iTF[i] 
		end
	end
	

	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	

	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	 

	local FLAG= false;
	Count=0;
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j); 
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   for j = 1, 8 , 1 do
		   
		   
		   
			 if not Both
			 or ( (Check(crncy1) and (Check(crncy2)) ) and Both)			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end
	
	assert(core.indicators:findIndicator("TRADERSDYNAMICINDEX") ~= nil, "Please, download and install TRADERSDYNAMICINDEX.LUA indicator");

	 id = 0;
	 
	for i = 1, Count, 1 do
	SourceData[i]={};
	loading[i]={};
	Indicator[i]={};
		  for j= 1 , Num, 1 do
		
		  id=id+1;
		  
		   Temp= core.indicators:create("TRADERSDYNAMICINDEX", source.close,RSI_N, VB_N, VB_W, RSI_P_N, RSI_P_M, TS_N, TS_M);
		   
		  SourceData[i][j] = core.host:execute("getSyncHistory", List[i],TF[j], source:isBid(), math.min(300,math.max(Temp:getStream(3):first(), Temp:getStream(4):first(), Temp:getStream(0):first(), Temp:getStream(3):first(1), Temp:getStream(2):first())) , 2000+id , 1000+id);		  
		  loading[i][j] = true;
				 
		  Indicator[i][j]= core.indicators:create("TRADERSDYNAMICINDEX", SourceData[i][j].close,RSI_N, VB_N, VB_W, RSI_P_N, RSI_P_M, TS_N, TS_M);
				 
		  end
	end
	
	 
	  instance:ownerDrawn(true);
	  	  core.host:execute ("setTimer", 1, 1);

end


 function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



function Check(Find)
 local FLAG= false;
            for j = 1, 8 , 1 do
			 if  (Find==Pair[j] and On[j])then
			 FLAG= true;
			 end
		   end 
return FLAG;		   
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


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	   local FLAG=false; 
 
	 
	
	for i = 1, Count, 1 do
	    for j = 1, Num, 1 do
	             if loading[i][j] then
				 FLAG= true; 
				 end
		end		 
	end
	
	
		
	if FLAG then
	return;
	end
	
	
	 local iSize = context:pointsToPixels( Size);
	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
 
	 
  
	
	
        if not init then
          
			context:createFont(1, "Arial",  Size,  Size, context.NORMAL);
			context:createFont(2, "Wingdings",  Size,  Size, context.BOLD);
			
			context:createSolidBrush(11, Color); 
            context:createSolidBrush(21, Up);
            context:createSolidBrush(31, Down);  			
  			
	        context:createPen (12, context.SOLID, 1, Color);
            context:createPen (22, context.SOLID, 1, Up);
			context:createPen (32, context.SOLID, 1, Up);			 

            init = true;
        end
		
		
		   
		local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 width, height = context:measureText (1, "X", style)		
     local width1=Size*10;
     local height1= height*VSpace; 
	 local VS=(Size*VSpace);
	 
     for i= 1, Count , 1 do 
     	 
	
     
	   x11=context:left()+25   ;
	   y11=context:top()+Shift+ height1*i +VS*i+height1*2;
	   x12=context:left()+ 25+  width1 ;
	   y12=context:top()+Shift+height1*(i+1)+VS*i+height1*2;        
	 context:drawText (1, List[i], Color, -1, x11, y11, x12,y12, style) ;	 
	 
			 for j= 1, Num ,1 do
			       x21= x12 + (j-1)*iSize*4 + iSize*3;
				   x22= x12 +(j)*iSize*4  +iSize*3 ;
				   if i== 1 then
			       context:drawText (1, TF[j], Color, -1, x21, y11-height1*3, x22,y12-height1*2, style) ;	
				   end
				    
				
                        
                      Add( context,i,j , y11,x21,  x22 )						
				  end	
			end
	 
	 end
	 
	

 


function Add( context,i,j, y11,x21,  x22 )	

 local style = context.SINGLELINE + context.CENTER + context.VCENTER;
 
 if     Indicator[i][j]:getStream(0):hasData( Indicator[i][j]:getStream(0):size()-1)
 and     Indicator[i][j]:getStream(1):hasData( Indicator[i][j]:getStream(1):size()-1)
 and  Indicator[i][j]:getStream(2):hasData( Indicator[i][j]:getStream(2):size()-1)
 and  Indicator[i][j]:getStream(3):hasData( Indicator[i][j]:getStream(3):size()-1) 
  and  Indicator[i][j]:getStream(4):hasData( Indicator[i][j]:getStream(4):size()-1) 
 then
  
 local PRICELINE = Indicator[i][j]:getStream(0)[ Indicator[i][j]:getStream(0):size()-1];
 local UPPERBAND = Indicator[i][j]:getStream(1)[ Indicator[i][j]:getStream(1):size()-1];
 local LOWERBAND = Indicator[i][j]:getStream(2)[ Indicator[i][j]:getStream(2):size()-1];
 local BASELINE = Indicator[i][j]:getStream(3)[ Indicator[i][j]:getStream(3):size()-1];
  local SIGNALLINE = Indicator[i][j]:getStream(4)[ Indicator[i][j]:getStream(4):size()-1];
  
 
	 local Flag=0;
	 
	
   if PRICELINE> SIGNALLINE and SIGNALLINE >BASELINE
   and BASELINE> BUYENTRYLEVEL
	and  PRICELINE < UPPERBAND
	and PRICELINE < BUYEXITLEVEL
	then
	Flag=1;
	elseif PRICELINE< SIGNALLINE and SIGNALLINE <BASELINE
	and BASELINE< SELLENTRYLEVEL
	and PRICELINE > LOWERBAND
	and  PRICELINE > SELLEXITLEVEL 
	then
	Flag=-1;
	else
	Flag=0;
	end
	 
	 
	  if Flag== 1 then
	  context:drawText (2, "\217", Up, -1, x21, y11 , x22, y11+ height, style) ;
	  elseif Flag==-1 then
	  context:drawText (2, "\218", Down, -1, x21, y11 , x22, y11+ height, style) ;
	  else
	    context:drawText (2, "\149", Neutral, -1, x21, y11 , x22, y11+ height, style) ;
	  end
  
 else
 
  context:drawText (2, "\149", Neutral, -1, x21, y11 , x22, y11+ height, style) ;
 end
 
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	

end	

 
function   Initialization(period,i,j)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[i][j] or SourceData[i][j]:size() <= 0  then
        return false;
    end
	
	
    
    if period <= source:first()+Period then
        return false;
    end

    local P = core.findDate(SourceData[i], Candle, true);
	 

    if P < 0 	
	or SourceData[i][j].close:first()  >= P
    or SourceData[i][j].close:size()<= P
    then
        return false;
	end
	 
	return P;	 
end	

 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
    local FLAG=false; 
	local Number=0;
    local id=0;
	
    for i = 1, Count, 1 do
		 for j = 1, Num, 1 do
		      id=id+1;
			  
			  if cookie == 1000+id then
			  loading[i][j] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 2000+id then
			  loading[i][j] = false;  
			
			  end
		 end 
	end    
	
	if not FLAG and cookie==1 then
		for i = 1, Count, 1 do
	 
		  for j= 1 , Num, 1 do
		 
				  Indicator[i][j]:update(core.UpdateLast );
				
	      end
	      end 
	
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*Num - Number) .. " / " .. Count*Num );
    else
	 core.host:execute ("setStatus",    "Loaded" );
     	instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end
 