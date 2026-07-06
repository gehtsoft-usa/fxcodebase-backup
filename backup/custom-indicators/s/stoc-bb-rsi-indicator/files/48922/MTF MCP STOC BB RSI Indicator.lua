-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27881
-- Id: 18469

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF MCP STOC BB RSI Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation ");
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
    Parameters (1 , "m1", false  );	
	Parameters (2 , "m5", false   );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false   );	
	Parameters (5 , "H1", true  );
	Parameters (6 , "H2", false   );
	Parameters (7 , "H3", false   );	
	Parameters (8 , "H4", false   );
	Parameters (9 , "H6", false   );
	Parameters (10 , "H8", true  );	
	Parameters (11 , "D1", true  );
	Parameters (12 , "W1", true  );
   Parameters (13 , "M1", true  );	
   
   
   
   
    for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	 

	
	indicator.parameters:addGroup( "Style");
	indicator.parameters:addInteger("Size", "Size", "", 90);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0)); 
     indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0)); 
	  indicator.parameters:addColor("Down", "Down Color", "Label Color", core.rgb(255, 0, 0)); 
	   indicator.parameters:addColor("Neutral", "Neutral Color", "Label Color", core.rgb(128, 128, 128)); 
 
	
	
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

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
   
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end


 
function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
 
 
    indicator.parameters:addInteger("STO_KPeriod"..id, "K period of stochastic", "", 5);
    indicator.parameters:addInteger("STO_DPeriod"..id, "D period of stochastic", "", 3);
    indicator.parameters:addInteger("STO_Slowing"..id, "Slowing of stochastic", "", 3);
    indicator.parameters:addString("STO_K"..id, "STO_K"..id, "Smoothing type for %K", "MVA");
    indicator.parameters:addStringAlternative("STO_K"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("STO_K"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("STO_K"..id, "Fast smoothed", "", "FS");
    indicator.parameters:addString("STO_D"..id, "STO_D", "Smoothing type for %D", "MVA");
    indicator.parameters:addStringAlternative("STO_D"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("STO_D"..id, "EMA", "", "EMA");	
    indicator.parameters:addInteger("BB_Period"..id, "Period of Band", "", 10);
    indicator.parameters:addDouble("BB_Deviation"..id, "Deviation of Band", "", 1);
    indicator.parameters:addInteger("RSI_Period"..id, "Period of RSI", "", 8);
    indicator.parameters:addString("RSI_Price"..id, "Price of RSI", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "close", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "open", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "high", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "low", "", "low");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "median", "", "median");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "typical", "", "typical");
    indicator.parameters:addStringAlternative("RSI_Price"..id, "weighted", "", "weighted");
	
    indicator.parameters:addDouble("BL"..id, "Buy Level", "", 50);
	indicator.parameters:addDouble("SL"..id, "Sell Level", "", 50);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;
local first;
local source = nil;
local Color, Up, Down,Neutral;
 
    local Indicator={};
	local STO_KPeriod={};
	local STO_DPeriod={};
	local STO_Slowing={};
	local STO_K={};
	local STO_D={};
	local BB_Deviation={};
	local BB_Period={};
	local RSI_Period={};
	local RSI_Price={};
	local BL={};
	local SL={};

local Num;
local loading={};
local SourceData={};
local Point={};
local Pair={};
local Count;
local TF={};

local id;
local Dodaj={};
 

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
 

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end

    Type= instance.parameters.Type;

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i); 	   
        
 
	STO_KPeriod[Num]=  instance.parameters:getInteger ("STO_KPeriod"..i); 	   
	STO_DPeriod[Num]=  instance.parameters:getInteger ("STO_DPeriod"..i); 	   
	STO_Slowing[Num]=  instance.parameters:getInteger ("STO_Slowing"..i); 	   
	STO_K[Num]=  instance.parameters:getString ("STO_K"..i); 	   
	STO_D[Num]=  instance.parameters:getString ("STO_D"..i); 	   
	BB_Deviation[Num]=  instance.parameters:getDouble ("BB_Deviation"..i); 	   
	BB_Period[Num]=  instance.parameters:getInteger ("BB_Period"..i); 	   
	RSI_Period[Num]=  instance.parameters:getInteger ("RSI_Period"..i); 	   
	RSI_Price[Num]=  instance.parameters:getString ("RSI_Price"..i); 	   
	BL[Num]=  instance.parameters:getDouble ("BL"..i); 	   
	SL[Num]=  instance.parameters:getDouble ("SL"..i); 	   		
	  end
	end	
	
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
	

	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");
	assert(core.indicators:findIndicator("STOC_BB_RSI") ~= nil, "Please, download and install STOC_BB_RSI.LUA indicator");
	
	Id=0;
	local Test;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 Indicator[j] = {}; 			 
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      Test = core.indicators:create("STOC_BB_RSI", source   ,	STO_KPeriod[i],STO_DPeriod[i],STO_Slowing[i],STO_K[i],STO_D[i],BB_Period[i],BB_Deviation[i],RSI_Period[i],RSI_Price[i]);   
			    
			  
	          first= Test.DATA:first();
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first*2, 300) , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("STOC_BB_RSI", SourceData[j][i],	STO_KPeriod[i],STO_DPeriod[i],STO_Slowing[i],STO_K[i],STO_D[i],BB_Period[i],BB_Deviation[i],RSI_Period[i],RSI_Price[i]  );
                   
            
		end
	end
    
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    
	
	 core.host:execute ("setTimer", 1, 1);
	 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
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


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    

 
 
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + Id) then
			  loading[j][i] = false;               
			  end
		       
          end
	end    
	
	  
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if cookie== 1 and  not FLAG then
		for j = 1, Count, 1 do
			 for i = 1, Num, 1 do	
					Indicator[j][i]:update(core.UpdateLast); 			
			  end
		end    
	end
	
	if FLAG then	
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	
	 core.host:execute ("setStatus", "")	
    instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end



local initDraw = false;

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

	local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	
	if FLAG then
	return;
	end
	
	
	
	

	
	 core.host:execute ("setStatus", " Loaded ");
	 

	 
	  
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right();
    

    
    xGap=  (right-left)/(Num+1);	 
    yGap=  (bottom-top)/(Count+1);
	
	if yGap> (bottom-top)/5 then
    yGap= (bottom-top)/5 ;
    end
	
	iwidth = ((xGap/10)/100)*Size ;
	iheight=  (yGap/100)*Size;
		
		

           	
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
        context:createFont (8, "Wingdings",iwidth, iheight , 0);
		
		
		
 
	 
		        for i = 1, Count, 1 do
						 for j = 1, Num, 1 do	

                             if Indicator[i][j].STO:hasData( Indicator[i][j].STO:size()-1) and Indicator[i][j].RSI:hasData( Indicator[i][j].RSI:size()-1)  then
                            y1=bottom -(i+1)*yGap;	
							x1=right -(j+1)*xGap;
							x2=right -(j )*xGap;
							
							
						 if j== Num then 
							width, height = context:measureText (7, Pair[i], context.CENTER  ); 
							context:drawText (7, Pair[i], Color, -1, x1, y1-height+yGap*2, x2, y1+yGap*2, context.CENTER, 0);
							end
							
							
						  
							if i== Count then 
							width, height = context:measureText (7, TF[j], 0); 
							context:drawText (7,  TF[j], Color, -1, x1+xGap  , y1-height+yGap ,x2+xGap ,  y1+yGap , context.CENTER   );	
							end				

							
                         --green dot: sto > rsi and rsi>sto signal and sto signal > buy level and sto< +2 sigma
                         --red dot: sto< rsi and rsi<sto signal and sto signal < sell level and sto>-2 sigma
						 
								
								
								 Text= "\108";		
								 
								 
								 if  Indicator[i][j].STO[Indicator[i][j].STO:size()-1]  >  Indicator[i][j].RSI[Indicator[i][j].RSI:size()-1] 
								 and   Indicator[i][j].RSI[Indicator[i][j].RSI:size()-1]  >   Indicator[i][j].STO_Signal[Indicator[i][j].STO_Signal:size()-1]  
								 and  Indicator[i][j].STO_Signal[Indicator[i][j].STO_Signal:size()-1]  > BL[j]
								 and Indicator[i][j].STO[Indicator[i][j].STO:size()-1]  <  Indicator[i][j].Plus2Sigma[Indicator[i][j].Plus2Sigma:size()-1]  
								 then
								 TextColor=Up;
								 elseif Indicator[i][j].STO[Indicator[i][j].STO:size()-1]  <  Indicator[i][j].RSI[Indicator[i][j].RSI:size()-1] 
								 and   Indicator[i][j].RSI[Indicator[i][j].RSI:size()-1]  <   Indicator[i][j].STO_Signal[Indicator[i][j].STO_Signal:size()-1]  
								 and  Indicator[i][j].STO_Signal[Indicator[i][j].STO_Signal:size()-1]  < SL[j]
								  and Indicator[i][j].STO[Indicator[i][j].STO:size()-1]  >  Indicator[i][j].Minus2Sigma[Indicator[i][j].Minus2Sigma:size()-1]  
								 then
								 TextColor=Down;
								 else
								 TextColor=Neutral;
								 end
						 
								
								 width, height = context:measureText (8, Text, 0);	
								 context:drawText (8, Text, TextColor, -1, x1+xGap  , y1-height+yGap*2 ,x2+xGap ,  y1+yGap*2 , context.CENTER   );	
								 
						 	   
						   end
						 
						end 
	 
                   
                 
				 
				 end
		 
	
 
	
end 