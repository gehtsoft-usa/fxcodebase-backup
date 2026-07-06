-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59997
-- Id: 11203

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
    indicator:name("Multi currency pair, Multi Time Frame, Step Choppy");
    indicator:description("Multi currency pair, Multi Time Frame, Step Choppy");
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
	
	
 
    indicator.parameters:addColor("Color1", "Strong Up trend color", "Strong Up trend color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Color2", "Retrace Up trend color", "Retrace Up trend color", core.rgb(128, 128, 255));
    indicator.parameters:addColor("Color3", "Choppy Up trend color", "Choppy Up trend color", core.rgb(128, 255, 255));
    indicator.parameters:addColor("Color4", "Be ready to change Up trend color", "Be ready to change Up trend color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("Color5", "Strong Dn trend color", "Strong Dn trend color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("Color6", "Retrace Dn trend color", "Retrace Dn trend color", core.rgb(255, 128, 128));
    indicator.parameters:addColor("Color7", "Choppy Dn trend color", "Choppy Dn trend color", core.rgb(255, 128, 64));
    indicator.parameters:addColor("Color8", "Be ready to change Dn trend color", "Be ready to change Dn trend color", core.rgb(255, 255, 0));
	
	
end



function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
   
 
    indicator.parameters:addInteger("Period"..id, "Period", "", 10);
    indicator.parameters:addDouble("Kv"..id, "Kv", "", 1);
    indicator.parameters:addInteger("StepSize"..id, "Step size", "", 0);
    indicator.parameters:addString("Mode"..id, "MA mode", "", "MVA");
    indicator.parameters:addStringAlternative("Mode"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Mode"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Mode"..id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Mode"..id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Mode"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Mode"..id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Mode"..id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Mode"..id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Mode"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Mode"..id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Mode"..id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Mode"..id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Mode"..id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Mode"..id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Mode"..id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Mode"..id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Mode"..id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Mode"..id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Mode"..id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Mode"..id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Mode"..id, "JSmooth", "", "JSmooth");
    indicator.parameters:addString("UsePrice"..id, "Use price", "", "0");
    indicator.parameters:addStringAlternative("UsePrice"..id, "Close", "", "0");
    indicator.parameters:addStringAlternative("UsePrice"..id, "High/Low", "", "1");
    indicator.parameters:addDouble("StepSizeFast"..id, "Step size fast", "", 5);
    indicator.parameters:addDouble("StepSizeSlow"..id, "Step size slow", "", 15);
	
end
local Period={};
local Kv={};
local StepSize={};
local Mode={};
local UsePrice={};
local StepSizeFast={};
local StepSizeSlow={};

local Size;
local first;
local source = nil;
local Color, Color1, Color2, Color3, Color4, Color5, Color6, Color7, Color8;

local SC={};
 

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
	Color1=instance.parameters.Color1;
	Color2=instance.parameters.Color2;
	Color3=instance.parameters.Color3;
	Color4=instance.parameters.Color4;
	Color5=instance.parameters.Color5;
	Color6=instance.parameters.Color6;
	Color7=instance.parameters.Color7;
	Color8=instance.parameters.Color8;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Bold2  = core.host:execute("createFont", "Courier", Size, false, true);
	Bold1  = core.host:execute("createFont", "Wingdings", Size , false, true); 
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	assert(core.indicators:findIndicator("STEP_CHOPPY") ~= nil, "Please, download and install STEP_CHOPPY.LUA indicator");
	assert(core.indicators:findIndicator("STEP_MA") ~= nil, "Please, download and install STEP_MA.LUA indicator");
	assert(core.indicators:findIndicator("STEP_RSI2") ~= nil, "Please, download and install STEP_RSI2.LUA indicator");
	
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   
 Period[Num]=  instance.parameters:getInteger ("Period"..i);
 Kv[Num]=  instance.parameters:getDouble ("Period"..i);
 StepSize[Num]=  instance.parameters:getInteger ("StepSize"..i);
 Mode[Num]=  instance.parameters:getString ("Mode"..i);
 UsePrice[Num]=  instance.parameters:getString("UsePrice"..i);
 StepSizeFast[Num]=  instance.parameters:getDouble ("StepSizeFast"..i);
 StepSizeSlow[Num]=  instance.parameters:getDouble ("StepSizeSlow"..i);
 
	 
	
	  end
	end	
	
	
	Id=0;
	local Test1,Test2,Test3;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 SC[j] = {};				
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      Test1 = core.indicators:create("STEP_CHOPPY", source  ,Period[i] ,Kv[i],StepSize[i] ,Mode[i] ,UsePrice[i],StepSizeFast[i] ,StepSizeSlow[i]);   
			  
	          first=  Test1.DATA:first()*2;
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first) , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			   SC[j][i] = core.indicators:create("STEP_CHOPPY", SourceData[j][i],Period[i] ,Kv[i],StepSize[i] ,Mode[i] ,UsePrice[i],StepSizeFast[i] ,StepSizeSlow[i]
			   ,Color1, Color2,Color3,Color4,Color5,Color6,Color7,Color8  );
                
            
		end
	end
    
	
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
	

for j = 1, Count, 1 do				
	for i = 1, Num, 1  do
				SC[j][i]:update(core.UpdateLast);
				 
  end
end


	id=0;
	


	
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
								
                
					    BarColor=  SC[j][i].DATA:colorI(SC[j][i].DATA:size()-1);
						 core.host:execute("drawLabel1", id , Size*10 + Size*5*(i) ,  core.CR_LEFT, 10*Size+(j-1)*Size*1.5  , core.CR_TOP, core.H_Right, core.V_Center, Bold1, BarColor,  "\108" );	
						 id = id+1;	
                   
                 
				 
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
    else
    instance:updateFrom(0);	
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
 

 