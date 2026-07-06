
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65386


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
	
	indicator.parameters:addInteger("RSIPeriod".. id, "RSI Period", "", 14);

  
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
    indicator.parameters:addStringAlternative("Method".. id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method".. id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method".. id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method".. id, "VAMA", "", "VAMA");


    indicator.parameters:addInteger("Period".. id, "Period", "", 20);
	
	indicator.parameters:addInteger("DeviationPeriod".. id, "Deviation Period", "", 20);
	indicator.parameters:addDouble("DeviationMultiplier".. id, "Deviation Multiplier", "", 2);
    
end



function Init()
    indicator:name("MTF MCP RSI_Midline Heat Map");
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
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("OBOS", "OBOS Color","", core.rgb(0, 0, 255));

   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end
local On={};
local ChartMethod;
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
local OBOS;
local Instrument={};

local RSIPeriod={};
local Method={};
local Period={};
local DeviationPeriod={};
local DeviationMultiplier={};
local Indicator = {} ;
 
function Prepare(nameOnly)
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	ChartMethod=instance.parameters.Method;
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	OBOS=instance.parameters.OBOS;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
	
	   local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
		    instance:name(name ..   " : "  ..  ChartMethod.. " ");	
			
	
	if   (nameOnly) then
        return;
    end
	

   

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
 	
	local ifirst;
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
	 local iTF={};
	 for i = 1, 13, 1 do
		       if   ChartMethod== "Chart Time Frame" then
	            iTF[i]=source:barSize();
				else
				iTF[i]=  instance.parameters:getString("TF" .. i);	
                		
				end
		 		
	end

	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	assert(core.indicators:findIndicator("RSI_MIDLINE") ~= nil, "Please, download and install RSI_MIDLINE.LUA indicator");  
	 
	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	      Period[Number]= instance.parameters:getInteger("Period" .. i);
		  
		 RSIPeriod[Number]= instance.parameters:getInteger("RSIPeriod" .. i);
		 Method[Number]= instance.parameters:getString("Method" .. i);
		 
		 DeviationPeriod[Number]= instance.parameters:getInteger("DeviationPeriod" .. i);
		 DeviationMultiplier[Number]= instance.parameters:getDouble("DeviationMultiplier" .. i);
		  
	 Label[Number]="";
	           
				 
				if  ChartMethod== "Chart Instrument" then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				 
				if   ChartMethod== "Chart Time Frame" then 
				TF[Number]=iTF[i];
				else
				TF[Number]=iTF[i];
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
 
				
			  	Temp1= core.indicators:create("RSI_MIDLINE", source.close ,  RSIPeriod[Number] ,  Method[Number] ,  Period[Number] ,  DeviationPeriod[Number] ,  DeviationMultiplier[Number]);  				
				ifirst= Temp1.DATA:first()*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("RSI_MIDLINE", SourceData[Number].close ,  RSIPeriod[Number] ,  Method[Number] ,  Period[Number] ,  DeviationPeriod[Number] ,  DeviationMultiplier[Number]);   
			 
				   
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
			
			context:createPen (11, context.SOLID, 3, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 3, UpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 3, DownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 3, DownDown)       
			context:createSolidBrush(42, DownDown);
			
			context:createPen (51, context.SOLID, 3, OBOS)       
 
			
			
		 
		  
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
				   
						
								
										if Indicator[j].Central:hasData(p) and Indicator[j].Central:hasData(p-1) then 
										
												    if Indicator[j].MID[p] > Indicator[j].Central[p] then		 
															if Indicator[j].MID[p] > Indicator[j].MID[p-1] then	
															C2=12;
															C1=11;
															else
															C2=22;
															C1=21;
															end		
												 
												    else  
													        if Indicator[j].MID[p] > Indicator[j].MID[p-1] then	
															C2=32;
															C1=31;
															else
															C2=42;
															C1=41;
															end														
													 
													end
										
																									
												
											 if  Indicator[j].MID[p]< Indicator[j].Bottom[p]
											 or Indicator[j].MID[p]> Indicator[j].Top[p]
											 then
											 C1=51;
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
 