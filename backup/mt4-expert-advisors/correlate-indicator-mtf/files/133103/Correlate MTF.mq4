// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69667
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
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot AUD
#property indicator_label1  "AUD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot CAD
#property indicator_label2  "CAD"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot CHF
#property indicator_label3  "CHF"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrFireBrick
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot EUR
#property indicator_label4  "EUR"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRoyalBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot GBP
#property indicator_label5  "GBP"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot JPY
#property indicator_label6  "JPY"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrYellow
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
//--- plot NZD
#property indicator_label7  "NZD"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkViolet
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2
//--- plot XAU
#property indicator_label8  "XAU"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrGold
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
//--- plot USD
#property indicator_label9  "USD"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrLimeGreen
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2
//---
#define indicator_handles 8
//---
#property indicator_levelcolor clrLightSlateGray
double indicator_level1=  0;
double indicator_level2= .2;
double indicator_level3= 20;
double indicator_level4= 30;
double indicator_level5=100;


input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
enum indicators
{
   INDICATOR_MA,           //Moving Average
   INDICATOR_MACD,         //Moving Average Convergence/Divergence
   INDICATOR_STOCHASTIC,   //Stochastic Oscillator
   INDICATOR_RSI,          //Relative Strength Index
   INDICATOR_CCI,          //Commodity Channel Index
   INDICATOR_RVI,          //Relative Vigour Index
   INDICATOR_DEMARKER,     //DeMarker Oscillator
   INDICATOR_MOMENTUM,     //Momentum Oscillator
   INDICATOR_MFI           //Money Flow Index
};
input indicators  Indicator=INDICATOR_MA;
input string MA;
input ushort MAPeriod=14;                       //MA Period
input ENUM_MA_METHOD MAMethod=MODE_SMA;         //MA Method
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;   //MA Price
input string MACD;
input ushort FastEMA=12;                        //Fast EMA Period
input ushort SlowEMA=26;                        //Slow EMA Period
input ENUM_APPLIED_PRICE MACDPrice=PRICE_CLOSE; //MACD Price
input string Stochastic;
input ushort Kperiod=7;                         //K Period
input ushort Slowing=3;
input ENUM_STO_PRICE PriceField=STO_LOWHIGH;    //Price Field
input string RSI;
input ushort RSIPeriod=14;                      //RSI Period
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;  //RSI Price
input string CCI;
input ushort CCIPeriod=14;                      //CCI Period
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE;  //CCI Price
input string RVI;
input ushort RVIPeriod=14;                      //RVI Period
input string DeMarker;
input ushort DeMarkerPeriod=14;                 //DeMarker Period
input string Momentum;
input ushort MomentumPeriod=14;                 //Momentum Period
input ENUM_APPLIED_PRICE MomentumPrice=PRICE_CLOSE;   //Momentum Price
input string MFI;
input ushort MFIPeriod=14;                      //MFI Period
input string _;                                 //---
input string Sfix="";                           //Symbol Suffix
input bool Auto=false;                          //Display chart currencies
input bool Aud=true;                            //Display Aussie
input bool Cad=true;                            //Display Loonie
input bool Chf=true;                            //Display Swissy
input bool Eur=true;                            //Display Fiber
input bool Gbp=true;                            //Display Sterling
input bool Jpy=true;                            //Display Yen
input bool Nzd=true;                            //Display Kiwi
input bool Xau=true;                            //Display Gold
input bool Usd=true;                            //Display Greenback

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

double aud[], cad[], chf[], eur[], gbp[], jpy[], nzd[], xau[], usd[];
int init()
{
   switch(Indicator)
   {
   case INDICATOR_MA:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF %s(%d)", StringSubstr(EnumToString(MAMethod), 5), MAPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,5);
      IndicatorSetInteger(INDICATOR_LEVELS,1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      break;
   case INDICATOR_MACD:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF MACD(%d,%d)", FastEMA, SlowEMA));
      IndicatorSetInteger(INDICATOR_DIGITS,5);
      IndicatorSetInteger(INDICATOR_LEVELS,1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      break;
   case INDICATOR_STOCHASTIC:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF Stochastic(%d,%d)", Kperiod, Slowing));
      IndicatorSetInteger(INDICATOR_DIGITS,1);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level4);
      break;
   case INDICATOR_RSI:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF RSI(%d)", RSIPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,1);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level3);
      break;
   case INDICATOR_CCI:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF CCI(%d)", CCIPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,0);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level5);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level5);
      break;
   case INDICATOR_RVI:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF RVI(%d)", RVIPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,3);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level2);
      break;
   case INDICATOR_DEMARKER:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF DeMarker(%d)", DeMarkerPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,3);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level2);
      break;
   case INDICATOR_MOMENTUM:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF Momentum(%d)", MomentumPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,3);
      IndicatorSetInteger(INDICATOR_LEVELS,1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      break;
   case INDICATOR_MFI:
      IndicatorName = GenerateIndicatorName(StringFormat("Correl8MTF MFI(%d)", MFIPeriod));
      IndicatorSetInteger(INDICATOR_DIGITS,1);
      IndicatorSetInteger(INDICATOR_LEVELS,3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level3);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level3);
   }
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, aud);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, cad);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, chf);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, eur);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, gbp);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, jpy);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, nzd);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, xau);
   ++id;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id, usd);
   ++id;

   double temp = iCustom(NULL, 0, "Correlate", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Correlate' indicator");
      return INIT_FAILED;
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      int period = iBarShift(_Symbol, tf, Time[i]);
      if (period < 0)
      {
         continue;
      }
      aud[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 0, period);
      cad[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 1, period);
      chf[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 2, period);
      eur[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 3, period);
      gbp[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 4, period);
      jpy[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 5, period);
      nzd[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 6, period);
      xau[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 7, period);
      usd[i] = iCustom(NULL, 0, "Correlate", Indicator, MA, MAPeriod, MAMethod, MAPrice, MACD, FastEMA, SlowEMA, MACDPrice, 
         Stochastic, Kperiod, Slowing, PriceField, RSI, RSIPeriod, RSIPrice, CCI, CCIPeriod, CCIPrice, RVI, RVIPeriod, DeMarker,
         DeMarkerPeriod, Momentum, MomentumPeriod, MomentumPrice, MFI, MFIPeriod, _, Sfix, Auto, Aud, Cad, Chf, Eur, Gbp, Jpy, Nzd, Xau, Usd, 8, period);
   }
   return 0;
}
