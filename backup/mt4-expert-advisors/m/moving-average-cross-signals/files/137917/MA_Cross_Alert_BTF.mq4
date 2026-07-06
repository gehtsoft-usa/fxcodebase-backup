// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64128
//+------------------------------------------------------------------+
//|                                               MA_Cross_Alert.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "Alert will be given if price touches or crosses the selected Moving Average"

#property indicator_buffers 2
#property indicator_chart_window
#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 2

enum e_method
{
   SMA = MODE_SMA,
   EMA = MODE_EMA,
   SMMA = MODE_SMMA,
   LWMA = MODE_LWMA
};
enum e_price
{
   CLOSE = PRICE_CLOSE,
   OPEN = PRICE_OPEN,
   LOW = PRICE_LOW,
   HIGH = PRICE_HIGH,
   MEDIAN = PRICE_MEDIAN,
   TYPICAL = PRICE_TYPICAL,
   WEIGHTED = PRICE_WEIGHTED
};
enum e_alert
{
   Touch = 1,
   Cross = 2
};

input int MA_Period = 50;
input e_method MA_Method = EMA;
input e_price MA_Price_Type = CLOSE;
input e_alert Signal_Type = Cross;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input bool Sound_Alert = true;
input bool Email_Alert = true;

double MA[];
double Signal[];

datetime LastAlert;

int init()
{

   IndicatorShortName("Moving Average Cross Alert");

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MA);

   SetIndexStyle(1, DRAW_ARROW);
   SetIndexBuffer(1, Signal);
   SetIndexArrow(1, 174);

   return (0);
}

int start()
{

   int i;
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;

   for (i = limit; i >= 0; i--)
   {
      int index = i == 0 ? 0 : iBarShift(_Symbol, tf, Time[i]);
      MA[i] = iMA(_Symbol, tf, MA_Period, 0, ENUM_MA_METHOD(MA_Method), ENUM_APPLIED_PRICE(MA_Price_Type), index);
   }

   for (i = limit; i >= 0; i--)
   {

      if (Signal_Type == 1 && ((Open[i] < MA[i] && Close[i] >= MA[i]) || (Open[i] > MA[i] && Close[i] <= MA[i])))
      {
         Signal[i] = MA[i];
         if (i == 0 && Time[0] > LastAlert)
         {
            if (Sound_Alert)
               Alert(Symbol() + "," + TFToStr(Period()) + ": Price is Touching the Moving Average!");
            if (Email_Alert)
               SendMail("Moving Average Touch Signal", Symbol() + "," + TFToStr(Period()) + ": Price is Touching the Moving Average!");
            LastAlert = TimeCurrent();
         }
      }

      if (Signal_Type == 2 && ((Close[i + 1] < MA[i + 1] && Close[i] >= MA[i]) || (Close[i + 1] > MA[i + 1] && Close[i] <= MA[i])))
      {
         Signal[i] = MA[i];
         if (i == 0 && Time[0] > LastAlert)
         {
            if (Sound_Alert)
               Alert(Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average!");
            if (Email_Alert)
               SendMail("Moving Average Cross Signal", Symbol() + "," + TFToStr(Period()) + ": Price just crossed the Moving Average!");
            LastAlert = TimeCurrent();
         }
      }
   }

   //----
   return (0);
}

string TFToStr(int tf)
{
   if (tf == 0)
      tf = Period();
   if (tf >= 43200)
      return ("MN");
   if (tf >= 10080)
      return ("W1");
   if (tf >= 1440)
      return ("D1");
   if (tf >= 240)
      return ("H4");
   if (tf >= 60)
      return ("H1");
   if (tf >= 30)
      return ("M30");
   if (tf >= 15)
      return ("M15");
   if (tf >= 5)
      return ("M5");
   if (tf >= 1)
      return ("M1");
   return ("");
}
