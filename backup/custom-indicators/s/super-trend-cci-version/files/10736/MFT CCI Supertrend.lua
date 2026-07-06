-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4306
-- Id: 11893

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MFT CCI Supertrend");
    indicator:description("MFT CCI Supertrend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

   
   Add(1,"H8");
   Add(2,"D1");
   Add(3,"W1");
   Add(4,"M1");
   
   
  Style(1,"H8");
   Style(2,"D1");
   Style(3,"W1");
   Style(4,"M1");
 
   
 indicator.parameters:addGroup( "Style");
 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
 indicator.parameters:addColor("Size", "Font Size", "", 10);
end

function Style (id, TF)
    
  	indicator.parameters:addGroup(TF .. ".  Style Options");   
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
 
end

function Add(id, TF)

  indicator.parameters:addGroup( TF .. " Calculation");
    indicator.parameters:addString("TF"..id, "Time Frame", "", TF);
    indicator.parameters:addInteger("N"..id, "ATR periods", "", 10);
	 indicator.parameters:addDouble("M"..id, "ATR Multiplier", "", 2);
	indicator.parameters:addInteger("C"..id, "CCI periods", "", 50);

end

local widht={};
local style={};
 
local font;
local first;
local source = nil;
local offset,weekoffset;
 local N={};
 local M={};
 local C={};
 local TF={};
 local Number=4;
local loading={};
local Indicator={};
local SourceData={};
 local Label,Size;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	offset = core.host:execute("getTradingDayOffset");
    weekoffset =  core.host:execute("getTradingWeekOffset");	
     Label= instance.parameters.Label;
	 Size= instance.parameters.Size;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
     
	font  = core.host:execute("createFont", "Arial", Size, true, false);
	
	assert(core.indicators:findIndicator("CCI_SUPERTREND") ~= nil, "Please, download and install CCI_SUPERTREND.LUA indicator");    
	
	for i= 1, Number ,1 do
		TF[i]= instance.parameters:getString("TF" .. i);
		N[i]= instance.parameters:getInteger("N" .. i);
		M[i]= instance.parameters:getDouble("M" .. i);
		C[i]= instance.parameters:getInteger("C" .. i);
		style[i]= instance.parameters:getDouble ("style"..i);
		widht[i]= instance.parameters:getDouble ("widht"..i);	
		Test = core.indicators:create("CCI_SUPERTREND", source ,N[i],M[i],C[i]);  
				
		first= Test.DATA:first() +1; 		
		SourceData[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(300,first*2), 200+i, 100+i);
		Indicator[i]= core.indicators:create("CCI_SUPERTREND", SourceData[i] ,N[i],M[i],C[i]);  
		loading[i]=true;
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    local Flag=false;

	for i= 1, Number, 1 do	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag  then
	return;
	end	
	
	 
	if period < source:size()-1 then
	return;
	end
	
	local Color;
	core.host:execute ("removeAll")
	
	for i= 1, Number, 1 do	
	
		Indicator[i]:update( core.UpdateLast );
		
		Color= Indicator[i].DATA:colorI(Indicator[i].DATA:size()-1);
		Level=Indicator[i].DATA[Indicator[i].DATA:size()-1];
		
	   Start,End = core.getcandle(TF[i], core.now(), offset, weekoffset);	
	 
		
		core.host:execute("drawLine", i, Start, Level, End, Level, Color, style[i], widht[i]);
		 core.host:execute("drawLabel1", 100+ i,  End, core.CR_CHART, Level, core.CR_CHART, core.H_Right, core.V_Bottom, font, Label,  string.format("%." .. source:getPrecision () .. "f", Level ) .. " ("  .. TF[i] ..  ")");
	end	 
	 
	 
end


function ReleaseInstance()
       core.host:execute("deleteFont", font ); 
 end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;	 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end







