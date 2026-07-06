// Id: 17060
//+------------------------------------------------------------------+
//|                                   Multiple_Equidistant_Lines.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern string    Comment0        = "- If 0 the Mid Price of the Window will be used -";
extern double    Price           = 0;
extern int       Pips_Separation = 25;
extern color     MidPrice_Color  = clrRed;
extern int       MidPrice_Width  = 2;
extern int       MidPrice_Style = STYLE_SOLID;
extern color     Lines_Color     = clrYellow;
extern int       Lines_Width     = 0;
extern int       Lines_Style    = STYLE_DOT;

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
   IndicatorName = GenerateIndicatorName("Multiple Equidistant Lines");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int start(){
   
   int i;
   int bar = WindowFirstVisibleBar();
   double MidPrice;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   if (Price == 0){
      MidPrice = (High[iHighest(NULL, 0, MODE_HIGH, bar - 1, 1)] + Low[iLowest(NULL, 0, MODE_LOW, bar - 1, 1)]) / 2;
   }
   else
      MidPrice = Price;
   
   Pivot("MidPrice",Time[bar],MidPrice,Time[0]+(6*Period()*60), MidPrice_Color,MidPrice_Width,MidPrice_Style);
   
   for (i=10; i>0; i--){
      Pivot("Equi_Plus_"+i,Time[bar],MidPrice+(i*Pips_Separation*pipSize),Time[0]+(6*Period()*60), Lines_Color,Lines_Width,Lines_Style);
      Pivot("Equi_Minus_"+i,Time[bar],MidPrice-(i*Pips_Separation*pipSize),Time[0]+(6*Period()*60), Lines_Color,Lines_Width,Lines_Style);
   }
   
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
}
