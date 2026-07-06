// Id: 17175
//+------------------------------------------------------------------+
//|                                          LOD_HOD_Price_Break.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern int   Number_Of_Days = 20;
extern color High_Color     = clrLime;
extern color Low_Color      = clrOrangeRed;
extern bool  Alert_ON       = true;
extern bool Send_Email=false;
extern bool Show_Alert=true;

datetime LastAlert;

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
   IndicatorName = GenerateIndicatorName("Price break PrLOD/HOD Alert");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

void CallAlert(string Msg)
{
 if (Send_Email)
 {
  SendMail("LOD HOD Price Break Alert", Msg);
 }

 if (Show_Alert)
 {
  Alert(Msg);
 }
 
}


int start()
  {
   
   int i;
   double HIGH, LOW;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   for(i=Number_Of_Days; i>=0; i--){
      
      // Calculations
      HIGH  = iHigh(NULL,PERIOD_D1,i+1);
      LOW   = iLow(NULL,PERIOD_D1,i+1);
      
      // Drawing the Lines
      Line_Start = iTime(NULL,PERIOD_D1,i);
      if (i==0){
         Line_End = iTime(NULL,PERIOD_D1,i)+(1*86400);
         Draw_Label = true;
      }else{
         Line_End = iTime(NULL,PERIOD_D1,(i-1));
         Draw_Label = false;
      }
      
      Pivot("HIGH"+i,Line_Start,HIGH,Line_End, High_Color,2, STYLE_SOLID,Draw_Label);
      Pivot("LOW"+i,Line_Start,LOW,Line_End, Low_Color,2, STYLE_SOLID,Draw_Label);
      
   }
   
   // Alerta
   if (Alert_ON && Time[0] > LastAlert)
   {
      if (Close[0] > iHigh(NULL,PERIOD_D1,1))
      {
         CallAlert(Symbol() + " " + TFToStr(Period()) + ": Price is Higher than Yesterday's High");
         LastAlert = TimeCurrent();
      }
      if (Close[0] < iLow(NULL,PERIOD_D1,1))
      {
         CallAlert(Symbol() + " " + TFToStr(Period()) + ": Price is Lower than Yesterday's Low");
         LastAlert = TimeCurrent();
      }
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
}

string TFToStr(int tf)   { 
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return(""); 
}