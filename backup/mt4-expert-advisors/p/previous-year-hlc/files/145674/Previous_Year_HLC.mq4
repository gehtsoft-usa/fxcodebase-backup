// Id: 20026
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65485

//+------------------------------------------------------------------+
//|                                            Previous_Year_HLC.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"

#property indicator_chart_window

extern color High_Color  = clrLime;
extern int   High_Width  = 0;
extern int   High_Style  = STYLE_DOT;
extern color Low_Color   = clrRed;
extern int   Low_Width   = 0;
extern int   Low_Style   = STYLE_DOT;
extern color Close_Color = clrDodgerBlue;
extern int   Close_Width = 0;
extern int   Close_Style = STYLE_DOT;
extern bool  Show_Prices = true;

//--- v.2.0
// ------------------------------------------------------------------
input string tHLines  = "== Lines Setup ==";  // == Lines Setup ==
input bool   showQt   = true;                 // Quarter On
input color  clrHigh  = clrOrangeRed;         // Color Quarter High
input color  clrLow   = clrForestGreen;       // Color Quarter Low
input color  clrClose = clrBlue;              // Color Quarter Close
color        clrLines = clrBlack;             // Color Quarters Lines

class Line
{
  string   _name;
  datetime _iniTm;
  double   _price;
  color    _clr;
  string   _txt;

 public:
  Line(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "")
  {
    _name  = inpName;
    _iniTm = inpIniTm;
    _price = inpPrice;
    _clr   = inpClr;
    _txt   = inpLabelTxt;
  }
  ~Line() { erase(); }

  Line* price(double inpPrice)
  {
    _price = inpPrice;
    return &this;
  }
  Line* txt(string inpTxt)
  {
    _txt = inpTxt;
    return &this;
  }

  Line* fromCandle(int candle)
  {
     _iniTm  = iTime(Symbol(), Period(), candle);
     return &this;
  }

  void draw()
  {
    // draw line
    ObjectCreate(0, _name, OBJ_TREND, 0, _iniTm, _price, iTime(NULL,0,0), _price);
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

    // draw label
    if (_txt != "") {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, iTime(NULL,0,0), _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
      // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
    }
  }

  void erase()
  {
    ObjectDelete(0, _name);
    ObjectDelete(0, _name + "Label");
  }

  Line* redraw()
  {
    erase();
    draw();
    return &this;
  }

Line* clr(color clr)
{
    _clr   = clr;
    return &this;
}

};
Line* qHigh;
Line* qLow;
Line* qClose;

// ------------------------------------------------------------------
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int    try  = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
   IndicatorName      = GenerateIndicatorName("Previous Year High Low Close");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);



//--- v2.0
   qHigh = new Line("Last Qrt High", 0, 0, clrBlack);
   qLow = new Line("Last Qrt Low", 0, 0, clrBlack);
   qClose = new Line("Last Qrt Close", 0, 0, clrBlack);
   return (0);
}

int start()
{
   datetime Date_Start;
   double   high, low, close;

   for (int i = 1; i <= 12; i++)
   {
      if (i == 1)
      {
         high = iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01")));
         low  = iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01")));
      } else
      {
         if (iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01"))) > high)
            high = iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01")));
         if (iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01"))) < low)
            low = iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01")));
         if (i == 12)
         {
            close      = iClose(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + "." + i + ".01")));
            Date_Start = iTime(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StrToTime((TimeYear(TimeCurrent()) - 1) + ".01.01")));
         }
      }
   }

   Pivot("Line_High", Date_Start, high, Time[0], High_Color, High_Width, High_Style);
   Pivot("Line_Low", Date_Start, low, Time[0], Low_Color, Low_Width, Low_Style);
   Pivot("Line_Close", Date_Start, close, Time[0], Close_Color, Close_Width, Close_Style);

   //--- v.2
   if (showQt) DrawQuarter();

   return (0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   //--- v.2
   delete qHigh;
   delete qLow;
   delete qClose;

   return (0);
}

void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style)
{
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true);
   if (Show_Prices)
   {
      ObjectDelete(IndicatorObjPrefix + "T" + Nombre);
      ObjectCreate(IndicatorObjPrefix + "T" + Nombre, OBJ_ARROW_RIGHT_PRICE, 0, tiempo2 + (0 * Period() * 60), precio1);
      ObjectSet(IndicatorObjPrefix + "T" + Nombre, OBJPROP_COLOR, bpcolor);
   }
}

struct quarter
{
   double high;
   double low;
   double close;
};
quarter lastQt;

void DrawQuarter()
{
   SetQuartesValues();
   qHigh.price(lastQt.high).fromCandle(50).clr(clrHigh).redraw();
   qLow.price(lastQt.low).fromCandle(50).clr(clrLow).redraw();
   qClose.price(lastQt.close).fromCandle(50).clr(clrClose).redraw();
}

double SetQuartesValues()
{
   // serch last quarter months candles
   double Highs[3], Lows[3];
   for (int i = 0; i < ArraySize(Highs); i++)
   {
      Highs[i] = iHigh(NULL, PERIOD_MN1, shiftMonth() - i);
      Lows[i]  = iLow(NULL, PERIOD_MN1, shiftMonth() - i);
   }

   // set values:
   lastQt.high  = Highs[ArrayMaximum(Highs)];
   lastQt.low   = Lows[ArrayMinimum(Lows)];
   lastQt.close = iClose(NULL, PERIOD_MN1, shiftMonth() - 2);
}

int shiftMonth()
{
   int currentMonth = Month();
   switch (currentMonth)
   {
      case 1: return 3;
      case 2: return 4;
      case 3: return 5;
      case 4: return 3;
      case 5: return 4;
      case 6: return 5;
      case 7: return 3;
      case 8: return 4;
      case 9: return 5;
      case 10: return 3;
      case 11: return 4;
      case 12: return 5;
   }
}