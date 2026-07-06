-- Id: 19360
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62332

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

function Init()
    indicator:name("MTF MCP HA Zone Trade List");
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
    indicator.parameters:addColor("Up", "Up Trend Color","", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Trend Color","",core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
 
	
	
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
	
	
	indicator.parameters:addString("Source".. id, "AO/AC Indicator Source Data", "Source Data" , "Price");
    indicator.parameters:addStringAlternative("Source".. id, "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Source".. id, "HA", "HA" , "HA")
	
    indicator.parameters:addInteger("FM".. id, "AC/AO fast moving average", "", 5);
    indicator.parameters:addInteger("SM".. id, "AC/AO slow moving average", "", 35);
    indicator.parameters:addInteger("AM".. id, "A/C moving average", "", 5);
 
	indicator.parameters:addInteger("MT" .. id, "Zone Trade", "" , 1);	
    indicator.parameters:addIntegerAlternative("MT".. id, "Awesome oscillator(AO)", "ZONE" , 2);
    indicator.parameters:addIntegerAlternative("MT".. id, "Acceleration/Deceleration (AC)", "" , 3);
	indicator.parameters:addIntegerAlternative("MT".. id, "B.W. Zone AC + AO", "" , 1);
	
	
	
	
	indicator.parameters:addString("Method".. id, "Presentation Method", "Method" , "Heiken Ashi");
    indicator.parameters:addStringAlternative("Method".. id, "Heiken Ashi", "Heiken Ashi" , "Heiken Ashi");
    indicator.parameters:addStringAlternative("Method".. id, "Price", "Price" , "Price")
	
end

function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
 
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
 

local Period={};
local Deviation={};
local Indicator={};
local Proximity={};

local Num;
local loading={};
local SourceData={};
local Point={};
local Pair={};
local Count;
local TF={};

local id;
local Dodaj={};


local Source={};
local FM={};
local SM={};
local AM={};
local MT={};
local Method={};

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
	
	if   (nameOnly) then
        return;
    end

    Type= instance.parameters.Type;

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i); 	   
      
		 Source[Num]=  instance.parameters:getString ("Source"..i); 	   
		  FM[Num]=  instance.parameters:getInteger ("FM"..i); 	   
		 SM[Num]=  instance.parameters:getInteger ("SM"..i); 	   
		 AM[Num]=  instance.parameters:getInteger ("AM"..i); 	   
		 MT[Num]=  instance.parameters:getInteger ("MT"..i); 	   
		 Method[Num]=  instance.parameters:getString ("Method"..i); 	   
	   
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
	
	
	assert(core.indicators:findIndicator( "HEIKEN ASHI ZONE TRADE" ) ~= nil, "Please, download and install HEIKEN ASHI ZONE TRADE.LUA indicator");
	
	Id=0;
	local Test;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 Indicator[j] = {}; 			 
             loading[j] = {};	
 

		 for i = 1, Num, 1 do	
		 
    assert(core.indicators:findIndicator("HEIKEN ASHI ZONE TRADE") ~= nil, "HEIKEN ASHI ZONE TRADE" .. " indicator must be installed");
		      Test = core.indicators:create("HEIKEN ASHI ZONE TRADE", source,Source[i], FM[i], SM[i],AM[i],MT[i], Method[i], Up, Down,Neutral    );   
			    
			  
	          first= Test.DATA:first();
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first*2, 300) , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("HEIKEN ASHI ZONE TRADE", SourceData[j][i],Source[i], FM[i], SM[i],AM[i],MT[i], Method[i], Up, Down,Neutral   );
                   
            
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
        context:createFont (8, "Wingdings",iwidth, iheight , context.UNDERLINE);
		
		
		
 
	 
		        for i = 1, Count, 1 do
						 for j = 1, Num, 1 do	

                             if Indicator[i][j].DATA:hasData( Indicator[i][j].DATA:size()-1) then
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

							
                         
						 
								  
								
								 
								 local iColor1;
								 
								 
								 if  Indicator[i][j].close[Indicator[i][j].close:size()-1]  >   Indicator[i][j].open[Indicator[i][j].open:size()-1] 
								 then
								 iColor1=Up;
								 else
								 iColor1=Down;
								 end
								 
								 
						
								
								  Text= "\110";
							 
								 width, height = context:measureText (8, Text, 0);	
								 context:drawText (8, Text, iColor1, -1, x1+xGap  , y1-height+yGap*2 ,x2+xGap ,  y1+yGap*2 , context.CENTER   );	
								 
						 	   
						   end
						 
						end 
	 
                   
                 
				 
				 end
		 
	
 
	
end