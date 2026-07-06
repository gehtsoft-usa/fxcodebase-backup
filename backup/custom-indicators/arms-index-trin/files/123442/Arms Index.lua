-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67284

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
function Init()
    indicator:name("Arms Index");
    indicator:description("Arms Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 21);
	indicator.parameters:addGroup("Selector");	
    local i;
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "USD");
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	 
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 2);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.5);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end


 

local loading={};
local SourceData={};
local Instrument={};

local Num;
local Index; 
 
local Default;
local pdate = "(%a%a%a)/(%a%a%a)";
local Position={};

local dayoffset, weekoffset;
local Data;
local Period;
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
 
function Prepare(nameOnly)      
	
    source = instance.source;
	Default = instance.parameters.Default;
	Period = instance.parameters.Period;
	 
	
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	local Pair, Count,Point = getInstrumentList();
		
 
	Num=0;
	local First, Second;
	for i = 1 , Count , 1 do   
	
	  
	   
	    First, Second= string.match( Pair[i], pdate);
	   
	   
			  if First== Default or Second== Default then
			  Num = Num+1;	

              Instrument[Num]=Pair[i];	


				  if First== Default then
				  Position[Num]=1;
				  else
				  Position[Num]=2;
				  end  			  
			 
			  end
	  
	end	
	
	
	
		
	local i;
			 
		 for i = 1, Num, 1 do	
		 
			   SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0  ,20000 +i , 10000 + i);
			   loading[i] = true;  
			  
			 
		end
 
		 
 		Data = instance:addInternalStream(0, 0);	  
	
		Index = instance:addStream("Index", core.Line, Default .. " Index",  Default.." Index",  instance.parameters.color, source:first());
		Index:setWidth(instance.parameters.width);
        Index:setStyle(instance.parameters.style);
        Index:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Index:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		Index:addLevel(1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		Index:setPrecision(math.max(2, instance.source:getPrecision()));
end




function Update(period)

 if period < source:first()+Period then
 return
 end
 
 
local p={};
 
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	
		 
		       
			     p[i]= Initialization(i, period);

                 if loading[i] or p[i]== false then
				 FLAG= true;				
				 end         	
         end
	
	if FLAG then 
	return;
	end
 
	local i;
	
						
	local advances=0;
	local declines=0;
	local advancing_volume=0;
	local declining_volume=0;	
             			
			 
							  for i = 1, Num, 1 do
									 
									 
								if SourceData[i].close:hasData(p[i]) then	 
								
								
								
		 
										
										         if Position[i]==1 then
														 if SourceData[i].close[p[i]]>  SourceData[i].open[p[i]]then
														 advances=advances+1;
														 advancing_volume=advancing_volume+SourceData[i].volume[p[i]];		
														 elseif SourceData[i].close[p[i]]<  SourceData[i].open[p[i]]then
														 declines=declines+1;
														 declining_volume=advancing_volume+SourceData[i].volume[p[i]];
														 end 
												 else
												 
														  if SourceData[i].close[p[i]]<  SourceData[i].open[p[i]]then
														 advances=advances+1;
														 advancing_volume=advancing_volume+SourceData[i].volume[p[i]];
														 elseif	 SourceData[i].close[p[i]]>  SourceData[i].open[p[i]]then
														 declines=declines+1;
														 declining_volume=advancing_volume+SourceData[i].volume[p[i]];
														 end 

                                                  end
									 
									 
									 
							  end
							  
							  end
							  if declines==0 or declining_volume==0 or advancing_volume==0 then
							  Data[period]= Index[period-1];
							  else
							  Data[period]= (advances / declines) / (advancing_volume / declining_volume);								  
                              end	


							  
			             					 
    Index[period]=mathex.avg(Data, period-Period+1, period); 					
	
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;   
			  
			  end
		       
          end
	
	
	
    local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num - Number) .. " / " .. (Num) ));	 
	else
	core.host:execute ("setStatus", "Loaded")
  	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end




