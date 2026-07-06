// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=62193

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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

input int Look_Back_Length = 20;
input bool Analyze_Current_Period = true;
input bool Show_Middle_Line = true;
input int extend_bars = 10; // Extend, bars

double Up[], Dn[], Mid[];


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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("dnc");
   IndicatorShortName("DNC");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Up);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Dn);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Mid);

   return (0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
  
   return (0);
}



int start()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   if (Bars <= 3)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos;

   pos = limit;
   while (pos >= 0)
   {

      if (Analyze_Current_Period)
      {
         Up[pos] = High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos)];
         Dn[pos] = Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos)];
      }
      else
      {
         Up[pos] = High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos + 1)];
         Dn[pos] = Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos + 1)];
      }
      if (Show_Middle_Line)
      {
         Mid[pos] = (Up[pos] + Dn[pos]) / 2;
      }
      pos--;
   }
   //ExtendLine(Up[0], Up[1], IndicatorObjPrefix + "u", Green);
   //ExtendLine(Dn[0], Dn[1], IndicatorObjPrefix + "d", Red);
   CreatePositionLine(Time[0], Up[1], Green);
   CreatePositionLine(Time[0], Dn[1], Red);
   if (Show_Middle_Line)
   {
      //ExtendLine(Mid[0], Mid[1], IndicatorObjPrefix + "m", Blue);
      CreatePositionLine(Time[0], Mid[0], Blue);
   }
   return (0);
}
void CreatePositionLine(datetime start_date, double start_price, int lineColor) 
{
   
  //
  
  datetime time2 = start_date + _Period * 60 * extend_bars;
  double price2 = start_price;
  string name = IndicatorObjPrefix + TimeToString(start_date)+IntegerToString(lineColor);
  if (!ObjectCreate(0, name, OBJ_TREND, 0, start_date, start_price, time2, price2))
      return;
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
}