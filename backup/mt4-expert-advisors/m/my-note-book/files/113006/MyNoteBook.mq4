//+------------------------------------------------------------------+
//|                                                   MyNoteBook.mq4 |
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

extern string Comment0        = "<< General Parameters: >>";
extern int    Corner          = 1;
extern int    Window          = 0;
extern string Font            = "Arial";
extern int    Line_Separation = 30;
extern string Comment1        = "<< Label 1 Paramters: >>";
extern string Label1_Text     = "";
extern int    Label1_Size     = 13;
extern color  Label1_Color    = clrDarkGray;
extern string Comment2        = "<< Label 2 Paramters: >>";
extern string Label2_Text     = "";
extern int    Label2_Size     = 13;
extern color  Label2_Color    = clrDarkGray;
extern string Comment3        = "<< Label 3 Paramters: >>";
extern string Label3_Text     = "";
extern int    Label3_Size     = 13;
extern color  Label3_Color    = clrDarkGray;
extern string Comment4        = "<< Label 4 Paramters: >>";
extern string Label4_Text     = "";
extern int    Label4_Size     = 13;
extern color  Label4_Color    = clrDarkGray;
extern string Comment5        = "<< Label 5 Paramters: >>";
extern string Label5_Text     = "";
extern int    Label5_Size     = 13;
extern color  Label5_Color    = clrDarkGray;
extern string Comment6        = "<< Label 6 Paramters: >>";
extern string Label6_Text     = "";
extern int    Label6_Size     = 13;
extern color  Label6_Color    = clrDarkGray;
extern string Comment7        = "<< Label 7 Paramters: >>";
extern string Label7_Text     = "";
extern int    Label7_Size     = 13;
extern color  Label7_Color    = clrDarkGray;
extern string Comment8        = "<< Label 8 Paramters: >>";
extern string Label8_Text     = "";
extern int    Label8_Size     = 13;
extern color  Label8_Color    = clrDarkGray;
extern string Comment9        = "<< Label 9 Paramters: >>";
extern string Label9_Text     = "";
extern int    Label9_Size     = 13;
extern color  Label9_Color    = clrDarkGray;
extern string Comment10       = "<< Label 10 Paramters: >>";
extern string Label10_Text    = "";
extern int    Label10_Size    = 13;
extern color  Label10_Color   = clrDarkGray;

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
   
   IndicatorName = GenerateIndicatorName("MyNoteBook");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit(){
   
   Clean();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
   return(0);
}

int start(){
  
  if (Label1_Text!="") ObjectMakeLabel( "Label1", 10, 10, Label1_Text, Label1_Color, Corner, Window, Font, Label1_Size );
  if (Label2_Text!="") ObjectMakeLabel( "Label2", 10, 10+(1*Line_Separation), Label2_Text, Label2_Color, Corner, Window, Font, Label2_Size );
  if (Label3_Text!="") ObjectMakeLabel( "Label3", 10, 10+(2*Line_Separation), Label3_Text, Label3_Color, Corner, Window, Font, Label3_Size );
  if (Label4_Text!="") ObjectMakeLabel( "Label4", 10, 10+(3*Line_Separation), Label4_Text, Label4_Color, Corner, Window, Font, Label4_Size );
  if (Label5_Text!="") ObjectMakeLabel( "Label5", 10, 10+(4*Line_Separation), Label5_Text, Label5_Color, Corner, Window, Font, Label5_Size );
  if (Label6_Text!="") ObjectMakeLabel( "Label6", 10, 10+(5*Line_Separation), Label6_Text, Label6_Color, Corner, Window, Font, Label6_Size );
  if (Label7_Text!="") ObjectMakeLabel( "Label7", 10, 10+(6*Line_Separation), Label7_Text, Label7_Color, Corner, Window, Font, Label7_Size );
  if (Label8_Text!="") ObjectMakeLabel( "Label8", 10, 10+(7*Line_Separation), Label8_Text, Label8_Color, Corner, Window, Font, Label8_Size );
  if (Label9_Text!="") ObjectMakeLabel( "Label9", 10, 10+(8*Line_Separation), Label9_Text, Label9_Color, Corner, Window, Font, Label9_Size );
  if (Label10_Text!="") ObjectMakeLabel( "Label10", 10, 10+(9*Line_Separation), Label10_Text, Label10_Color, Corner, Window, Font, Label10_Size );
   
//----
   return(0);
}
  
// Etiquetas del Box
void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int window = 0, string font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, font, LabelColor );
   return;
}

void Clean(){
}