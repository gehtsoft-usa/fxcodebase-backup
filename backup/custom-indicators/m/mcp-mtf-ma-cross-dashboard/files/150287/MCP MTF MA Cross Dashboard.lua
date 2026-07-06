-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64558

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Multi currency pair, Multi Time Frame, MA Cross Dashboard");
    indicator:description("Multi currency pair, Multi Time Frame, MA Cross Dashboard");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation ");
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");


	indicator.parameters:addGroup( "Selector");
	indicator.parameters:addBoolean("TheShort", "Use Short", "", true);
	indicator.parameters:addBoolean("TheMedium", "Use Medium", "", true);	
	indicator.parameters:addBoolean("TheLong", "Use Long", "", true);	
	
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
	indicator.parameters:addInteger("Size", "Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 10);	
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL );
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0,255, 0));	
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255,0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
 
	 
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
   
 
     indicator.parameters:addInteger("Short"..id, "Short MVA Period" , "", 30, 0, 1000)
	 
	 indicator.parameters:addString("ShortMethod"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("ShortMethod"..id, "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addStringAlternative("ShortMethod"..id, "DEMA", "DEMA" , "DEMA");
	 
    indicator.parameters:addInteger("Medium"..id, "Medium MVA Period" , "", 50, 0, 1000)
	indicator.parameters:addString("MediumMethod"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("MediumMethod"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("MediumMethod"..id, "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addStringAlternative("MediumMethod"..id, "DEMA", "DEMA" , "DEMA");
	 
	 
    indicator.parameters:addInteger("Long"..id, "Long MVA Period" , "", 100, 0, 1000)
	indicator.parameters:addString("LongMethod"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("LongMethod"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("LongMethod"..id, "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addStringAlternative("LongMethod"..id, "DEMA", "DEMA" , "DEMA");
	
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
 

local LongMethod={} ;
local MediumMethod={};
local ShortMethod={};

local Long={} ;
local Medium={};
local Short={};

local long={} ;
local medium={};
local short={};

local TheShort;
local TheLong;
local TheMedium;

local Num;
local loading={};
local SourceData={};
local Point={};
local Pair={};
local Count;
local TF={};
local Bold2, Bold1;
local id;
local Dodaj={};
function ReleaseInstance()
       core.host:execute("deleteFont", Bold1);	
	     core.host:execute("deleteFont", Bold2);
 end  

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	Shift=instance.parameters.Shift;

    TheMedium=  instance.parameters:getBoolean ("TheMedium");	   
	TheShort=  instance.parameters:getBoolean ("TheShort");
    TheLong=  instance.parameters:getBoolean ("TheLong");	  
	
	Bold2  = core.host:execute("createFont", "Courier", Size, false, true);
	Bold1  = core.host:execute("createFont", "Wingdings", Size , false, true); 
    Type= instance.parameters.Type;

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   
	   
       Medium[Num]=  instance.parameters:getInteger ("Medium"..i);	   
	   Short[Num]=  instance.parameters:getInteger ("Short"..i);
       Long[Num]=  instance.parameters:getInteger ("Long"..i);
	   
	  
	    MediumMethod[Num]=  instance.parameters:getString ("MediumMethod"..i);	   
	   ShortMethod[Num]=  instance.parameters:getString  ("ShortMethod"..i);
       LongMethod[Num]=  instance.parameters:getString  ("LongMethod"..i);
	   
	   assert(core.indicators:findIndicator( MediumMethod[Num]) ~= nil, "Please, download and install " ..  MediumMethod[Num].. "indicator");
	   assert(core.indicators:findIndicator(ShortMethod[Num]) ~= nil, "Please, download and install " ..  ShortMethod[Num].. "indicator");
	   assert(core.indicators:findIndicator(LongMethod[Num]) ~= nil, "Please, download and install " ..  LongMethod[Num].. "indicator");
	   
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
	
	
	Id=0;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 short[j] = {};		
             long[j] = {};	
             medium[j] = {}; 			 
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		      if TheShort then
              assert(core.indicators:findIndicator(ShortMethod[i]) ~= nil, ShortMethod[i] .. " indicator must be installed");
			  end
		      if TheMedium then			  
              assert(core.indicators:findIndicator(MediumMethod[i]) ~= nil, MediumMethod[i] .. " indicator must be installed");
              end
			  
			  if TheLong then
			  assert(core.indicators:findIndicator(LongMethod[i]) ~= nil, LongMethod[i] .. " indicator must be installed");
			  end
			  
 
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),300 , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			   if TheShort then
			   short[j][i] = core.indicators:create(ShortMethod[i], SourceData[j][i].close, Short[i]   );
			   end
			   
		      if TheMedium then	
               medium[j][i] = core.indicators:create(MediumMethod[i], SourceData[j][i].close, Medium[i]   );
			   end
			   
			   if TheLong then			   
               long[j][i] = core.indicators:create(LongMethod[i], SourceData[j][i].close, Long[i]   );			   
               end
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
	
	
		if not FLAG and cookie == 1 then
		
					for j = 1, Count, 1 do				
						for i = 1, Num, 1  do
									if TheMedium then
									medium[j][i]:update(core.UpdateLast);
									end
									if TheShort then					
									short[j][i]:update(core.UpdateLast);
									end
									
									if TheLong then
									long[j][i]:update(core.UpdateLast); 
									end
					  end
				  end
	 
	  end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	 core.host:execute ("setStatus", "  Loaded" );	
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end



local initDraw = false;

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

	id=0;
	
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
	 

	 
	
	   for i = 1, Num, 1 do	
										
						 core.host:execute("drawLabel1", id ,Size*4 + Size*5*(i) ,  core.CR_LEFT, Shift*(Size)+ (-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  TF[i]);	
						 id = id+1;					
				 
	   end
	
	local BarColor=Neutral;
	local Alert= "\113";
	
		for j = 1, Count, 1 do
		core.host:execute("drawLabel1", id, Size  ,  core.CR_LEFT, Shift*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  Pair[j]);			  
        id = id+1;	
		
		        for i = 1, Num, 1 do	
					 

                    local SignalLong=1;
                    local SignalShort=1;					
					local ItIs=1;
                    if  TheShort and short[j] ~=nil then
						if not short[j][i].DATA:hasData(short[j][i].DATA:size()-1) then
						ItIs=0;
						end
					end
					 
                    if  TheMedium and medium[j] ~=nil then					
				        if not medium[j][i].DATA:hasData(medium[j][i].DATA:size()-1) then
						ItIs=0;
						end
				    end
				   
                    if  TheLong and long[j] ~=nil then
						 if not long[j][i].DATA:hasData(long[j][i].DATA:size()-1) then
						 ItIs=0;
						 end
                    end					
					    
						if ItIs~=0 then
							if TheShort and  TheMedium then 
								 if short[j][i].DATA[short[j][i].DATA:size()-1] > medium[j][i].DATA[medium[j][i].DATA:size()-1] then
								 SignalShort=0;
								 elseif short[j][i].DATA[short[j][i].DATA:size()-1] < medium[j][i].DATA[medium[j][i].DATA:size()-1] then
								 SignalLong=0;
								 end							 
							end
							
							if TheShort and  TheLong then
								if short[j][i].DATA[short[j][i].DATA:size()-1] > long[j][i].DATA[long[j][i].DATA:size()-1] then
								 SignalShort=0;
								 elseif short[j][i].DATA[short[j][i].DATA:size()-1] < long[j][i].DATA[long[j][i].DATA:size()-1] then
								 SignalLong=0;
								 end	
							end
							
							if TheMedium and  TheLong then
							
								 if medium[j][i].DATA[medium[j][i].DATA:size()-1] > long[j][i].DATA[long[j][i].DATA:size()-1] then
								 SignalShort=0;
								 elseif medium[j][i].DATA[medium[j][i].DATA:size()-1] < long[j][i].DATA[long[j][i].DATA:size()-1] then
								 SignalLong=0;
								 end							
							end
						end
						
						
						if SignalLong == 1 and SignalShort==0 then
						Alert= "\228";
						BarColor= Up;					
						elseif SignalLong == 0 and SignalShort==1 then
						Alert= "\230";			
						BarColor= Down;						
                        else
						BarColor=Neutral;						
	                    Alert= "\113";						
                        end
						
						
						 core.host:execute("drawLabel1", id , Size*4 + Size*5*(i) ,  core.CR_LEFT, Shift*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  Alert );	
						 id = id+1;	
                   
                 end
				 
				 end
		 
	
 
	
end


 

 --+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+