// Id: 24280
//+------------------------------------------------------------------+
//|                                                   BTF_Source.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+


#property indicator_chart_window


enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8, Quoter=9, Year=10 };
enum e_method{ Current=1, Previous = 2 };

input        e_cycles BTF          = Quoter;
input        e_method Method       = Previous;
extern int   Number_Of_BTF_Candles = 3;
extern bool  Show_Labels           = true;
extern bool  Draw_Cycles_Separator = true;
extern color Open_Color            = clrDarkGray;
extern color High_Color            = clrLime;
extern color Low_Color             = clrRed;
extern color Close_Color           = clrBlue;
///////////////////////////////////////////////////////////////////
extern color HIGH11Color        = clrLime;                                                
extern color HIGH12Color        = clrLime;
extern color HIGH13Color        = clrLime;
extern color HIGH14Color        = clrLime;

extern color HALF00Color        = clrMagenta; 

extern color LOW11Color        = clrRed;                                                
extern color LOW12Color        = clrRed;
extern color LOW13Color        = clrRed;
extern color LOW14Color        = clrRed;

//////////////////////////////////////////////////////////////////
////////////////////////////////////////Frazioni max 1 
extern color DecimoMax1Color         = clrDarkGray;
extern color OttavoMax1Color         = clrDarkGray;
extern color SestoMax1Color          = clrDarkGray;
extern color QuartoMax1Color         = clrDarkGray;
////////////////////////////////////////Frazioni max 2 
extern color DecimoMax2Color         = clrDarkGray;
extern color OttavoMax2Color         = clrDarkGray;
extern color SestoMax2Color          = clrDarkGray;
extern color QuartoMax2Color         = clrDarkGray;
////////////////////////////////////////Frazioni max 3 
extern color DecimoMax3Color         = clrDarkGray;
extern color OttavoMax3Color         = clrDarkGray;
extern color SestoMax3Color          = clrDarkGray;
extern color QuartoMax3Color         = clrDarkGray;
//////////////////////////////////////////////////////////////////
  
      //////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////////

////////////////////////////////////////Frazioni Min 1 
extern color DecimoMin1Color         = clrDarkGray;
extern color OttavoMin1Color         = clrDarkGray;
extern color SestoMin1Color          = clrDarkGray;
extern color QuartoMin1Color         = clrDarkGray;
////////////////////////////////////////Frazioni Min 2 
extern color DecimoMin2Color         = clrDarkGray;
extern color OttavoMin2Color         = clrDarkGray;
extern color SestoMin2Color          = clrDarkGray;
extern color QuartoMin2Color         = clrDarkGray;
////////////////////////////////////////Frazioni Min 3 
extern color DecimoMin3Color         = clrDarkGray;
extern color OttavoMin3Color         = clrDarkGray;
extern color SestoMin3Color          = clrDarkGray;
extern color QuartoMin3Color         = clrDarkGray;

      //////////////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////////////






extern int   Lines_Style           = 0;
extern int   Lines_Width           = 2;
extern color BTF_Separator         = clrDimGray;

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
   IndicatorName = GenerateIndicatorName("Bigger TF Source");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if (IsInvalidTimeframe()) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   int i;
   double OPEN, HIGH, LOW, CLOSE, HALF00, HIGH11, HIGH12,HIGH13,HIGH14, LOW11, LOW12, LOW13, LOW14 ;///////////////////////////
   double DecimoMax1,OttavoMax1,SestoMax1,QuartoMax1;
   double DecimoMax2,OttavoMax2,SestoMax2,QuartoMax2;
   double DecimoMax3,OttavoMax3,SestoMax3,QuartoMax3;
   
   double DecimoMin1,OttavoMin1,SestoMin1,QuartoMin1;
   double DecimoMin2,OttavoMin2,SestoMin2,QuartoMin2;
   double DecimoMin3,OttavoMin3,SestoMin3,QuartoMin3;
   
   
   
   
   
   datetime Line_Start, Line_End;
   bool Draw_Label;
   
   if (IsInvalidTimeframe())
      return 0;
   int start = Number_Of_BTF_Candles;
   int periods = 1;
   switch (BTF)
   {
      case 1:
         Periodo = PERIOD_M5;
         Minutes = 5;
         break;
      case 2:
         Periodo = PERIOD_M15;
         Minutes = 15;
         break;
      case 3:
         Periodo = PERIOD_M30;
         Minutes = 30;
         break;
      case 4: 
         Periodo = PERIOD_H1;
         Minutes = 60;
         break;
      case 5:
         Periodo = PERIOD_H4;
         Minutes = 240;
         break;
      case 6:
         Periodo = PERIOD_D1;
         Minutes = 1440;
         break;
      case 7:
         Periodo = PERIOD_W1;
         Minutes = 10080;
         break;
      case 8:
         Periodo = PERIOD_MN1;
         Minutes = 43200;
         break;
      case Quoter:
         {
            Periodo = PERIOD_MN1;
            periods = 3;
            Minutes = 43200;
            while (start < iBars(NULL, PERIOD_MN1) - 1)
            {
               MqlDateTime time;
               if (!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
                  break;
               ++start;
            }
            start -= 3;
         }
         break;
      case Year:
         {
            Periodo = PERIOD_MN1;
            periods = 12;
            Minutes = 43200;
            while (start < iBars(NULL, PERIOD_MN1) - 1)
            {
               MqlDateTime time;
               if (!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
                  break;
               ++start;
            }
            start -= 12;
         }
         break;
   }
   int shift = Method == Current ? 0 : periods;
   for (i = start; i >= 0; i -= periods)
   {
      OPEN = iOpen(NULL, Periodo, i + shift);
      CLOSE = iClose(NULL, Periodo, i + shift - 2);
      HIGH = iHigh(NULL, Periodo, i + shift);
      LOW = iLow(NULL, Periodo, i + shift);
      
      double range1 = iHigh(NULL, Periodo, i + shift)- iLow(NULL, Periodo, i + shift);
      
         HIGH11 = HIGH + range1 * 0.5;                                                   ///////////////////////////
          HIGH12 = HIGH + range1 * 1;                                                     ///////////////////////////
           HIGH13 = HIGH + range1 * 1.5; 
             HIGH14 = HIGH + range1 * 2; 
         
         HALF00  = HIGH - range1 * 0.5;                                                    ///////////////////////////
           
         LOW11 = LOW - range1 * 0.5;                                                     ///////////////////////////
          LOW12 = LOW - range1 * 1; 
           LOW13 = LOW - range1 * 1.5; 
            LOW14 = LOW - range1 * 2; 
      
      
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 1 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
    
     /////////////////////////////DecimoMax
      DecimoMax1 = HIGH + range1 * 0.1;
     /////////////////////////////OttaviMax
      OttavoMax1 = HIGH + range1 * 0.125;
     /////////////////////////////SestoMax
      SestoMax1 = HIGH + range1 * 0.167;
     /////////////////////////////SestoMax
      QuartoMax1 = HIGH + range1 * 0.25;
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 2 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      
      /////////////////////////////DecimoMax
      DecimoMax2 = HIGH + range1 * 1.1;
     /////////////////////////////OttaviMax
      OttavoMax2 = HIGH + range1 * 1.125;
     /////////////////////////////SestoMax
      SestoMax2 = HIGH + range1 * 1.167;
     /////////////////////////////SestoMax
      QuartoMax2 = HIGH + range1 * 1.25;
      
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 3 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      
      /////////////////////////////DecimoMax
      DecimoMax3 = HIGH + range1 * 2.1;
     /////////////////////////////OttaviMax
      OttavoMax3 = HIGH + range1 * 2.125;
     /////////////////////////////SestoMax
      SestoMax3 = HIGH + range1 * 2.167;
     /////////////////////////////SestoMax
      QuartoMax3 = HIGH + range1 * 2.25;

      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 1 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
    
     /////////////////////////////DecimoMin
      DecimoMin1 = LOW - range1 * 0.1;
     /////////////////////////////OttaviMin
      OttavoMin1 = LOW - range1 * 0.125;
     /////////////////////////////SestoMin
      SestoMin1 = LOW - range1 * 0.167;
     /////////////////////////////SestoMin
      QuartoMin1 = LOW -  range1 * 0.25;           
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 2 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////DecimoMin
      DecimoMin2 = LOW - range1 * 1.1;
     /////////////////////////////OttaviMin
      OttavoMin2 = LOW - range1 * 1.125;
     /////////////////////////////SestoMin
      SestoMin2 = LOW - range1 * 1.167;
     /////////////////////////////SestoMin
      QuartoMin2 = LOW -  range1 * 1.25;
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 3 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////DecimoMin
      DecimoMin3 = LOW - range1 * 2.1;
     /////////////////////////////OttaviMin
      OttavoMin3 = LOW - range1 * 2.125;
     /////////////////////////////SestoMin
      SestoMin3 = LOW - range1 * 2.167;
     /////////////////////////////SestoMin
      QuartoMin3 = LOW -  range1 * 2.25;
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
    
      
      
      
      for (int ii = 1; ii < periods; ++ii)
      {
         OPEN = iOpen(NULL, Periodo, i + shift - ii);
         
         HIGH = MathMax(HIGH, iHigh(NULL, Periodo, i + shift - ii));
         LOW = MathMin(LOW, iLow(NULL, Periodo, i + shift - ii));
         
         CLOSE = iClose(NULL, Periodo, i + shift - 2);
        
        double range = MathMax(HIGH, iHigh(NULL, Periodo, i + shift - ii))- MathMin(LOW, iLow(NULL, Periodo, i + shift - ii));///////////////////////////
        
        HIGH11 = HIGH + range * 0.5;                                                   ///////////////////////////
         HIGH12 = HIGH + range * 1;                                                     ///////////////////////////
          HIGH13 = HIGH + range * 1.5; 
             HIGH14 = HIGH + range * 2; 
          
         HALF00  = HIGH - range * 0.5;                                                    ///////////////////////////
           
           LOW11 = LOW - range * 0.5;                                                     ///////////////////////////
            LOW12 = LOW - range * 1;                                                       ///////////////////////////
             LOW13 = LOW - range * 1.5; 
             LOW14 = LOW - range * 2; 
      
     
     
     //  DecimoMax1,OttavoMax1,SestoMax1,QuartoMax1;
     
     ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
     
     ///////////////////////////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////Frazioni max 1 ////////////////////////////////////////
     ///////////////////////////////////////////////////////////////////////////////////////////////
    
     /////////////////////////////DecimoMax
      DecimoMax1 = HIGH + range * 0.1;
     /////////////////////////////OttaviMax
      OttavoMax1 = HIGH + range * 0.125;
     /////////////////////////////SestoMax
      SestoMax1 = HIGH + range * 0.167;
     /////////////////////////////SestoMax
      QuartoMax1 = HIGH + range * 0.25;
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 2 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      
      /////////////////////////////DecimoMax
      DecimoMax2 = HIGH + range * 1.1;
     /////////////////////////////OttaviMax
      OttavoMax2 = HIGH + range * 1.125;
     /////////////////////////////SestoMax
      SestoMax2 = HIGH + range * 1.167;
     /////////////////////////////SestoMax
      QuartoMax2 = HIGH + range * 1.25;
      
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 3 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      
      /////////////////////////////DecimoMax
      DecimoMax3 = HIGH + range * 2.1;
     /////////////////////////////OttaviMax
      OttavoMax3 = HIGH + range * 2.125;
     /////////////////////////////SestoMax
      SestoMax3 = HIGH + range * 2.167;
     /////////////////////////////SestoMax
      QuartoMax3 = HIGH + range * 2.25;
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 1 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
    
     /////////////////////////////DecimoMin
      DecimoMin1 = LOW - range * 0.1;
     /////////////////////////////OttaviMin
      OttavoMin1 = LOW - range * 0.125;
     /////////////////////////////SestoMin
      SestoMin1 = LOW - range * 0.167;
     /////////////////////////////SestoMin
      QuartoMin1 = LOW -  range * 0.25;           
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 2 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////DecimoMin
      DecimoMin2 = LOW - range * 1.1;
     /////////////////////////////OttaviMin
      OttavoMin2 = LOW - range * 1.125;
     /////////////////////////////SestoMin
      SestoMin2 = LOW - range * 1.167;
     /////////////////////////////SestoMin
      QuartoMin2 = LOW -  range * 1.25;
      ///////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 3 ////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////////////////
      /////////////////////////////DecimoMin
      DecimoMin3 = LOW - range * 2.1;
     /////////////////////////////OttaviMin
      OttavoMin3 = LOW - range * 2.125;
     /////////////////////////////SestoMin
      SestoMin3 = LOW - range * 2.167;
     /////////////////////////////SestoMin
      QuartoMin3 = LOW -  range * 2.25;
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
  
      
      }
      
      Line_Start = iTime(NULL, Periodo, i);
      if (i < periods)
      {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods + 1))+(1*(Minutes*60));
         Draw_Label = true;
      }
      else
      {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods));
         Draw_Label = false;
      }
      
      //Pivot("OPEN"+i,Line_Start,OPEN,Line_End, Open_Color,3, STYLE_SOLID,Draw_Label);
      Pivot("HIGH"+i,Line_Start,HIGH,Line_End, High_Color,5, STYLE_SOLID,Draw_Label);
      Pivot("LOW"+i,Line_Start,LOW,Line_End, Low_Color,5, STYLE_SOLID,Draw_Label);
      //Pivot("CLOSE"+i,Line_Start,CLOSE,Line_End, Close_Color,1, STYLE_SOLID,Draw_Label);
      
      Pivot("HIGH11"+i,Line_Start,HIGH11,Line_End, HIGH11Color,1, STYLE_DOT,Draw_Label); ///////////////////////////
       Pivot("HIGH12"+i,Line_Start,HIGH12,Line_End, HIGH12Color,2, STYLE_SOLID,Draw_Label); ///////////////////////////
        Pivot("HIGH13"+i,Line_Start,HIGH13,Line_End, HIGH13Color,1, STYLE_DOT,Draw_Label);
         Pivot("HIGH14"+i,Line_Start,HIGH14,Line_End, HIGH14Color,2, STYLE_SOLID,Draw_Label);
        
        Pivot("HALF00"+i,Line_Start,HALF00,Line_End, HALF00Color,2, STYLE_SOLID,Draw_Label); ///////////////////////////
         
         Pivot("LOW11"+i,Line_Start,LOW11,Line_End, LOW11Color,1, STYLE_DOT,Draw_Label);    ///////////////////////////
          Pivot("LOW12"+i,Line_Start,LOW12,Line_End, LOW12Color,2, STYLE_SOLID,Draw_Label);    ///////////////////////////
           Pivot("LOW13"+i,Line_Start,LOW13,Line_End, LOW13Color,1, STYLE_DOT,Draw_Label);
            Pivot("LOW14"+i,Line_Start,LOW14,Line_End, LOW14Color,2, STYLE_SOLID,Draw_Label);
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 1 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMax1"+i,Line_Start,DecimoMax1,Line_End, DecimoMax1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMax1"+i,Line_Start,OttavoMax1,Line_End, OttavoMax1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMax1"+i,Line_Start,SestoMax1,Line_End, SestoMax1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMax1"+i,Line_Start,QuartoMax1,Line_End, QuartoMax1Color,1, STYLE_DOT,Draw_Label); 
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 2 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMax2"+i,Line_Start,DecimoMax2,Line_End, DecimoMax2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMax2"+i,Line_Start,OttavoMax2,Line_End, OttavoMax2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMax2"+i,Line_Start,SestoMax2,Line_End, SestoMax2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMax2"+i,Line_Start,QuartoMax2,Line_End, QuartoMax2Color,1, STYLE_DOT,Draw_Label); 
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni max 3 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMax3"+i,Line_Start,DecimoMax3,Line_End, DecimoMax3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMax3"+i,Line_Start,OttavoMax3,Line_End, OttavoMax3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMax3"+i,Line_Start,SestoMax3,Line_End, SestoMax3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMax3"+i,Line_Start,QuartoMax3,Line_End, QuartoMax3Color,1, STYLE_DOT,Draw_Label); 
      
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++////
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 1 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMin1"+i,Line_Start,DecimoMin1,Line_End, DecimoMin1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMin1"+i,Line_Start,OttavoMin1,Line_End, OttavoMin1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMin1"+i,Line_Start,SestoMin1,Line_End, SestoMin1Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMin1"+i,Line_Start,QuartoMin1,Line_End, QuartoMin1Color,1, STYLE_DOT,Draw_Label); 
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 2 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMin2"+i,Line_Start,DecimoMin2,Line_End, DecimoMin2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMin2"+i,Line_Start,OttavoMin2,Line_End, OttavoMin2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMin2"+i,Line_Start,SestoMin2,Line_End, SestoMin2Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMin2"+i,Line_Start,QuartoMin2,Line_End, QuartoMin2Color,1, STYLE_DOT,Draw_Label); 
      
      //////////////////////////////////////////////////////////////////////////////////////////////
      ////////////////////////////////////////Frazioni Min 3 ///////////////////////////////////////
      //////////////////////////////////////////////////////////////////////////////////////////////
      
      //////////////////////DecimoMax///////////////////////////////////////////////////////////
      Pivot("DecimoMin3"+i,Line_Start,DecimoMin3,Line_End, DecimoMin3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////OttaviMax///////////////////////////////////////////////////////////
      Pivot("OttavoMin3"+i,Line_Start,OttavoMin3,Line_End, OttavoMin3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////SestoMax///////////////////////////////////////////////////////////
      Pivot("SestoMin3"+i,Line_Start,SestoMin3,Line_End, SestoMin3Color,1, STYLE_DOT,Draw_Label); 
      //////////////////////QuartoMaxMax///////////////////////////////////////////////////////////
      Pivot("QuartoMin3"+i,Line_Start,QuartoMin3,Line_End, QuartoMin3Color,1, STYLE_DOT,Draw_Label); 
      
   
      if (Draw_Cycles_Separator)
         Separator("Sep"+i, Line_Start, BTF_Separator, 0, STYLE_DOT);
   }
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

bool IsInvalidTimeframe (){
   
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<2) wrong_tf = true;
   if (Period()==15    && BTF<3) wrong_tf = true;
   if (Period()==30    && BTF<4) wrong_tf = true;
   if (Period()==60    && BTF<5) wrong_tf = true;
   if (Period()==240   && BTF<6) wrong_tf = true;
   if (Period()==1440  && BTF<7) wrong_tf = true;
   if (Period()==10080 && BTF<8) wrong_tf = true;
   if (Period()==43200)          wrong_tf = true;
   
   return(wrong_tf);
   
}