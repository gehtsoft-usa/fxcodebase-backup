// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68698

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
#property indicator_buffers 0
#property indicator_plots 0

input ENUM_LINE_STYLE   linestyle   = STYLE_DOT;         // Line Style
input color             H1_color    = clrRed,            // Prev H1 color
                        H4_color    = clrGreen,          // Prev H4 color
                        D1_color    = clrBlue,           // Prev Day color
                        W1_color    = clrGold;           // Prev Week color

int         CalcDay = 7;
int         CalcBar = 0;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

void OnInit()
{
   IndicatorName = GenerateIndicatorName("PreviousCandleHiLo");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
   double H1_High = 0, H1_Low = 0;
   double H4_High = 0, H4_Low = 0;
   double D1_High = 0, D1_Low = 0;
   double W1_High = 0, W1_Low = 0;

   PrevPeriod(PERIOD_H1, H1_Low, H1_High, "Prev H1 High", "Prev H1 Low", linestyle, H1_color, 1);
   PrevPeriod(PERIOD_H4, H4_Low, H4_High, "Prev H4 High", "Prev H4 Low", linestyle, H4_color, 1);
   PrevPeriod(PERIOD_D1, D1_Low, D1_High, "Prev Day High", "Prev Day Low", linestyle, D1_color, 1);
   PrevPeriod(PERIOD_W1, W1_Low, W1_High, "Prev Week High", "Prev Week Low", linestyle, W1_color, 1);
   return rates_total;
}

void PrevPeriod(ENUM_TIMEFRAMES period,double high,double low,string hiname,string lowname,int style,color col,int width)
{
   PrevCandle(period, low, high);
   HLine(hiname, hiname, 10, high, style, col, width);
   HLine(lowname, lowname, 10, low, style, col, width);
}

void PrevCandle(ENUM_TIMEFRAMES period,double &low,double &high)
{
   low = iLow(_Symbol, period, 1);
   high = iHigh(_Symbol, period, 1);
}

void DrawShortHLine(string nameX, int time1, double P0, int style, color clr, int width)
{
   datetime T0 = iTime(Symbol(),PERIOD_H1,time1);
   datetime T1 = iTime(Symbol(),PERIOD_M1,1);

   if (ObjectFind(0, IndicatorObjPrefix + nameX) != 0)
      ObjectCreate(0, IndicatorObjPrefix + nameX, OBJ_TREND, 0, T0, P0, T1, P0);
   else
   {
      ObjectDelete(0, IndicatorObjPrefix + nameX);
      ObjectCreate(0, IndicatorObjPrefix + nameX, OBJ_TREND, 0, T0, P0, T1, P0);
   }

   ObjectSetInteger(0, IndicatorObjPrefix + nameX, OBJPROP_STYLE, style);
   ObjectSetInteger(0, IndicatorObjPrefix + nameX, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, IndicatorObjPrefix + nameX, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, IndicatorObjPrefix + nameX, OBJPROP_RAY, false);
   ObjectSetInteger(0, IndicatorObjPrefix + nameX, OBJPROP_BACK, true);
}

void HLine(string name, string desc,int pShiftTime,double pPrice,int pStyle,color pColor,int pWidth)
{
   DrawShortHLine(name, pShiftTime, pPrice, pStyle, pColor, pWidth);
   CreatePriceLabel(name + " Label", desc, pPrice, pColor);
   CreatePriceFlag(name + " Price", pPrice, pColor);
}

int ChartScaleGet()
{
   long result = -1;
   ChartGetInteger(0, CHART_SCALE, 0, result);
   return((int)result);
}

void CreatePriceFlag(string name,double price,color col)
{
   datetime time=iTime(_Symbol, _Period, 0)+Period()*60;

   if(ObjectFind(0,IndicatorObjPrefix+name)!=0)
   {
      ObjectCreate(0, IndicatorObjPrefix+name,OBJ_ARROW_RIGHT_PRICE,0,time,price);
      ObjectSetInteger(0,IndicatorObjPrefix+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetInteger(0,IndicatorObjPrefix+name,OBJPROP_COLOR,col);
   }
   else 
      ObjectMove(0, IndicatorObjPrefix+name,0,time,price);
}

void CreatePriceLabel(string name,string desc,double price,color col) export
{
   int Chart_Scale,Bar_Width;
   Chart_Scale=ChartScaleGet();

   if(Chart_Scale==0) Bar_Width=64;
   else if(Chart_Scale == 1) Bar_Width = 32;
   else if(Chart_Scale == 2) Bar_Width = 16;
   else if(Chart_Scale == 3) Bar_Width = 9;
   else if(Chart_Scale == 4) Bar_Width = 5;
   else if(Chart_Scale == 5) Bar_Width = 3;
   else Bar_Width=2;

   datetime time=iTime(_Symbol, _Period, 0)+Period()*60*Bar_Width;

   if(ObjectFind(0,IndicatorObjPrefix+name)!=0)
   {
      ObjectCreate(0, IndicatorObjPrefix+name,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,IndicatorObjPrefix+name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString(0,IndicatorObjPrefix+name,OBJPROP_TEXT,desc);
      ObjectSetString(0,IndicatorObjPrefix+name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,IndicatorObjPrefix+name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,IndicatorObjPrefix+name,OBJPROP_COLOR,col);
   }
   else 
      ObjectMove(0, IndicatorObjPrefix+name,0,time,price);
}
