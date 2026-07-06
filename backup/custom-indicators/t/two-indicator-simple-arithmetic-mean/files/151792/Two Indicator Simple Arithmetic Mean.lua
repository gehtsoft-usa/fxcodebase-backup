-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73968

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

function Init()
    indicator:name("Two Indicator Simple Arithmetic Mean");
    indicator:description("Two Indicator Simple Arithmetic Mean");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 
    local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"}
    indicator.parameters:addString("TF", "Price Time Frame", "", TF[14]);
	for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF", TF[i], "", TF[i]);
    end
	
	
	for i= 1, 7, 1 do 
	Add(i);
	end
	 
 
    indicator.parameters:addGroup( "Style");
 
	
    indicator.parameters:addColor("color1", "color", "color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end


function Add(id)
    local Pairs={"EUR/USD","USD/JPY","GBP/USD","USD/CHF","AUD/USD","NZD/USD","USD/CAD"};
    indicator.parameters:addGroup(id.. ". Indicator");
	
	 
	indicator.parameters:addBoolean("On"..id, "Use this Indicator", "", true);
	
	indicator.parameters:addBoolean("Inverse"..id, "Use inverse rate", "", false);
	 
    indicator.parameters:addString("Select"..id ,  "Pair", "", Pairs[id]);
    indicator.parameters:setFlag("Select"..id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addDouble("Weight"..id , "Weight", "", 1);
	
	 
	indicator.parameters:addString("INDICATOR"..id, "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR"..id,core.FLAG_INDICATOR);
	indicator.parameters:addInteger("DataStreamNumber"..id, "Data Stream Number", "", 1, 1 , 100);
	
 
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local Weight={};
local Select={};

local last;
local data;
local instrument;
 
local dayoffset, weekoffset;
 
 
local SourceData={};
local Inverse={};
 
local pauto =  "(%a%a%a)/(%a%a%a)";
 local Index={};
local Number=0;
local N;
local loading={};
 
local Indicator={};
local INDEX={};
local Number={};
local DataStreamNumber={};
local StreamCount={};
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;  
   

    local name = profile:id() .. "()";
    instance:name(name);
	
	if nameOnly then
		return;
	end
	
	local name = profile:id() .. " ";
	  
	Number=0;
	
	for i =1, 7, 1 do	
		if instance.parameters:getBoolean ("On"..i) then		
		Number=Number+1;
		Select[Number]=   instance.parameters:getString ("Select"..i);
		Weight[Number]=   instance.parameters:getDouble ("Weight"..i);
		Inverse[Number]=   instance.parameters:getBoolean ("Inverse"..i);
 
	
		DataStreamNumber[Number]=instance.parameters:getInteger ("DataStreamNumber"..i); 
		DataStreamNumber[Number]=DataStreamNumber[Number]-1;	 
		
		if Inverse[Number] then		
		name= name .. " 1/" .. Select[Number] .. " ";
		else
		name= name .." ".. Select[Number].. " ";
		end
		
		end
	end
	
	
	
    instance:name(name);
	
	if nameOnly then
		return;
	end
	
	N=Number;
	
	
	local InstrumentFlag=nil;
	for i = 1, Number, 1 do
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", Select[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  Select[i] );    
	end
	 
	
	dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	 
    TF = instance.parameters.TF;
	if TF == "Chart" then
	TF=source:barSize();
	end
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
		
   
    instrument=source:instrument();
	 
	Mean = instance:addStream("Mean", core.Line, "Mean", "Mean", instance.parameters.color1, first);
    Mean:setPrecision(math.max(2, instance.source:getPrecision()));
	Mean:setWidth(instance.parameters.width);
    Mean:setStyle(instance.parameters.style);
 
   for i= 1, Number , 1 do
   
   SourceData[i] = core.host:execute("getSyncHistory",Select[i], TF, source:isBid(), 0, 200 +i, 100+i);
   loading[i]=true;
   
   
   		iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"..i));
		iparams = instance.parameters:getCustomParameters("INDICATOR"..i);
		
 

		if  iprofile:requiredSource() == core.Tick then			
			Indicator[i] = iprofile:createInstance( SourceData[i].close, iparams);
		else
			Indicator[i] = iprofile:createInstance(SourceData[i], iparams);
		end
		
		
		 
	
	 StreamCount[i]= Indicator[i]:getStreamCount (); 
	 
	 if DataStreamNumber[i] > StreamCount[i] then
	 DataStreamNumber[i] = StreamCount[i];
	  assert( false, "Incorrect index of stream. The indicator has only ".. StreamCount[i]  .. " stream(s).");
	 end	 
	 
	   
 
	    INDEX[i]=  Indicator[i]:getStream (DataStreamNumber[i]); 			

   end
   
   
end

-- Indicator calculation routine
 
function Update(period )

 
   
	
    if period  <= source:first()	
	then
    return;		
    end	
     
	  local Flag=false;
	for i= 1, Number, 1 do	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
			
	 local p={}
	 
	 local Flag=false;
	   
	 for i= 1, Number, 1 do	
	   p[i]= Initialization(period,i)	 

       if not p[i] then 
	   Flag= true;
	   end	   
     end
	 
	if Flag then
	return;
	end

   for i= 1, Number , 1 do
   Indicator[i]:update(mode);
   end
 
   
   
 
 
   
		 
					       local Sum=0;	
					 	
						   
						   for i= 1, Number, 1 do	
						   
							   if Inverse[i] then
							   Sum= Sum+ (1/INDEX[i][p[i]]) *Weight[i];
							   else						   
							   Sum= Sum+ INDEX[i][p[i]] *Weight[i];		
							   end						   
						   
						   end
						   
				           Mean[period]=Sum/Number;
				 
		 
						
		 		 
      
	   
end





function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);
  
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
		instance:updateFrom(0);
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
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