//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double trend[];

int init()
{
   IndicatorName = GenerateIndicatorName("antoniadisnikolaos");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, trend);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int GetNextHigh(int pos)
{
   for (int i = pos; i < Bars - 2; ++i)
   {
      if (High[i + 1] > High[i] && High[i + 1] > High[i + 2])
      {
         return i + 1;
      }
   }
   return -1;
}

bool IsNewHigh(int i, int& h2)
{
   if (High[i + 2] > High[i + 1] && High[i + 2] > High[i + 3])
   {
      int h1 = GetNextHigh(i + 2);
      if (h1 == -1)
      {
         return false;
      }
      h2 = GetNextHigh(h1);
      if (h2 == -1)
      {
         return false;
      }
      return High[h2] < High[i + 2] && High[h1] < High[i + 2];
   }
   return false;
}

int GetNextLow(int pos)
{
   for (int i = pos; i < Bars - 2; ++i)
   {
      if (Low[i + 1] < Low[i] && Low[i + 1] < Low[i + 2])
      {
         return i + 1;
      }
   }
   return -1;
}

bool IsNewLow(int i, int& h2)
{
   if (Low[i + 2] < Low[i + 1] && Low[i + 2] < Low[i + 3])
   {
      int h1 = GetNextLow(i + 2);
      if (h1 == -1)
      {
         return false;
      }
      h2 = GetNextLow(h1);
      if (h2 == -1)
      {
         return false;
      }
      return Low[h2] > Low[i + 2] && Low[h1] > Low[i + 2];
   }
   return false;
}

int start()
{
   int minBars = 4;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      trend[i] = trend[i + 1];
      int prev;
      if (IsNewHigh(i, prev) && trend[i + 1] != 1)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(Time[i]) + "v";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_VLINE, 0, Time[i + 2], 0))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Green);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, Time[i + 2]);

         ResetLastError();
         id = IndicatorObjPrefix + TimeToString(Time[i]) + "t";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[prev], High[prev], Time[i + 2], High[i + 2]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Green);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, High[prev]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, High[i + 2]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, Time[prev]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, Time[i + 2]);
         trend[i] = 1;
      }
      if (IsNewLow(i, prev) && trend[i + 1] != -1)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(Time[i]) + "v";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_VLINE, 0, Time[i + 2], 0))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, Time[i + 2]);
         ResetLastError();
         id = IndicatorObjPrefix + TimeToString(Time[i]) + "t";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[prev], Low[prev], Time[i + 2], Low[i + 2]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               continue;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE1, Low[prev]);
         ObjectSetDouble(0, id, OBJPROP_PRICE2, Low[i + 2]);
         ObjectSetInteger(0, id, OBJPROP_TIME1, Time[prev]);
         ObjectSetInteger(0, id, OBJPROP_TIME2, Time[i + 2]);
         trend[i] = -1;
      }
   }
   return 0;
}
