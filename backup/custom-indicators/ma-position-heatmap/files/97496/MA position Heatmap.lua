-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61569

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


 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period1".. id, "1. MA Period ", "", 7, 1, 2000);
	indicator.parameters:addString("Method1".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1".. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1".. id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2".. id, "2. MA Period", "", 14, 1, 2000);
	indicator.parameters:addString("Method2".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2".. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2".. id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period3".. id, "3. MA Period", "", 21, 1, 2000);
	indicator.parameters:addString("Method3".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3".. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3".. id, "WMA", "WMA" , "WMA");
    
end

 
 
function Init()
    indicator:name("MA position Heatmap");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Time Frame");
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
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "DownTrend Color","", core.rgb(255, 0, 0));
  
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
local Neutral,Up, Down ;
local Instrument={};

local Period1= {} ;
local Period2= {} ;
local Period3= {} ;
local Indicator1 = {} ;
local Indicator2 = {} ;
local Indicator3 = {} ;
local Method3={};
local Method2={};
local Method1={};
local Last; 


function Prepare(nameOnly)   
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	Up =instance.parameters.Up ;
	Down =instance.parameters.Down ; 
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
 
   
   Last=nil;
    
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

	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getString("On" .. i)~= "Off" and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	      Period1[Number]= instance.parameters:getInteger("Period1" .. i);
		  Period2[Number]= instance.parameters:getInteger("Period2" .. i);
		  Period3[Number]= instance.parameters:getInteger("Period3" .. i);
		  Method1[Number]= instance.parameters:getString("Method1" .. i);
		  Method2[Number]= instance.parameters:getString("Method2" .. i);
		  Method3[Number]= instance.parameters:getString("Method3" .. i);
		
		  
	 Label[Number]="";
	            On[Number]=instance.parameters:getString("On" .. i);
				
				if On[Number]=="Alert" then
				AlertNumber=AlertNumber+1;
				end
				 
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
				
				
				
			  	Temp1= core.indicators:create( Method1[Number], source.close ,  Period1[Number]);  
                Temp2= core.indicators:create( Method2[Number], source.close ,  Period2[Number]); 
                Temp3= core.indicators:create( Method3[Number], source.close ,  Period3[Number]); 				
				ifirst=math.max( Temp1.DATA:first(),Temp2.DATA:first(),Temp3.DATA:first());
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),ifirst, 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator1[Number] = core.indicators:create( Method1[Number], SourceData[Number].close ,  Period1[Number]);  
                 Indicator2[Number] = core.indicators:create( Method2[Number], SourceData[Number].close ,  Period2[Number]);   
                 Indicator3[Number] = core.indicators:create( Method3[Number], SourceData[Number].close ,  Period3[Number]);        				 
			 
				   
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
   
     if cookie== 1 and not FLAG then
  
   
	   for i= 1, Number , 1 do
	  Indicator1[i]:update(core.UpdateLast );
	  Indicator2[i]:update(core.UpdateLast );
	  Indicator3[i]:update(core.UpdateLast );
	  
	 
	end
	
 
     end	 
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded")
	 instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
	
end

function Update(period, mode)
        
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
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		
			
			 context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=Initialization(i,j);
				  
				 
				  
				  if p~= false then
				   
						
								
										if Indicator1[j].DATA:hasData(p)  
										and Indicator2[j].DATA:hasData(p)  
										and Indicator3[j].DATA:hasData(p)  
										then 
										
												    if Indicator1[j].DATA[p] > Indicator2[j].DATA[p] 
													and Indicator2[j].DATA[p] > Indicator3[j].DATA[p] 
													then		 
														 
															C2=12;
															C1=11;
															 	
												 
												    elseif Indicator1[j].DATA[p] < Indicator2[j].DATA[p] 
													and Indicator2[j].DATA[p] < Indicator3[j].DATA[p]   
													then
													         
															C2=22;
															C1=21;
													else	 													
													 C1=1; C2=2;		
													end
										
																									
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace, x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize * (j) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top() + VCellSize * (j+1)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end

