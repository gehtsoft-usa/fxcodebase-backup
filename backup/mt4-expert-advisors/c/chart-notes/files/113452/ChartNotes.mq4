// Id: 18664
//+------------------------------------------------------------------+
//|                                                   ChartNotes.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

// Available @ http://fxcodebase.com/code/viewtopic.php?f=38&t=64909 

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "User can add a text message to any part of the screen"

#property indicator_chart_window

extern string   TextEntry              = "Text Entry";
extern string   Note_ID                = "1";
extern int      X_Position             = 100;
extern int      Y_Position             = 100;
extern int      Corner                 = 1;
extern color    Note_Color             = clrWhite;
extern string   Font_Family            = "Arial";
extern int      Font_Size              = 20;

string   WindowName;

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
   
   IndicatorName = GenerateIndicatorName("ChartNote"+Note_ID);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   WindowName = IndicatorName;

   return(0);
}

int deinit(){
   Limpiar();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   ObjectMakeLabel(IndicatorObjPrefix + "Note"+Note_ID, X_Position, Y_Position, TextEntry, Note_Color, Corner, 0, Font_Family, Font_Size );
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(nm);
   ObjectCreate( nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet( nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet( nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet( nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet( nm, OBJPROP_BACK, false );
   ObjectSetText( nm, LabelTexto, FSize, Font, LabelColor );
   return;
}

void Limpiar(){
   ObjectDelete(IndicatorObjPrefix + "Note"+Note_ID);
}