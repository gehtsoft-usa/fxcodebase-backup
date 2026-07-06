// Id: 24677
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68333

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
#property indicator_chart_window
#property version   "1.0"
#property strict

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8, Quoter=9, Year=10 };
enum e_method{ Current=1, Previous = 2 };

input        e_cycles BTF          = Daily;
input        e_method Method       = Current;
input double RetracementLevel = 38.2; // Retracement level, %
extern int   Number_Of_BTF_Candles = 20;
extern bool  Show_Labels           = true;
extern bool  Draw_Cycles_Separator = true;
extern color Open_Color            = clrDarkGray;
extern color High_Color            = clrRed;
extern color Low_Color             = clrLime;
extern color Close_Color           = clrBlue;
extern color Up_retr_Color           = clrPink; // Up retracement color
extern color Dn_retr_Color           = clrGreen; // Down retracement color
extern int   Lines_Style           = 0;
extern int   Lines_Width           = 2;
extern color BTF_Separator         = clrDimGray;

int Periodo, Minutes;

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
   IndicatorName = GenerateIndicatorName("Bigger TF Source");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if (IsInvalidTimeframe()) 
      Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   double OPEN, HIGH, LOW, CLOSE;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   if (IsInvalidTimeframe())
      return 0;
   int start = Number_Of_BTF_Candles;
   int periods = 1;
   switch (BTF)
   {
      case 1:
         Periodo = PERIOD_M5;
         Minutes = 5;
         break;
      case 2:
         Periodo = PERIOD_M15;
         Minutes = 15;
         break;
      case 3:
         Periodo = PERIOD_M30;
         Minutes = 30;
         break;
      case 4: 
         Periodo = PERIOD_H1;
         Minutes = 60;
         break;
      case 5:
         Periodo = PERIOD_H4;
         Minutes = 240;
         break;
      case 6:
         Periodo = PERIOD_D1;
         Minutes = 1440;
         break;
      case 7:
         Periodo = PERIOD_W1;
         Minutes = 10080;
         break;
      case 8:
         Periodo = PERIOD_MN1;
         Minutes = 43200;
         break;
      case Quoter:
         {
            Periodo = PERIOD_MN1;
            periods = 3;
            Minutes = 43200;
            while (start < iBars(NULL, PERIOD_MN1) - 1)
            {
               MqlDateTime time;
               if (!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
                  break;
               ++start;
            }
            start -= 3;
         }
         break;
      case Year:
         {
            Periodo = PERIOD_MN1;
            periods = 12;
            Minutes = 43200;
            while (start < iBars(NULL, PERIOD_MN1) - 1)
            {
               MqlDateTime time;
               if (!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
                  break;
               ++start;
            }
            start -= 12;
         }
         break;
   }
   int shift = Method == Current ? 0 : periods;
   for (int i = start; i >= 0; i -= periods)
   {
      OPEN = iOpen(NULL, Periodo, i + shift);
      CLOSE = iClose(NULL, Periodo, i + shift - 2);
      HIGH = iHigh(NULL, Periodo, i + shift);
      LOW = iLow(NULL, Periodo, i + shift);
      for (int ii = 1; ii < periods; ++ii)
      {
         HIGH = MathMax(HIGH, iHigh(NULL, Periodo, i + shift - ii));
         LOW = MathMin(LOW, iLow(NULL, Periodo, i + shift - ii));
      }
      
      Line_Start = iTime(NULL, Periodo, i);
      if (i < periods)
      {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods + 1))+(1*(Minutes*60));
         Draw_Label = true;
      }
      else
      {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods));
         Draw_Label = false;
      }
      
      Pivot("OPEN" + IntegerToString(i),Line_Start,OPEN,Line_End, Open_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("HIGH" + IntegerToString(i),Line_Start,HIGH,Line_End, High_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("LOW" + IntegerToString(i),Line_Start,LOW,Line_End, Low_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("CLOSE" + IntegerToString(i),Line_Start,CLOSE,Line_End, Close_Color,2, STYLE_SOLID,Draw_Label);

      double retracement = (HIGH - LOW) * RetracementLevel / 100;
      Pivot("UPRETR" + IntegerToString(i), Line_Start, HIGH - retracement, Line_End, Up_retr_Color, 2, STYLE_SOLID, Draw_Label);
      Pivot("DNRETR" + IntegerToString(i), Line_Start, LOW + retracement, Line_End, Dn_retr_Color, 2, STYLE_SOLID, Draw_Label);
      if (Draw_Cycles_Separator)
         Separator("Sep" + IntegerToString(i), Line_Start, BTF_Separator, 0, STYLE_DOT);
   }
   return(0);
}

void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style, bool draw_text)
{
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true );
   if (Show_Labels && draw_text)
   {
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_TEXT, 0, tiempo2+(2*Period()*60), precio1 );
      ObjectSetText(IndicatorObjPrefix + "T"+Nombre, StringSubstr(Nombre,0,StringLen(Nombre)-1), 10, "Arial", bpcolor );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_TIME1, tiempo2+(2*Period()*60));
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_PRICE1, precio1);
   }
}

// Draw Separator
void Separator(string Nombre, datetime tiempo1, color sesscolor, int ancho, int style)
{
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_VLINE, 0, tiempo1, WindowPriceMax());
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, sesscolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, True);
}

bool IsInvalidTimeframe ()
{
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<2) wrong_tf = true;
   if (Period()==15    && BTF<3) wrong_tf = true;
   if (Period()==30    && BTF<4) wrong_tf = true;
   if (Period()==60    && BTF<5) wrong_tf = true;
   if (Period()==240   && BTF<6) wrong_tf = true;
   if (Period()==1440  && BTF<7) wrong_tf = true;
   if (Period()==10080 && BTF<8) wrong_tf = true;
   if (Period()==43200)          wrong_tf = true;
   
   return(wrong_tf);
}