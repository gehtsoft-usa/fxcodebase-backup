// Id: 22154
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66594

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrBlue
#property indicator_color2 clrGreen
#property indicator_color3 clrRed

extern double Delta = 50; // Delta
extern int OpenHour = 23; // Open hour
extern bool ShowLabel = true; // Show Label
extern color LabelColor = clrGray; // Color
extern int Size = 10; // Size

double o[], t[], b[];

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

int init()
{
   IndicatorName = GenerateIndicatorName("Daily_Open");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexBuffer(0, o);
   SetIndexStyle(0, DRAW_LINE);
   
   SetIndexBuffer(1, t);
   SetIndexStyle(1, DRAW_LINE);
   
   SetIndexBuffer(2, b);
   SetIndexStyle(2, DRAW_LINE);
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars<=2)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0)
      return(-1);
   int limit=Bars-2;
   if (ExtCountedBars>2)
      limit = Bars - ExtCountedBars;

   int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
   double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
   int pos = limit;
   while(pos>=0)
   {
      int H_Curr = TimeHour(Time[pos]);
      int H_Prev = TimeHour(Time[pos + 1]);
      if (OpenHour != H_Prev && OpenHour == H_Curr)
      {
         o[pos] = Open[pos];
         t[pos] = Open[pos] + Delta * pipSize;
         b[pos] = Open[pos] + Delta * pipSize;
         if (ShowLabel)
         {
            ObjectCreate(IndicatorObjPrefix + "o_" + TimeToString(Time[pos]), OBJ_TEXT, 0, Time[pos], o[pos]);
            ObjectSetText(IndicatorObjPrefix + "o_" + TimeToString(Time[pos]), DoubleToStr(o[pos], Digits), Size, "Arial", LabelColor);
            ObjectCreate(IndicatorObjPrefix + "t_" + TimeToString(Time[pos]), OBJ_TEXT, 0, Time[pos], t[pos]);
            ObjectSetText(IndicatorObjPrefix + "t_" + TimeToString(Time[pos]), DoubleToStr(t[pos], Digits), Size, "Arial", LabelColor);
            ObjectCreate(IndicatorObjPrefix + "b_" + TimeToString(Time[pos]), OBJ_TEXT, 0, Time[pos], b[pos]);
            ObjectSetText(IndicatorObjPrefix + "b_" + TimeToString(Time[pos]), DoubleToStr(b[pos], Digits), Size, "Arial", LabelColor);
         }
      }
      else
      {
         o[pos] = o[pos + 1];
         t[pos] = t[pos + 1];
         b[pos] = b[pos + 1];
      }
      pos--;
   } 

   return(0);
}
