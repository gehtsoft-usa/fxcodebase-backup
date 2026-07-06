-- Id: 10527
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59983

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
    indicator:name("ColorDM oscillator");
    indicator:description("ColorDM oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Mode", "Mode", "", "Histogram");
    indicator.parameters:addStringAlternative("Mode", "Dots", "", "Dots");
    indicator.parameters:addStringAlternative("Mode", "Histogram", "", "Histogram");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 2, 1, 5);
end

local first;
local source = nil;
local ColorDM=nil;
local Coeff1={[0]=-0.0579436862774459, -0.0436582666343197, 0.0168933393379673, 0.110448213843891, 0.20522024711311, 0.264664029548369, 0.264664029548369,
      0.20522024711311, 0.110448213843891, 0.0168933393379673, -0.0436582666343197, -0.0579436862774459, -0.0348346366317942, 0.00221235473421834,
      0.0289331217219094, 0.0324244017763432, 0.0155698339961958, -0.00766055486881318, -0.0221383478294209, -0.0205529903682718, -0.00643334760273044,
      0.00962748150382101, 0.0173944693332311, 0.0131760869975097, 0.00120942458662409, -0.0100027091335947, -0.0135055787778998, -0.00803583151940507,
      0.00190389109551071, 0.00948046725746693, 0.0101660909790824, 0.00430310478968843, -0.00365978720396328, -0.00841195685924682, -0.0072828460058001,
      -0.00162070447070519, 0.00446601446733231, 0.00704898572229122, 0.0048477999271653, -0.000217319809293247, -0.00460353885204705, -0.00557481706302029,
      -0.0028770471916742, 0.00137150496947603, 0.00428050657042468, 0.00413626988519937, 0.00136151337463329, -0.00197382022845936, -0.00367569927752237,
      -0.00283678858956286, -0.00028463168971981, 0.00215338773173264, 0.00293485520510334, 0.00175896282134328, -0.000389897847025107, -0.00203100698386829,
      -0.00219727740869414, -0.000975033303736501, 0.000693883112457725, 0.00175105610512485, 0.00168381712349721, 0.000645916394658871, -0.00122951364590661,
      -0.00549716561545307, 0.00171989273244504};
local Coeff2={[0]=0.21064209031795, 0.271656355551084, 0.271656355551084, 0.21064209031795, 0.113366214899538, 0.0173396551298304, -0.0448117019294051,
      -0.0594745370883487, -0.0357549548780298, 0.00227080432996318, 0.0296975241218164, 0.0332810425070465, 0.0159811832652874, -0.00786294390179145,
      -0.022723234810281, -0.0210959927899868, -0.00660331427256404, 0.00988183601272311, 0.0178540247946579, 0.0135241943541608, 0.00124137713793908,
      -0.0102669770180208, -0.0138623911858102, -0.00824813522301926, 0.00195419119574041, 0.00973093770422689, 0.0104346753515803, 0.00441679123043631,
      -0.00375647743147302, -0.00863419765555374, -0.00747525610998775, -0.0016635228848001, 0.00458400492165176, 0.0072352173240803, 0.00497587701245914,
      -0.000223061318466289, -0.00472516264986577, -0.00572210167278254, -0.00295305771688123, 0.00140773962470019, 0.00439359597455809, 0.0042455486093308,
      0.00139748405560848, -0.00202596783057852, -0.00377280989614416, -0.00291173549735707, -0.000292151553936419, 0.00221027944102996, 0.00301239299669469,
      0.00180543397004632, -0.000400198804275733, -0.0020846654389641, -0.002255328667062, -0.00100079332384525, 0.000712215248254048, 0.00179731836130289,
      0.00172830295059105, 0.000662981267470111, -0.0012619969427552, -0.00564239870262307, 0.0017653316638158};
    


function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+65;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if instance.parameters.Mode=="Dots" then
     ColorDM = instance:addStream("ColorDM", core.Dot, name .. ".ColorDM", "ColorDM", instance.parameters.UPclr, first);
     ColorDM:setWidth(instance.parameters.DotSize);
    else
     ColorDM = instance:addStream("ColorDM", core.Bar, name .. ".ColorDM", "ColorDM", instance.parameters.UPclr, first);
    end 
    ColorDM:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local value1=0;
    local value2=0;
    local i;
    for i=0, 64, 1 do
     value1=value1+source[period-i]*Coeff1[i];
    end
    for i=0, 60, 1 do
     value2=value2+source[period-i]*Coeff2[i];
    end
    local Res=value2-value1;
    ColorDM[period]=Res;
    if ColorDM[period]>=ColorDM[period-1] then
     ColorDM:setColor(period, instance.parameters.UPclr);
    else
     ColorDM:setColor(period, instance.parameters.DNclr);
    end
 
end

