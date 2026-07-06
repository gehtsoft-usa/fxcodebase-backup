// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71145

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property strict

//#property indicator_separate_window
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input ENUM_TIMEFRAMES tf = PERIOD_D1; // Timeframe
input int count = 5; // How many boxes
input color box_color = Red; // Box color

input int bars_limit = 1000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double out[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("barbox");
   IndicatorSetString(INDICATOR_SHORTNAME, "Bar Box");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(out, EMPTY_VALUE);
   }
   for (int i = 0; i < count; ++i)
   {
      string id = IndicatorObjPrefix + IntegerToString(i);
      datetime from = i == 0 ? time[rates_total - 1] : iTime(_Symbol, tf, i - 1);
      datetime to = iTime(_Symbol, tf, i);
      if (ObjectFind(0, id) == -1)
      {
         if (ObjectCreate(0, id, OBJ_RECTANGLE, 0, from, iHigh(_Symbol, tf, i), to, iLow(_Symbol, tf, i)))
         {
            ObjectSetInteger(0, id, OBJPROP_COLOR, box_color);
            ObjectSetInteger(0, id, OBJPROP_FILL, false);
         }
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, 0, from);
      ObjectSetDouble(0, id, OBJPROP_PRICE, 0, iHigh(_Symbol, tf, i));
      ObjectSetInteger(0, id, OBJPROP_TIME, 1, to);
      ObjectSetDouble(0, id, OBJPROP_PRICE, 1, iLow(_Symbol, tf, i));
   }
   return rates_total;
}