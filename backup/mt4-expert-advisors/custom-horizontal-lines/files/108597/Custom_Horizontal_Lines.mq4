// Id: 16797
//+------------------------------------------------------------------+
//|                                      Custom_Horizontal_Lines.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window

extern string    Comment0    = "- To Hide a Line Write 0 in Price Field -";
extern string    Comment1    = "- Horizontal Line 1 - ";
extern double    Price1      = 0;
extern datetime  Date1_Start = 0;
extern datetime  Date1_End   = 0;
extern color     Line1_Color = clrRed;
extern int       Line1_Width = 2;
extern int       Line1_Style = STYLE_SOLID;
extern string    Comment2    = "- Horizontal Line 2 - ";
extern double    Price2      = 0;
extern datetime  Date2_Start = 0;
extern datetime  Date2_End   = 0;
extern color     Line2_Color = clrYellow;
extern int       Line2_Width = 0;
extern int       Line2_Style = STYLE_DOT;
extern string    Comment3    = "- Horizontal Line 3 - ";
extern double    Price3      = 0;
extern datetime  Date3_Start = 0;
extern datetime  Date3_End   = 0;
extern color     Line3_Color = clrMagenta;
extern int       Line3_Width = 0;
extern int       Line3_Style = STYLE_DASH;
extern string    Comment4    = "- Horizontal Line 4 - ";
extern double    Price4      = 0;
extern datetime  Date4_Start = 0;
extern datetime  Date4_End   = 0;
extern color     Line4_Color = clrBlue;
extern int       Line4_Width = 2;
extern int       Line4_Style = STYLE_SOLID;
extern string    Comment5    = "- Horizontal Line 5 - ";
extern double    Price5      = 0;
extern datetime  Date5_Start = 0;
extern datetime  Date5_End   = 0;
extern color     Line5_Color = clrLime;
extern int       Line5_Width = 2;
extern int       Line5_Style = STYLE_SOLID;
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
   IndicatorName = GenerateIndicatorName("Custom_Horizontal_Lines");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int start(){
   
   if (Price1>0)
      Pivot("Line1",Date1_Start,Price1,Date1_End, Line1_Color,Line1_Width, Line1_Style);
   else
      ObjectDelete(IndicatorObjPrefix + "Line1");
      
   if (Price2>0)
      Pivot("Line2",Date2_Start,Price2,Date2_End, Line2_Color,Line2_Width, Line2_Style);
   else
      ObjectDelete(IndicatorObjPrefix + "Line2");
      
   if (Price3>0)
      Pivot("Line3",Date3_Start,Price3,Date3_End, Line3_Color,Line3_Width, Line3_Style);
   else
      ObjectDelete(IndicatorObjPrefix + "Line3");
      
   if (Price4>0)
      Pivot("Line4",Date4_Start,Price4,Date4_End, Line4_Color,Line4_Width, Line4_Style);
   else
      ObjectDelete(IndicatorObjPrefix + "Line4");
   
   if (Price5>0)
      Pivot("Line5",Date5_Start,Price5,Date5_End, Line5_Color,Line5_Width, Line5_Style);
   else
      ObjectDelete(IndicatorObjPrefix + "Line5");
   
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
