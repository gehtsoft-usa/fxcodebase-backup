-- Id: 13499
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Difference between two different indicators");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("1. Indicator Calculation"); 
	indicator.parameters:addString("Indicator1", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
	  indicator.parameters:addGroup("2. Indicator Calculation"); 
	indicator.parameters:addString("Indicator2", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator2",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number2", "Data Stream Number", "", 1, 1 , 100);
    
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local Data1, Data2;
local Difference;
local Number2, Number1;
local Indicator1,Indicator2; 
local Data2, Data1;
-- Routine
function Prepare(nameOnly)

     Number2=instance.parameters.Number2-1;
	 Number1=instance.parameters.Number1-1;
	 Indicator1=instance.parameters.Indicator1;
	 Indicator2=instance.parameters.Indicator2;
	 
	 source = instance.source;       

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Indicator1).. ", " .. tostring(Indicator2) .. ")";
    instance:name(name);

	if (not (nameOnly)) then
		local profile1 = core.indicators:findIndicator(instance.parameters:getString("Indicator1"));
		local params1 = instance.parameters:getCustomParameters("Indicator1");

		if  profile1:requiredSource() == core.Tick then			
			Data1 = profile1:createInstance( source.close, params1);
		else
			Data1 = profile1:createInstance(source, params1);
		end		
	
	
		Count1= Data1:getStreamCount ();
		
		local profile2 = core.indicators:findIndicator(instance.parameters:getString("Indicator2"));
			local params2 = instance.parameters:getCustomParameters("Indicator2");

			if  profile2:requiredSource() == core.Tick then			
				Data2 = profile1:createInstance( source.close, params2);
			else
				Data2 = profile1:createInstance(source, params2);
			end
			
			Count2= Data2:getStreamCount ();
			
			first = math.max(Data1.DATA:first(),  Data2.DATA:first());
		
		if Number1 >= Count1 then
		Number1 = Count1;
		assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
		end	
		
		
		if Number2 >= Count2 then
		Number2 = Count2;
		assert( false, "Incorrect index of stream. The indicator has only ".. Count2  .. " stream(s).");
		end	
        Difference = instance:addStream("DBTDF", core.Bar, name, "Difference", instance.parameters.UPUP, first);
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
     Data1:update(mode);
	 Data2:update(mode); 
	 
    if period < first or not source:hasData(period) then
	return;
	end 
	
	Difference[period] =Data1:getStream (Number1)[period] - Data2:getStream (Number2)[period];
	
	if Difference[period] > 0 then
	    if  Difference[period] > Difference[period-1] then
		Difference:setColor(period, instance.parameters.UPUP);
		else
		Difference:setColor(period, instance.parameters.UPDN);
		end                	
	else
	    if  Difference[period] > Difference[period-1] then
		Difference:setColor(period, instance.parameters.DNUP);
		else
		Difference:setColor(period, instance.parameters.DNDN);
		end       
	end
	
    
end

