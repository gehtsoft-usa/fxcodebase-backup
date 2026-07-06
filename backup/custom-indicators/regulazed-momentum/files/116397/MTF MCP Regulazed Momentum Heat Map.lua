
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65440


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

 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
 
    indicator.parameters:addInteger("Length".. id, "Length", "", 14);

    indicator.parameters:addString("Price" .. id, "Price", "", "Close");
    indicator.parameters:addStringAlternative("Price" .. id, "Close", "", "Close");
    indicator.parameters:addStringAlternative("Price" .. id, "Open", "", "Open");
    indicator.parameters:addStringAlternative("Price" .. id, "High", "", "High");
    indicator.parameters:addStringAlternative("Price" .. id, "Low", "", "Low");
    indicator.parameters:addStringAlternative("Price" .. id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Price" .. id, "Typical", "", "Typical");
    indicator.parameters:addStringAlternative("Price" .. id, "Weighted", "", "Weighted");
    indicator.parameters:addStringAlternative("Price" .. id, "Average (high+low+open+close)/4", "", "Average (high+low+open+close)/4");
    indicator.parameters:addStringAlternative("Price" .. id, "Average median body (open+close)/2", "", "Average median body (open+close)/2");
    indicator.parameters:addStringAlternative("Price" .. id, "Trend biased price", "", "Trend biased price");
    indicator.parameters:addStringAlternative("Price" .. id, "Trend biased (extreme) price", "", "Trend biased (extreme) price");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi close", "", "Heiken ashi close");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi open", "", "Heiken ashi open");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi high", "", "Heiken ashi high");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi low", "", "Heiken ashi low");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi median", "", "Heiken ashi median");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi typical", "", "Heiken ashi typical");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi weighted", "", "Heiken ashi weighted");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi average", "", "Heiken ashi average");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi median body", "", "Heiken ashi median body");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi trend biased price", "", "Heiken ashi trend biased price");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi trend biased (extreme) price", "", "Heiken ashi trend biased (extreme) price");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) close", "", "Heiken ashi (better formula) close");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) open", "", "Heiken ashi (better formula) open");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) high", "", "Heiken ashi (better formula) high");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) low", "", "Heiken ashi (better formula) low");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) median", "", "Heiken ashi (better formula) median");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) typical", "", "Heiken ashi (better formula) typical");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) weighted", "", "Heiken ashi (better formula) weighted");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) average", "", "Heiken ashi (better formula) average");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) median body", "", "Heiken ashi (better formula) median body");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) trend biased price", "", "Heiken ashi (better formula) trend biased price");
    indicator.parameters:addStringAlternative("Price" .. id, "Heiken ashi (better formula) trend biased (extreme) price", "", "Heiken ashi (better formula) trend biased (extreme) price");

    indicator.parameters:addDouble("Lambda" .. id, "Lambda", "", 7);

    indicator.parameters:addString("LevelType" .. id, "Level type", "", "Quantile level");
    indicator.parameters:addStringAlternative("LevelType" .. id, "Floating levels", "", "Floating levels");
    indicator.parameters:addStringAlternative("LevelType" .. id, "Quantile level", "", "Quantile level");

    indicator.parameters:addInteger("MinMaxPeriod" .. id, "Min max period", "", 15);
    indicator.parameters:addDouble("LevelUp" .. id, "Level up", "", 90);
    indicator.parameters:addDouble("LevelDown" .. id, "Level down", "", 10);

    indicator.parameters:addString("ColorOn" .. id, "Change color on", "", "On slope");
    indicator.parameters:addStringAlternative("ColorOn" .. id, "On slope", "", "On slope");
    indicator.parameters:addStringAlternative("ColorOn" .. id, "On middle", "", "On middle");
    indicator.parameters:addStringAlternative("ColorOn" .. id, "On levels", "", "On levels");
    

end

 
 
function Init()
    indicator:name("MTF MCP Regulazed Momentum Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
  
    Add(1, "m1",  "Off", "EUR/USD"); 
    Add(2, "m5",  "Off", "USD/JPY"); 
    Add(3, "m15",  "Off", "GBP/USD"); 
    Add(4, "m30",  "Off", "USD/CHF"); 
    Add(5, "H1",  "Off", "EUR/CHF"); 
    Add(6, "H2", "View", "AUD/USD"); 
    Add(7, "H3",  "Off", "USD/CAD"); 
    Add(8, "H4", "View", "NZD/USD" ); 
    Add(9, "H6",  "Off", "NZD/USD" ); 
    Add(10, "H8", "View", "EUR/JPY"); 
    Add(11, "D1",  "Off", "GBP/JPY"); 
    Add(12, "W1",  "Off", "CHF/JPY"); 
    Add(13, "M1",  "Off", "GBP/CHF");

 
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", " Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(128, 128, 0));

   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end
local On={};
local Method;
local source;
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};

local VSpace,HSpace;
local Color;
local Size;
local SourceData={};
local TF={};
local loading={};
local Number;
local host;
local RSI={}; 
local Up, Down, Neutral;
local Instrument={};

local Period= {} ;
local Indicator = {} ;

local Length = {} ;
local  Price = {} ;
local Lambda = {} ;
local  LevelType = {} ;
local  MinMaxPeriod = {} ;
local  LevelUp = {} ;
local  LevelDown = {} ;
local  ColorOn = {} ;
	
 
function Prepare(nameOnly) 
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
 

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	
	 instance:name(name ..   " : "  ..  Method.. " ");	
        if   (nameOnly) then
        return;
        end	
		
		
	local ifirst;
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
	 local iTF={};
	 for i = 1, 13, 1 do
		       if   Method== "Chart Time Frame" then
	            iTF[i]=source:barSize();
				else
				iTF[i]=  instance.parameters:getString("TF" .. i);	
                		
				end
		 		
	end

	
	assert(core.indicators:findIndicator("REGULAZED_MOMENTUM") ~= nil, "Please, download and install REGULAZED_MOMENTUM.LUA indicator");    
	 
	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	       
		  Length[Number]= instance.parameters:getInteger("Length" .. i);
		  Price[Number]= instance.parameters:getString("Price" .. i);
		  Lambda[Number]= instance.parameters:getDouble("Lambda" .. i);
		  LevelType[Number]= instance.parameters:getString("LevelType" .. i);
		  MinMaxPeriod[Number]= instance.parameters:getInteger("MinMaxPeriod" .. i);
		  LevelUp[Number]= instance.parameters:getDouble("LevelUp" .. i);
		  LevelDown[Number]= instance.parameters:getDouble("LevelDown" .. i);
		  ColorOn[Number]= instance.parameters:getString(" ColorOn" .. i);
		
		  
	 Label[Number]="";
	           
				 
				if  Method== "Chart Instrument" then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				 
				if   Method== "Chart Time Frame" then 
				TF[Number]=iTF[i];
				else
				TF[Number]=iTF[i];
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
				
				
				
			  	Temp1= core.indicators:create("REGULAZED_MOMENTUM", source ,   Length[Number], Price[Number],Lambda[Number], LevelType[Number], MinMaxPeriod[Number], LevelUp[Number], LevelDown[Number], ColorOn[Number]);  				
				ifirst= Temp1.DATA:first()*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("REGULAZED_MOMENTUM", SourceData[Number] ,  Length[Number], Price[Number],Lambda[Number], LevelType[Number], MinMaxPeriod[Number], LevelUp[Number], LevelDown[Number], ColorOn[Number],core.rgb(0, 255, 0),core.rgb(255, 0, 0),core.rgb(128, 128, 0));   
			 
				   
       end
    end
  
	
	   	
		core.host:execute ("setTimer", 1, 1);
		   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
   
    
   if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  Indicator[i]:update(core.UpdateLast );
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

function Update(period)
 
     
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] 
				 then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
			 context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 3,Down)       
			context:createSolidBrush(22,Down);
		
			
			context:createPen (31, context.SOLID, 3, Neutral)       
			context:createSolidBrush(32,Neutral);
		 
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=Initialization(i,j);
				  
				 
				  
				  if p~= false then
				   
						
								
										if Indicator[j].mom:hasData(p) then 
										
												    if Indicator[j].mom:colorI(p) ==  core.rgb(0, 255, 0) then		 
														 
															C2=12;
															C1=11;
													 elseif Indicator[j].mom:colorI(p) ==  core.rgb(255, 0, 0) then		 
															C2=22;
															C1=21;
											 	
												 
												    elseif Indicator[j].mom:colorI(p) ==  core.rgb(128, 128, 0) then		  
													        
															C2=32;
															C1=31;
															 												
													  else		
									               C1=1; C2=2;										   
									   
									   
													end
										
																									
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end
 