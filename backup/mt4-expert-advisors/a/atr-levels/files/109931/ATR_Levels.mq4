// Id: 17212
// More information about this indicator can be found at:
// http://fxcodebase.com/

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

#property indicator_chart_window

extern int   Number_Of_Days = 20;
extern bool  Show_Labels    = true;
extern int   ATR_Periods    = 10;
extern color H4T_Color      = clrDodgerBlue;
extern color L4T_Color      = clrOrangeRed;
extern color H4_Color       = clrLime;
extern color L4_Color       = clrRed;

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
   
   IndicatorName = GenerateIndicatorName("ATR Levels");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   int i;
   double H4T, L4T, H4, L4, ATR;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   for(i=Number_Of_Days; i>=0; i--){
      
      // Calculations
      ATR = iATR(NULL,PERIOD_D1,ATR_Periods,i);
      H4  = iHigh(NULL,PERIOD_D1,i+1) + ATR;
      H4T = iHigh(NULL,PERIOD_D1,i)   + ATR;
      L4  = iLow(NULL,PERIOD_D1,i+1)  - ATR;
      L4T = iLow(NULL,PERIOD_D1,i)    - ATR;
      
      // Drawing the Lines
      Line_Start = iTime(NULL,PERIOD_D1,i);
      if (i==0){
         Line_End = iTime(NULL,PERIOD_D1,i)+(1*86400);
         Draw_Label = true;
      }else{
         Line_End = iTime(NULL,PERIOD_D1,(i-1));
         Draw_Label = false;
      }
      
      Pivot("H4T"+i,Line_Start,H4T,Line_End, H4T_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("H4"+i,Line_Start,H4,Line_End, H4_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("L4T"+i,Line_Start,L4T,Line_End, L4T_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("L4"+i,Line_Start,L4,Line_End, L4_Color,3, STYLE_SOLID,Draw_Label);
      
   }
   
//----
   return(0);
}

void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style, bool draw_text){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true );
   if (Show_Labels && draw_text){
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_TEXT, 0, tiempo2+(2*Period()*60), precio1 );
      ObjectSetText(IndicatorObjPrefix + "T"+Nombre, StringSubstr(Nombre,0,StringLen(Nombre)-1), 10, "Arial", bpcolor );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_TIME1, tiempo2+(2*Period()*60));
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_PRICE1, precio1);
   }
}
