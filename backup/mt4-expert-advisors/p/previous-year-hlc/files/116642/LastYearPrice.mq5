// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
#property version "1.0"
#property strict
#property indicator_chart_window

input string tPYHLC      = "== Previous Year HLC Setup ==";  // == Previous Year HLC Setup ==
input color  High_Color  = clrLime;
input int    High_Width  = 0;
input int    High_Style  = STYLE_DOT;
input color  Low_Color   = clrRed;
input int    Low_Width   = 0;
input int    Low_Style   = STYLE_DOT;
input color  Close_Color = clrDodgerBlue;
input int    Close_Width = 0;
input int    Close_Style = STYLE_DOT;
input bool   Show_Prices = true;

// ------------------------------------------------------------------
string IndicatorName;
string IndicatorObjPrefix;

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
  IndicatorName      = "Previous Year High Low Close";
  IndicatorObjPrefix = "__" + IndicatorName + "__";
  IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

  return (INIT_SUCCEEDED);
}

// NOTE: OnCalculate
// ------------------------------------------------------------------
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  datetime Date_Start = 0;
  double   _high = 0;
  double   _low  = 0;
  double   _close = 0;

  for (int i = 1; i <= 12; i++)
  {
	  if (i == 1)
  {
  _high = iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
  _low  = iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
	
  } else
      {
         if (iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01"))) > _high)
            _high = iHigh(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
         if (iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01"))) < _low)
            _low = iLow(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
         if (i == 12)
         {
            _close      = iClose(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
            Date_Start = iTime(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, StringToTime(lastYear() + "." + (string)i + ".01")));
         }
      }
  }

  
Pivot("Line_High", Date_Start, _high, TimeCurrent(), High_Color, High_Width, High_Style);
Pivot("Line_Low", Date_Start, _low, TimeCurrent(), Low_Color, Low_Width, Low_Style);
Pivot("Line_Close", Date_Start, _close, TimeCurrent(), Close_Color, Close_Width, Close_Style);

return (rates_total);

}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

//+------------------------------------------------------------------+

string lastYear()
{
  MqlDateTime dt;
  if (TimeToStruct(TimeCurrent(), dt)) {
    int ly = dt.year - 1;
    return (string) ly;
  }

  return "";
}


void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style)
{
   ObjectDelete(0, IndicatorObjPrefix + Nombre);
   ObjectCreate(0, IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSetInteger(0, IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSetInteger(0, IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSetInteger(0, IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSetInteger(0, IndicatorObjPrefix + Nombre, OBJPROP_RAY, false);
   ObjectSetInteger(0, IndicatorObjPrefix + Nombre, OBJPROP_BACK, true);
   if (Show_Prices)
   {
     string _name = IndicatorObjPrefix + "T" + Nombre;
     ObjectDelete(0, _name);
     ObjectCreate(0, _name, OBJ_ARROW_RIGHT_PRICE, 0, tiempo2, precio1);
     ObjectSetInteger(0, _name, OBJPROP_COLOR, bpcolor);
   }
}