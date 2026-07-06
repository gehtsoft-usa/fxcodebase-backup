// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71670

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers   9

extern int              CountPeriods=20;
extern int              Days2Plot=1;
extern ENUM_TIMEFRAMES  TimePeriod=PERIOD_D1;
extern bool             PlotPivots=true;
extern bool             PlotFuturePivots=false;
extern bool             PlotPivotRange=true;
extern color            PivotRangeColor=clrRoyalBlue;
extern ENUM_LINE_STYLE  PivotRangeStyle=STYLE_SOLID;
extern bool             PlotPivotLabels=true;
extern bool             PlotPivotPrices=false;
extern ENUM_LINE_STYLE  StylePivots=STYLE_SOLID;
extern int              WidthPivots=1;
extern color            ColorRes=clrRed;
extern color            ColorPP=clrMagenta;
extern color            ColorSup=clrGreen;
extern bool             PlotMidpoints=false;
extern ENUM_LINE_STYLE  StyleMidpoints=STYLE_DASH;
extern int              WidthMidpoints=1;
extern color            ColorM35=clrRed;
extern color            ColorM02=clrGreen;
extern bool             PlotZones=false;
extern color            ColorBuyZone=clrLightGreen;
extern color            ColorSellZone=clrPink;
extern bool             PlotBorders=false;
extern ENUM_LINE_STYLE  StyleBorder=STYLE_SOLID;
extern int              WidthBorder=1;
extern color            ColorBorder=clrBlack;
extern bool             PlotFibots=false;
extern bool             PlotFibotLabels=false;
extern bool             PlotFibotPrices=false;
extern ENUM_LINE_STYLE  StyleFibots1=STYLE_DOT;
extern ENUM_LINE_STYLE  StyleFibots2=STYLE_SOLID;
extern int              WidthFibots1=1;
extern int              WidthFibots2=1;
extern color            ColorFibots=clrDodgerBlue;
extern bool             PlotYesterdayOHLC=false;
extern bool             PlotYesterdayHL=true;
extern bool             PlotOHLCPrices=false;
extern ENUM_LINE_STYLE  StyleOHLC=STYLE_DOT;
extern int              WidthOHLC=1;
extern color            ColorO=clrGold;
extern color            ColorH=clrRed;
extern color            ColorL=clrGreen;
extern color            ColorC=clrMagenta;


double  pivot[] ;
double  r1[];
double  r2[];
double  r3[];
double    s1[];
double  s2[];
double  s3[];
double   ptop[];
double  pbottom[];



string   period;

datetime timestart,
         timeend;

double   open,
         close,
         high,
         low;

double   PP,         // Pivot Levels
         PDiff,      //Pivot Range addition
         PRTop,      //Pivot Range addition
         PRBottom,   //Pivot Range addition
         R1,
         R2,
         R3,
         S1,
         S2,
         S3,
         M0,
         M1,
         M2,
         M3,
         M4,
         M5,
         f214,       // Fibot Levels
         f236,
         f382,
         f50,
         f618,
         f764,
         f786,
         rangeopen1, // OHLC Levels
         rangeopen2,
         rangeclose1,
         rangeclose2;

int      shift;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LevelsDelete(string name)
  {
   ObjectDelete("R3"+name);
   ObjectDelete("R2"+name);
   ObjectDelete("R1"+name);
   ObjectDelete("PP"+name);
   ObjectDelete("S1"+name);
   ObjectDelete("S2"+name);
   ObjectDelete("S3"+name);
   ObjectDelete("PDiff"+name);      //Pivot Range addition
   ObjectDelete("PRTop"+name);      //Pivot Range addition
   ObjectDelete("PRBottom"+name);   //Pivot Range addition
   ObjectDelete("R3P"+name);
   ObjectDelete("R2P"+name);
   ObjectDelete("R1P"+name);
   ObjectDelete("PPP"+name);
   ObjectDelete("S1P"+name);
   ObjectDelete("S2P"+name);
   ObjectDelete("S3P"+name);

   ObjectDelete("R3L"+name);
   ObjectDelete("R2L"+name);
   ObjectDelete("R1L"+name);
   ObjectDelete("PPL"+name);
   ObjectDelete("S1L"+name);
   ObjectDelete("S2L"+name);
   ObjectDelete("S3L"+name);

   ObjectDelete("M0"+name);
   ObjectDelete("M1"+name);
   ObjectDelete("M2"+name);
   ObjectDelete("M3"+name);
   ObjectDelete("M4"+name);
   ObjectDelete("M5"+name);

   ObjectDelete("M0P"+name);
   ObjectDelete("M1P"+name);
   ObjectDelete("M2P"+name);
   ObjectDelete("M3P"+name);
   ObjectDelete("M4P"+name);
   ObjectDelete("M5P"+name);

   ObjectDelete("M0L"+name);
   ObjectDelete("M1L"+name);
   ObjectDelete("M2L"+name);
   ObjectDelete("M3L"+name);
   ObjectDelete("M4L"+name);
   ObjectDelete("M5L"+name);

   ObjectDelete("BZ"+name);
   ObjectDelete("SZ"+name);

   ObjectDelete("BDU"+name);
   ObjectDelete("BDD"+name);
   ObjectDelete("BDL"+name);
   ObjectDelete("BDR"+name);

   ObjectDelete("f214a"+name);
   ObjectDelete("f236a"+name);
   ObjectDelete("f382a"+name);
   ObjectDelete("f50a"+name);
   ObjectDelete("f618a"+name);
   ObjectDelete("f764a"+name);
   ObjectDelete("f786a"+name);

   ObjectDelete("f214b"+name);
   ObjectDelete("f236b"+name);
   ObjectDelete("f382b"+name);
   ObjectDelete("f50b"+name);
   ObjectDelete("f618b"+name);
   ObjectDelete("f764b"+name);
   ObjectDelete("f786b"+name);

   ObjectDelete("f214p"+name);
   ObjectDelete("f236p"+name);
   ObjectDelete("f382p"+name);
   ObjectDelete("f50p"+name);
   ObjectDelete("f618p"+name);
   ObjectDelete("f764p"+name);
   ObjectDelete("f786p"+name);

   ObjectDelete("f214l"+name);
   ObjectDelete("f236l"+name);
   ObjectDelete("f382l"+name);
   ObjectDelete("f50l"+name);
   ObjectDelete("f618l"+name);
   ObjectDelete("f764l"+name);
   ObjectDelete("f786l"+name);

   ObjectDelete("open"+name);
   ObjectDelete("high"+name);
   ObjectDelete("low"+name);
   ObjectDelete("close"+name);

   ObjectDelete("openp"+name);
   ObjectDelete("highp"+name);
   ObjectDelete("lowp"+name);
   ObjectDelete("closep"+name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PlotTrend(const long              chart_ID=0,
               string                  name="trendline",
               const int               subwindow=0,
               datetime                time1=0,
               double                  price1=0,
               datetime                time2=0,
               double                  price2=0,
               const color             clr=clrBlack,
               const ENUM_LINE_STYLE   style=STYLE_SOLID,
               const int               width=2,
               const bool              back=true,
               const bool              selection=false,
               const bool              ray=false,
               const bool              hidden=true)
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,subwindow,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   if(TimeSeconds(TimeCurrent())  %2 == 0)
     {

       if  (  name  ==   "PRBottomD10"){
double   valuePRBottomD10 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(int   i   = 0   ;   i < 30 ;  i++)
           {
            pbottom[i]    =   valuePRBottomD10;
           }

       }

     if  (  name  ==   "PRTopD10"){
double   valuePRTopD10 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(   i   = 0   ;   i < 30 ;  i++)
           {
            ptop[i]    =   valuePRTopD10;
           }

       }


      if(name    == "PPD10")
        {
         double   valuePP =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(   i   = 0   ;   i < 30 ;  i++)
           {
            pivot[i]    =   valuePP;
           }
        }


      if(name    == "S1D10")
        {
         double   valueS1 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            s1[i]    =   valueS1;
           }
        }

      if(name    == "S2D10")
        {
         double   valueS2 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            s2[i]    =   valueS2;
           }
        }

      if(name    == "S3D10")
        {
         double   valueS3 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            s3[i]    =   valueS3;
           }
        }
      if(name   ==  "R1D10")
        {
         double   valueR1 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            r1[i]    =   valueR1;
           }
        }
      if(name    == "R2D10")
        {
         double   valueR2 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            r2[i]    =   valueR2;
           }
        }

      if(name    == "R3D10")
        {
         double   valueR3 =   ObjectGetDouble(0,name,OBJPROP_PRICE, 0);
         for(i   = 0   ;   i < 30 ;  i++)
           {
            r3[i]    =   valueR3;
           }
        }
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PlotRectangle(const long        chart_ID=0,
                   string            name="rectangle",
                   const int         subwindow=0,
                   datetime          time1=0,
                   double            price1=1,
                   datetime          time2=0,
                   double            price2=0,
                   const color       clr=clrGray,
                   const bool        back=true,
                   const bool        selection=false,
                   const bool        hidden=true)
  {
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,subwindow,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PlotText(const long        chart_ID=0,
              string            name="text",
              const int         subwindow=0,
              datetime          time1=0,
              double            price1=0,
              const string      text="text",
              const string      font="Arial",
              const int         font_size=10,
              const color       clr=clrGray,
              const ENUM_ANCHOR_POINT anchor = ANCHOR_RIGHT_UPPER,
              const bool        back=true,
              const bool        selection=false,
              const bool        hidden=true)
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,subwindow,time1,price1))
     {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
     }
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LevelsDraw(int      shft,
                datetime tmestrt,
                datetime tmend,
                string   name,
                bool     future)
  {
   high  = iHigh(NULL,TimePeriod,shft);
   low   = iLow(NULL,TimePeriod,shft);
   open  = iOpen(NULL,TimePeriod,shft);
   if(future==false)
     {
      close = iClose(NULL,TimePeriod,shft);
     }
   else
     {
      close = Bid;
     }

   PP  = (high+low+close)/3.0;
   PDiff = PP - ((high + low)/2.0); //Pivot Range addition
   PRTop = PP + PDiff; //Pivot Range addition
   PRBottom = PP - PDiff; //Pivot Range addition
   R1 = 2*PP-low;
   R2 = PP+(high - low);
   R3 = (2*PP)+(high-(2*low));

   S1 = 2*PP-high;
   S2 = PP-(high - low);
   S3 = (2*PP)-((2*high)-low);

   M0=0.5*(S2+S3);
   M1=0.5*(S1+S2);
   M2=0.5*(PP+S1);
   M3=0.5*(PP+R1);
   M4=0.5*(R1+R2);
   M5=0.5*(R2+R3);

   f214 = (low+(((high-low)/100)*(100-21.4)));
   f236 = (low+(((high-low)/100)*(100-23.6)));
   f382 = (low+(((high-low)/100)*(100-38.2)));
   f50  = (low+(((high-low)/100)*(100-50)));
   f618 = (low+(((high-low)/100)*(38.2)));
   f764 = (low+(((high-low)/100)*(23.6)));
   f786 = (low+(((high-low)/100)*(21.4)));

   rangeopen1  = (open-low)/((high-low)/100);
   rangeopen2  = 100-((open-low)/((high-low)/100));
   rangeclose1 = (close-low)/((high-low)/100);
   rangeclose2 = 100-((close-low)/((high-low)/100));

   if(PlotPivots)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"R3"+name,0,tmestrt,R3,tmend,R3,ColorRes,StylePivots,WidthPivots);
         PlotTrend(0,"R2"+name,0,tmestrt,R2,tmend,R2,ColorRes,StylePivots,WidthPivots);
         PlotTrend(0,"R1"+name,0,tmestrt,R1,tmend,R1,ColorRes,StylePivots,WidthPivots);
         PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,ColorPP,StylePivots,WidthPivots);
         PlotTrend(0,"S1"+name,0,tmestrt,S1,tmend,S1,ColorSup,StylePivots,WidthPivots);
         PlotTrend(0,"S2"+name,0,tmestrt,S2,tmend,S2,ColorSup,StylePivots,WidthPivots);
         PlotTrend(0,"S3"+name,0,tmestrt,S3,tmend,S3,ColorSup,StylePivots,WidthPivots);

         if(PlotPivotLabels)
           {
            PlotText(0,"R3L"+name,0,tmend,R3,"R3","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
            PlotText(0,"R2L"+name,0,tmend,R2,"R2","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
            PlotText(0,"R1L"+name,0,tmend,R1,"R1","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
            PlotText(0,"PPL"+name,0,tmend,PP,"PP","Arial",8,ColorPP,ANCHOR_RIGHT_UPPER);
            PlotText(0,"S1L"+name,0,tmend,S1,"S1","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
            PlotText(0,"S2L"+name,0,tmend,S2,"S2","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
            PlotText(0,"S3L"+name,0,tmend,S3,"S3","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
           }
         if(PlotPivotPrices)
           {
            PlotText(0,"R3P"+name,0,tmestrt,R3,DoubleToString(R3,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
            PlotText(0,"R2P"+name,0,tmestrt,R2,DoubleToString(R2,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
            PlotText(0,"R1P"+name,0,tmestrt,R1,DoubleToString(R1,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
            PlotText(0,"PPP"+name,0,tmestrt,PP,DoubleToString(PP,4),"Arial",8,ColorPP,ANCHOR_LEFT_UPPER);
            PlotText(0,"S1P"+name,0,tmestrt,S1,DoubleToString(S1,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
            PlotText(0,"S2P"+name,0,tmestrt,S2,DoubleToString(S2,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
            PlotText(0,"S3P"+name,0,tmestrt,S3,DoubleToString(S3,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
           }
        }
     }

//-------Pivot Range addition
   if(PlotPivotRange)
     {
      PlotTrend(0,"PRTop"+name,0,tmestrt,PRTop,tmend,PRTop,PivotRangeColor,PivotRangeStyle,1);
      PlotTrend(0,"PRBottom"+name,0,tmestrt,PRBottom,tmend,PRBottom,PivotRangeColor,PivotRangeStyle,1);
      if(!PlotPivots || (shift >= Days2Plot))
        {
         PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,ColorPP,StylePivots,WidthPivots);
        }
     }

   if(PlotMidpoints)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"M0"+name,0,tmestrt,M0,tmend,M0,ColorM02,StyleMidpoints,WidthMidpoints);
         PlotTrend(0,"M1"+name,0,tmestrt,M1,tmend,M1,ColorM02,StyleMidpoints,WidthMidpoints);
         PlotTrend(0,"M2"+name,0,tmestrt,M2,tmend,M2,ColorM02,StyleMidpoints,WidthMidpoints);
         PlotTrend(0,"M3"+name,0,tmestrt,M3,tmend,M3,ColorM35,StyleMidpoints,WidthMidpoints);
         PlotTrend(0,"M4"+name,0,tmestrt,M4,tmend,M4,ColorM35,StyleMidpoints,WidthMidpoints);
         PlotTrend(0,"M5"+name,0,tmestrt,M5,tmend,M5,ColorM35,StyleMidpoints,WidthMidpoints);
         if(PlotPivotLabels)
           {
            PlotText(0,"M0L"+name,0,tmend,M0,"M0","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
            PlotText(0,"M1L"+name,0,tmend,M1,"M1","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
            PlotText(0,"M2L"+name,0,tmend,M2,"M2","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
            PlotText(0,"M3L"+name,0,tmend,M3,"M3","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
            PlotText(0,"M4L"+name,0,tmend,M4,"M4","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
            PlotText(0,"M5L"+name,0,tmend,M5,"M5","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
           }
         if(PlotPivotPrices)
           {
            PlotText(0,"M0P"+name,0,tmestrt,M0,DoubleToString(M0,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
            PlotText(0,"M1P"+name,0,tmestrt,M1,DoubleToString(M1,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
            PlotText(0,"M2P"+name,0,tmestrt,M2,DoubleToString(M2,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
            PlotText(0,"M3P"+name,0,tmestrt,M3,DoubleToString(M3,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
            PlotText(0,"M4P"+name,0,tmestrt,M4,DoubleToString(M4,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
            PlotText(0,"M5P"+name,0,tmestrt,M5,DoubleToString(M5,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
           }
        }
     }

   if(PlotZones)
     {
      if(shift < Days2Plot)
        {
         PlotRectangle(0,"BZ"+name,0,tmestrt,M1,tmend,S2,ColorBuyZone);
         PlotRectangle(0,"SZ"+name,0,tmestrt,M4,tmend,R2,ColorSellZone);
        }
     }

   if(PlotBorders)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"BDU"+name,0,tmestrt,R2,tmend,R2,ColorBorder,StyleBorder,WidthBorder);
         PlotTrend(0,"BDD"+name,0,tmestrt,S2,tmend,S2,ColorBorder,StyleBorder,WidthBorder);
         PlotTrend(0,"BDL"+name,0,tmestrt,R2,tmestrt,S2,ColorBorder,StyleBorder,WidthBorder);
         PlotTrend(0,"BDR"+name,0,tmend,R2,tmend,S2,ColorBorder,StyleBorder,WidthBorder);
        }
     }

   if(PlotFibots)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"f214a"+name,0,tmestrt,f214,tmend,f214,ColorFibots,StyleFibots1,WidthFibots1);
         PlotTrend(0,"f382a"+name,0,tmestrt,f382,tmend,f382,ColorFibots,StyleFibots1,WidthFibots1);
         PlotTrend(0,"f50a"+name,0,tmestrt,f50,tmend,f50,ColorFibots,StyleFibots1,WidthFibots1);
         PlotTrend(0,"f618a"+name,0,tmestrt,f618,tmend,f618,ColorFibots,StyleFibots1,WidthFibots1);
         PlotTrend(0,"f786a"+name,0,tmestrt,f786,tmend,f786,ColorFibots,StyleFibots1,WidthFibots1);
         PlotTrend(0,"f214b"+name,0,tmestrt+TimePeriod*10,f214,tmend,f214,ColorFibots,StyleFibots2,WidthFibots2);
         PlotTrend(0,"f382b"+name,0,tmestrt+TimePeriod*10,f382,tmend,f382,ColorFibots,StyleFibots2,WidthFibots2);
         PlotTrend(0,"f50b"+name,0,tmestrt+TimePeriod*10,f50,tmend,f50,ColorFibots,StyleFibots2,WidthFibots2);
         PlotTrend(0,"f618b"+name,0,tmestrt+TimePeriod*10,f618,tmend,f618,ColorFibots,StyleFibots2,WidthFibots2);
         PlotTrend(0,"f786b"+name,0,tmestrt+TimePeriod*10,f786,tmend,f786,ColorFibots,StyleFibots2,WidthFibots2);
         if(PlotFibotLabels)
           {
            PlotText(0,"f214l"+name,0,tmend,f214,"21.4%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
            PlotText(0,"f382l"+name,0,tmend,f382,"38.2%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
            PlotText(0,"f50l"+name,0,tmend,f50,"50%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
            PlotText(0,"f618l"+name,0,tmend,f618,"61.8%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
            PlotText(0,"f786l"+name,0,tmend,f786,"78.6%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);
           }
         if(PlotFibotPrices)
           {
            PlotText(0,"f214p"+name,0,tmestrt,f214,DoubleToString(f214,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
            PlotText(0,"f382p"+name,0,tmestrt,f382,DoubleToString(f382,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
            PlotText(0,"f50p"+name,0,tmestrt,f50,DoubleToString(f50,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
            PlotText(0,"f618p"+name,0,tmestrt,f618,DoubleToString(f618,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
            PlotText(0,"f786p"+name,0,tmestrt,f786,DoubleToString(f786,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);
           }
        }
     }

   if(PlotYesterdayOHLC)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"open"+name,0,tmestrt,open,tmestrt+TimePeriod*10,open,ColorO,StyleOHLC,WidthOHLC);
         //      PlotTrend(0,"high"+name,0,tmestrt,high,tmestrt+TimePeriod*10,high,ColorH,StyleOHLC,WidthOHLC);
         //      PlotTrend(0,"low"+name,0,tmestrt,low,tmestrt+TimePeriod*10,low,ColorL,StyleOHLC,WidthOHLC);
         PlotTrend(0,"close"+name,0,tmestrt,close,tmestrt+TimePeriod*10,close,ColorC,StyleOHLC,WidthOHLC);
         if(PlotOHLCPrices)
           {
            PlotText(0,"openp"+name,0,tmestrt+TimePeriod*10,open,DoubleToString(rangeopen1,1)+"/"+DoubleToString(rangeopen2,1)+"%","Arial",8,ColorO,6);
            PlotText(0,"closep"+name,0,tmestrt+TimePeriod*10,close,DoubleToString(rangeclose1,1)+"/"+DoubleToString(rangeclose2,1)+"%","Arial",8,ColorC,6);
           }
        }
     }
   if(PlotYesterdayHL)
     {
      if(shift < Days2Plot)
        {
         PlotTrend(0,"high"+name,0,tmestrt,high,tmestrt+TimePeriod*60,high,ColorH,StyleOHLC,WidthOHLC);
         PlotTrend(0,"low"+name,0,tmestrt,low,tmestrt+TimePeriod*60,low,ColorL,StyleOHLC,WidthOHLC);
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,  pivot) ;
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0, "pivot");

   SetIndexBuffer(1,r1) ;
   SetIndexStyle(1,  DRAW_LINE);
   SetIndexLabel(1, "r1");

   SetIndexBuffer(2,r2) ;
   SetIndexStyle(2, DRAW_LINE);
   SetIndexLabel(2,  "r2");

   SetIndexBuffer(3,  r3);
   SetIndexStyle(3, DRAW_LINE) ;
   SetIndexLabel(3, "r3");


   SetIndexBuffer(4,  s1);
   SetIndexStyle(4, DRAW_LINE) ;
   SetIndexLabel(4, "s1");
   SetIndexBuffer(5,  s2);
   SetIndexStyle(5, DRAW_LINE) ;
   SetIndexLabel(5, "s2");
   SetIndexBuffer(6,  s3);
   SetIndexStyle(6, DRAW_LINE) ;
   SetIndexLabel(6, "s3");
SetIndexBuffer(7,  ptop);
   SetIndexStyle(7, DRAW_LINE) ;
   SetIndexLabel(7, "pbottom");
SetIndexBuffer(8,  pbottom);
   SetIndexStyle(8, DRAW_LINE) ;
   SetIndexLabel(8, "ptop");

   if(TimePeriod==PERIOD_M1||TimePeriod==PERIOD_CURRENT)
     {
      TimePeriod=PERIOD_M5;
      period="M5";
     }
   if(TimePeriod==PERIOD_M5)
     {
      period="M5";
     }
   if(TimePeriod==PERIOD_M15)
     {
      period="M15";
     }
   if(TimePeriod==PERIOD_M30)
     {
      period="M30";
     }
   if(TimePeriod==PERIOD_H1)
     {
      period="H1";
     }
   if(TimePeriod==PERIOD_H4)
     {
      period="H4";
     }
   if(TimePeriod==PERIOD_D1)
     {
      period="D1";
     }
   if(TimePeriod==PERIOD_W1)
     {
      period="W1";
     }
   if(TimePeriod==PERIOD_MN1)
     {
      period="MN1";
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   for(shift=0; shift<=CountPeriods; shift++)
     {
      LevelsDelete(period+shift);
     }
   LevelsDelete("F"+period);
   Comment("");
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   /*







   */








   for(shift=0; shift<=CountPeriods; shift++)
     {
      LevelsDelete(period+shift);
     }
   LevelsDelete("F"+period);

   for(shift=CountPeriods-1; shift>=0; shift--)
     {
      timestart = iTime(NULL,TimePeriod,shift);
      timeend   = iTime(NULL,TimePeriod,shift)+TimePeriod*60;

      LevelsDraw(shift+1,timestart,timeend,period+shift,false);
     }

   if(PlotFuturePivots)
     {
      timestart=iTime(NULL,TimePeriod,0)+TimePeriod*60;
      timeend=iTime(NULL,TimePeriod,0)+TimePeriod*120;

      LevelsDraw(0,timestart,timeend,"F"+period,true);
     }

   return(0);
  }
//+------------------------------------------------------------------+
