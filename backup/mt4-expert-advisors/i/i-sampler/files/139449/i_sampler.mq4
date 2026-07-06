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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 3
//--- plot analog
#property indicator_label1  "analog"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSpringGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot discrete
#property indicator_label2  "discrete"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "discrete"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrCoral
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input int      bars_future=10;
input int      max_bars=10000;
input int      discrete_metod=1;
input double   porog=0.5;
input int      tp=500;
input int      sl=200;
input bool     show_arrow=true;
input bool     save_file=false;
input int bars_limit = 1000;
//--- indicator buffers
double         analogBuffer[];
double         discreteBuffer[];
double         discreteColors[];
//--- global variable
double point;
string name;
int timesignal[];
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
   IndicatorObjPrefix = GenerateIndicatorPrefix("sampler");
   IndicatorShortName("sampler");

   IndicatorBuffers(3);
   SetIndexBuffer(0, analogBuffer);
   SetIndexBuffer(1, discreteBuffer);
   SetIndexBuffer(2, discreteColors);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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
      ArrayInitialize(analogBuffer, EMPTY_VALUE);
      ArrayInitialize(discreteBuffer, EMPTY_VALUE);
      ArrayInitialize(discreteColors, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double price_high = high[ArrayMaximum(high, pos, bars_future)];
      double price_low = low[ArrayMinimum(low, pos, bars_future)];

      double deviation_plus = price_high - open[pos];
      double deviation_minus = open[pos] - price_low;

      double value = (2.0 * deviation_plus) / (deviation_plus + deviation_minus) - 1;
      analogBuffer[pos] = value;

      switch (discrete_metod)
      {
         case 1:
            if (value > porog)
            { 
               discreteBuffer[pos] = 1;
            }
            else if (value < -porog)
            {
               discreteColors[pos] = -1;
            }
            break;
         case 2:
            if (deviation_plus > tp * point && deviation_minus < sl * point)
            {
               discreteBuffer[pos] = 1;
            }
            else if (deviation_plus < sl * point && deviation_minus > tp * point)
            {
               discreteColors[pos] = -1;
            }
            break;
      }
      if (show_arrow)
         SetArrow(discreteBuffer[pos], time[pos], open[pos]);

      if (save_file && pos == rates_total - bars_future - 1)
         SaveBuffer(rates_total, time, discreteBuffer);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

void SetArrow(double signal, datetime timebar, double price)
{
   if (signal == 0)
      return;
   string name_arrow;
   if (signal > 0)
   {
      name_arrow =  name + " Buy  " + timebar;
      ObjectCreate(0, name_arrow, OBJ_ARROW_BUY, 0, timebar, price);
   }
   if (signal < 0)
   {
      name_arrow =  name + " Buy  " + timebar;
      ObjectCreate(0, name_arrow, OBJ_ARROW_SELL, 0, timebar, price);
   }
}

void SaveBuffer(const int rates_total, const datetime &time[], const double &Buffer[])
{
   uint n = 0, ne;
   for (int i = 0; i < rates_total; i++)
   {
      if (Buffer[i] == 1 || Buffer[i] == -1)
         n++;
   }
   ArrayResize(timesignal, n);
   n = 0;
   for (int i = 0; i < rates_total; i++)
   {
      if (Buffer[i] == 1 || Buffer[i] == -1)
      {
         timesignal[n] = (int)time[i] * (int)Buffer[i];
         n++;
      }
   }

   ResetLastError();
   string namefile;
   StringConcatenate(namefile, _Symbol, "_Sampler.BIN");
   int filehandle = FileOpen(namefile, FILE_WRITE | FILE_BIN | FILE_COMMON);
   if (filehandle != INVALID_HANDLE)
   {
      ne = FileWriteArray(filehandle, timesignal, 0, WHOLE_ARRAY);
      FileClose(filehandle);
   }
   else 
      Print(namefile," �������� FileWrite ��������, ������ ",GetLastError());
}
