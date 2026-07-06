//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property description "This indicator highlights the Forex Market Sessions"

#property indicator_chart_window

input int   Number_Of_Days        = 20; // Number of days
input int   Sidney_Session_Start  = 0; // Sydney session start
input int   Sidney_Session_End    = 9; // Sydney session end
input color Sidney_Color          = clrYellow; // Sydney color
input int   Tokyo_Session_Start   = 2; // Tokyo session start
input int   Tokyo_Session_End     = 11; // Tokyo session end
input color Tokyo_Color           = clrRed; // Tokyo color
input int   London_Session_Start  = 10; // London session start
input int   London_Session_End    = 19; // London session end
input color London_Color          = clrGreen; // London color
input int   NewYork_Session_Start = 15; // New York session start
input int   NewYork_Session_End   = 0; // New York session end
input color NewYork_Color         = clrDodgerBlue; // New York color
input bool  Show_Labels           = true; // Show labels
input bool  Show_Session_Start_Line = true; // Show session start line
input bool  Show_Session_End_Line = true; // Show session end line

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

int init()
{
   IndicatorName = GenerateIndicatorName("Market Sessions");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   if (Period()>60) Alert("This indicator works only on H1 charts and lower");
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   
   // It works only for Periods lower or equal than 60 minutes
   if (Period()<=60){
   
      for(int i=Number_Of_Days*(1440/Period()); i>=0; i--){
         
         if (TimeHour(Time[i]) == Sidney_Session_Start && TimeMinute(Time[i])==0)   Calculations(i, "Sidney");
         if (TimeHour(Time[i]) == Tokyo_Session_Start && TimeMinute(Time[i])==0)   Calculations(i, "Tokyo");
         if (TimeHour(Time[i]) == London_Session_Start && TimeMinute(Time[i])==0)  Calculations(i, "London");
         if (TimeHour(Time[i]) == NewYork_Session_Start && TimeMinute(Time[i])==0) Calculations(i, "NewYork");
      }
   }
   
   return(0);
}

void Calculations(int shift, string Sess_Label)
{
   int j;
   int Multiplier, Session_Start, Session_End, Previous_Session_Start, Previous_Session_End, Current_Session_Start, Current_Session_End, Next_Session_Start;
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   color PP_color;
   double pips_position;
   
   if      (Period()==1)  Multiplier = 60;
   else if (Period()==5)  Multiplier = 20;
   else if (Period()==15) Multiplier =  4;
   else if (Period()==30) Multiplier =  2;
   else if (Period()==60) Multiplier =  1;
   
   if (Sess_Label=="Sidney")
   {
      Previous_Session_Start = NewYork_Session_Start;
      Previous_Session_End   = NewYork_Session_End;
      Current_Session_Start  = Sidney_Session_Start;
      Current_Session_End    = Sidney_Session_End;
      Next_Session_Start     = Sidney_Session_End;
      PP_color = Sidney_Color;
      pips_position = 15;
   }
   if (Sess_Label=="Tokyo")
   {
      Previous_Session_Start = Sidney_Session_Start;
      Previous_Session_End   = Sidney_Session_End;
      Current_Session_Start  = Tokyo_Session_Start;
      Current_Session_End    = Tokyo_Session_End;
      Next_Session_Start     = Tokyo_Session_End;
      PP_color = Tokyo_Color;
      pips_position = 12;
   }
   if (Sess_Label=="London")
   {
      Previous_Session_Start = Tokyo_Session_Start;
      Previous_Session_End   = Tokyo_Session_End;
      Current_Session_Start  = London_Session_Start;
      Current_Session_End    = London_Session_End;
      Next_Session_Start     = London_Session_End;
      PP_color = London_Color;
      pips_position = 9;
   }
   if (Sess_Label=="NewYork")
   {
      Previous_Session_Start = London_Session_Start;
      Previous_Session_End   = London_Session_End;
      Current_Session_Start  = NewYork_Session_Start;
      Current_Session_End    = NewYork_Session_End;
      Next_Session_Start     = NewYork_Session_End;
      PP_color = NewYork_Color;
      pips_position = 6;
   }
   
   // Retrieving the High, Low & Close values
   for (j = iBarShift(NULL,0,Time[shift])+ (16*Multiplier); j > iBarShift(NULL,0,Time[shift]); j--)
   {
      if (TimeHour(Time[j]) == Previous_Session_Start && TimeMinute(Time[j])==0) 
         Session_Start = j;
   }
   Session_End   = Session_Start - (Session_Duration(Previous_Session_Start, Previous_Session_End))*Multiplier;
   
   // Drawing the Lines
   Line_Start = Time[shift];
   if (shift < Session_Duration(Current_Session_Start,Current_Session_End)-1)
   {
      Line_End = Time[shift] + (8*3600);
      Draw_Label = true;
   }
   else
   {
      for (j = iBarShift(NULL,0,Time[shift])- (12*Multiplier); j < iBarShift(NULL,0,Time[shift]); j++)
      {
         if (TimeHour(Time[j]) == Next_Session_Start && TimeMinute(Time[j])==0) 
            Line_End = Time[j];
      }
      Draw_Label = false;
   }
   
   if (Session_Duration(Current_Session_Start,Current_Session_End)*3600 > (Time[0] - Line_Start)) 
      Line_End = Time[0];
   
   double rectangle_pos2 = 3;
   if (Digits==3||Digits==5)
   { 
      pips_position*=10; 
      rectangle_pos2*=10; 
   }
   double rectangle_position1 = iHigh(NULL,PERIOD_D1,iBarShift(NULL,PERIOD_D1,Line_Start))+(pips_position*Point);
   double rectangle_position2 = rectangle_position1-(rectangle_pos2*Point);
   Pivot(Sess_Label+" "+TimeToStr(Line_Start,TIME_DATE|TIME_MINUTES), Sess_Label,Line_Start,rectangle_position1,Line_End,rectangle_position2, PP_color,3, STYLE_SOLID,Draw_Label);
   Comment("");
}

void Pivot(string Nombre, string Nombre_Shift, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color bpcolor, int ancho, int style, bool draw_text)
{
   ObjectDelete(IndicatorObjPrefix + Nombre+" "+Nombre_Shift);
   ObjectCreate(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJ_RECTANGLE, 0, tiempo1, precio1, tiempo2, precio2);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre+" "+Nombre_Shift, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix +  Nombre+" "+Nombre_Shift, OBJPROP_BACK, true );
   if (Show_Labels)
   {
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_TEXT, 0, tiempo1, precio1 );
      ObjectSetText(IndicatorObjPrefix + "T"+Nombre, Nombre_Shift, 8, "Arial", bpcolor );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_TIME1, tiempo1+(2*Period()*60));
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_PRICE1, precio2);
   }
   if (Show_Session_End_Line)
   {
      ObjectDelete(IndicatorObjPrefix + "L"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "L"+Nombre, OBJ_VLINE, 0, tiempo2, 0);
      ObjectSet(IndicatorObjPrefix + "L"+Nombre, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(IndicatorObjPrefix + "L"+Nombre, OBJPROP_WIDTH, 1);
      ObjectSet(IndicatorObjPrefix + "L"+Nombre, OBJPROP_COLOR, bpcolor);
   }
   if (Show_Session_Start_Line)
   {
      ObjectDelete(IndicatorObjPrefix + "S" + Nombre);
      ObjectCreate(IndicatorObjPrefix + "S" + Nombre, OBJ_VLINE, 0, tiempo1, 0);
      ObjectSet(IndicatorObjPrefix + "S" + Nombre, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(IndicatorObjPrefix + "S" + Nombre, OBJPROP_WIDTH, 1);
      ObjectSet(IndicatorObjPrefix + "S" + Nombre, OBJPROP_COLOR, bpcolor);
   }
}

int Session_Duration(int Start, int End)
{
   if (End == 0) End = 24;
   if (End > Start && End <= 24)  return((24-Start)-(24-End));
   if (Start <=24 && End < Start) return((24-Start)+End);
   return(0);
}
