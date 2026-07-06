-- Available @ http://fxcodebase.com/ 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
           
	
	indicator.parameters:addString("Type".. id, "MACD / HISTOGRAM", "HISTOGRAM", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type".. id, "Histogram", "", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type".. id, "MACD/SIGNAL", "", "MACD");
	 indicator.parameters:addStringAlternative("Type".. id, "MACD/ZERO", "", "ZERO");
	
 
	
	
    
end

 
 
function Init()
    indicator:name("MTF MCP Heat Map Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "MACD / HISTOGRAM", "HISTOGRAM", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "HISTOGRAM");
    indicator.parameters:addStringAlternative("Type", "MACD/SIGNAL", "", "MACD");
	indicator.parameters:addStringAlternative("Type", "MACD/ZERO", "", "ZERO");
	
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the long EMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);


	
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
	indicator.parameters:addColor("Color", "Label Color","", core.COLOR_LABEL);
	indicator.parameters:addColor("Up" , "Up Trend Up Color","", core.rgb(0, 96, 191) );	
	indicator.parameters:addColor("UpDown" , "Up Trend Down Color","", core.rgb(0, 46, 141) );	
	indicator.parameters:addColor("Down" , "Down Trend Up Color","",  core.rgb(255, 0, 0));	
	indicator.parameters:addColor("DownDown" , "Down Trend Down Color","", core.rgb(219, 0, 0)  );	
	indicator.parameters:addColor("Neutral" , "Neutral Up Color","", core.rgb(128, 128, 128));		


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
local UpUp, DownDown ;
local UpDown, DownUp ;
local Instrument={};

local Period= {} ;
local Indicator = {} ;
 
function Prepare(nameOnly)
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	TYPE = instance.parameters.Type;
	
	
	Up = instance.parameters.Up;
	UpDown = instance.parameters.UpDown;
	Down = instance.parameters.Down;
	DownDown = instance.parameters.DownDown;
	Neutral = instance.parameters.Neutral;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   
   

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name);
	
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

	
	if   (nameOnly) then
        return;
    end
	
	 
	 
	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
 
		  
		
		  
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
				
				
				
			  	Temp1= core.indicators:create("MACD", source.close  ,  SN, LN, IN);  				
				ifirst= Temp1.SIGNAL:first()*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("MACD", SourceData[Number].close , SN, LN, IN);   
			 
				   
       end
    end
  
	    instance:setLabelColor(Color);
        instance:ownerDrawn(true);
		core.host:execute ("setTimer", 1, 5);
		 
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
			
			context:createPen (21, context.SOLID, 3, UpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 3, Down)       
			context:createSolidBrush(32, Down);
			
			context:createPen (41, context.SOLID, 3, DownDown)       
			context:createSolidBrush(42, DownDown);
		 
			context:createPen (51, context.SOLID, 3, Neutral)       
			context:createSolidBrush(52, Neutral);	  
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
				   
						
								
										if Indicator[j].SIGNAL:hasData(p) and Indicator[j].SIGNAL:hasData(p-1) then 
										
						 
										
												if TYPE == "HISTOGRAM" then
												
												        if Indicator[j].HISTOGRAM[p] > 0 then
															if Indicator[j].HISTOGRAM[p] > Indicator[j].HISTOGRAM[p-1] then 	
																C2=12;
																C1=11;
															else
																C2=22;
																C1=21;
															end
														else
															if Indicator[j].HISTOGRAM[p] > Indicator[j].HISTOGRAM[p-1] then 	
																C2=32;
																C1=31;
															else
																C2=42;
																C1=41;
															end
														end
														
														
												elseif TYPE == "MACD" then
												
												       if Indicator[j].MACD[p]> Indicator[j].SIGNAL [p] then
															   if Indicator[j].MACD[p] > Indicator[j].MACD[p-1] then 	
																	C2=12;
																	C1=11;
																else
																	C2=22;
																	C1=21;
																end
														else
														
																
																if Indicator[j].MACD[p] > Indicator[j].MACD[p-1] then 	
																	C2=32;
																	C1=31;
																else
																	C2=42;
																	C1=41;
																end
														end		
												elseif TYPE == "ZERO" then
												
												
														if  Indicator[j].MACD[p] > 0 then
																if Indicator[j].MACD[p] >  Indicator[j].MACD[p-1] then 	
														        C2=32;
															    C1=31; 
																else
														        C2=22;
														    	C1=21;
																end	
														else
 
																if Indicator[j].MACD[p] >  Indicator[j].MACD[p-1] then 	
														        C2=32;
															    C1=31;
																else
														        C2=42;
														    	C1=41;
																end		

													   end				
												end
										
											 
															
										 
										
																									
												
											 
												 
												     
									   else		
									   C1=51; C2=52;										   
									   end  
						 
				 else
                   
					 C1=51; C2=52;		
										
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+