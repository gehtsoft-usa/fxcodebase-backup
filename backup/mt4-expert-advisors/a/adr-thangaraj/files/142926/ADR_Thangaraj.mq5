// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=150614#p150614

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property indicator_plots 0
#property indicator_chart_window

input int NumOfDays = 14;
input string FontName = "Arial Black";
input int FontSize = 10;
input int LineHeight = 20;
input color FontColor = DarkOrange;
input int Window = 0;
input ENUM_BASE_CORNER Corner = CORNER_LEFT_UPPER; // Corner
input int HorizPos = 20;
input int VertPos = 55;
input string custom_indi_id = ""; // Custom indicator ID

double pnt;
double dig;
string IndicatorObjPrefix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorObjPrefix = GenerateIndicatorPrefix("adr");
   pnt = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   dig = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   if(dig == 3 || dig == 5)
     {
      pnt *= 10;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix, -1, -1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   double dToday = 0;
   double dADR = GetADR(PERIOD_D1, NumOfDays, dToday);
   string objtext = "ADR = " + DoubleToString(dADR, 1) + " - Today = " + DoubleToString(dToday, 1);
   string objname = IndicatorObjPrefix + "ADR";
   if(ObjectFind(0, objname) == -1)
     {
      if(!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
        {
         return 0;
        }
     }
   ObjectSetInteger(0, objname, OBJPROP_CORNER, Corner);
   ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, VertPos);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, FontColor);
   ObjectSetInteger(0, objname, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, objname, OBJPROP_TEXT, objtext);
   ObjectSetString(0, objname, OBJPROP_FONT, FontName);
   dToday = 0;
   dADR = GetADR(PERIOD_W1, NumOfDays, dToday);
   objtext = "AWR = " + DoubleToString(dADR, 1) + " - Today = " + DoubleToString(dToday, 1);
   objname = IndicatorObjPrefix + "AWR";
   if(ObjectFind(0, objname) == -1)
     {
      if(!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
        {
         return 0;
        }
     }
   ObjectSetInteger(0, objname, OBJPROP_CORNER, Corner);
   ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, VertPos + LineHeight);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, FontColor);
   ObjectSetInteger(0, objname, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, objname, OBJPROP_TEXT, objtext);
   ObjectSetString(0, objname, OBJPROP_FONT, FontName);
   dToday = 0;
   dADR = GetADR(PERIOD_MN1, NumOfDays, dToday);
   objtext = "AMR = " + DoubleToString(dADR, 1) + " - Today = " + DoubleToString(dToday, 1);
   objname = IndicatorObjPrefix + "AMR";
   if(ObjectFind(0, objname) == -1)
     {
      if(!ObjectCreate(0, objname, OBJ_LABEL, Window, 0, 0))
        {
         return 0;
        }
     }
   ObjectSetInteger(0, objname, OBJPROP_CORNER, Corner);
   ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, HorizPos);
   ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, VertPos + LineHeight * 2);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, FontColor);
   ObjectSetInteger(0, objname, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, objname, OBJPROP_TEXT, objtext);
   ObjectSetString(0, objname, OBJPROP_FONT, FontName);
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(0, -1, -1); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(const string target)
  {
   if(custom_indi_id != "")
     {
      return custom_indi_id;
     }
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetADR(ENUM_TIMEFRAMES tf, int count, double& today)
  {
   double hi = 0.0;
   double lo = 0.0;
   double sum = 0.0;
   for(int i = 1; i <= count; i++)
     {
      hi = iHigh(Symbol(), tf, i);
      lo = iLow(Symbol(), tf, i);
      datetime dt = iTime(Symbol(), tf, i);
      sum += hi - lo;
     }
   hi = iHigh(Symbol(), tf, 0);
   lo = iLow(Symbol(), tf, 0);
   today = (hi - lo) / pnt;
   if(count == 0 || pnt == 0)
     {
      return 0;
     }
   return sum / count / pnt;
  }
//+------------------------------------------------------------------+
