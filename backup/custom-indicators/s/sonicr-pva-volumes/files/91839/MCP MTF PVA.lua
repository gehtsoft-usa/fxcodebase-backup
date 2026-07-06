-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60177

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

function Init()
    indicator:name("Multi currency pair, Multi Time Frame, PVA Table");
    indicator:description("Multi currency pair, Multi Time Frame, PVA Table");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
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

	
	indicator.parameters:addGroup( "Style");
	indicator.parameters:addInteger("Size", "Size", "", 10);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	
	
	 indicator.parameters:addColor("C1", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
	
	indicator.parameters:addColor("C2", "Color of Rising Bull", "Color of Rising Bull", core.rgb(0,200, 0));	
	indicator.parameters:addColor("C3", "Color of Rising Bear", "Color of Rising Bear", core.rgb(200,0, 0));
	
	indicator.parameters:addColor("C4", "Color of Climax Bull", "Color of Climax Bull", core.rgb(0,255, 0));	
	indicator.parameters:addColor("C5", "Color of Climax Bear", "Color of Climax Bear", core.rgb(255,0, 0));
	
	
end



function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
 
    indicator.parameters:addInteger("PVA_Climax_Period"..id, "PVA Climax Period", "PVA Climax Period", 10);
    indicator.parameters:addInteger("PVA_Rising_Period"..id, "PVA Rising Period", "PVA Rising Period", 10);
    indicator.parameters:addDouble("PVA_Rising_Factor"..id, "PVA Rising Factor", "PVA Rising Factor", 1);
    indicator.parameters:addDouble("PVA_Extreme_Factor"..id, "PVA Extreme Factor", "PVA Extreme Factor", 2);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;
local first;
local source = nil;
local Color;

local PVA={};

local PVA_Climax_Period={};
local PVA_Rising_Period={};
local PVA_Rising_Factor={};
local PVA_Extreme_Factor={};

local Num;
local loading={};
local SourceData={};

local PointSize;
local Pair, Count;
local TF={};
local Bold2, Bold1;
local id;


local Up, Down;
 

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

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Bold2  = core.host:execute("createFont", "Courier", Size, false, true);
	Bold1  = core.host:execute("createFont", "Wingdings", Size , false, true); 
	
	assert(core.indicators:findIndicator("PVA") ~= nil, "Please, download and install PVA.LUA indicator");
	
	
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   
	   
       PVA_Climax_Period[Num]=  instance.parameters:getInteger ("PVA_Climax_Period"..i);	   
	   PVA_Rising_Period[Num]=  instance.parameters:getInteger ("PVA_Rising_Period"..i);
	  
	  PVA_Rising_Factor[Num]=  instance.parameters:getDouble ("PVA_Rising_Factor"..i);	   
	   PVA_Extreme_Factor[Num]=  instance.parameters:getDouble("PVA_Extreme_Factor"..i);
	   
	
	  end
	end	
	
	
	Id=0;
	local Test1,Test2,Test3;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 PVA[j] = {};				
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      Test1 = core.indicators:create("PVA", source  ,PVA_Climax_Period[i] ,PVA_Rising_Period[i],PVA_Rising_Factor[i] ,PVA_Extreme_Factor[i]);   
			  
	          first=  Test1.DATA:first();
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   PVA[j][i] = core.indicators:create("PVA", SourceData[j][i],PVA_Climax_Period[i] ,PVA_Rising_Period[i],PVA_Rising_Factor[i] ,PVA_Extreme_Factor[i]
			   ,instance.parameters.C1,instance.parameters.C2,instance.parameters.C3,instance.parameters.C4   );
                
            
		end
	end
    
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    
end



function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    

if period < source:size()-1 then
return;
end

for j = 1, Count, 1 do				
	for i = 1, Num, 1  do
				PVA[j][i]:update(core.UpdateLast);
				 
  end
end

 
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
			  instance:updateFrom(0);
			  
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
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	end
   
        
    return core.ASYNC_REDRAW ;
end

function getPointSize()
    PointSize = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        PointSize[count] = row.PointSize;      
      
        row = enum:next();
    end

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
										
						 core.host:execute("drawLabel1", id ,Size*10 + Size*5*(i) ,  core.CR_LEFT, 10*(Size)+ (-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  TF[i]);	
						 id = id+1;					
				 
	   end
	
	local BarColor=instance.parameters.C1;
	
		for j = 1, Count, 1 do
		core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, 10*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold2, Color,  Pair[j]);			  
        id = id+1;	
		
		        for i = 1, Num, 1 do	
								
                
					    BarColor=  PVA[j][i].DATA:colorI(PVA[j][i].DATA:size()-1);
						 core.host:execute("drawLabel1", id , Size*10 + Size*5*(i) ,  core.CR_LEFT, 10*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  "\108" );	
						 id = id+1;	
                   
                 
				 
				 end
		 end
	
 
	
end


 