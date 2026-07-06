// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70761
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
#property indicator_chart_window
#property strict

input int P = 64;//200 default
input int StepBack = 0;
input int defbackbars = 24;
input bool RayLine =false;
input bool BackLine =false;
input string  _Select_Visual_TimeFrames  =  "=== Select Murrey on TimeFrames ===";
input bool    Enable_M1                  =  false;//*******
input bool    Enable_M5                  =  true;
input bool    Enable_M15                 =  true;
input bool    Enable_M30                 =  true;
input bool    Enable_H1                  =  true;
input bool    Enable_H4                  =  true;
input bool    Enable_D1                  =  true;
input bool    Enable_W1                  =  true;
input bool    Enable_MN1                 =  true;

input string mml_colors    = "=== Colors ===";
input color  mml_clr_m_2_8 = Yellow;      // [-2]/8 //was White
input color  mml_clr_m_1_8 = Yellow;      // [-1]/8  //White
input color  mml_clr_0_8   = Aqua;        // [0]/8
input color  mml_clr_1_8   = Gold;        // [1]/8
input color  mml_clr_2_8   = Red;         // [2]/8
input color  mml_clr_3_8   = Lime;       //  [3]/8
input color  mml_clr_4_8   = DeepSkyBlue;//  [4]/8
input color  mml_clr_5_8   = Lime;       //  [5]/8
input color  mml_clr_6_8   = Red;         // [6]/8
input color  mml_clr_7_8   = Gold;        // [7]/8
input color  mml_clr_8_8   = Aqua;        // [8]/8
input color  mml_clr_p_1_8 = Yellow;      // [+1]/8  //was White
input color  mml_clr_p_2_8 = Yellow;      // [+2]/8  //White

input string mml_wdth_       = "=== Width ===";
input int    mml_wdth_m_2_8  = 2;        // [-2]/8
input int    mml_wdth_m_1_8  = 2;       // [-1]/8//***************was almal 1.
input int    mml_wdth_0_8    = 2;        //  [0]/8
input int    mml_wdth_1_8    = 2;      //  [1]/8
input int    mml_wdth_2_8    = 2;         //  [2]/8
input int    mml_wdth_3_8    = 2;       //  [3]/8
input int    mml_wdth_4_8    = 2;        //  [4]/8 //************** 1 NB!
input int    mml_wdth_5_8    = 2;       //  [5]/8
input int    mml_wdth_6_8    = 2;         //  [6]/8
input int    mml_wdth_7_8    = 2;      //  [7]/8
input int    mml_wdth_8_8    = 2;        //  [8]/8
input int    mml_wdth_p_1_8  = 2;       // [+1]/8
input int    mml_wdth_p_2_8  = 2;       // [+2]/8

input string mml_styles      = "=== Styles ===";  
input int    mml_style_m_2_8 = 0;        // [-2]/8
input int    mml_style_m_1_8 = 0;       // [-1]/8
input int    mml_style_0_8   = 0;        //  [0]/8// van hier af is almal -------
input int    mml_style_1_8   = 0;      //  [1]/8
input int    mml_style_2_8   = 0;         //  [2]/8
input int    mml_style_3_8   = 0;       //  [3]/8
input int    mml_style_4_8   = 0;        //  [4]/8 //******************** 1 NB!
input int    mml_style_5_8   = 0;       //  [5]/8
input int    mml_style_6_8   = 0;         //  [6]/8
input int    mml_style_7_8   = 0;      //  [7]/8
input int    mml_style_8_8   = 0;        //  [8]/8
input int    mml_style_p_1_8 = 0;       // [+1]/8
input int    mml_style_p_2_8 = 0;       // [+2]/8

input string mml_labels      = "=== Labels ===";
input string mml_label_m_2_8 = "[-2/8] "; //EXTREME";
input string mml_label_m_1_8 = "[-1/8] "; //Overshoot";
input string mml_label_0_8   = "[0/8] "; //ULTIMATE SUPP";
input string mml_label_1_8   = "[1/8] "; //WEAK, STALL & REVERSE";
input string mml_label_2_8   = "[2/8] "; //PIVOT_STRONG REVERSE";
input string mml_label_3_8   = "[3/8] "; //BOTTOM Trading RANGE";
input string mml_label_4_8   = "[4/8] "; //MAJOR RES/SUPP";
input string mml_label_5_8   = "[5/8] "; //TOP OF Trading Range";
input string mml_label_6_8   = "[6/8] "; //PIVOT_STRONG REVERSE";
input string mml_label_7_8   = "[7/8] "; //WEAK,STALL & REVERSE";
input string mml_label_8_8   = "[8/8] "; //ULTIMATE RES";
input string mml_label_p_1_8 = "[+1/8] "; //Overshoot";
input string mml_label_p_2_8 = "[+2/8] "; //EXTREME";
input string __________Line_Text_On_Off_________;
input bool  Text_on_Off=true;

input bool Line1 = true;   // Display text
input bool Line2= true; 
input bool Line3= true; 
input bool Line4= true; 
input bool Line5= true; 
input bool Line6= true; 
input bool Line7= true; 
input bool Line8= true; 
input bool Line9= true; 
input bool Line10= true; 
input bool Line11= true; 
input bool Line12= true; 
input bool Line13= true; 
input string  FontName       = "Sanserif";
input int     FontSize       = 10;
input color   FontColor      = DarkGray;
input int     LabelsShift    = -25;//*************************NB!

double   dmml = 0,    dvtl = 0,       sum = 0,        v1 = 0,
         v2 = 0,        mn = 0,        mx = 0,
         x1 = 0,        x2 = 0,        x3 = 0,        x4 = 0,        x5 = 0,        x6 = 0,
         y1 = 0,        y2 = 0,        y3 = 0,        y4 = 0,        y5 = 0,        y6 = 0,
         octave = 0,fractal= 0,     range = 0,    finalH = 0,   finalL  = 0,
         ip[9,13],
         mml[13];
string   ln_txt[13], ln_txt1[13], tf_txt[9,13], buff_str = "",      tstr="",
         sf_txt[9]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
int      bn_v1        = 0,
         bn_v2        = 0,
         OctLinesCnt  = 13,
         mml_thk      = 8,
         mml_clr[13],
         mml_wdth[13],
         mml_style[13],
         mml_shft     = 3,
         nTime        = 0,
         CurPeriod    = 0,
         nDigits      = 0,
         i            = 0,
         j            = 0,
         iTF          = 0,
         iLC          = 0, 
         TF[9] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1},
         Lwidth[13],
         nTF=9;

input int button_x = 20;
input int button_y = 30;

class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;

//+------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                   |
//+------------------------------------------------------------------------------------------------------------+
int init()
{
   visibility.Init("mmatfloon", "mmatfloon", "Show/Hide", button_x, button_y);
   //---- indicators
   
   ln_txt1[0]  = mml_label_m_2_8;// "extreme overshoot [-2/8]";// [-2/8]
   ln_txt1[1]  = mml_label_m_1_8;// "overshoot [-1/8]";// [-1/8]
   ln_txt1[2]  = mml_label_0_8;// "Ultimate Support - extremely oversold [0/8]";// [0/8]
   ln_txt1[3]  = mml_label_1_8;// "Weak, Place to Stop and Reverse - [1/8]";// [1/8]
   ln_txt1[4]  = mml_label_2_8;// "Pivot, Reverse - major [2/8]";// [2/8]
   ln_txt1[5]  = mml_label_3_8;// "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone";//[3/8]
   ln_txt1[6]  = mml_label_4_8;// "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level";// [4/8]
   ln_txt1[7]  = mml_label_5_8;// "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone";//[5/8]
   ln_txt1[8]  = mml_label_6_8;// "Pivot, Reverse - major [6/8]";// [6/8]
   ln_txt1[9]  = mml_label_7_8;// "Weak, Place to Stop and Reverse - [7/8]";// [7/8]
   ln_txt1[10] = mml_label_8_8;// "Ultimate Resistance - extremely overbought [8/8]";// [8/8]
   ln_txt1[11] = mml_label_p_1_8;// "overshoot [+1/8]";// [+1/8]
   ln_txt1[12] = mml_label_p_2_8;// "extreme overshoot [+2/8]";// [+2/8]
   
   mml_shft = 25;
   mml_thk  = 3;
      
   mml_clr[0]  = mml_clr_m_2_8;   mml_wdth[0] = mml_wdth_m_2_8; mml_style[0]  = mml_style_m_2_8;// [-2]/8
   mml_clr[1]  = mml_clr_m_1_8;   mml_wdth[1] = mml_wdth_m_1_8; mml_style[1]  = mml_style_m_1_8;// [-1]/8
   mml_clr[2]  = mml_clr_0_8;     mml_wdth[2] = mml_wdth_0_8;   mml_style[2]  = mml_style_0_8;  //  [0]/8
   mml_clr[3]  = mml_clr_1_8;     mml_wdth[3] = mml_wdth_1_8;   mml_style[3]  = mml_style_1_8;  //  [1]/8
   mml_clr[4]  = mml_clr_2_8;     mml_wdth[4] = mml_wdth_2_8;   mml_style[4]  = mml_style_2_8;  //  [2]/8
   mml_clr[5]  = mml_clr_3_8;     mml_wdth[5] = mml_wdth_3_8;   mml_style[5]  = mml_style_3_8;  //  [3]/8
   mml_clr[6]  = mml_clr_4_8;     mml_wdth[6] = mml_wdth_4_8;   mml_style[6]  = mml_style_4_8;  //  [4]/8
   mml_clr[7]  = mml_clr_5_8;     mml_wdth[7] = mml_wdth_5_8;   mml_style[7]  = mml_style_5_8;  //  [5]/8
   mml_clr[8]  = mml_clr_6_8;     mml_wdth[8] = mml_wdth_6_8;   mml_style[8]  = mml_style_6_8;  //  [6]/8
   mml_clr[9]  = mml_clr_7_8;     mml_wdth[9] = mml_wdth_7_8;   mml_style[9]  = mml_style_7_8;  //  [7]/8
   mml_clr[10] = mml_clr_8_8;     mml_wdth[10]= mml_wdth_8_8;   mml_style[10] = mml_style_8_8;  //  [8]/8
   mml_clr[11] = mml_clr_p_1_8;   mml_wdth[11]= mml_wdth_p_1_8; mml_style[11] = mml_style_p_1_8;// [+1]/8
   mml_clr[12] = mml_clr_p_2_8;   mml_wdth[12]= mml_wdth_p_2_8; mml_style[12] = mml_style_p_2_8;// [+2]/8
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //---- TODO: add your code here
   Comment(" ");   
   
   for( i=0; i < OctLinesCnt; i++ ) {
      buff_str = "mml"+i;       ObjectDelete(buff_str);
      buff_str = "mml_txt"+i;   ObjectDelete(buff_str);
   }
   visibility.DeInit();
   
   return( 0 );
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   visibility.HandleButtonClicks();

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         nTime = 0;
      }
      else
      {
         Comment(" ");   
         for (i = 0; i < OctLinesCnt; i++) 
         {
            buff_str = "mml" + i;
            ObjectDelete(buff_str);
            buff_str = "mml_txt" + i;
            ObjectDelete(buff_str);
         }
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
   int LD=0;
   if( (nTime != Time[0]) || (CurPeriod != Period()) ) {// ïåðâûé ïåðåñ÷åò è ïðè çàâåðøåíèè ñâå÷è
      for( iLC=0; iLC < OctLinesCnt; iLC++ )   {
         ln_txt[iLC]="";
         Lwidth[iLC]=0;   // øèðèíà âñåõ ëèíèé ïî óìîë÷àíèþ=0
         for( iTF=0; iTF < nTF; iTF++ ) {
            ip[iTF,iLC] = 0.0;
            tf_txt[iTF,iLC] = "";
         }
      }
      
      for( iTF=nTF-1; iTF >= 0; iTF-- ) { //  ñî ñòàðøèõ òàéìôðåéìîâ äî òåêóùåãî
         
         if( !Enable_M1  &&  TF[iTF] == PERIOD_M1 ) continue;
         if( !Enable_M5  &&  TF[iTF] == PERIOD_M5 ) continue;
         if( !Enable_M15  &&  TF[iTF] == PERIOD_M15 ) continue;
         if( !Enable_M30  &&  TF[iTF] == PERIOD_M30 ) continue;
         if( !Enable_H1  &&  TF[iTF] == PERIOD_H1 ) continue;
         if( !Enable_H4  &&  TF[iTF] == PERIOD_H4 ) continue;
         if( !Enable_D1  &&  TF[iTF] == PERIOD_D1 ) continue;
         if( !Enable_W1  &&  TF[iTF] == PERIOD_W1 ) continue;
         if( !Enable_MN1  &&  TF[iTF] == PERIOD_MN1 ) continue;
         
         Raschet( TF[iTF] );
         
         for( iLC=0; iLC < OctLinesCnt; iLC++ ) {
            ip[iTF,iLC] = mml[iLC];
            tf_txt[iTF,iLC] = StringConcatenate(StringTrimRight(sf_txt[iTF]),ln_txt1[iLC]);
         }
         
         if( TF[iTF] == Period() ) break;   // ìäàäøèå ÒàéìÔðåéìû íå íóæíû
      }
      
      for( iTF=nTF-1; iTF >= 0; iTF-- ) {   // ïðîñòàíîâêà íàäïèñåé íà óðîâíè ïîñëåäíåãî ðàñ÷èòàííîãî ÒÔ
         
         if( !Enable_M1  &&  TF[iTF] == PERIOD_M1 ) continue;
         if( !Enable_M5  &&  TF[iTF] == PERIOD_M5 ) continue;
         if( !Enable_M15  &&  TF[iTF] == PERIOD_M15 ) continue;
         if( !Enable_M30  &&  TF[iTF] == PERIOD_M30 ) continue;
         if( !Enable_H1  &&  TF[iTF] == PERIOD_H1 ) continue;
         if( !Enable_H4  &&  TF[iTF] == PERIOD_H4 ) continue;
         if( !Enable_D1  &&  TF[iTF] == PERIOD_D1 ) continue;
         if( !Enable_W1  &&  TF[iTF] == PERIOD_W1 ) continue;
         if( !Enable_MN1  &&  TF[iTF] == PERIOD_MN1 ) continue;
         
         for( iLC=0; iLC < OctLinesCnt; iLC++ ) { // öèêë ïî âñåì ëèíèÿì
            for( j=0; j < OctLinesCnt; j++ ) {
               if( (ip[iTF,iLC]<(mml[j]+(dmml/2))) && (ip[iTF,iLC]>(mml[j]-(dmml/2))) ) {// ïîïàäàíèå â äèàïàçîí
                  tstr = StringTrimLeft(StringTrimRight(ln_txt[j])+" ");
                  ln_txt[j] = StringConcatenate(tstr, tf_txt[iTF,iLC]);
                  if( Lwidth[j] < iTF ) Lwidth[j] = iTF;  //äëÿ  øèðèíû ëèíèé, çàíîñèòñÿ íîìåð èç ìàêñ ÒÔ
               }
            }
         }
         
         if( TF[iTF] == Period() ) break; // ìåíüøèå ÒÔ íå íóæíû
      }
      
      ShowLines();
      nTime = Time[0];
      CurPeriod = Period(); // ïåðâûé ïåðåñ÷åò ïðîøåë
   }
   
   return( 0 );
}// End Start()



//+------------------------------------------------------------------+
void Raschet( int pTF )
{
   bn_v1 = iLowest( NULL, pTF,MODE_LOW, P+StepBack,0);
   bn_v2 = iHighest(NULL, pTF,MODE_HIGH,P+StepBack,0);
   v1    = iLow(NULL,pTF,bn_v1);
   v2    = iHigh(NULL,pTF,bn_v2);
   //determine fractal.....
   if( v2<=250000 && v2>25000 )                 fractal  =  100000;
   else if( v2<=25000 && v2>2500 )              fractal  =   10000;
    else if( v2<=2500 && v2>250 )               fractal  =    1000;
     else if( v2<=250 && v2>25 )                fractal  =     100;
      else if( v2<=25 && v2>12.5 )              fractal  =      12.5;
       else if( v2<=12.5 && v2>6.25)            fractal  =      12.5;
        else if( v2<=6.25 && v2>3.125 )         fractal  =       6.25;
         else if( v2<=3.125 && v2>1.5625 )      fractal  =       3.125;
          else if( v2<=1.5625 && v2>0.390625 )  fractal  =       1.5625;
           else if( v2<=0.390625 && v2>0)       fractal  =       0.1953125;
   range    =(v2-v1);
   sum      =MathFloor(MathLog(fractal/range)/MathLog(2));
   octave   =fractal*(MathPow(0.5,sum));
   mn       =MathFloor(v1/octave)*octave;
   if( (mn+octave)>v2 )
      mx=mn+octave; 
   else
      mx=mn+(2*octave);
   // calculating xx
   if( (v1>=(3*(mx-mn)/16+mn)) && (v2<=(9*(mx-mn)/16+mn)))              x2=mn+(mx-mn)/2;  else x2=0;
   if( (v1>=(mn-(mx-mn)/8))    && (v2<=(5*(mx-mn)/8+mn)) && (x2==0))    x1=mn+(mx-mn)/2;  else x1=0;
   if( (v1>=(mn+7*(mx-mn)/16)) && (v2<=(13*(mx-mn)/16+mn)))             x4=mn+3*(mx-mn)/4;else x4=0;
   if( (v1>=(mn+3*(mx-mn)/8))  && (v2<=(9*(mx-mn)/8+mn))&& (x4==0))     x5=mx;            else x5=0;
   if( (v1>=(mn+(mx-mn)/8))    && (v2<=(7*(mx-mn)/8+mn))&&(x1==0)
                               &&(x2==0)&&(x4==0)&&(x5==0))             x3=mn+3*(mx-mn)/4;else x3=0;
   if( (x1+x2+x3+x4+x5) ==0 )    x6=mx;                                                   else x6=0;
   finalH = x1+x2+x3+x4+x5+x6;
   // calculating yy
   if( x1>0 )    y1=mn;               else y1=0;
   if( x2>0 )    y2=mn+(mx-mn)/4;     else y2=0;
   if( x3>0 )    y3=mn+(mx-mn)/4;     else y3=0;
   if( x4>0 )    y4=mn+(mx-mn)/2;     else y4=0;
   if( x5>0 )    y5=mn+(mx-mn)/2;     else y5=0;
   if( (finalH>0) && ((y1+y2+y3+y4+y5)==0) )    y6=mn;     else y6=0;
   finalL = y1+y2+y3+y4+y5+y6;
   for( i=0; i<OctLinesCnt; i++) {mml[i] = 0;}
   dmml = (finalH-finalL)/8;
   mml[0] =(finalL-dmml*2); //-2/8
   for( i=1; i<OctLinesCnt; i++) {mml[i] = mml[i-1] + dmml;}
   
  // return( 0 );
}



//+------------------------------------------------------------------+
void ShowLines()
{
   for( i=0; i<OctLinesCnt; i++ ) {
      buff_str = "mml"+i;
      
      if( ObjectFind(buff_str) == -1 ) {
         ObjectCreate( buff_str, OBJ_TREND, 0, Time[defbackbars], mml[i], Time[0], mml[i] );
      }
      ObjectSet( buff_str, OBJPROP_STYLE, mml_style[i] );
      ObjectSet( buff_str, OBJPROP_COLOR, mml_clr[i] );
      ObjectSet( buff_str, OBJPROP_WIDTH, mml_wdth[i] );
      ObjectSet( buff_str, OBJPROP_RAY, RayLine );
      ObjectSet( buff_str, OBJPROP_BACK, BackLine );
      ObjectMove( buff_str, 0, Time[defbackbars], mml[i] );
      ObjectMove( buff_str, 1, Time[0], mml[i] );
      
      //ShowTipLines( Lwidth[i], mml[i] );
      
      buff_str = "mml_txt"+i;
      
      datetime time = Time[0];
      if (LabelsShift < 0)
         time = Time[0] + MathAbs(LabelsShift) * Period() * 60;
      
      if( ObjectFind(buff_str) == -1 ) {
         ObjectCreate( buff_str, OBJ_TEXT, 0, time, LabelsShift );
      }
      ObjectSetText( buff_str, ln_txt[i], FontSize, FontName, FontColor ); //mml_clr[i] );
      ObjectMove( buff_str, 0, time, mml[i] );
      
      if(!Line1)
         ObjectDelete("mml"+12);
      if(!Line1)   
          ObjectDelete("mml_txt"+12);   
      
      
        if(!Line2)
         ObjectDelete("mml"+11);
      if(!Line2)   
          ObjectDelete("mml_txt"+11);  
      
      
     if(!Line3)
         ObjectDelete("mml"+10);
      if(!Line3)   
          ObjectDelete("mml_txt"+10);   

     if(!Line4)
         ObjectDelete("mml"+9);
      if(!Line4)   
          ObjectDelete("mml_txt"+9);
         
       if(!Line5)
         ObjectDelete("mml"+8);
      if(!Line5)   
          ObjectDelete("mml_txt"+8);   
          
          
          
       if(!Line6)
         ObjectDelete("mml"+7);
      if(!Line6)   
          ObjectDelete("mml_txt"+7);      
          
      
       if(!Line7)
         ObjectDelete("mml"+6);
      if(!Line7)   
          ObjectDelete("mml_txt"+6); 
          
          
          
       if(!Line8)
         ObjectDelete("mml"+5);
      if(!Line8)   
          ObjectDelete("mml_txt"+5);   
          
          
          
       if(!Line9)
         ObjectDelete("mml"+4);
      if(!Line9)   
          ObjectDelete("mml_txt"+4);    
          
          
          
        if(!Line10)
         ObjectDelete("mml"+3);
      if(!Line10)   
          ObjectDelete("mml_txt"+3);   
          
          
          
       if(!Line11)
         ObjectDelete("mml"+2);
      if(!Line11)   
          ObjectDelete("mml_txt"+2);     
          
          
          
         if(!Line12)
         ObjectDelete("mml"+1);
      if(!Line12)   
          ObjectDelete("mml_txt"+1);  
          
          
         if(!Line13)
         ObjectDelete("mml"+0);
      if(!Line13)   
          ObjectDelete("mml_txt"+0);   
          
          
        if(!Text_on_Off)   
          ObjectDelete("mml_txt"+i);  
   }
}// End ShowLines()


  
//+------------------------------------------------------------------+
void ShowTipLines( int pS, double pCoord )
{
   int wi=1, st=STYLE_SOLID;
   ObjectMove(buff_str, 0, Time[0],   pCoord);
   if (pS==0){wi=0; st=STYLE_DOT;         }//M1  
   if (pS==1){wi=0; st=STYLE_DOT;         }//M5  
   if (pS==2){wi=0; st=STYLE_DASHDOTDOT;  }//M15 
   if (pS==3){wi=0; st=STYLE_DASHDOTDOT;  }//M30 
   if (pS==4){wi=1; st=STYLE_DASHDOT;     }//H1   
   if (pS==5){wi=1; st=STYLE_DASH;        }//H4  
   if (pS==6){wi=1; st=STYLE_SOLID;       }//D1  
   if (pS==7){wi=2; st=STYLE_SOLID;       }//W1
   if (pS==8){wi=3; st=STYLE_SOLID;       }//MN1
   ObjectSet(buff_str, OBJPROP_WIDTH, wi); 
   ObjectSet(buff_str, OBJPROP_STYLE, st);
}
// End of Program  *****************************+