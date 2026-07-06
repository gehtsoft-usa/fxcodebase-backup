// Id: 16971
//+------------------------------------------------------------------+
//|                                   FXSessionsPivotsExtensions.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern int   Number_Of_Days        = 20;
extern int   Asian_Session_Start   = 0;
extern int   Asian_Session_End     = 10;
extern int   Europe_Session_Start  = 10;
extern int   Europe_Session_End    = 19;
extern int   NewYork_Session_Start = 16;
extern int   NewYork_Session_End   = 0;
extern bool  Show_Labels           = true;
extern color PP_Color              = clrRed;
extern color BP_Color              = clrDarkGray;
extern color TP_Color              = clrDarkGray;
extern color High_Color            = clrLime;
extern color Low_Color             = clrOrangeRed;
extern color Close_Color           = clrMagenta;
extern color S_and_R_Color         = clrTeal;

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
   
   IndicatorName = GenerateIndicatorName("Forex Sessions Pivot Extensions");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   if (Period()>60) Alert("This indicator works only on H1 charts and lower");
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   // It works only for Periods lower or equal than 60 minutes
   if (Period()<=60){
   
      for(int i=Number_Of_Days*(1440/Period()); i>=0; i--){
         
         if (TimeHour(Time[i]) == Asian_Session_Start)   Calculations(i, "Asia");
         if (TimeHour(Time[i]) == Europe_Session_Start)  Calculations(i, "Europe");
         if (TimeHour(Time[i]) == NewYork_Session_Start) Calculations(i, "NewYork");
         
      }
   
   }
   
//----
   return(0);
}

void Calculations(int shift, string Sess_Label){

   int j;
   double PP, TP, BP, HIGH, LOW, CLOSE, S1, S2, S3, S4, R1, R2, R3, R4;
   int Multiplier, Session_Start, Session_End, Previous_Session_Start, Previous_Session_End, Current_Session_Start, Current_Session_End, Next_Session_Start;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   if      (Period()==1)  Multiplier = 60;
   else if (Period()==5)  Multiplier = 20;
   else if (Period()==15) Multiplier =  4;
   else if (Period()==30) Multiplier =  2;
   else if (Period()==60) Multiplier =  1;
   
   if (Sess_Label=="Asia"){
      Previous_Session_Start = NewYork_Session_Start;
      Previous_Session_End   = NewYork_Session_End;
      Current_Session_Start  = Asian_Session_Start;
      Current_Session_End    = Asian_Session_End;
      Next_Session_Start     = Europe_Session_Start;
   }
   if (Sess_Label=="Europe"){
      Previous_Session_Start = Asian_Session_Start;
      Previous_Session_End   = Asian_Session_End;
      Current_Session_Start  = Europe_Session_Start;
      Current_Session_End    = Europe_Session_End;
      Next_Session_Start     = NewYork_Session_Start;
   }
   if (Sess_Label=="NewYork"){
      Previous_Session_Start = Europe_Session_Start;
      Previous_Session_End   = Europe_Session_End;
      Current_Session_Start  = NewYork_Session_Start;
      Current_Session_End    = NewYork_Session_End;
      Next_Session_Start     = Asian_Session_Start;
   }
   
   // Retrieving the High, Low & Close values
   for (j = iBarShift(NULL,0,Time[shift])+ (16*Multiplier); j > iBarShift(NULL,0,Time[shift]); j--){
      if (TimeHour(Time[j]) == Previous_Session_Start && TimeMinute(Time[j])==0) Session_Start = j;
   }
   Session_End   = Session_Start - (Session_Duration(Previous_Session_Start, Previous_Session_End))*Multiplier;
   for (j = Session_Start; j > Session_End; j--){
      if (j == Session_Start){
         HIGH  = iHigh(NULL,0,j);
         LOW   = iLow(NULL,0,j);
      }else{
         if (iHigh(NULL,0,j) > HIGH) HIGH = iHigh(NULL,0,j);
         if (iLow(NULL,0,j)  < LOW)  LOW  = iLow(NULL,0,j);
      }
      if (j == (Session_End + 1)) CLOSE = iClose(NULL,0,j);
   }
   
   // Calculations
   PP    = (HIGH + LOW + CLOSE) / 3;
   HIGH  = HIGH;
   LOW   = LOW;
   CLOSE = CLOSE;
   BP    = (HIGH + LOW) / 2;
   TP    = PP + (PP - BP);
   S1    = LOW - ((HIGH - LOW) * 0.25);
   S2    = LOW - ((HIGH - LOW) * 0.50);
   S3    = LOW - ((HIGH - LOW) * 0.75);
   S4    = LOW - ((HIGH - LOW) * 1.00);
   R1    = HIGH + ((HIGH - LOW) * 0.25);
   R2    = HIGH + ((HIGH - LOW) * 0.50);
   R3    = HIGH + ((HIGH - LOW) * 0.75);
   R4    = HIGH + ((HIGH - LOW) * 1.00);
   
   // Drawing the Lines
   Line_Start = Time[shift];
   if (shift < Session_Duration(Current_Session_Start,Current_Session_End)-1){
      Line_End = Time[shift] + (8*3600);
      Draw_Label = true;
   }
   else{
      for (j = iBarShift(NULL,0,Time[shift])- (12*Multiplier); j < iBarShift(NULL,0,Time[shift]); j++){
         if (TimeHour(Time[j]) == Next_Session_Start && TimeMinute(Time[j])==0) Line_End = Time[j];
      }
      Draw_Label = false;
   }  
   
   Pivot("PP",Sess_Label+" "+shift,Line_Start,PP,Line_End, PP_Color,3, STYLE_SOLID,Draw_Label);
   Pivot("HIGH",Sess_Label+" "+shift,Line_Start,HIGH,Line_End, High_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("LOW",Sess_Label+" "+shift,Line_Start,LOW,Line_End, Low_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("CLOSE",Sess_Label+" "+shift,Line_Start,CLOSE,Line_End, Close_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("BP",Sess_Label+" "+shift,Line_Start,BP,Line_End, BP_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("TP",Sess_Label+" "+shift,Line_Start,TP,Line_End, TP_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("S1",Sess_Label+" "+shift,Line_Start,S1,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("S2",Sess_Label+" "+shift,Line_Start,S2,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("S3",Sess_Label+" "+shift,Line_Start,S3,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("S4",Sess_Label+" "+shift,Line_Start,S4,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("R1",Sess_Label+" "+shift,Line_Start,R1,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("R2",Sess_Label+" "+shift,Line_Start,R2,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("R3",Sess_Label+" "+shift,Line_Start,R3,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);
   Pivot("R4",Sess_Label+" "+shift,Line_Start,R4,Line_End, S_and_R_Color,2, STYLE_SOLID,Draw_Label);

}
   

void Pivot(string Nombre, string Nombre_Shift, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style, bool draw_text){
   ObjectDelete(IndicatorObjPrefix + Nombre+" "+Nombre_Shift);
   ObjectCreate(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix +  Nombre+" "+Nombre_Shift, OBJPROP_BACK, true );
   if (Show_Labels && draw_text){
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_TEXT, 0, tiempo2+(2*Period()*60), precio1 );
      ObjectSetText(IndicatorObjPrefix + "T"+Nombre, Nombre+" "+StringSubstr(Nombre_Shift,0,StringLen(Nombre_Shift)-1), 10, "Arial", bpcolor );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_TIME1, tiempo2+(2*Period()*60));
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_PRICE1, precio1);
   }
}

int Session_Duration(int Start, int End){

   if (End == 0) End = 24;
   if (End > Start && End <= 24)  return((24-Start)-(24-End));
   if (Start <=24 && End < Start) return((24-Start)+End);

}
