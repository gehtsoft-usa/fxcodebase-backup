-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60739

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
    indicator:name("MTF Bollinger Bands");
    indicator:description("MTF Bollinger Bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    Add(1, "Chart" );
	Add(2, "W1" );
	Add(3, "M1" );
 
	AddStyle(1, core.rgb(255, 0, 0));
	AddStyle(2, core.rgb(0, 255, 0));
	AddStyle(3,  core.rgb(0, 0, 255));
end

 
function Add(id, TimeFrame)


    local iTF={"m1", "m5","m15","m30", "H1", "H2", "H3", "H4", "H6","H8", "D1", "W1", "M1" , "Chart"};
    
    indicator.parameters:addGroup(id .. ". Time Frame");	
	indicator.parameters:addBoolean("On"..id, "Use This Time Frame", "", true);
	indicator.parameters:addString("TF"..id, "Time frame", "", TimeFrame);
	for i= 1, 14, 1 do
    indicator.parameters:addStringAlternative("TF"..id, iTF[i], "", iTF[i]);
	end
	
	indicator.parameters:addInteger("Period"..id, "Period", "Period", 20); 
	indicator.parameters:addDouble("Deviation"..id, "Number of Standard Deviation", "Number of Standard Deviation", 2); 
	indicator.parameters:addBoolean("Use"..id, "Use Central Line", "", true);
	
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
end
function AddStyle(id , Color)
	indicator.parameters:addGroup(id .. ". Time Frame Style");
	indicator.parameters:addColor("LColor"..id, "Line Color"       , "Line Color"  ,Color);
    indicator.parameters:addColor("MColor"..id, "Central Line Color", "Central Line ", Color);
	
	indicator.parameters:addInteger("Width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..id, core.FLAG_LINE_STYLE);

  
end 
local Width={};
local Style={};
local Deviation={};
local offset,weekoffset;
local SourceData={};
local  TF={};
local host;
local first;
local source = nil;
local loading={};
 
local p={};
local Number ; 
local Period={};
local Indicator={};
local Top={};
local Bottom={};
local Central={};
local Use={};
local MColor={};
local LColor={};
local Price={};
local Last;
-- Routine
function Prepare(nameOnly)   
	  
    source = instance.source;
     
	host=core.host;	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");	

	Number=0;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i;
		for  i = 1, 3, 1 do
		
				local s, e, s1, e1;
				s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
				if   instance.parameters:getString("TF" .. i)  == "Chart"  then
				s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
				else
				s1, e1 = core.getcandle(instance.parameters:getString("TF" .. i), core.now(), 0, 0);
				end
				  
					 if instance.parameters:getBoolean ("On"..i) and ((e - s) <= (e1 - s1)) then
					 Number=Number+1;
					 Period[Number]=  instance.parameters:getInteger ("Period"..i);
					 Price[Number]=  instance.parameters:getString ("Price"..i);
					 Use[Number]=  instance.parameters:getBoolean ("Use"..i);  
					 Deviation[Number]=  instance.parameters:getDouble ("Deviation"..i);
					 TF[Number]= instance.parameters:getString("TF" .. i);
					 if TF[Number]== "Chart" then
					  TF[Number]=  source:barSize();
					 end
					 
					 LColor[Number]= instance.parameters:getColor("LColor" .. i);
					 MColor[Number]= instance.parameters:getColor("MColor" .. i);
					 Width[Number]= instance.parameters:getInteger("Width" .. i);
					 Style[Number]= instance.parameters:getInteger("Style" .. i);
					 Test = core.indicators:create("BB", source.close ,Period[Number],Deviation[Number]);  
					
					first= Test.DATA:first() ; 		
					
					
					SourceData[Number] = core.host:execute("getSyncHistory",source:instrument(), TF[Number], source:isBid(), math.min(300,first*2), 200+Number, 100+Number);
					Indicator[Number]= core.indicators:create("BB", SourceData[Number][Price[Number]] ,Period[Number],Deviation[Number]);  
					loading[Number]=true;
					
					Top[Number]=      instance:addStream("Top"..Number   , core.Line, name .. ".Top"   , "Top" ,   LColor[Number] , Indicator[Number].TL:first());
					Bottom[Number]=   instance:addStream("Bottom"..Number, core.Line, name .. ".Bottom", "Bottom", LColor[Number] , Indicator[Number].BL:first());
					
					Top[Number]:setWidth(Width[Number]);
                    Top[Number]:setStyle(Style[Number]);
					Bottom[Number]:setWidth(Width[Number]);
                    Bottom[Number]:setStyle(Style[Number]);
					if Use[Number] then	
					 Central[Number]=   instance:addStream("Central"..Number, core.Line, name .. ".Central", "Central",  MColor[Number] , Indicator[Number].AL:first());		
                     Central[Number]:setWidth(Width[Number]);
                     Central[Number]:setStyle(Style[Number]);
                      else
					  Central[Number] = instance:addInternalStream(0, 0);
					 end
			   end
        end
   

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


local Flag = false;	 
	
	
	
    for j = 1, Number, 1 do
		 
			  
		if loading[j] then 
		Flag=true;
		end	 
	end	
		
	if Flag then
    return;
    end
	
	
		for i = 1, Number, 1 do
				Indicator[i]:update(mode);
			end
	

		for i= 1, Number, 1 do
			p[i]= Initialization(period,i)	
		
			if  p[i]~= false  and p[i]>Indicator[i].TL:first() and Indicator[i].DATA:hasData(p[i]) then
			Top[i][period]=Indicator[i].TL[p[i]]
			Bottom[i][period]=Indicator[i].BL[p[i]]
			Central[i][period]=Indicator[i].AL[p[i]]
			end
		end

end




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
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



