
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62520

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
	
	indicator.parameters:addInteger("DMIPeriod".. id, "Number of periods for DMI", "", 14, 1, 200);
    indicator.parameters:addInteger("ADXPeriod".. id, "Number of periods for ADX", "", 14, 1, 200);
	
	
	indicator.parameters:addInteger("SN".. id, "Short MACD EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN".. id, "Long MACD EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN".. id, "Signal MACD Line", "", 9, 2, 1000);
end

 
 
function Init()
    indicator:name("MTF MCP Filter Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Selector" );
	indicator.parameters:addBoolean("iADX" , "Use ADX", "",true);	
    indicator.parameters:addBoolean("iDMI" , "Use DMI", "",true);	
     indicator.parameters:addBoolean("iMACD" , "Use MACD", "",true);  	
	
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
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
	
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
local Up, Down,Neutral ;
local Instrument={};
local SN={};
local LN={};
local IN={};
local ADXPeriod= {} ;
local DMIPeriod= {} ;
local ADX = {} ;
local DMI = {} ;
local Last; 
local iMACD, iADX, iDMI;
local MACD={};
function Prepare(nameOnly)
    
	iMACD=instance.parameters.iMACD;
	iADX=instance.parameters.iADX;
	iDMI=instance.parameters.iDMI;
	
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
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	      ADXPeriod[Number]= instance.parameters:getInteger("ADXPeriod" .. i);
		  DMIPeriod[Number]= instance.parameters:getInteger("DMIPeriod" .. i);
		  SN[Number]= instance.parameters:getInteger("SN" .. i);
		  LN[Number]= instance.parameters:getInteger("LN" .. i);
		  IN[Number]= instance.parameters:getInteger("IN" .. i);
		  
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
				
				
				
			  	Temp1= core.indicators:create("DMI", source ,  DMIPeriod[Number]);  
                Temp2= core.indicators:create("ADX", source ,  ADXPeriod[Number]); 	
                Temp3= core.indicators:create("MACD", source.close ,  SN[Number],LN[Number],IN[Number]); 								
				ifirst= math.max(Temp1.DATA:first(),Temp2.DATA:first(),Temp3.DATA:first())*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),ifirst, 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 ADX[Number] = core.indicators:create("ADX", SourceData[Number] ,  ADXPeriod[Number]);   
				 DMI[Number] = core.indicators:create("DMI", SourceData[Number] ,  DMIPeriod[Number]);  
			     MACD[Number] = core.indicators:create("MACD", SourceData[Number].close ,  SN[Number],LN[Number],IN[Number]);  
				   
       end
    end
  
	
	 
		   instance:setLabelColor(Color);
            instance:ownerDrawn(true);
		   core.host:execute ("setTimer", 1, 1);
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
	
	
	
	if cookie == 1 and not FLAG then
	
	  for i= 1, Number , 1 do
			  if iADX then
			  ADX[i]:update(core.UpdateLast );
			  end
			  if iDMI then
			  DMI[i]:update(core.UpdateLast );
			  end
			  if iMACD then
			  MACD[i]:update(core.UpdateLast );
			  end
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
		
			
			context:createPen (31, context.SOLID, 1, Neutral)       
			context:createSolidBrush(32, Neutral);
			
	
		 
		  
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
				   
						
										
												if (DMI[j].DIP:hasData(p) or not iDMI) 
												and ((ADX[j].DATA:hasData(p) and ADX[j].DATA:hasData(p-1))  or not iADX)
												and (MACD[j].DATA:hasData(p) or  not iMACD)
												and (iDMI or iADX or iMACD) 
												then
															if (  not iDMI or DMI[j].DIP[p] > DMI[j].DIM[p] )   	 
															and (   not iADX or ADX[j].DATA[p] >  ADX[j].DATA[p-1]  ) 	 
															and  (  not iMACD or MACD[j].DATA[p] > 0 ) 
															then										
																 
															 C1=11; C2=12; 		
										            elseif (not iDMI or DMI[j].DIP[p] < DMI[j].DIM[p] )   	 
													and ( not iADX or ADX[j].DATA[p] >  ADX[j].DATA[p-1]) 	 
													and  ( not iMACD or MACD[j].DATA[p] < 0 )
                                                    then
													 C1=21; C2=22;	
													else
													 C1=31; C2=32;		
													end		  	
													
										
																									
												
											 
												 
												     
									   else		
									    C1=31; C2=32;												   
									   end 
									   
						 
				 else
                   
					 C1=31; C2=32;		
										
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

