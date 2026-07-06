-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25257

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
    indicator:name("MTF MCP MI List");
    indicator:description("MTF MCP MI List");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "All currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
	
	
	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");

	AddCurrencyPair (i );
	
	end
	
	indicator.parameters:addGroup("Time Frame Selector");	
	AddTimeFrame (1 , "m30", true );
	AddTimeFrame (2 , "H1" , true );
	AddTimeFrame (3 , "H4", true );
	AddTimeFrame (4 , "H8" , false );
	AddTimeFrame (5 , "D1" , false );
	

	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));  
	indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("No", "Neutral Color", "Neutral Color", core.rgb(0, 0, 255)); 
 
	indicator.parameters:addInteger("Height", "Height (% of chart height)", "", 15);
	indicator.parameters:addInteger("Width", "Width (% of chart Width)", "", 5);
	indicator.parameters:addInteger("Size", "Max Font Size", "", 10);
	indicator.parameters:addInteger("Limit", "Maximum Number of Charts in a row", "", 5, 1, 5);
    
	
	 
	 
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

function AddTimeFrame(id , FRAME , DEFAULT )

    
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show This Time Frame"  , "", DEFAULT); 
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);	
	
	 indicator.parameters:addString("Method"..id, "Indicator", "", "MVA");
    indicator.parameters:setFlag("Method"..id,core.FLAG_INDICATOR);
	
	indicator.parameters:addString("iType"..id, "Indicaton Type", "", "Numeric");
    indicator.parameters:addStringAlternative("iType"..id, "Numeric", "", "Numeric");
    indicator.parameters:addStringAlternative("iType"..id, "Trend", "", "Trend");
	
	indicator.parameters:addInteger("Lock"..id, "Stream Number", "", 1,1, 100);	
end	

 
function AddCurrencyPair(id)

     local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"				  
			  };
			  
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		  
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Pair= {};
local Dodaj={};
local Period;
local Up;
local Down;
local No;
local FontSize;
local Color;
local Source={};
local Size;
local transparency;
local Method;

local Value={};
local Space;
local source;
local List={};
local Label={};
local Limit;
local Point={};
local SourceData={};
local loading={};
local Num;
local  Count;
local Coordinates1={};
local Coordinates2={};
local Array={};
local yNumber, xNumber;
local Width,Height;


	local On= {};
	local Method={};
	local TF={};
	local iType={};
	local Type;
	local tprofile={};
	local tparams={};
	local iprofile={};
	local iparams={};
	local SC={};
	local Lock={};
	local first={};
	local Indicator={};
	local Test={};
	
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	
    Type = instance.parameters.Type;
	Limit = instance.parameters.Limit;  
	Size = instance.parameters.Size;
    init=false;
	source = instance.source;
	Up= instance.parameters.Up
	Down= instance.parameters.Down;
	No= instance.parameters.No;
	
	Color= instance.parameters.Color;
	Height = instance.parameters.Height; 
	Width = instance.parameters.Width;
	 
	Pair={};
	
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
	
    Num=0;
	for i = 1 , 5 , 1 do  
	
	  
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   Method[Num]=  instance.parameters:getString ("Method"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   iType[Num]=  instance.parameters:getString ("iType"..i);
	   Lock [Num]=  instance.parameters:getInteger ("Lock"..i);
	 


	           tprofile[Num] = core.indicators:findIndicator(instance.parameters:getString("Method"..i));
			   tparams[Num] = instance.parameters:getCustomParameters("Method"..i);
			   if  tprofile[Num]:requiredSource() == core.Tick then
			   Test[Num] = tprofile[Num]:createInstance(source.close, tparams[Num]);
			   else
			   Test[Num] = tprofile[Num]:createInstance(source, tparams[Num]);
			   end  
			   
			   SC[Num] = Test[Num]:getStreamCount ()
			   
			    if Lock [Num] > SC[Num] then
				  Lock [Num] = SC[Num];
			    end
			   
			   local TS=Test[Num]:getStream(Lock [Num]-1);
	           first[Num]= TS:first();	
			   
			 
	  end
	  
	end	 

   
	local ID=0;
		
	
	for j = 1, Count, 1 do
	         
	
	
	         SourceData[j] = {}; 
             loading[j] = {};		
			 iprofile[j] = {};	
			 iparams[j] = {};
			 Indicator[j] = {};
			  
			
	   
		 for i = 1, Num, 1 do	
		       
			   ID=ID+1;
			   
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),  first[i]*2   , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			   
			
			   iprofile[j][i] = core.indicators:findIndicator(instance.parameters:getString("Method"..i));
			   iparams[j][i] = instance.parameters:getCustomParameters("Method"..i);			
			   
			   if  iprofile[j][i]:requiredSource() == core.Tick then
			   Indicator[j][i] = iprofile[j][i]:createInstance(SourceData[j][i].close, iparams[j][i]);
			   else
			   Indicator[j][i] = iprofile[j][i]:createInstance(SourceData[j][i], iparams[j][i]);
			   end
             			  
			  
		end
	end
	
	 
	 instance:ownerDrawn(true); 
     	core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 
    local ID=0;
	  local Broj=0;
	  local FLAG=false;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do
              ID=ID+1;
			   
			  if cookie == (1000 + ID) then
			  loading[j][i] = true;
			 
		      elseif  cookie == (2000 +ID) then
			  loading[j][i] = false;    
			  end
		       
          end
	end   

   for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

					 if loading[j][i] then
					 FLAG= true;
					 Broj=Broj+1;
					 end
				 
			 
		   
		end
	end
	
	
	 if not FLAG and cookie== 1 then
	 
	 
	 for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
	
	 Indicator[j][i]:update(core.UpdateLast);
	 
	 end
	end
   end	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Broj) .. " / " .. (Count*Num) );
	else
	core.host:execute ("setStatus", " Loaded " );
	 instance:updateFrom(0); 
	end	
   
        
    return core.ASYNC_REDRAW;
	
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 

end


function round(num, idp)

  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5);
end

local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	return;
	end
		
	
	 local Loading=false; 
   
	
	  for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

					 if loading[j][i] then
					 Loading= true;		
					 end	
		   
		end
	end
		
	 if Loading then
         return;
     end
	 
	
        if not init then
		  
            init = true;
			   Max= context:pointsToPixels (Size);
			   xNumber= math.min(Limit,Count );
			   ABS =round((Count/xNumber), 0)
			   if Count/xNumber > ABS then
			   ABS=ABS+1;
			   end
			   yNumber=  math.min(ABS,Count );
			   Array={};
			   x=0;
			   y=1;
			   
				   for i= 1, Count,1 do
				   x=x+1;
					   if x> Limit then 
					   x=1;
					   y=y+1;
					   end
				   Array[i]={};
				   Array[i]["X"]=x;
				   Array[i]["Y"]=y;
				   end
        end
	
        
		
		for i= 1, Count,1 do		
		Calculate(context, i  )		
		end
end


function Calculate(context, i)
   
   local top, bottom = context:top(), context:bottom();			
   local left, right = context:left(), context:right();
	
	
	xCell= (right- left)/xNumber;
    yCell= (bottom-top)/yNumber;	
	
	
	xSize=(xCell/100)*Width;
	if xSize> Max then
	xSize= Max;
	end
	ySize=(yCell/100)*Height;
	
	if ySize> Max then
	ySize= Max;
	end
	
	context:createFont (10, "Arial",xSize*0.9, ySize*0.9, 0);
    context:createFont (11, "Wingdings",xSize*0.9, ySize*0.9, 0);
	
	width, height = context:measureText (10, Pair[i], 0)
	
	Coordinates1[i]={};	
	Coordinates1[i]["X1"]=context:left()+(Array[i]["X"]-1)*xCell;	
	Coordinates1[i]["Y1"]=ySize+context:top()+(Array[i]["Y"]-1)*yCell;
	Coordinates1[i]["X2"]=Coordinates1[i]["X1"] + width;	
	Coordinates1[i]["Y2"]=Coordinates1[i]["Y1"] +   height;
    
	Temp1= Coordinates1[i]["X1"];
	Temp2=Coordinates1[i]["Y2"];
	
	context:drawText (10, Pair[i], Color, -1, Coordinates1[i]["X1"] , Coordinates1[i]["Y1"], Coordinates1[i]["X2"], Coordinates1[i]["Y2"], 0 )
	
	 for j= 1 , Num, 1 do
	 Coordinates2[j]={};	
	 width, height = context:measureText (10, TF[j].. " : ", 0)
 	 
	 Coordinates2[j]["X1"]=Temp1;	 
	 Coordinates2[j]["X2"]=Coordinates2[j]["X1"]+width;
	 
		 if j== 1  then
		 Coordinates2[j]["Y1"]=Temp2;
		 else
		Coordinates2[j]["Y1"]=Coordinates2[j-1]["Y2"]; 
		end
	Coordinates2[j]["Y2"]=Coordinates2[j]["Y1"] +   height;
	 
	 context:drawText (10, TF[j].. " : ", Color, -1, Coordinates2[j]["X1"] , Coordinates2[j]["Y1"], Coordinates2[j]["X2"], Coordinates2[j]["Y2"], 0 );
	 Value(context, Coordinates2[j]["X2"],Coordinates2[j]["Y1"],i,j);
	 
	 end
	
end

function Value(context, x,y,j,i)


 
 
		  if   not Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1) 
		  or not  Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-2)
		  or  SC[i] <= 0    then
		  return;
		  end
		  
		  
		               local Color =nil;			
						local Style = nil 
						local Font=nil;
						
						Style = nil;			

						 if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] >  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then
										
											
											Color = Up;
											Style= "\225";
						elseif Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] <  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then
											
											  Color = Down;									
												Style= "\226";	
												
						 else				
                                              Style= "\158";							 
											 Color = No;
						 end 			
						 
						 
		  --***************
		  
			
		
		                if iType[i]~= "Trend" then
						Font= 10;	
						Style= string.format("%." .. 5 .. "f", Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] );   
						else
						Font= 11;						
                        end		
		 
		 if Style ~= nil then
		 width, height = context:measureText (Font, Style, 0)
		 context:drawText (Font, Style, Color, -1, x  , y, x+width, y+height, 0 );
		 end
		 
		
 end