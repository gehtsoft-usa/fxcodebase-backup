// Id: 16629
//+------------------------------------------------------------------+
//|                                       CustomPivotsExtensions.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern int   Number_Of_Days = 20;
extern bool  Show_Labels    = true;
extern color PP_Color       = clrRed;
extern color BP_Color       = clrDarkGray;
extern color TP_Color       = clrDarkGray;
extern color High_Color     = clrLime;
extern color Low_Color      = clrOrangeRed;
extern color Close_Color    = clrMagenta;
extern color S_and_R_Color  = clrTeal;

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
   IndicatorName = GenerateIndicatorName("CustomPivotsExtensions");
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
   double PP, TP, BP, HIGH, LOW, CLOSE, S1, S2, S3, S4, R1, R2, R3, R4;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   for(i=Number_Of_Days; i>=0; i--){
      
      // Calculations
      PP    = (iHigh(NULL,PERIOD_D1,i+1) + iLow(NULL,PERIOD_D1,i+1) + iClose(NULL,PERIOD_D1,i+1)) / 3;
      HIGH  = iHigh(NULL,PERIOD_D1,i+1);
      LOW   = iLow(NULL,PERIOD_D1,i+1);
      CLOSE = iClose(NULL,PERIOD_D1,i+1);
      BP    = (iHigh(NULL,PERIOD_D1,i+1) + iLow(NULL,PERIOD_D1,i+1)) / 2;
      TP    = PP + (PP - BP);
      S1    = iLow(NULL,PERIOD_D1,i+1) - ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.25);
      S2    = iLow(NULL,PERIOD_D1,i+1) - ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.50);
      S3    = iLow(NULL,PERIOD_D1,i+1) - ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.75);
      S4    = iLow(NULL,PERIOD_D1,i+1) - ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 1.00);
      R1    = iHigh(NULL,PERIOD_D1,i+1) + ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.25);
      R2    = iHigh(NULL,PERIOD_D1,i+1) + ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.50);
      R3    = iHigh(NULL,PERIOD_D1,i+1) + ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 0.75);
      R4    = iHigh(NULL,PERIOD_D1,i+1) + ((iHigh(NULL,PERIOD_D1,i+1) - iLow(NULL,PERIOD_D1,i+1)) * 1.00);
      
      // Drawing the Lines
      Line_Start = iTime(NULL,PERIOD_D1,i);
      if (i==0){
         Line_End = iTime(NULL,PERIOD_D1,i)+(1*86400);
         Draw_Label = true;
      }else{
         Line_End = iTime(NULL,PERIOD_D1,(i-1));
         Draw_Label = false;
      }
      
      Pivot("PP"+i,Line_Start,PP,Line_End, PP_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("HIGH"+i,Line_Start,HIGH,Line_End, High_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("LOW"+i,Line_Start,LOW,Line_End, Low_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("CLOSE"+i,Line_Start,CLOSE,Line_End, Close_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("BP"+i,Line_Start,BP,Line_End, BP_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("TP"+i,Line_Start,TP,Line_End, TP_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("S1"+i,Line_Start,S1,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("S2"+i,Line_Start,S2,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("S3"+i,Line_Start,S3,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("S4"+i,Line_Start,S4,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("R1"+i,Line_Start,R1,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("R2"+i,Line_Start,R2,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("R3"+i,Line_Start,R3,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("R4"+i,Line_Start,R4,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
      
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
