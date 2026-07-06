// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68457

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

enum CalcMethod
{
   InPips, // In Pips
   AsPercentages // As Percentages
};

enum PresentationMethod
{
   Overlay, // Overlay
   Sign // Sign
};

input int Level = 10; // Level (In pips or As Percentages)
input CalcMethod Method = InPips; // Method
input PresentationMethod Type = Overlay; // Presentation Method
extern color Up_color = Green; // Up Color
extern color Down_color = Red; // Down Color

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

double buy[], sell[];

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

class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 3, LowStream);
      return id + 4;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

CandleStreams up;
CandleStreams down;
double pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("Inertia bars indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   int id = 2;
   id = up.RegisterStreams(id, Up_color);
   id = down.RegisterStreams(id, Down_color);

   double point = MarketInfo(_Symbol, MODE_POINT);
   double digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   pipSize = point * mult;
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

double GetValue(int pos)
{
   double Body = MathAbs(Close[pos] - Open[pos]);
   if (Method == InPips)
      return Body / pipSize;

   double Candle = MathAbs(High[pos] - Low[pos]);
   return Body / (Candle / 100.0);
}

void DoOvelay(int pos)
{
   buy[pos] = EMPTY_VALUE;
   sell[pos] = EMPTY_VALUE;
   double Value = GetValue(pos);
   if (Close[pos] >= Open[pos])
   {
      if (Value >= Level)
      {
         up.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
         down.Clear(pos);
      }
      return;
   }
   if (Value >= Level)
   {
      down.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      up.Clear(pos);
   }
}

void DoSign(int pos)
{
   down.Clear(pos);
   up.Clear(pos);
   double Value = GetValue(pos);
   if (Close[pos] >= Open[pos])
   {
      if (Value >= Level)
      {
         buy[pos] = Low[pos];
         sell[pos] = EMPTY_VALUE;
      }
      return;
   }
   
   if (Value >= Level)
   {
      buy[pos] = EMPTY_VALUE;
      sell[pos] = High[pos];
   }
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      if (Type == Overlay)
         DoOvelay(pos);
      else 
         DoSign(pos);
      pos--;
   } 
   return 0;
}

