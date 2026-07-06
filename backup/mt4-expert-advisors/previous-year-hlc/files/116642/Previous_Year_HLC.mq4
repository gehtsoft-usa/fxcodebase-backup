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
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern color     High_Color  = clrLime;
extern int       High_Width  = 0;
extern int       High_Style  = STYLE_DOT;
extern color     Low_Color   = clrRed;
extern int       Low_Width   = 0;
extern int       Low_Style   = STYLE_DOT;
extern color     Close_Color = clrDodgerBlue;
extern int       Close_Width = 0;
extern int       Close_Style = STYLE_DOT;
extern bool      Show_Prices = true;

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

int init(){
   IndicatorName = GenerateIndicatorName("Previous Year High Low Close");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int start(){
   
      datetime Date_Start;
      double high, low, close;
      
      for (int i=1; i<=12; i++){
         if (i==1){
            high = iHigh(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01")));
            low  = iLow(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01")));
         }else{
            if (iHigh(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01"))) > high)
               high = iHigh(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01")));
            if (iLow(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01"))) < low)
               low = iLow(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01")));
            if (i==12){
               close = iClose(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+"."+i+".01")));
               Date_Start = iTime(NULL,PERIOD_MN1,iBarShift(NULL,PERIOD_MN1,StrToTime((TimeYear(TimeCurrent())-1)+".01.01")));
            }
         }
      }
      
      Pivot("Line_High",Date_Start,high, Time[0], High_Color,High_Width, High_Style);
      Pivot("Line_Low",Date_Start,low,  Time[0], Low_Color,Low_Width, Low_Style);
      Pivot("Line_Close",Date_Start,close,Time[0], Close_Color,Close_Width, Close_Style);
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true );
   if (Show_Prices){
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_ARROW_RIGHT_PRICE, 0, tiempo2+(0*Period()*60), precio1 );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_COLOR, bpcolor);
   }
}
