-- Id: 11187
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60338

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
    indicator:name("Alternative On Balance Volume");
    indicator:description("Displays volume as a histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Type", "OBV Method", "Method" , "Classical");
    indicator.parameters:addStringAlternative("Type", "Classical", "Classical" , "Classical");
    indicator.parameters:addStringAlternative("Type", "1. Alternative", "1. Alternative" , "1. Alternative");
	indicator.parameters:addStringAlternative("Type", "2. Alternative", "2. Alternative" , "2. Alternative");
    indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
end

local Volume;
local first;
local OBV;
local High, Low, Close, Open;
local Type;
function Prepare(nameOnly)

    assert(instance.source:supportsVolume(), "The source must have volume");

    Open = instance.source.open;
	Low = instance.source.low;
	High = instance.source.high;
	Close = instance.source.close;
    Volume = instance.source.volume;
	Type =  instance.parameters.Type;
    first = instance.source:first();


    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ", " .. tostring(Type) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

    OBV = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.clrV, first);
    OBV:setPrecision(0);
end

function Update(inx, mode)
    if inx == first then
        OBV[inx] = Volume[inx];
    elseif inx > first then
			  if Type == "Classical"  then
			  
					if Close[inx] > Close[inx - 1] then
						OBV[inx] = OBV[inx - 1] + Volume[inx];
					elseif Close[inx] < Close[inx - 1] then
						OBV[inx] = OBV[inx - 1] - Volume[inx];
					else
						OBV[inx] = OBV[inx - 1];
					end
			 else
			            
					 if High[inx] == Low[inx] or Open[inx] == Close[inx] or Close[inx] == Close[inx-1]  then         
					 OBV[inx] =OBV[inx-1];
					 else  
					 
					         if Type == "1. Alternative"  then
							               if (Close[inx] > Open[inx]) then  
											  OBV[inx] = OBV[inx-1] + (Volume[inx] * (Close[inx]-Open[inx]) / (High[inx]-Low[inx]));
										   else                           
											  OBV[inx] = OBV[inx-1] - (Volume[inx] * (Open[inx]-Close[inx]) / (High[inx]-Low[inx]));
											end
											  
							 elseif Type == "2. Alternative"  then
							              OBV[inx] = OBV[inx-1] + (Volume[inx] * (High[inx]-Open[inx]) / (High[inx]-Low[inx])) - (Volume[inx] * (Open[inx]-Low[inx]) / (High[inx]-Low[inx])); 
							 end
					 
					 end
					 
	         end		 
    end         
	
end

