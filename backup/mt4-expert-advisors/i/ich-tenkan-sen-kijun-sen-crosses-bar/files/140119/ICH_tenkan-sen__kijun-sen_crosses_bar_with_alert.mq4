// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=145928#p145928

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_minimum 0

input int tenkan_sen = 9; // Tenkan sen
input int kijun_sen = 26; // Kijun sen
input int senkou_span_b = 52; // Senkou span b
input int bars_limit = 100000; // Bars limit

input bool   notificationsOn       = false;                  // Notifications On:
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input bool   sound_notification    = false;                  // Sound Notifications
input string sound_file            = "Tick.wav";              // Sound File

string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(); k >= 0; k--)
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

double up[], down[], neutral[];
int init()
  {
   IndicatorObjPrefix = GenerateIndicatorPrefix("ichtskscb");
   IndicatorShortName("ICH tenkan-sen & kijun-sen crosses bar");
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, up);
   SetIndexLabel(0, "Up");
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, down);
   SetIndexLabel(1, "Down");
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, neutral);
   SetIndexLabel(2, "Neutral");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(prev_calculated <= 0 || prev_calculated > rates_total)
     {
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(down, EMPTY_VALUE);
      ArrayInitialize(neutral, EMPTY_VALUE);
     }
   bool nb = IsNewBar();
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
   for(int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
     {
      double ich0 = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkou_span_b, MODE_TENKANSEN, pos);
      double ich1 = iIchimoku(_Symbol, _Period, tenkan_sen, kijun_sen, senkou_span_b, MODE_KIJUNSEN, pos);
      if(ich0 > ich1)
        {
         down[pos] = 1;
        }
      else
         if(ich0 < ich1)
           {
            up[pos] = 1;
           }
         else
           {
            neutral[pos] = 1;
           }
     }
   if(nb && notificationsOn)
     {
      if(down[0] == 1 && down[1] == EMPTY_VALUE)
        {
         Notify(2);
        }
      if(up[0] == 1 && up[1] == EMPTY_VALUE)
        {
         Notify(1);
        }
      if(neutral[0] == 1 && neutral[1] == EMPTY_VALUE)
        {
         Notify(0);
        }
     }
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "ICH tenkan-sen & kijun-sen crosses bar: ";
   switch(type)
     {
      case 0:
         text += " Trend is changed Neutral - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 1:
         text += " Trend is changed Up - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Trend is changed Down - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(!notificationsOn)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notification)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
