// Id: 16664
//+------------------------------------------------------------------+
//|                                       CustomPivotsExtensions.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_chart_window

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

input        e_cycles Cycles       = Weekly;
extern int   Number_Of_Cycles      = 20;
extern bool  Show_Labels           = true;
extern bool  Draw_Cycles_Separator = true;
extern color PP_Color              = clrRed;
extern color BP_Color              = clrDarkGray;
extern color TP_Color              = clrDarkGray;
extern color High_Color            = clrLime;
extern color Low_Color             = clrOrangeRed;
extern color Close_Color           = clrMagenta;
extern color S_and_R_Color         = clrTeal;
extern color Cycles_Separator      = clrDimGray;

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

int init(){
   IndicatorName = GenerateIndicatorName("CustomPivotsExtensions");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if (Check()) Alert("The Cycles selected for this Time Frame cannot be calculated");
   
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
   
   if (Check()==false){
   
   for(i=Number_Of_Cycles; i>=0; i--){
      
      if (Cycles==1){ Periodo = PERIOD_M5;  Minutes = 5;     }
      if (Cycles==2){ Periodo = PERIOD_M15; Minutes = 15;    }
      if (Cycles==3){ Periodo = PERIOD_M30; Minutes = 30;    }
      if (Cycles==4){ Periodo = PERIOD_H1;  Minutes = 60;    }
      if (Cycles==5){ Periodo = PERIOD_H4;  Minutes = 240;   }
      if (Cycles==6){ Periodo = PERIOD_D1;  Minutes = 1440;  }
      if (Cycles==7){ Periodo = PERIOD_W1;  Minutes = 10080; }
      if (Cycles==8){ Periodo = PERIOD_MN1; Minutes = 43200; }
      
      // Calculations
      PP    = (iHigh(NULL,Periodo,i+1) + iLow(NULL,Periodo,i+1) + iClose(NULL,Periodo,i+1)) / 3;
      HIGH  = iHigh(NULL,Periodo,i+1);
      LOW   = iLow(NULL,Periodo,i+1);
      CLOSE = iClose(NULL,Periodo,i+1);
      BP    = (iHigh(NULL,Periodo,i+1) + iLow(NULL,Periodo,i+1)) / 2;
      TP    = PP + (PP - BP);
      S1    = iLow(NULL,Periodo,i+1) - ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.25);
      S2    = iLow(NULL,Periodo,i+1) - ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.50);
      S3    = iLow(NULL,Periodo,i+1) - ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.75);
      S4    = iLow(NULL,Periodo,i+1) - ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 1.00);
      R1    = iHigh(NULL,Periodo,i+1) + ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.25);
      R2    = iHigh(NULL,Periodo,i+1) + ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.50);
      R3    = iHigh(NULL,Periodo,i+1) + ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 0.75);
      R4    = iHigh(NULL,Periodo,i+1) + ((iHigh(NULL,Periodo,i+1) - iLow(NULL,Periodo,i+1)) * 1.00);
      
      // Drawing the Lines
      Line_Start = iTime(NULL,Periodo,i);
      if (i==0){
         Line_End = iTime(NULL,Periodo,i)+(1*(Minutes*60));
         Draw_Label = true;
      }else{
         Line_End = iTime(NULL,Periodo,(i-1));
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
      
      if (Draw_Cycles_Separator) Separator("Sep"+i, Line_Start, Cycles_Separator, 0, STYLE_DOT);
      
   }
   
   } // if Check==false
   
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

// Draw Separator
void Separator(string Nombre, datetime tiempo1, color sesscolor, int ancho, int style){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_VLINE, 0, tiempo1, WindowPriceMax());
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, sesscolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, True);
}

bool Check (){
   
   bool wrong_tf = false;
   
   if (Period()==5     && Cycles<2) wrong_tf = true;
   if (Period()==15    && Cycles<3) wrong_tf = true;
   if (Period()==30    && Cycles<4) wrong_tf = true;
   if (Period()==60    && Cycles<5) wrong_tf = true;
   if (Period()==240   && Cycles<6) wrong_tf = true;
   if (Period()==1440  && Cycles<7) wrong_tf = true;
   if (Period()==10080 && Cycles<8) wrong_tf = true;
   if (Period()==43200)             wrong_tf = true;
   
   return(wrong_tf);
   
}