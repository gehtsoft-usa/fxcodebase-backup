-- Id: 16237
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63592

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Multi currency pair, Multi Time Frame, Price MA Dashboard");
    indicator:description("Multi currency pair, Multi Time Frame, Price MA Dashboard");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation ");
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");

	indicator.parameters:addString("Mode", "Indicator mode", "Indicator mode" , "Arrows");
    indicator.parameters:addStringAlternative("Mode", "Arrows", "Arrows" , "Arrows");
    indicator.parameters:addStringAlternative("Mode", "Distance", "Distance" , "Distance");
	
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
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
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
	
    if id< 5 then
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);	
    else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);	
    end	
   
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end


 
function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
 
     indicator.parameters:addInteger("Period"..id, "MVA Period" , "", 30, 0, 1000)
	 
	 indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method"..id, "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addStringAlternative("Method"..id, "DEMA", "DEMA" , "DEMA");
	 

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
local pipSize;
 

local Method={} ;
local MA={};
local ma={};

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
local Mode;

local Shift;

function ReleaseInstance()
       core.host:execute("deleteFont", Bold1);	
	     core.host:execute("deleteFont", Bold2);
		 
		 core.host:execute ("killTimer", 1);
 end  

-- Routine
function RoundPips(index, Inp)
	return math.floor(Inp/Point[index]);
end

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
	Mode=instance.parameters.Mode;
	
	Shift=instance.parameters.Shift;

   
	
	Bold2  = core.host:execute("createFont", "Courier", Size, false, true);
	if Mode=="Arrows" then
		Bold1  = core.host:execute("createFont", "Wingdings", Size , false, true); 
	else
		Bold1  = core.host:execute("createFont", "Courier", Size, false, true);
	end
    Type= instance.parameters.Type;

    pipSize=source:pipSize();

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   
	   
       MA[Num]=  instance.parameters:getInteger ("Period"..i);
	  
	   Method[Num]=  instance.parameters:getString ("Method"..i);	   
	
	   
	   assert(core.indicators:findIndicator( Method[Num]) ~= nil, "Please, download and install " ..  Method[Num].. "indicator");
	  
	   
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
	local Test1,Test2,Test3;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 ma[j] = {}; 			 
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
		      Test1 = core.indicators:create(Method[i], source.close  ,MA[i]);   
		   
			  
	          first=  Test1.DATA:first() ;
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first, 300) , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   ma[j][i] = core.indicators:create(Method[i], SourceData[j][i].close, MA[i]   );
               
            
		end
	end
    
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    

	
	      core.host:execute ("setTimer", 1, 1);
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
	
	  if not FLAG and cookie== 1 then
		for j = 1, Count, 1 do				
	          for i = 1, Num, 1  do
				ma[j][i]:update(core.UpdateLast);				 
              end
          end
	end
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
	   core.host:execute ("setStatus", " " );	 
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
										
						 core.host:execute("drawLabel1", id ,Size*4 + Size*5*(i) ,  core.CR_LEFT, Shift +5*(Size)+ (-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  TF[i]);	
						 id = id+1;					
				 
	   end
	
	local BarColor=Neutral;
	local Alert= "\113";
	
		for j = 1, Count, 1 do
		core.host:execute("drawLabel1", id, Size  ,  core.CR_LEFT, Shift + 5*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  Pair[j]);			  
        id = id+1;	
		
		        for i = 1, Num, 1 do	
								
                         if  ma[j][i].DATA:hasData(ma[j][i].DATA:size()-1) then
					     if ma[j][i].DATA[ma[j][i].DATA:size()-1] < SourceData[j][i].close[SourceData[j][i].close:size()-1]
						 
						 then
						 if Mode=="Arrows" then
						 	Alert= "\228";
						 else
						 	Alert="" .. RoundPips(j, -ma[j][i].DATA[ma[j][i].DATA:size()-1]+SourceData[j][i].close[SourceData[j][i].close:size()-1]);
						 end
								 if  ma[j][i].DATA[ma[j][i].DATA:size()-2] > SourceData[j][i].close[SourceData[j][i].close:size()-2]
								 then 
								 if Mode=="Arrows" then
								 	Alert = Alert  ..   "\37";
								 end
								 end
						 BarColor= Up;
						 elseif ma[j][i].DATA[ma[j][i].DATA:size()-1] > SourceData[j][i].close[SourceData[j][i].close:size()-1]
						 then
						 if Mode=="Arrows" then
						 	Alert= "\230";
						 else
						 	Alert="" .. RoundPips(j, -ma[j][i].DATA[ma[j][i].DATA:size()-1]+SourceData[j][i].close[SourceData[j][i].close:size()-1]);
						 end
						         if   ma[j][i].DATA[ma[j][i].DATA:size()-2] < SourceData[j][i].close[SourceData[j][i].close:size()-2]
								 then 
								 if Mode=="Arrows" then
								 	Alert = Alert ..   "\37";
								 end
								 end
						 BarColor= Down;
						 else
						  BarColor=Neutral;
						  if Mode=="Arrows" then
	                      	Alert= "\113";
	                      else
	                      	Alert="0";
	                      end
						 end
						 
						 core.host:execute("drawLabel1", id , Size*4 + Size*5*(i) ,  core.CR_LEFT,Shift +5*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  Alert );	
						 id = id+1;	
                   
                    end
				 
				 end
		 end
	
 
	
end


 