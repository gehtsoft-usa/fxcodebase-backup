// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68900

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 54

input int        Bollinger_Bands_Periods       = 20; // Periods
input double     Bollinger_Bands_Deviations_1    = 2; // Deviations 1
input double     Bollinger_Bands_Deviations_2    = 2.5; // Deviations 2
input double     Bollinger_Bands_Deviations_3    = 3; // Deviations 3
input ENUM_LINE_STYLE dev_1_style = STYLE_SOLID; // Deviations 1 style
input ENUM_LINE_STYLE dev_2_style = STYLE_DASH; // Deviations 2 style
input ENUM_LINE_STYLE dev_3_style = STYLE_DOT; // Deviations 3 style
input bool     Include_M1               = true;
input bool     Include_M5               = true;
input bool     Include_M15              = true;
input bool     Include_M30              = true;
input bool     Include_H1               = true;
input bool     Include_H4               = true;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = true;
input color m1_color = Red; // M1 color
input color m5_color = Green; // M5 color
input color m15_color = White; // M15 color
input color m30_color = Blue; // M30 color
input color h1_color = Yellow; // H1 color
input color h4_color = Pink; // H4 color
input color d1_color = Purple; // D1 color
input color w1_color = Orange; // W1 color
input color mn1_color = Lime; // MN1 color
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

class BBStreams
{
   ENUM_TIMEFRAMES _timeframe;
   double _up[];
   double _down[];
   double _deviations;
public:
   BBStreams(ENUM_TIMEFRAMES timeframe, double deviations)
   {
      _timeframe = timeframe;
      _deviations = deviations;
   }

   int RegisterStreams(int id, color clr, int style)
   {
      SetIndexStyle(id, DRAW_LINE, style, 1, clr);
      SetIndexBuffer(id, _up);
      SetIndexLabel(id, GetTimeframeStr() + " Up");

      SetIndexStyle(id + 1, DRAW_LINE, style, 1, clr);
      SetIndexBuffer(id + 1, _down);
      SetIndexLabel(id + 1, GetTimeframeStr() + " Down");

      return id + 2;
   }

   void Update(int pos)
   {
      int index = iBarShift(_Symbol, _timeframe, Time[pos]);
      _up[pos] = iBands(_Symbol, _timeframe, Bollinger_Bands_Periods, _deviations, 0, PRICE_CLOSE, MODE_UPPER, index);
      _down[pos] = iBands(_Symbol, _timeframe, Bollinger_Bands_Periods, _deviations, 0, PRICE_CLOSE, MODE_LOWER, index);
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

class BBStreamsPack
{
   BBStreams* _bb1;
   BBStreams* _bb2;
   BBStreams* _bb3;
public:
   BBStreamsPack(ENUM_TIMEFRAMES timeframe)
   {
      _bb1 = new BBStreams(timeframe, Bollinger_Bands_Deviations_1);
      _bb2 = new BBStreams(timeframe, Bollinger_Bands_Deviations_2);
      _bb3 = new BBStreams(timeframe, Bollinger_Bands_Deviations_3);
   }

   ~BBStreamsPack()
   {
      delete _bb1;
      delete _bb2;
      delete _bb3;
   }

   int RegisterStreams(int id, color clr)
   {
      id = _bb1.RegisterStreams(id, clr, dev_1_style);
      id = _bb2.RegisterStreams(id, clr, dev_2_style);
      return _bb3.RegisterStreams(id, clr, dev_3_style);
   }

   void Update(int pos)
   {
      _bb1.Update(pos);
      _bb2.Update(pos);
      _bb3.Update(pos);
   }
};

BBStreamsPack* _bbs[];

int CreateBBs(int id, ENUM_TIMEFRAMES tf, color clr)
{
   if (_Period > tf)
      return id;
   int size = ArraySize(_bbs);
   ArrayResize(_bbs, size + 1);
   _bbs[size] = new BBStreamsPack(tf);
   return _bbs[size].RegisterStreams(id, clr);
}

int init()
{
   IndicatorName = GenerateIndicatorName("Multi_bb");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   int id = 0;
   if (Include_M1)
      id = CreateBBs(id, PERIOD_M1, m1_color);
   if (Include_M5)
      id = CreateBBs(id, PERIOD_M5, m5_color);
   if (Include_M15)
      id = CreateBBs(id, PERIOD_M15, m15_color);
   if (Include_M30)
      id = CreateBBs(id, PERIOD_M30, m30_color);
   if (Include_H1)
      id = CreateBBs(id, PERIOD_H1, h1_color);
   if (Include_H4)
      id = CreateBBs(id, PERIOD_H4, h4_color);
   if (Include_D1)
      id = CreateBBs(id, PERIOD_D1, d1_color);
   if (Include_W1)
      id = CreateBBs(id, PERIOD_W1, w1_color);
   if (Include_MN1)
      id = CreateBBs(id, PERIOD_MN1, mn1_color);

   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(_bbs); ++i)
   {
      delete _bbs[i];
   }
   ArrayResize(_bbs, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      for (int i = 0; i < ArraySize(_bbs); ++i)
      {
         BBStreamsPack* item = _bbs[i];
         item.Update(pos);
      }
   } 
   return 0;
}