
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61329

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

 function Add(id, TF,Flag )
   
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",Flag);	    
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addString("Method".. id, "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method".. id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method".. id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method".. id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method".. id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method".. id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method".. id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method".. id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method".. id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method".. id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method".. id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method".. id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method".. id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method".. id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method".. id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method".. id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method".. id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method".. id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method".. id, "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method".. id, "KAMA", "", "KAMA");
	indicator.parameters:addStringAlternative("Method".. id, "CMA", "", "CMA");

    indicator.parameters:addInteger("Period".. id, "Period", "", 20);
	
  
end

 
 
function Init()
    indicator:name("MTF MCP Averages Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
	
	indicator.parameters:addGroup("Calculation" );
    indicator.parameters:addString("Presentation" , "Presentation", "", "MA Slope");
    indicator.parameters:addStringAlternative("Presentation" , "MA Slope", "", "MA Slope");
    indicator.parameters:addStringAlternative("Presentation" , "Price / MA", "", "Price/MA");
	indicator.parameters:addStringAlternative("Presentation" , "Price + Price Slope / MA + MA Slope", "", "Price + Price Slope / MA + MA Slope");
	indicator.parameters:addStringAlternative("Presentation" , "Price/MA + MA Slope", "", "Price/MA + MA Slope");
	indicator.parameters:addGroup("Override" );
	indicator.parameters:addBoolean("oPair"  , "Use Chart Currency pair", "", true );	
	indicator.parameters:addBoolean("oTime"  , "Use Chart Time Frame", "", false );	
	 	 
	indicator.parameters:addGroup("1. Time Frame" );
    Add(1, "m1", true);
	indicator.parameters:addGroup("2. Time Frame" );
    Add(2, "m5", true);
	indicator.parameters:addGroup("3. Time Frame" );
    Add(3, "m15", true);
	indicator.parameters:addGroup("4. Time Frame" );
    Add(4, "m30", true);
	indicator.parameters:addGroup("5. Time Frame" );
    Add(5, "H1", true);
	
	
	indicator.parameters:addGroup("6. Time Frame" );
    Add(6, "H2", true);
	indicator.parameters:addGroup("7. Time Frame" );
    Add(7, "H3", true);
	indicator.parameters:addGroup("8. Time Frame" );
    Add(8, "H4", true);
	indicator.parameters:addGroup("9. Time Frame" );
    Add(9, "H6", true);
	indicator.parameters:addGroup("10. Time Frame" );
    Add(10, "H8", true);
	
	indicator.parameters:addGroup("11. Time Frame" );
    Add(11, "D1", true);
	indicator.parameters:addGroup("12. Time Frame" );
    Add(12, "W1", true);
	indicator.parameters:addGroup("13. Time Frame" );
    Add(13, "M1", true);

    indicator.parameters:addGroup("Calculation");
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpUp", "Up Color In Up Trend Average","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down Color In Up Trend Average","", core.rgb(0, 100, 0));
	indicator.parameters:addColor("DownUp", "Up Color In Down Trend Average","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down Color In Down Trend Average","", core.rgb(200, 0, 0)); 
	indicator.parameters:addColor("Up", " Up Slope","", core.rgb(0,255, 0));
	indicator.parameters:addColor("Down", " Up Slope","", core.rgb(255,0, 0));
	indicator.parameters:addColor("NoSlope", " No Slope/Neutral","", core.rgb(0,0, 255));
	indicator.parameters:addDouble("size", "Line Size","",10, 0, 100);
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",50, 0, 100);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",25, 0, 30);
end
local On={};
local oPair;
local oTime ;
local Method={};
local Period={};
local source;
local day_offset, week_offset;
local Label = {};
local first;
local VSpace,HSpace;
local Color;
local size;
local SourceData={};
local TF={};
local loading={};
local Number=5;
local host;
local Averages={}; 
local UpUp, UpDown,DownUp, DownDown, Neutral;
local Instrument={};
local OversoldOverbought;
local Up, Down, NoSlope;
local Presentation;

function Prepare(nameOnly) 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	UpUp=instance.parameters.UpUp;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	Presentation=instance.parameters.Presentation;
	DownDown=instance.parameters.DownDown;
	Neutral=instance.parameters.Neutral;
	OversoldOverbought=instance.parameters.OversoldOverbought;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	NoSlope=instance.parameters.NoSlope;
	
	oPair=instance.parameters.oPair;
	oTime=instance.parameters.oTime;
	
	
		
	 host = core.host;
	size=instance.parameters.size;
    Color=instance.parameters.Color;
    first=source:first();
    local name = profile:id() .. "(" .. source:name() .. ")"; 
    instance:name(name);	
		
	if   (nameOnly) then
        return;
    end
   
   assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
   
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
	
	local s1,e1, s2, s2;
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	
   
    for i = 1, 13, 1 do
		if  oTime then 
		s2, e2 = core.getcandle(source:barSize(), 0, 0, 0);
		else
		s2, e2 = core.getcandle( instance.parameters:getString("TF" .. i), 0, 0, 0);
		end
	
	
	 if  instance.parameters:getBoolean("On" .. i) and  not ((e1 - s1) > (e2 - s2)) then
	 
	 Number=Number+1;
	 Label[Number]="";
	            On[Number]=instance.parameters:getBoolean("On" .. i);
				 
				if  oPair then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				if  oTime then
	            TF[Number]=source:barSize();
				else
				TF[Number]=  instance.parameters:getString("TF" .. i);				
				end
				
				Period[Number]=  instance.parameters:getInteger("Period" .. i);				
				Method[Number]=  instance.parameters:getString("Method" .. i);	
                if Method[Number]== "CMA" then
                assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.BIN indicator");  			
                end 				
				
				Label[Number]=Label[Number] .. "  -  " ..  TF[Number];
				 if Method[Number]== "CMA" then 
				 Temp= core.indicators:create("CMA",source.close,   Period[Number] );  
				 else
			  	Temp= core.indicators:create("AVERAGES",source.close,  Method[Number], Period[Number], false );  
				end
				
				first= Temp.DATA:first();
			--	first=0;
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,first), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	
                 if Method[Number]== "CMA" then 
				 Averages[Number]= core.indicators:create("CMA",SourceData[Number].close,   Period[Number] ); 	
			     else
				  Averages[Number]= core.indicators:create("AVERAGES",SourceData[Number].close,  Method[Number], Period[Number], false ); 
				 end
				  
       end
    end
	
 
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
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
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Number, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;    
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
	

	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	 instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
	
end





function Update(period, mode)

  	local FLAG=false; 
	
 
    for j = 1, Number, 1 do
 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
   
    
	if FLAG then
	return;
	end
	
	
	
 
    for i = 1, Number, 1 do
		      
                 if not loading[i] then
				    if Method[i]== "CMA" then
					Averages[i]:update(core.UpdateAll);
                    else					
				 	Averages[i]:update(mode);
					end
				 end    
	end    

 
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	
	local FLAG=false; 
	
 
    for j = 1, Number, 1 do
 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
   
    
	if FLAG then
	return;
	end
	
	
	 
	 local Size = context:pointsToPixels(size);
	local CellSize = math.floor(Size * 0.9);
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
 
        if not init then
		    context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 1, UpDown)       
			context:createSolidBrush(22, UpDown);
			
			context:createPen (41, context.SOLID, 1, DownUp)       
			context:createSolidBrush(42, DownUp);
			
			context:createPen (51, context.SOLID, 1, DownDown)       
			context:createSolidBrush(52, DownDown);
			
			
			context:createPen (31, context.SOLID, 1, NoSlope)       
			context:createSolidBrush(32,NoSlope);
			
			
			
			 context:createPen (61, context.SOLID, 1, Up)  
			 context:createPen (62, context.SOLID, 1, Down)  	
			
			
			context:createFont(3, "Arial", Size, CellSize, context.NORMAL);
            init = true;
        end
 
      
        local first = math.max(first, context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
        local p1,p2;
       local VS=(Size*VSpace);
       local i,j;
	   local x0, x1, x2;
	   local style = context.SINGLELINE + context.CENTER + context.VCENTER;
       for i= first, last, 1 do	   
	   
	   
	  --p
	   
	   x0, x1, x2 = context:positionOfBar (i);
	        
			 local HS= HSpace;
			 if x2-x1 <= Size then
			 HS=0;
			 end
			 for j= 1, Number , 1 do
			 
			 First=1
			 Second=2;
				  p1=Initialization(i,j);
			 
				  if p1~= false  and Averages[j].DATA:hasData(p1)  and  Averages[j].DATA:hasData(p1-1) then
				  
				  --Presentation 
				  
				  
				        if Presentation == "Price + Price Slope / MA + MA Slope" then
				                if SourceData[j].close[p1] > Averages[j].DATA[p1] then 
									if SourceData[j].close[p1] > SourceData[j].open[p1] then 
									Second=12;
									elseif SourceData[j].close[p1]< SourceData[j].open[p1] then
									Second=22;
									else
									Second=32;
									end
								
								elseif SourceData[j].close[p1] < Averages[j].DATA[p1]  then
								     if SourceData[j].close[p1] > SourceData[j].open[p1] then 
									Second=42;
									elseif SourceData[j].close[p1]< SourceData[j].open[p1] then
									Second=52;
									else
									Second=32;
									end
								 
								else 
								Second =32
								end
								
								
								  if Averages[j].DATA[p1]>Averages[j].DATA[p1-1] then
								  First=61;
								  elseif   Averages[j].DATA[p1]<Averages[j].DATA[p1-1] then 
								  First=62;
								  else
								  First=31;
								  end
								  
				        elseif Presentation == "MA Slope" then
						         
									if Averages[j].DATA[p1]  >Averages[j].DATA[p1-1] then 
									First=11;
									Second=12;
									elseif Averages[j].DATA[p1]  < Averages[j].DATA[p1-1] then
									First=51;
									Second=52;
									else
									First=31;
									Second=32;
									end
						elseif Presentation == "Price/MA" then
						            
									if SourceData[j].close[p1] > Averages[j].DATA[p1]  then 
									First=11;
									Second=12;
									elseif SourceData[j].close[p1] < Averages[j].DATA[p1]  then
									First=51;
									Second=52;
									else
									First=31;
									Second=32;
									end
									
						elseif Presentation == "Price/MA + MA Slope" then
						            
									if SourceData[j].close[p1] > Averages[j].DATA[p1]  then 
												if Averages[j].DATA[p1]> Averages[j].DATA[p1-1]  then 
												First=11;
												Second=12;
												elseif Averages[j].DATA[p1]< Averages[j].DATA[p1-1] then
												First=21;
												Second=22;
												else
												First=31;
												Second=32;
									            end
									elseif SourceData[j].close[p1] < Averages[j].DATA[p1]  then
									             if Averages[j].DATA[p1]> Averages[j].DATA[p1-1]  then 
												 First=41;
												 Second=42;
												 elseif Averages[j].DATA[p1]< Averages[j].DATA[p1-1] then
												 First=51;
												 Second=52;
												else
												First=31;
												Second=32;
												end
									else
									First=31;
									Second=32;
									end			
						            
						end
				
				  end
				  
				      context:drawRectangle (First, Second, x1+(x2-x1)*HS, 2*Size + Size*j+j*VS, x2-(x2-x1)*HS, 2*Size + Size*(j+1)+j*VS);
			 end
	   end
     
      x0, x1, x2 = context:positionOfBar (source:size()-1);
	 
	 local width, height;
     for j= 1, Number , 1 do 
     width, height = context:measureText (3, Label[j], style)	 
	 context:drawText(3, Label[j], Color, -1, x2, 2*Size + Size*j+j*VS,x2+width, 2*Size + Size*(j+1)+j*VS, style);
	 end
 
 
end


