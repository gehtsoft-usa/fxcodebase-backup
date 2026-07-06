-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59550

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
    indicator:name("Currency Strength");
    indicator:description("Currency Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");	

	indicator.parameters:addString("TF", "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style");	
	
	indicator.parameters:addColor("Label", "Label Color","", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("Size", "Font Size As % of Cell","", 90); 
	indicator.parameters:addBoolean("Show", "Show Score","", false)
    indicator.parameters:addBoolean("Rainbow", "Use Rainbow Coloring","", true);
	

	indicator.parameters:addInteger("Shift", "Vertical Shift ", "Shift", 25); 
	
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local offset,weekoffset;
local SourceData={};
local  TF;
local host; 
local loading={};
local Label;
local pauto =  "(%a%a%a)/(%a%a%a)";
local Bid,Ask;
local  Count=28;
local RawList={};
local ScaleList={};
local Score={};
local Temp={};
local Num={};
--local font;
local Size;
local Sorted={};
local Unsorted={};
local Number=8;


local List={"EUR/USD","GBP/USD","USD/JPY","AUD/USD","EUR/GBP","EUR/JPY","EUR/AUD",	"GBP/JPY","GBP/AUD","AUD/JPY", 
	"EUR/CHF","EUR/NZD","EUR/CAD",
	"GBP/NZD","GBP/CAD","GBP/CHF",
	"AUD/CHF",	"AUD/NZD","AUD/CAD",
	"NZD/JPY",	"CAD/JPY","CHF/JPY",
	"USD/CHF","USD/CAD","NZD/USD",
	"NZD/CAD","CAD/CHF",
	"NZD/CHF" 	 
	};

local Indexes={"USD","EUR","JPY","GBP","AUD", "NZD", "CAD",  "CHF"};
local Shift;
local Rainbow, Show;
function Prepare(nameOnly)
    Label = instance.parameters.Label;
	Rainbow = instance.parameters.Rainbow;
	Show = instance.parameters.Show;
	Shift = instance.parameters.Shift;
	Size= instance.parameters.Size;
	TF= instance.parameters.TF;
    source = instance.source;
    first = source:first();
	
	--font = core.host:execute("createFont", "Courier", Size, false, false);

	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TF) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		local j ;
		
		for j= 1, 8 , 1 do 
		Unsorted[j]={};
		Unsorted[j][1]=Indexes[j];
		Sorted[j]={};
	    end
	
	host=core.host;	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");	
	
		
	local i;
		
	for i = 1 , Count, 1 do
	
	       local Flag =  FindInstrument(List[i]);	
			 
			
			assert(   Flag , "Please Subscribe to " .. List[i] ) ;
			
			if not Flag then
			error( "Please Subscribe to " .. List[i]);
			end
			if Flag then			
			SourceData[i] = core.host:execute("getSyncHistory",List[i], TF, source:isBid(), 0, 200+i, 100+i);
			loading[i]=true;
			end
	end		
	
	
		instance:ownerDrawn(true);
end

 function FindInstrument(Instrument)
  
   
    local row, enum;   
	local Flag= false;
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
       
        if Instrument == row.Instrument then
		Flag= true;
		break;
		end
         row = enum:next(); 
    end

    return Flag;
end

function getBidAskList()
    local BID = {};
   local ASK  = {};
   local i;
   
    for i = 1, Count, 1 do	
	      
		ASK[i]= core.host:findTable("offers"):find("Instrument", List[i]).Ask;
		BID[i]= core.host:findTable("offers"):find("Instrument", List[i]).Bid;						
    end

    return BID, ASK;
end			

	-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)


  
	local Flag = false;
	
	for i = 1, Count , 1 do
		if loading[i] then
		Flag = true;
		end
	end
	
	if Flag then
	return;
	end
	
	if  not(checkReady("offers")) then
           return ;
    end
	
	 
	RawCalculate();
	Scale();
	Calculate();
	Sort();
	--Draw();
end


function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		return;
		end
      
	    local xCell = (context:right () -context:left ())/(Number+1);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 	
		
		   if Sorted[i][1] ~= nil then
			local Color;
						 
		   if Rainbow then
			Color =Coloring ((100/8)*i,50);
			else
			Color = Label;
			end

					    
			        		
			context:createFont (1, "Arial", (xCell/12)*(Size/100), yCell*(Size/100), 0);	
           
			 width, height = context:measureText (1, tostring(Sorted[i][1]), 0)			
			 context:drawText (1, tostring(Sorted[i][1]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+Shift+yCell/4, context:left ()+(i-1)*xCell + width, context:top ()+Shift+yCell/4 + height, 0);
			 
			 if Show then 
			   Value = win32.formatNumber(Sorted[i][2], false, 2);
			  width, height = context:measureText (1, tostring(Value), 0)				
		      context:drawText (1, tostring(Value), Color, -1, context:left ()+(i-1)*xCell    , context:top ()+Shift+yCell*(5/4), context:left ()+(i-1)*xCell + width, context:top ()+Shift+yCell*(5/4) + height, 0);
			 end
		 end
	 
         		 
       end
		
end



--[[
function Draw ()
local Color;
local i;

	for i = 1, 8, 1 do
			 if Rainbow then
			Color =Coloring ((100/8)*i,50);
			else
			Color = Label;
			end

		 core.host:execute("drawLabel1", i, 50 +120 *i, core.CR_LEFT, 50+Shift, core.CR_TOP, core.H_Right, core.V_Bottom, font, Color, Sorted[i][1]);
		 if Show then
		 core.host:execute("drawLabel1", i+10, 100 +120*i, core.CR_LEFT, 50+Shift, core.CR_TOP, core.H_Right, core.V_Bottom, font,Color ,string.format("%." .. 2 .. "f", Sorted[i][2] ));
		 end
	end

end]]

--function ReleaseInstance()
--       core.host:execute("deleteFont", font);
--end

function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end

function Sort()
	local i,j;
	
	 
	local Cursor;
	local Max;
	local Flag={1,1,1,1,1,1,1,1,1};
	
	 for j = 1 , 8 , 1 do
	
	Unsorted[j][1]=Indexes[j];
	Unsorted[j][2]=Temp[j]/Num[j];
    
--Sorted[j][1]=Unsorted[j][1];
--	Sorted[j][2]=Unsorted[j][2];
	end



		for  j=1,8, 1  do
					   
					 for  i=1,8, 1  do
					 
					 
							   
					
								 if i == 1 then
								 Max=-1000;
								 end
							
								if  Unsorted[i][2] > Max and Flag[i]  ~= -1 then
								Max= Unsorted[i][2];
								Cursor=i;
								end		
								
								if i== 8 then
								Sorted[j][1]	= Unsorted[Cursor][1];	   
								Sorted[j][2]	= Unsorted[Cursor][2];
								Flag[Cursor]= -1;
								end
						end
						 
			end			       
end		
		
	


function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function Calculate()

      Num={0,0,0,0,0,0,0,0,0};
	  Temp={0,0,0,0,0,0,0,0,0};
	
    local crncy1, crncy2;
    local i,j;	
	
	for i = 1 , Count , 1 do 	
	crncy1, crncy2 = string.match(List[i], pauto);
		
		for j = 1 , 8 , 1 do
	    
			if crncy1== Indexes[j] then
			Temp[j]= Temp[j]+ScaleList[i];	
			Num[j]= Num[j]+1;		
			end
			
			if crncy2== Indexes[j] then
			Temp[j]= Temp[j]+(10-ScaleList[i]);		
			Num[j]= Num[j]+1;
			end	
           	
		end
		
		
			
     end
	 
	

end

function Scale()

 
 local  i ;

	for i = 1 , Count , 1 do 
		if RawList[i] <= 0.1 then
		ScaleList[i]=1;
		elseif RawList[i] <= 0.2 then
		ScaleList[i]=2;
		elseif RawList[i] <= 0.3 then
		ScaleList[i]=3;
		elseif RawList[i] <= 0.4 then
		ScaleList[i]=4;
		elseif RawList[i] <= 0.5 then
		ScaleList[i]=5;
		elseif RawList[i] <= 0.6 then
		ScaleList[i]=6;
		elseif RawList[i] <= 0.7 then
		ScaleList[i]=7;
		elseif RawList[i] <= 0.8 then
		ScaleList[i]=8;
		elseif RawList[i] <= 0.9 then
		ScaleList[i]=9;
		elseif RawList[i] <=  1 then
		ScaleList[i]=10;	
		end
    end
end

function RawCalculate()

Bid, Ask = getBidAskList();



local  i ;

	for i = 1 , Count , 1 do 	
    RawList[i]= (Bid[i]-SourceData[i].low[ SourceData[i].low:size()-1])/(SourceData[i].high[ SourceData[i].high:size()-1]-SourceData[i].low[ SourceData[i].low:size()-1]);
	end
	


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


function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local iCount=0;	
	
	
    for j = 1, Count, 1 do
		
			  if cookie == (100 +j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  
              end
			  
		if loading[j] then
		iCount=iCount+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Count-iCount) .."/" .. Count);
		else
		core.host:execute ("setStatus","Loaded");
		 instance:updateFrom(0);	           
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
