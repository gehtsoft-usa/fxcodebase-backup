
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62917

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Multi currency pair, Multi Time Frame, Moving Average Channel Break Dashboard");
    indicator:description("Multi currency pair, Multi Time Frame, Moving Average Channel Break Dashboard");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation ");
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 

	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 34);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	
	indicator.parameters:addGroup("Volume Filter");
	indicator.parameters:addBoolean("UseFilter", "Use Volume Filter", "", true);		
	indicator.parameters:addInteger("VolumeNumber", "Number of High Volume Currency pair", "Volume" , 5,1,  200);
	
	indicator.parameters:addString("vTF", "Volume Time frame", "", "D1");
    indicator.parameters:setFlag("vTF", core.FLAG_PERIODS);

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
	
    
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
   
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
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
local VolumeNumber,UseFilter;
local Size;
local first;
local source = nil;
local Color, Up, Down,Neutral;

local vTF;

local Top={};
local Bottom={};
local Period, Method, Price;

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

local VolumeLoading={};
local Volume={};

function ReleaseInstance()
       core.host:execute("deleteFont", Bold1);	
	     core.host:execute("deleteFont", Bold2);
 end  

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	VolumeNumber=instance.parameters.VolumeNumber;
	UseFilter=instance.parameters.UseFilter;
	vTF=instance.parameters.vTF;
	
	
	Period=instance.parameters.Period;
	Method=instance.parameters.Method; 
	
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " .. Method ..".LUA indicator");
	
	
	Bold2  = core.host:execute("createFont", "Courier", Size, false, true);
	Bold1  = core.host:execute("createFont", "Wingdings", Size , false, true); 
    Type= instance.parameters.Type;

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	    
	   TF[Num]=  instance.parameters:getString ("TF"..i); 
	   
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
	
	
	id=0;
	local Test1,Test2 ;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 Top[j]={};
             Bottom[j]={};			 
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      id=id+1;
		 
		      Test1 = core.indicators:create(Method , source.close  ,Period);   
			  Test2 = core.indicators:create(Method, source.close  ,Period); 
             
			  
	          first=  math.max(Test1.DATA:first() ,Test2.DATA:first());
		 
		 	  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first, 300) , 2000 +  id , 1000 + id);
			   loading[j][i] = true;  
			  
			   Top[j][i] = core.indicators:create(Method, SourceData[j][i].high, Period   );
               Bottom[j][i] = core.indicators:create(Method, SourceData[j][i].low, Period   );		

               if UseFilter then
			   Volume[j] = core.host:execute("getSyncHistory", Pair[j], vTF, source:isBid(), 1 , 4000 +  j , 3000 + j);
			   VolumeLoading[j] = true;  
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
    local id=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		     
			  id=id+1;
			  
			  if cookie == (1000 + id)   then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + id)  then
			  loading[j][i] = false;            
					  
			  end
			  
				  if UseFilter then
					   if  cookie == (3000 + j)  then
					  VolumeLoading[j] = true;
					  elseif  cookie == (4000 + j)  then
					  VolumeLoading[j]= false;    	  
				  end
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
		       if UseFilter then
						if  VolumeLoading[j] then
								 FLAG= true;
								 Number=Number+1;
						end
				end
    end
	
	
	if not FLAG and cookie== 1 then
	
	
			 for j = 1, Count, 1 do
				  for i = 1, Num, 1 do	
						Top[j][i]:update(core.UpdateLast);
						Bottom[j][i]:update(core.UpdateLast); 
				 end
			end		
			
			
	end
	
	if FLAG then
		 if UseFilter then
		 core.host:execute ("setStatus", "  Loading "..((Count*Num+Count) - Number) .. " / " .. (Count*Num+Count) );  
		 else
		 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );  
		 end
    else  
	      core.host:execute ("setStatus", "Loaded" ) 
    	  instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end


function Filter()

 local Index={};
 local FilterFlag=true;
 
 for j = 1, Count, 1 do
 Index[j]= j; 
 end
            		 
      if  UseFilter then 
                           while FilterFlag do
						   FilterFlag=false;
                                          for j = 2, Count, 1 do
										          p1= Index[j-1];
												  p2= Index[j];
                                                  if   Volume[p2].volume[Volume[p2].volume:size()-1] >  Volume[p1].volume[Volume[p1].volume:size()-1] then
												  Temp=p1;
												  Index[j-1]=p2 ;
												  Index[j]=p1;	
                                                FilterFlag=true												  
												  end		   
													  
										 end
 
                           end
				 end	
				 
 
 if UseFilter then 							 
 return Index, math.min(Count,VolumeNumber);
 else
 return Index, Count;
 end
end



local initDraw = false;

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

	id=0;
	
	local FLAG=false; 
 
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] 
				 or (VolumeLoading[j]and UseFilter )  then
				 FLAG= true; 
				 end
		 
         end  	
    end
	
	
	if FLAG then
	return;
	else
	 
				
	end
	
	local xCount,NewIndex;

	NewIndex, xCount= Filter();
	 
	
	 core.host:execute ("setStatus", " Loaded ");
	 

	 
	
	   for i = 1, Num, 1 do	
										
						 core.host:execute("drawLabel1", id ,Size*4 + Size*5*(i) ,  core.CR_LEFT, 5*(Size)+ (-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  TF[i]);	
						 id = id+1;					
				 
	   end
	
	local BarColor=Neutral;
	local Alert= "\113";
	local x=0;
	
		for k = 1, xCount, 1 do 
			j=NewIndex[k]; 
			
		x=x+1;
	
		core.host:execute("drawLabel1", id, Size  ,  core.CR_LEFT, 5*Size+(x-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  Pair[j]);			  
        id = id+1;	
		
		        for i = 1, Num, 1 do	
								
                         if Top[j][i].DATA:hasData(Top[j][i].DATA:size()-1 ) then
					     if SourceData[j][i].close[ SourceData[j][i].close:size()-1]> Top[j][i].DATA[Top[j][i].DATA:size()-1]
						 then
						 Alert= "\228";
								  if  SourceData[j][i].close[ SourceData[j][i].close:size()-1]<= Top[j][i].DATA[Top[j][i].DATA:size()-1]								 
								 then 
								 Alert = Alert  ..   "\37";
								 end 
						 BarColor= Up;
						 elseif SourceData[j][i].close[ SourceData[j][i].close:size()-1]< Bottom[j][i].DATA[Bottom[j][i].DATA:size()-1]
						 then
						 Alert= "\230";
						         if  SourceData[j][i].close[ SourceData[j][i].close:size()-1]>= Bottom[j][i].DATA[Bottom[j][i].DATA:size()-1]		
								 then 
								 Alert = Alert ..   "\37";
								 end 
						 BarColor= Down;
						 else
						  BarColor=Neutral;
	                      Alert= "\113";
						 end
						 
						 core.host:execute("drawLabel1", id , Size*4 + Size*5*(i) ,  core.CR_LEFT, 5*Size+(x-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  Alert );	
						 id = id+1;	
                   
                   end
				 
				 end
		 end
	
 
	
end


 