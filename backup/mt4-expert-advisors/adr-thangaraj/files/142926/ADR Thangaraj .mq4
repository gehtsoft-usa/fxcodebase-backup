// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71362

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
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window

input int NumOfDays = 14;
input string FontName = "Arial Black";
input int FontSize = 10;
input color FontColor = DarkOrange;
input int Window = 0;
input ENUM_BASE_CORNER Corner = CORNER_LEFT_UPPER; // Corner
input int HorizPos = 20;
input int VertPos = 55;

double pnt;
int dig;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

//+------------------------------------------------------------------+
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("adr");
   pnt = MarketInfo(Symbol(), MODE_POINT);
   dig = MarketInfo(Symbol(), MODE_DIGITS);
   if (dig == 3 || dig == 5)
   {
      pnt *= 10;
   }
   return (0);
}

//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

double GetADR(ENUM_TIMEFRAMES tf, int count, double& today)
{
   double sum = 0;
   for (int i = 1; i <= count; i++)
   {
      double hi = iHigh(NULL, tf, i);
      double lo = iLow(NULL, tf, i);
      datetime dt = iTime(NULL, tf, i);
      sum += hi - lo;
   }
   hi = iHigh(NULL, tf, 0);
   lo = iLow(NULL, tf, 0);
   today = (hi - lo) / pnt;
   return sum / count / pnt;
}

//+------------------------------------------------------------------+
int start()
{
   double dToday = 0;
   double dADR = GetADR(PERIOD_D1, NumOfDays, dToday);

   string objtext = "ADR = " + DoubleToStr(dADR, 1) + " - Today = " + DoubleToStr(dToday, 1);
   string objname = IndicatorObjPrefix + "ADR";
   if (ObjectFind(0, objname) == -1)
   {
      if (!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
      {
         return 0;
      }
   }
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSet(objname, OBJPROP_YDISTANCE, VertPos);
   ObjectSetText(objname, objtext, FontSize, FontName, FontColor);

   dToday = 0;
   dADR = GetADR(PERIOD_W1, NumOfDays, dToday);
   objtext = "AWR = " + DoubleToStr(dADR, 1) + " - Today = " + DoubleToStr(dToday, 1);
   objname = IndicatorObjPrefix + "AWR";
   if (ObjectFind(0, objname) == -1)
   {
      if (!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
      {
         return 0;
      }
   }
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSet(objname, OBJPROP_YDISTANCE, VertPos + 20);
   ObjectSetText(objname, objtext, FontSize, FontName, FontColor);
   
   dToday = 0;
   dADR = GetADR(PERIOD_MN1, NumOfDays, dToday);
   objtext = "AMR = " + DoubleToStr(dADR, 1) + " - Today = " + DoubleToStr(dToday, 1);
   objname = IndicatorObjPrefix + "AMR";
   if (ObjectFind(0, objname) == -1)
   {
      if (!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
      {
         return 0;
      }
   }
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSet(objname, OBJPROP_YDISTANCE, VertPos + 40);
   ObjectSetText(objname, objtext, FontSize, FontName, FontColor);
   return (0);
}
