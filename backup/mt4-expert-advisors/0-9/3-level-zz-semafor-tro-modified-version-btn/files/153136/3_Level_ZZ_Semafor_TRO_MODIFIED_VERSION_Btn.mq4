// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74306  

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window 
#property indicator_buffers 6
#property indicator_color1 Chocolate 
#property indicator_color2 Chocolate 
#property indicator_color3 MediumVioletRed
#property indicator_color4 MediumVioletRed
#property indicator_color5 Yellow
#property indicator_color6 Yellow

bool hide = false;
#include <Controls/Button.mqh>
int deinitReason;
CButton bt1;
#define BUTTON1_NAME "On/Off"

int filehandle;
string filename = "setState.csv";

void SaveState()
{
    filehandle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV);
    FileWrite(filehandle,hide); 
    FileClose(filehandle); 
}
void GetState()
{
    filehandle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV);
    hide = FileReadBool(filehandle); 
    FileClose(filehandle);
}
void DeleteState()
{
    if(FileIsExist(filename))
    {
        FileDelete(filename);
    }
}


//+--------- TRO MODIFICATION ---------------------------------------+ 
extern bool   TURN_OFF = false;
extern bool   TrainingWheels     = true ;
extern bool   Show_TRO_Mods      = false ;
extern bool   Show_Tradelines    = true; 

extern bool   Show_Diff          = true ;
extern bool   Show_Floaters      = false ;
extern bool   Show_Legend        = true ;
extern bool   Show_Trendlines    = true; 
extern bool   Show_Retracelines  = true; 
extern bool   Show_Targetlines   = true; 
extern bool   Show_Medianline    = true; 
extern bool   Show_TrendLines3   = true; 
extern bool   Show_Fiblines      = true; 
extern bool   Show_Fiblines3     = true; 
extern bool   Show_Bars          = true ;
extern bool   Show_Boxes         = true ;
extern bool   Show_Label         = true ;
extern int    ShiftLabel         =  10 ;
extern bool   Show_SupResLines3  = true; 
extern int    myTradeLinelevel   = 0 ;
extern int    NumTradeLineLines  = 5 ;
extern int    mySRlevel          = 1;
extern int    NumSRLines         = 5 ;


extern bool   Sound_Alert    = false ;
extern bool   Show_Comment   = false ; 



extern int win = 0;
extern int price_x_offset= 140 ; 
extern int price_y_offset= 20 ; 

extern string myFont          = "Impact";
extern int   myFontSize       = 20;


extern int    myBars         = 100 ;
extern int    myThreshold    = 1;
extern int    myRetracePips  = 20;
extern int    myTargetPips   = 20;


extern int    NumComments    = 5 ;

extern int    yIncLegend     = 50 ;
 
extern color Buy_color = Lime;
extern color Wait_color = Yellow;
extern color Sell_color = Red;

extern color  myUpperTradeLineColor = Red; 
extern int    myUpperTradeLineStyle = STYLE_DOT;
extern int    myUpperTradeLineWidth = 1;
 
extern color  myLowerTradeLineColor = Blue; 
extern int    myLowerTradeLineStyle = STYLE_DOT;
extern int    myLowerTradeLineWidth = 1;

extern color  myUpperTrendLineColor = Red; 
extern int    myUpperTrendLineStyle = STYLE_SOLID;
extern int    myUpperTrendLineWidth = 2;
extern string myUpperSoundFile      = "ahooga.wav";

//extern string myLowerTrendLineName  = "LowerTrendLine001";
extern color  myLowerTrendLineColor = Blue; 
extern int    myLowerTrendLineStyle = STYLE_SOLID;
extern int    myLowerTrendLineWidth = 2;
extern string myLowerSoundFile      = "siren.wav";

extern color  myRetraceLineColor = Orange; 
extern int    myRetraceLineStyle = STYLE_DOT;
extern int    myRetraceLineWidth = 1;

extern color  myTargetLineColor = Magenta; 
extern int    myTargetLineStyle = STYLE_DOT;
extern int    myTargetLineWidth = 1;

extern color  myMedianLineColor = Violet; 
extern int    myMedianLineStyle = STYLE_DOT;
extern int    myMedianLineWidth = 1;

extern color  myUpperTrendLine3Color = Red; 
extern int    myUpperTrendLine3Style = STYLE_SOLID;
extern int    myUpperTrendLine3Width = 3;
 
 
extern color  myLowerTrendLine3Color = Blue; 
extern int    myLowerTrendLine3Style = STYLE_SOLID;
extern int    myLowerTrendLine3Width = 3;
 

extern color  myUpperSRColor = Red; 
extern int    myUpperSRStyle = STYLE_DASH;
extern int    myUpperSRWidth = 1;
 
 
extern color  myLowerSRColor = Blue; 
extern int    myLowerSRStyle = STYLE_DASH;
extern int    myLowerSRWidth = 1;


extern double    iLevel1 = 0.24; 
extern double    iLevel2 = 0.382; 
extern double    iLevel3 = 0.5; 
extern double    iLevel4 = 0.618; 
extern double    iLevel5 = 0.76; 

extern color Fibcolor1 = DarkSeaGreen ;
extern color Fibcolor2 = Khaki ;
extern color Fibcolor3 = Gray ;
extern color Fibcolor4 = Khaki ;
extern color Fibcolor5 = DarkSeaGreen ; 
 
extern int    myFibLineStyle = STYLE_DASHDOTDOT;
extern int    myFibLineWidth = 1; 
 
extern int    myFibLine3Style = STYLE_DASHDOT;
extern int    myFibLine3Width = 1;  
  
//---- input parameters 
extern double Period1=5; 
extern double Period2=13; 
extern double Period3=34; 
extern string   Dev_Step_1="1,3";
extern string   Dev_Step_2="8,5";
extern string   Dev_Step_3="13,8";
extern int Symbol_1_Kod=140;
extern int Symbol_2_Kod=141;
extern int Symbol_3_Kod=142;

extern int Symbol_1_Size=1 ;
extern int Symbol_2_Size=2;
extern int Symbol_3_Size=4;

extern color Color_1 = clrBrown;
extern color Color_2 = clrMediumVioletRed;
extern color Color_3 = clrYellow;

// ------------------------------------------------------------------

input string Tbtn = "== Button  ==";  // ————————————
input color on_color = SpringGreen; // ON Color:
input color off_color = Gray; // OFF Color:

//+------------------------------------------------------------------+ 


//---- buffers 
double FP_BuferUp[];
double FP_BuferDn[]; 
double NP_BuferUp[];
double NP_BuferDn[]; 
double HP_BuferUp[];
double HP_BuferDn[]; 

int F_Period;
int N_Period;
int H_Period;
int Dev1;
int Stp1;
int Dev2;
int Stp2;
int Dev3;
int Stp3;
//+--------- TRO MODIFICATION ---------------------------------------+ 
string symbol, tChartPeriod,  tShortName ;  
int    digits, period  ; 

bool Trigger1,  Trigger2,  Trigger3 ;

int OldBars = -1 ;

color tColor = Yellow ;

int i, j, k, tltop, tlbot;
 
string Messages[26], theMessage, space ;

bool roll ;

double point ;
double upperTL1[2], lowerTL1[2], upperTL2[2], lowerTL2[2], upperTL3[2], lowerTL3[2], upperTL[2], lowerTL[2];
double UpperTrendLinePrice, LowerTrendLinePrice, UpperLimit, LowerLimit, xThreshold;
double upperTradeLine, lowerTradeLine ;
double UpperRetracePrice, LowerRetracePrice, xRetracePips ;
double pUpperTargetPrice, pLowerTargetPrice, UpperTargetPrice, LowerTargetPrice, xTargetPips ;

datetime upperTLtime1[2], lowerTLtime1[2],upperTLtime2[2], lowerTLtime2[2],upperTLtime3[2], lowerTLtime3[2],upperTLtime[2], lowerTLtime[2];
datetime upperStime, upperEtime, lowerStime, lowerEtime;
string TAG = "3lzz", OBJ001, OBJ002, OBJ003, OBJ004, OBJ005, OBJ006 ;  
string OBJ007, OBJ008 ;   
 
double midpoint, midstart ; 
datetime midstarttime ; 

datetime upperTL3time[2], lowerTL3time[2]  ;
 
double upperTL3Max, lowerTL3Min,  UpperTrendLine3Price, LowerTrendLine3Price ;
int    tl1top, tl1bot, tl2top, tl2bot, tl3top, tl3bot;

double upperSR, lowerSR ;

double fibrange, fibvalue[5], fibvalue3[5]  , FIBLEVEL[5], FIBCOLOR[5];
datetime fibstarttime ;
int yIncL ;
string sFib;
datetime upperTLBars1[2], lowerTLBars1[2],upperTLBars2[2], lowerTLBars2[2],upperTLBars3[2], lowerTLBars3[2],upperTLBars[2], lowerTLBars[2];

double Sema3Diff , Close3Diff;

 double  W1_VALUE, D1_VALUE,W1_OPEN, D1_OPEN, close ;
 bool    W1_UP, D1_UP,W1_DOWN, D1_DOWN  ;
 string TW_MESSAGE;
 color  TW_COLOR ;
 datetime   TW_TRIGGER ;
 
 int SRlevel, TradeLinelevel ;
//+------------------------------------------------------------------+ 

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
  OnChartEventButtons(id, lparam, dparam, sparam);
}

// NOTE: initbutons
int OnInitButtons()
{
    if(deinitReason != REASON_CHARTCHANGE && deinitReason != REASON_PARAMETERS)
    {
        if(!Create_button(BUTTON1_NAME, 10, 100, 17, 100, bt1)) return (INIT_FAILED);
    }
return true;
}

bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt)
{
  int x2 = x1 + width;
  int y2 = y1 + high;

  bt.Create(0, name, 0, x1, y1, x2, y2);
  bt.Text("ON");
  bt.Font("Calibri");
  bt.FontSize(8);
  bt.ColorBackground(on_color);
  return true;
}

// NOTE: Events
void OnChartEventButtons(const int id, const long& lparam, const double& dparam, const string& sparam)
{
  if (id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON1_NAME)
  {
    ActionBt1();
  }
}

void setButtonState(bool _hide)
{
    if(_hide)
    {
        TURN_OFF = true;
        for(int i = 0; i < 6; i++) SetIndexStyle(i, DRAW_NONE);
        ObDeleteObjectsByPrefix(TAG);

        bt1.ColorBackground(off_color);
        bt1.Text("OFF");
    }
    else
    {
        TURN_OFF = false;
        //---- Обрабатываем 1 буфер 
   if (Period1>0)
   {
   SetIndexStyle(0,DRAW_ARROW,0,Symbol_1_Size,Color_1); 
   SetIndexArrow(0,Symbol_1_Kod); 
   SetIndexBuffer(0,FP_BuferUp); 
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(1,DRAW_ARROW,0,Symbol_1_Size,Color_1); 
   SetIndexArrow(1,Symbol_1_Kod); 
   SetIndexBuffer(1,FP_BuferDn); 
   SetIndexEmptyValue(1,0.0); 
   }
   
//---- Обрабатываем 2 буфер 
   if (Period2>0)
   {
   SetIndexStyle(2,DRAW_ARROW,0,Symbol_2_Size,Color_2); 
   SetIndexArrow(2,Symbol_2_Kod); 
   SetIndexBuffer(2,NP_BuferUp); 
   SetIndexEmptyValue(2,0.0); 
   
   SetIndexStyle(3,DRAW_ARROW,0,Symbol_2_Size,Color_2); 
   SetIndexArrow(3,Symbol_2_Kod); 
   SetIndexBuffer(3,NP_BuferDn); 
   SetIndexEmptyValue(3,0.0); 
   }
//---- Обрабатываем 3 буфер 
   if (Period3>0)
   {
   SetIndexStyle(4,DRAW_ARROW,0,Symbol_3_Size,Color_3); 
   SetIndexArrow(4,Symbol_3_Kod); 
   SetIndexBuffer(4,HP_BuferUp); 
   SetIndexEmptyValue(4,0.0); 

   SetIndexStyle(5,DRAW_ARROW,0,Symbol_3_Size,Color_3); 
   SetIndexArrow(5,Symbol_3_Kod); 
   SetIndexBuffer(5,HP_BuferDn); 
   SetIndexEmptyValue(5,0.0); 
   }

        bt1.ColorBackground(on_color);
        bt1.Text("ON");
    }
    
}

void ActionBt1()
{
    hide = !hide;
    setButtonState(hide);    
}


// ------------------------------------------------------------------
// NOTE: oninit
 int init()
 {
     if(deinitReason != REASON_CHARTCHANGE)
    {
        GetState();
        OnInitButtons();
        setButtonState(hide);
    }

    //+--------- TRO MODIFICATION ---------------------------------------+  
   period       = Period() ;     
   tChartPeriod =  TimeFrameToString(period) ;
   symbol       =  Symbol() ;
   digits       =  Digits ;
   point        =  Point ;   
   
   if(digits == 5 || digits == 3) { digits = digits - 1 ; point = point * 10 ; }   
   
   
   tShortName = "tbb"+ symbol + tChartPeriod  ;
    
   xThreshold   = myThreshold * point ;   
   xRetracePips = myRetracePips * point ;  
   xTargetPips = myTargetPips * point ; 
 
   OBJ001       = TAG + "001";
   OBJ002       = TAG + "002";  
   OBJ003       = TAG + "003";
   OBJ004       = TAG + "004";  
   OBJ005       = TAG + "005";
   OBJ006       = TAG + "006";  
   OBJ007       = TAG + "007";
   OBJ008       = TAG + "008";  

   
   FIBLEVEL[0] =     iLevel1 ; 
   FIBLEVEL[1] =     iLevel2 ; 
   FIBLEVEL[2] =     iLevel3 ; 
   FIBLEVEL[3] =     iLevel4 ; 
   FIBLEVEL[4] =     iLevel5 ; 
   
   FIBCOLOR[0] =  Fibcolor1  ;
   FIBCOLOR[1] =  Fibcolor2  ;
   FIBCOLOR[2] =  Fibcolor3  ;
   FIBCOLOR[3] =  Fibcolor4  ;
   FIBCOLOR[4] =  Fibcolor5  ;   
           
// --------- Корректируем периоды для построения ЗигЗагов
  
  
   if (Period1>0) F_Period=MathCeil(Period1*Period()); else F_Period=0; 
   if (Period2>0) N_Period=MathCeil(Period2*Period()); else N_Period=0; 
   if (Period3>0) H_Period=MathCeil(Period3*Period()); else H_Period=0; 
   
//---- Обрабатываем 1 буфер 
   if (Period1>0)
   {
   SetIndexStyle(0,DRAW_ARROW,0,Symbol_1_Size,Color_1); 
   SetIndexArrow(0,Symbol_1_Kod); 
   SetIndexBuffer(0,FP_BuferUp); 
   SetIndexEmptyValue(0,0.0); 
   
   SetIndexStyle(1,DRAW_ARROW,0,Symbol_1_Size,Color_1); 
   SetIndexArrow(1,Symbol_1_Kod); 
   SetIndexBuffer(1,FP_BuferDn); 
   SetIndexEmptyValue(1,0.0); 
   }
   
//---- Обрабатываем 2 буфер 
   if (Period2>0)
   {
   SetIndexStyle(2,DRAW_ARROW,0,Symbol_2_Size,Color_2); 
   SetIndexArrow(2,Symbol_2_Kod); 
   SetIndexBuffer(2,NP_BuferUp); 
   SetIndexEmptyValue(2,0.0); 
   
   SetIndexStyle(3,DRAW_ARROW,0,Symbol_2_Size,Color_2); 
   SetIndexArrow(3,Symbol_2_Kod); 
   SetIndexBuffer(3,NP_BuferDn); 
   SetIndexEmptyValue(3,0.0); 
   }
//---- Обрабатываем 3 буфер 
   if (Period3>0)
   {
   SetIndexStyle(4,DRAW_ARROW,0,Symbol_3_Size,Color_3); 
   SetIndexArrow(4,Symbol_3_Kod); 
   SetIndexBuffer(4,HP_BuferUp); 
   SetIndexEmptyValue(4,0.0); 

   SetIndexStyle(5,DRAW_ARROW,0,Symbol_3_Size,Color_3); 
   SetIndexArrow(5,Symbol_3_Kod); 
   SetIndexBuffer(5,HP_BuferDn); 
   SetIndexEmptyValue(5,0.0); 
   }
// Обрабатываем значения девиаций и шагов
   int CDev=0;
   int CSt=0;
   int Mass[]; 
   int C=0;  
   if (IntFromStr(Dev_Step_1,C, Mass)==1) 
      {
        Stp1=Mass[1];
        Dev1=Mass[0];
      }
   
   if (IntFromStr(Dev_Step_2,C, Mass)==1)
      {
        Stp2=Mass[1];
        Dev2=Mass[0];
      }      
   
   
   if (IntFromStr(Dev_Step_3,C, Mass)==1)
      {
        Stp3=Mass[1];
        Dev3=Mass[0];
      }   
      
   if( myTradeLinelevel != 0 ) { TradeLinelevel = myTradeLinelevel ; } else 
   if( period > PERIOD_H1 ) { TradeLinelevel = 1 ; } else { TradeLinelevel = 2 ; } 
         
   return(0); 
  } 

//+------------------------------------------------------------------+
void ObDeleteObjectsByPrefix(string Prefix)
  {
   int LL = StringLen(Prefix);
   int ii = 0; 
   while(ii < ObjectsTotal())
     {
       string ObjName = ObjectName(ii);
       if(StringSubstr(ObjName, 0, LL) != Prefix) 
         { 
           ii++; 
           continue;
         }
       ObjectDelete(ObjName);
     }
  } 
    
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   deinitReason = reason;
   SaveState();
   if(deinitReason != REASON_CHARTCHANGE && deinitReason != REASON_PARAMETERS)
   {
       bt1.Destroy();
       DeleteState();
   }
    _deinit();
}

int _deinit()
{
    ObDeleteObjectsByPrefix(TAG);  
    TRO();

    return(0);
}

//+------------------------------------------------------------------+ 
int start() 
{ 
    _deinit();
   if( TURN_OFF ) { return(0) ; }

//+--------- TRO MODIFICATION ---------------------------------------+   
   if( Bars != OldBars ) { Trigger1 = True ; Trigger2 = True ; Trigger3 = True ; }
   
     
   if (Period1>0) CountZZ(FP_BuferUp,FP_BuferDn,Period1,Dev1,Stp1);
   if (Period2>0) CountZZ(NP_BuferUp,NP_BuferDn,Period2,Dev2,Stp2);
   if (Period3>0) CountZZ(HP_BuferUp,HP_BuferDn,Period3,Dev3,Stp3);
   
   if(TrainingWheels)
   {
      close    = iClose(symbol,PERIOD_D1, 0) ;  
      D1_OPEN  = iOpen(symbol,PERIOD_D1, 0) ; 
      W1_OPEN  = iOpen(symbol,PERIOD_W1, 0) ;                   
 
      if (close < D1_OPEN  ) { D1_DOWN = TRUE ; D1_UP = FALSE ; }    
      else                   { D1_DOWN = FALSE ; D1_UP = TRUE ; }   
      
      if (close < W1_OPEN  ) { W1_DOWN = TRUE ; W1_UP = FALSE ; }    
      else                   { W1_DOWN = FALSE ; W1_UP = TRUE ; }        
     
     while(true)
     {
        if( HP_BuferUp[0] != 0 )                  { TW_MESSAGE = "3-LONG NEXT BAR"; TW_COLOR = Buy_color ; break; } 
        if( NP_BuferUp[0] != 0 && W1_UP )         { TW_MESSAGE = "2-LONG NEXT BAR"; TW_COLOR = Buy_color ; break; }         
        if( FP_BuferUp[0] != 0 && W1_UP && D1_UP) { TW_MESSAGE = "1-LONG NEXT BAR"; TW_COLOR = Buy_color ; break; } 
                
        if( HP_BuferDn[0] != 0 )                      { TW_MESSAGE = "3-SHORT NEXT BAR"; TW_COLOR = Sell_color ; break; } 
        if( NP_BuferDn[0] != 0 && W1_DOWN )           { TW_MESSAGE = "2-SHORT NEXT BAR"; TW_COLOR = Sell_color ; break; }         
        if( FP_BuferDn[0] != 0 && W1_DOWN && D1_DOWN) { TW_MESSAGE = "1-SHORT NEXT BAR"; TW_COLOR = Sell_color ; break; }   
        
        TW_MESSAGE = "WAIT";
        TW_COLOR   = Wait_color ; 
        break;       
     }

                   
   ObjectCreate(TAG+"tw", OBJ_LABEL, win, 0, 0);//HiLow LABEL;   
   ObjectSetText(TAG+"tw",TW_MESSAGE, myFontSize , myFont, TW_COLOR );
   ObjectSet(TAG+"tw", OBJPROP_CORNER, 0);
   ObjectSet(TAG+"tw", OBJPROP_XDISTANCE, price_x_offset); 
   ObjectSet(TAG+"tw", OBJPROP_YDISTANCE, price_y_offset); 

   if( Sound_Alert && TW_TRIGGER != Time[0] && TW_MESSAGE != "WAIT") {TW_TRIGGER = Time[0] ; Alert(symbol, " " + TW_MESSAGE) ; }
     
   //  Comment( TW_MESSAGE ) ;
   }
   
   if(!Show_TRO_Mods) { return(0) ; }
     
//+--------- TRO MODIFICATION ---------------------------------------+  
      
      if ( Trigger1 ) 
      { 
        if( FP_BuferUp[0] != 0 ) { Trigger1 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 1 Lower "+ DoubleToStr(Close[0] ,digits));} }
        if( FP_BuferDn[0] != 0 ) { Trigger1 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 1 Upper "+ DoubleToStr(Close[0] ,digits)); } }
      }
      
      if ( Trigger2 ) 
      {
        if( NP_BuferUp[0] != 0 ) { Trigger2 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 2 Lower "+ DoubleToStr(Close[0] ,digits)); } }
        if( NP_BuferDn[0] != 0 ) { Trigger2 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 2 Upper "+ DoubleToStr(Close[0] ,digits)); } }
      }
      
      if ( Trigger3 ) 
      {     
        if( HP_BuferUp[0] != 0 ) { Trigger3 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 3 Lower "+ DoubleToStr(Close[0] ,digits)); } }
        if( HP_BuferDn[0] != 0 ) { Trigger3 = False ; if(Sound_Alert) {Alert(symbol,"  ", tChartPeriod, " Level 3 Upper "+ DoubleToStr(Close[0] ,digits)); } }
      }


 
      tl3top = 0 ; 
      tl3bot = 0 ;   
      tl2top = 0 ; 
      tl2bot = 0 ; 
      tl1top = 0 ; 
      tl1bot = 0 ; 
               
   for( j=0; j<1000; j++ )
   {   
      while(true)
      {  
         if( HP_BuferUp[j] != 0 && tl3bot < 2 ) {lowerTLBars3[tl3bot] = j ; lowerTL3[tl3bot] = HP_BuferUp[j] ; tl3bot = tl3bot + 1 ; break ; }
         if( HP_BuferDn[j] != 0 && tl3top < 2 ) {upperTLBars3[tl3top] = j ; upperTL3[tl3top] = HP_BuferDn[j] ; tl3top = tl3top + 1 ; break ; }         
         if( NP_BuferUp[j] != 0 && tl2bot < 2 ) {lowerTLBars2[tl2bot] = j ; lowerTL2[tl2bot] = NP_BuferUp[j] ; tl2bot = tl2bot + 1 ; break ; }
         if( NP_BuferDn[j] != 0 && tl2top < 2 ) {upperTLBars2[tl2top] = j ; upperTL2[tl2top] = NP_BuferDn[j] ; tl2top = tl2top + 1 ; break ; }         
         if( FP_BuferUp[j] != 0 && tl1bot < 2 ) {lowerTLBars1[tl1bot] = j ; lowerTL1[tl1bot] = FP_BuferUp[j] ; tl1bot = tl1bot + 1 ; break ; }
         if( FP_BuferDn[j] != 0 && tl1top < 2 ) {upperTLBars1[tl1top] = j ; upperTL1[tl1top] = FP_BuferDn[j] ; tl1top = tl1top + 1 ; break ; }         
                           
         break ;
      } // while
      
      if( tl3bot >=2 && tl3top >= 2 && tl2bot >=2 && tl2top >= 2  && tl1bot >=2 && tl1top >= 2) { break ;  }
   } // for j  

    
   if(Show_Comment)
   {
      k = 0 ;
      theMessage = "";
      for( i=0; i<26; i++ ) { Messages[i] = "" ; }
      
   for( j=myBars; j>=0; j-- )
   {   
      while(true)
      {
         if( HP_BuferUp[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " bot 3 " ) ; break ; }
         if( HP_BuferDn[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " top 3 " ) ; break ; }         
         
         if( NP_BuferUp[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " bot 2 " ) ; break ; }
         if( NP_BuferDn[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " top 2 " ) ; break ; }         
         
         if( FP_BuferUp[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " bot 1 " ) ; break ; }
         if( FP_BuferDn[j] != 0 ) {DoRollMsg( TimeToStr(Time[j]) + " top 1 " ) ; break ; }
         break ;
      } // while
   } // for j
   
         
      for( i=0; i<NumComments; i++ )
      {
         if(Messages[i] != "" )
         {
            theMessage = theMessage + "\n" +Messages[i] ;
         }
         else { break ; }
      } // for i
 
      Comment(theMessage) ;
   
   } // if

   if(Show_TrendLines3)
   { 
      tl3top = 0 ; 
      tl3bot = 0 ;   
   
   for( j=0; j<1000; j++ )
   {   
      while(true)
      {  
         if( HP_BuferUp[j] != 0 && tl3bot < 2 ) {lowerTL3time[tl3bot] = Time[j] ; lowerTL3[tl3bot] = HP_BuferUp[j] ; tl3bot = tl3bot + 1 ; break ; }
         if( HP_BuferDn[j] != 0 && tl3top < 2 ) {upperTL3time[tl3top] = Time[j] ; upperTL3[tl3top] = HP_BuferDn[j] ; tl3top = tl3top + 1 ; break ; }         
         break ;
      } // while
      
      if( tl3bot >=2 && tl3top >= 2 ) { break ;  }
   } // for j  
   
   DrawPriceTrendLines(OBJ001+"3", upperTL3time[1], upperTL3time[0], upperTL3[1], 
                        upperTL3[0], myUpperTrendLine3Color, myUpperTrendLine3Style, myUpperTrendLine3Width) ;

   DrawPriceTrendLines(OBJ002+"3", lowerTL3time[1], lowerTL3time[0], lowerTL3[1], 
                        lowerTL3[0], myLowerTrendLine3Color, myLowerTrendLine3Style, myLowerTrendLine3Width) ;

   DrawPriceTrendLines(OBJ003+"3", upperTL3time[0], Time[0], upperTL3[0], 
                        upperTL3[0], myUpperTrendLine3Color, myUpperTrendLine3Style, myUpperTrendLine3Width) ;

   DrawPriceTrendLines(OBJ004+"3", lowerTL3time[0], Time[0], lowerTL3[0], 
                        lowerTL3[0], myLowerTrendLine3Color, myLowerTrendLine3Style, myLowerTrendLine3Width) ;
   

   if( lowerTL3time[0] < upperTL3time[0] ) { Close3Diff = upperTL3[0] - Close[0] ; } 
   else { Close3Diff = Close[0] - lowerTL3[0] ; } 
   
   Sema3Diff = upperTL3[0] - lowerTL3[0] ;   
    
   } // if   

//-------------------------------------------------------------------------------------------------

   if(Show_Tradelines)
   {
 
      tl3top = 0 ; 
      tl3bot = 0 ;

      for( j=0; j<1000; j++ )
      {   
          
         if(myTradeLinelevel == 3 ) { upperTradeLine = HP_BuferUp[j] ; lowerTradeLine = HP_BuferDn[j] ; } else
         if(myTradeLinelevel == 2 ) { upperTradeLine = NP_BuferUp[j] ; lowerTradeLine = NP_BuferDn[j] ; } else
                             { upperTradeLine = FP_BuferUp[j] ; lowerTradeLine = FP_BuferDn[j] ; }  
                        
         if( upperTradeLine != 0 && tl3bot < NumTradeLineLines ) 
         {
            tl3bot = tl3bot + 1 ;
            if( Close[j] >= Open[j] ) { upperTradeLine = Open[j] ; } else { upperTradeLine = Close[j] ; }
            
            DrawPriceTradeLines(OBJ003+"TRL"+j, Time[j], Time[0], upperTradeLine, 
                        upperTradeLine, myLowerTradeLineColor, myLowerTradeLineStyle, myLowerTradeLineWidth) ;
         }
 

         if( lowerTradeLine != 0 && tl3top < NumTradeLineLines ) 
         {
            tl3top = tl3top + 1 ;
            
            if( Close[j] <= Open[j] ) { lowerTradeLine = Open[j] ; } else { lowerTradeLine = Close[j] ; }
             
            DrawPriceTradeLines(OBJ004+"TRL"+j, Time[j], Time[0], lowerTradeLine, 
                        lowerTradeLine, myUpperTradeLineColor, myUpperTradeLineStyle, myUpperTradeLineWidth) ; 
         }   
   
         if( tl3bot >=NumTradeLineLines && tl3top >=NumTradeLineLines ) { break ;  }
            
      } // for j    
 
   } // if Show_Tradelines

//-------------------------------------------------------------------------------------------------

   if(Show_Trendlines)
   {
      tltop = 0 ; 
      tlbot = 0 ;
   
   for( j=0; j<1000; j++ )
   {   
      while(true)
      {
         if( HP_BuferUp[j] != 0 && tlbot < 2 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = HP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( HP_BuferDn[j] != 0 && tltop < 2 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = HP_BuferDn[j] ; tltop = tltop + 1 ; break ; }         
         
         if( NP_BuferUp[j] != 0 && tlbot < 2 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = NP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( NP_BuferDn[j] != 0 && tltop < 2 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = NP_BuferDn[j] ; tltop = tltop + 1 ; break ; }         
         
         if( FP_BuferUp[j] != 0 && tlbot < 2 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = FP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( FP_BuferDn[j] != 0 && tltop < 2 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = FP_BuferDn[j] ; tltop = tltop + 1 ; break ; }
         break ;
      } // while
      
      if( tlbot >=2 && tltop >= 2 ) { break ;  }
   } // for j   
      

   DrawPriceTrendLines(OBJ001, upperTLtime[1], upperTLtime[0], upperTL[1], 
                        upperTL[0], myUpperTrendLineColor, myUpperTrendLineStyle, myUpperTrendLineWidth) ;

   DrawPriceTrendLines(OBJ002, lowerTLtime[1], lowerTLtime[0], lowerTL[1], 
                        lowerTL[0], myLowerTrendLineColor, myLowerTrendLineStyle, myLowerTrendLineWidth) ;

   DrawPriceTrendLines(OBJ003, upperTLtime[0], Time[0], upperTL[0], 
                        upperTL[0], myUpperTrendLineColor, myUpperTrendLineStyle, myUpperTrendLineWidth) ;

   DrawPriceTrendLines(OBJ004, lowerTLtime[0], Time[0], lowerTL[0], 
                        lowerTL[0], myLowerTrendLineColor, myLowerTrendLineStyle, myLowerTrendLineWidth) ;


   if(Show_Medianline)
   {
   midpoint = MathAbs(upperTL[0] + lowerTL[0]) * 0.50 ;
   
   for( j=0; j<1000; j++ )
   {  
      if(Time[j] > upperTLtime[0] && Time[j] > lowerTLtime[0]) { continue ; } 
      if( midpoint < High[j] && midpoint > Low[j] ) { break ; }
    
   }
   
   if( lowerTLtime[1] > upperTLtime[1]  ) { midstarttime = lowerTLtime[1] ; midstart = lowerTL[1] ; }
   else { midstarttime = upperTLtime[1] ;  midstart = upperTL[1] ; }
   
   DrawPriceTrendLines(OBJ004+"pf", midstarttime, Time[j], midstart, 
                        midpoint,  myMedianLineColor, myMedianLineStyle, myMedianLineWidth ) ;

   } // if
   
   
   if(Show_Retracelines)
   {
   UpperRetracePrice = upperTL[0] - xRetracePips ;
   LowerRetracePrice = lowerTL[0] + xRetracePips ;
   
//   if( upperTLtime[0] == Time[0] ) { upperStime = Time[1] ;  } else { upperStime = upperTLtime[0] ;  } 
   
   DrawPriceTrendLines(OBJ005, upperTLtime[0], Time[0], UpperRetracePrice, 
                        UpperRetracePrice, myRetraceLineColor, myRetraceLineStyle, myRetraceLineWidth) ;

   DrawPriceTrendLines(OBJ006, lowerTLtime[0], Time[0], LowerRetracePrice, 
                        LowerRetracePrice, myRetraceLineColor, myRetraceLineStyle, myRetraceLineWidth) ;
   }

   if(Show_Targetlines)
   {
   pUpperTargetPrice = UpperTargetPrice ;
   pLowerTargetPrice = LowerTargetPrice ;
   
   UpperTargetPrice = upperTL[0] + xTargetPips ;
   LowerTargetPrice = lowerTL[0] - xTargetPips ;
   
   DrawPriceTrendLines(OBJ007, upperTLtime[0], Time[0], pUpperTargetPrice, 
                        pUpperTargetPrice, myTargetLineColor, myTargetLineStyle, myTargetLineWidth) ;

   DrawPriceTrendLines(OBJ008, lowerTLtime[0], Time[0], pLowerTargetPrice, 
                        pLowerTargetPrice, myTargetLineColor, myTargetLineStyle, myTargetLineWidth) ;
   } // if(Show_Targetlines)


      UpperTrendLinePrice = ObjectGetValueByShift(OBJ001, 0);
      
      LowerTrendLinePrice = ObjectGetValueByShift(OBJ002, 0);
           
      UpperLimit = Ask + xThreshold ;
      LowerLimit = Bid - xThreshold ;
      
 

   if(Sound_Alert)
   {      
      if( UpperTrendLinePrice >= LowerLimit && UpperTrendLinePrice <= UpperLimit )
      {
         PlaySound(myUpperSoundFile);
      } 
      
      if( LowerTrendLinePrice >= LowerLimit && LowerTrendLinePrice <= UpperLimit )
      {
         PlaySound(myLowerSoundFile);
      } 

      if( upperTL[0] >= LowerLimit && upperTL[0] <= UpperLimit )
      {
         PlaySound(myUpperSoundFile);
      } 
      
      if( lowerTL[0] >= LowerLimit && lowerTL[0] <= UpperLimit )
      {
         PlaySound(myLowerSoundFile);
      } 
            
      
   } // if(Sound_Alert) 
   
  } // if(Show_Trendlines)
  
  
  
   if(Show_SupResLines3)
   {
      tl3top = 0 ; 
      tl3bot = 0 ;

   for( j=0; j<1000; j++ )
   {   
      
         if(mySRlevel == 3 ) { upperSR = HP_BuferUp[j] ; lowerSR = HP_BuferDn[j] ; } else
         if(mySRlevel == 2 ) { upperSR = NP_BuferUp[j] ; lowerSR = NP_BuferDn[j] ; } else
                             { upperSR = FP_BuferUp[j] ; lowerSR = FP_BuferDn[j] ; }  
                        
         if( upperSR != 0 && tl3bot < NumSRLines ) 
         {
            tl3bot = tl3bot + 1 ;
            DrawPriceTrendLines(OBJ003+"SR"+j, Time[j], Time[0], upperSR, 
                        upperSR, myLowerSRColor, myLowerSRStyle, myLowerSRWidth) ;
         }
         
 
 
         if( lowerSR != 0 && tl3top < NumSRLines ) 
         {
            tl3top = tl3top + 1 ; 
            DrawPriceTrendLines(OBJ004+"SR"+j, Time[j], Time[0], lowerSR, 
                        lowerSR, myUpperSRColor, myUpperSRStyle, myUpperSRWidth) ; 
         }   
   
         if( tl3bot >=NumSRLines && tl3top >=NumSRLines ) { break ;  }
         
   } // for j    
   } // if


   
   if(Show_Fiblines)
   {
      tltop = 0 ; 
      tlbot = 0 ;
   
   for( j=0; j<1000; j++ )
   {   
      while(true)
      {
         if( HP_BuferUp[j] != 0 && tlbot < 1 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = HP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( HP_BuferDn[j] != 0 && tltop < 1 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = HP_BuferDn[j] ; tltop = tltop + 1 ; break ; }         
         
         if( NP_BuferUp[j] != 0 && tlbot < 1 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = NP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( NP_BuferDn[j] != 0 && tltop < 1 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = NP_BuferDn[j] ; tltop = tltop + 1 ; break ; }         
         
         if( FP_BuferUp[j] != 0 && tlbot < 1 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = FP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( FP_BuferDn[j] != 0 && tltop < 1 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = FP_BuferDn[j] ; tltop = tltop + 1 ; break ; }
         break ;
      } // while
      
      if( tlbot >=1 && tltop >= 1 ) { break ;  }
   } // for j   
      
   fibstarttime = MathMin(upperTLtime[0], lowerTLtime[0]) ;

   fibrange     = upperTL[0] - lowerTL[0] ;
   
   for(j=0;j<5;j++)
   {
      fibvalue[j] = lowerTL[0] + ( fibrange * FIBLEVEL[j]);
      fibvalue[j] = NormalizeDouble(fibvalue[j],Digits);
      DrawPriceTrendLines(OBJ003+"FIB"+j, fibstarttime, Time[0], fibvalue[j], 
                        fibvalue[j], FIBCOLOR[j], myFibLineStyle, myFibLineWidth) ;
   } // for

} // if(Show_Fiblines)


   
   if(Show_Fiblines3)
   {
      tltop = 0 ; 
      tlbot = 0 ;
   
   for( j=0; j<1000; j++ )
   {   
      while(true)
      {
         if( HP_BuferUp[j] != 0 && tlbot < 1 ) {lowerTLtime[tlbot] = Time[j] ; lowerTL[tlbot] = HP_BuferUp[j] ; tlbot = tlbot + 1 ; break ; }
         if( HP_BuferDn[j] != 0 && tltop < 1 ) {upperTLtime[tltop] = Time[j] ; upperTL[tltop] = HP_BuferDn[j] ; tltop = tltop + 1 ; break ; }         
         break ;
      } // while
      
      if( tlbot >=1 && tltop >= 1 ) { break ;  }
   } // for j   
      
   fibstarttime = MathMin(upperTLtime[0], lowerTLtime[0]) ;

   fibrange     = upperTL[0] - lowerTL[0] ;
   
   for(j=0;j<5;j++)
   {
      fibvalue3[j] = lowerTL[0] + ( fibrange * FIBLEVEL[j]);
      fibvalue3[j] = NormalizeDouble(fibvalue3[j],Digits);
      DrawPriceTrendLines(OBJ003+"FIB3"+j, fibstarttime, Time[0], fibvalue3[j], 
                        fibvalue3[j], FIBCOLOR[j], myFibLine3Style, myFibLine3Width) ;
   } // for

} // if(Show_Fiblines3)


//+--------- TRO MODIFICATION ---------------------------------------+        

   if(Show_Legend) { DoShowLegend () ; }   
    
   OldBars = Bars ;   
             
   return(0);
}

//+--------- TRO MODIFICATION ---------------------------------------+  

string TimeFrameToString(int tf)
{
   string tfs;
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}

//+------------------------------------------------------------------+ 
// дополнительные функции
//int Take



//+------------------------------------------------------------------+ 
//| Функц формирования ЗигЗага                        | 
//+------------------------------------------------------------------+  
int CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep )
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
        
          ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;
  
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }

   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
        }
     }

   if(!Show_Floaters)
   {     
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(ExtMapBuffer2[shift] > High[shift] ) { ExtMapBuffer2[shift] = 0.0; }
      if(ExtMapBuffer[shift]  < Low[shift]  ) { ExtMapBuffer[shift]  = 0.0; } 
     } // for
   } // if

 return(0);
 } // int 

//+------------------------------------------------------------------+   
int Str2Massive(string VStr, int& M_Count, int& VMass[])
  {
    int val=StrToInteger( VStr);
    if (val>0)
       {
         M_Count++;
         int mc=ArrayResize(VMass,M_Count);
         if (mc==0)return(-1);
          VMass[M_Count-1]=val;
         return(1);
       }
    else return(0);    
  } 
  

//+------------------------------------------------------------------+   
int IntFromStr(string ValStr,int& M_Count, int& VMass[])
  {
    
    if (StringLen(ValStr)==0) return(-1);
    string SS=ValStr;
    int NP=0; 
    string CS;
    M_Count=0;
    ArrayResize(VMass,M_Count);
    while (StringLen(SS)>0)
      {
            NP=StringFind(SS,",");
            if (NP>0)
               {
                 CS=StringSubstr(SS,0,NP);
                 SS=StringSubstr(SS,NP+1,StringLen(SS));  
               }
               else
               {
                 if (StringLen(SS)>0)
                    {
                      CS=SS;
                      SS="";
                    }
               }
            if (Str2Massive(CS,M_Count,VMass)==0) 
               {
                 return(-2);
               }
      }
    return(1);    
  }
  



//+------------------------------------------------------------------+

string fFill(string filled, int f ) 
{
   string FILLED ;
   
   FILLED = StringSubstr(filled + "                                         ",0,f) ;
   
return(FILLED);
}

//+------------------------------------------------------------------+

void DoRollMsg( string msg ) 
{    

if(msg != "" )
{
   roll = true ;

   for( int m=23; m>=0 ; m-- )
   {
      Messages[m+1] = Messages[m];
   } // for
   
   Messages[0] = fFill(msg, 30 ) ;  
    
}// if

} // void
//+------------------------------------------------------------------+
 

void DrawPriceTrendLines(string objname, datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, int style, int width)
  {
    
   ObjectDelete(objname);
   ObjectCreate(objname, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(objname, OBJPROP_RAY, false);
 
   ObjectSet(objname, OBJPROP_COLOR, lineColor);
   ObjectSet(objname, OBJPROP_STYLE, style);
   ObjectSet(objname, OBJPROP_WIDTH, width);

/*
   if(Show_Label && y1 == y2)
   {
   string Obj0002 = objname+"linelbl" ;
      ObjectDelete(Obj0002);
      if(ObjectFind(Obj0002) != 0)
      {
         ObjectCreate(Obj0002, OBJ_TEXT, 0, Time[0]+period*60, y1); // Time[ShiftLabel]
         ObjectSetText(Obj0002, DoubleToStr(y1 ,digits) , 8, "Arial", lineColor);
      }
      else
      {
         ObjectMove(Obj0002, 0, Time[0]+period*60, y1); // Time[ShiftLabel]
      } // if  

   }// if
*/
   if(Show_Boxes)
   {  
     string dName = objname+"boxes" ;
     if (ObjectFind(dName) != 0)
      {
          ObjectCreate(dName,OBJ_ARROW,0,Time[0],y1);
          ObjectSet(dName,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(dName,OBJPROP_COLOR,lineColor);  
      } 
      else
      {
         ObjectMove(dName,0,Time[0],y1);
      } 
   } // if  
   
  } // void

//+------------------------------------------------------------------+
 

void DrawPriceTradeLines(string objname, datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, int style, int width)
  {
    
   ObjectDelete(objname);
   ObjectCreate(objname, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(objname, OBJPROP_RAY, false);
 
   ObjectSet(objname, OBJPROP_COLOR, lineColor);
   ObjectSet(objname, OBJPROP_STYLE, style);
   ObjectSet(objname, OBJPROP_WIDTH, width);

/*
   if(Show_Label && y1 == y2)
   {
   string Obj0002 = objname+"linelbl" ;
      ObjectDelete(Obj0002);
      if(ObjectFind(Obj0002) != 0)
      {
         ObjectCreate(Obj0002, OBJ_TEXT, 0, Time[0]+period*60, y1); // Time[ShiftLabel]
         ObjectSetText(Obj0002, DoubleToStr(y1 ,digits) , 8, "Arial", lineColor);
      }
      else
      {
         ObjectMove(Obj0002, 0, Time[0]+period*60, y1); // Time[ShiftLabel]
      } // if  

   }// if
*/

   if(Show_Boxes)
   {  
     string dName = objname+"boxes" ;
     if (ObjectFind(dName) != 0)
      {
          ObjectCreate(dName,OBJ_ARROW,0,Time[0],y1);
          ObjectSet(dName,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
          ObjectSet(dName,OBJPROP_COLOR,lineColor);  
      } 
      else
      {
         ObjectMove(dName,0,Time[0],y1);
      } 
   } // if   

   
  } // void
 
 
//+------------------------------------------------------------------+  
void DoShowLegend()
{ 
   yIncL = 0;



  if(Show_Trendlines)
   {
   
   setObject(TAG+"ut","Upper Target  " + DoubleToStr(pUpperTargetPrice, digits) ,30,yIncLegend,myTargetLineColor); setObject(TAG+"ut1","l",10,yIncLegend,myTargetLineColor     ,"Wingdings");

   yIncL = yIncL + 20;
   setObject(TAG+"us","Upper Semafor " + DoubleToStr(upperTL[0], digits) ,30,yIncLegend+yIncL,myUpperTrendLineColor); setObject(TAG+"us1","l",10,yIncLegend+yIncL,myUpperTrendLineColor     ,"Wingdings");  
   yIncL = yIncL + 20;   
   setObject(TAG+"ur","Upper Retrace " + DoubleToStr(UpperRetracePrice, digits) ,30,yIncLegend+yIncL,myRetraceLineColor); setObject(TAG+"ur1","l",10,yIncLegend+yIncL,myRetraceLineColor     ,"Wingdings");
   yIncL = yIncL + 20;   
   setObject(TAG+"lr","Lower Retrace " + DoubleToStr(LowerRetracePrice, digits) ,30,yIncLegend+yIncL,myRetraceLineColor); setObject(TAG+"lr1","l",10,yIncLegend+yIncL,myRetraceLineColor     ,"Wingdings");   
   yIncL = yIncL + 20;
   setObject(TAG+"ls","Lower Semafor " + DoubleToStr(lowerTL[0], digits) ,30,yIncLegend+yIncL,myLowerTrendLineColor); setObject(TAG+"ls1","l",10,yIncLegend+yIncL,myLowerTrendLineColor     ,"Wingdings");
   yIncL = yIncL + 20;
   setObject(TAG+"lt","Lower Target  " + DoubleToStr(pLowerTargetPrice, digits) ,30,yIncLegend+yIncL,myTargetLineColor); setObject(TAG+"lt1","l",10,yIncLegend+yIncL,myTargetLineColor     ,"Wingdings");           
   yIncL = yIncL + 20;      
   setObject(TAG+"ml","Median Line   " + DoubleToStr(midpoint, digits) ,30,yIncLegend+yIncL,myMedianLineColor); setObject(TAG+"ml1","l",10,yIncLegend+yIncL,myMedianLineColor     ,"Wingdings");           
   } // if(Show_Trendlines)
   

   
   if(Show_Fiblines3)
   {
      yIncL = yIncL + 20;
      
      for(j=4;j>=0;j--)
      {
         yIncL = yIncL + 20;
         sFib  = DoubleToStr(FIBLEVEL[j]*100,1) + "%    " ;
         setObject(TAG+"Fib3."+j,"Fib3 " + sFib + DoubleToStr(fibvalue3[j], digits) ,30,yIncLegend+yIncL,FIBCOLOR[j]); 
         setObject(TAG+"fib31."+j,"l",10,yIncLegend+yIncL,FIBCOLOR[j] ,"Wingdings");                       
      }
   } // if(Show_Fiblines)
 
       
   if(Show_Fiblines)
   {
      yIncL = yIncL + 20;
      for(j=4;j>=0;j--)
      {
         yIncL = yIncL + 20;
         sFib  = DoubleToStr(FIBLEVEL[j]*100,1) + "%     " ;
         setObject(TAG+"Fib"+j,"Fib " + sFib + DoubleToStr(fibvalue[j], digits) ,30,yIncLegend+yIncL,FIBCOLOR[j]); 
         setObject(TAG+"fib1"+j,"l",10,yIncLegend+yIncL,FIBCOLOR[j] ,"Wingdings");                       
      }
   } // if(Show_Fiblines)

   if(Show_Bars)
   {
         yIncL = yIncL + 40;
         setObject(TAG+"sem3u" ,"Upper Semafor " + DoubleToStr(upperTL3[0], digits) + "["+upperTLBars3[0]+"]" ,30,yIncLegend+yIncL,indicator_color6); 
         setObject(TAG+"sem3u1" ,CharToStr(Symbol_3_Kod),10,yIncLegend+yIncL,indicator_color6 ,"Wingdings");                       
         yIncL = yIncL + 20;
         setObject(TAG+"sem3l" ,"Lower Semafor " + DoubleToStr(lowerTL3[0], digits) + "["+lowerTLBars3[0]+"]" ,30,yIncLegend+yIncL,indicator_color6); 
         setObject(TAG+"sem3l1" ,CharToStr(Symbol_3_Kod),10,yIncLegend+yIncL,indicator_color6 ,"Wingdings");                       
         yIncL = yIncL + 20;
         setObject(TAG+"sem2u" ,"Upper Semafor " + DoubleToStr(upperTL2[0], digits) + "["+upperTLBars2[0]+"]" ,30,yIncLegend+yIncL,indicator_color4); 
         setObject(TAG+"sem2u1" ,CharToStr(Symbol_2_Kod),10,yIncLegend+yIncL,indicator_color4 ,"Wingdings");                       
         yIncL = yIncL + 20;
         setObject(TAG+"sem2l" ,"Lower Semafor " + DoubleToStr(lowerTL2[0], digits) + "["+lowerTLBars2[0]+"]" ,30,yIncLegend+yIncL,indicator_color4); 
         setObject(TAG+"sem2l1" ,CharToStr(Symbol_2_Kod),10,yIncLegend+yIncL,indicator_color4 ,"Wingdings");                       
         yIncL = yIncL + 20;
         setObject(TAG+"sem1u" ,"Upper Semafor " + DoubleToStr(upperTL1[0], digits) + "["+upperTLBars1[0]+"]" ,30,yIncLegend+yIncL,indicator_color2); 
         setObject(TAG+"sem1u1" ,CharToStr(Symbol_1_Kod),10,yIncLegend+yIncL,indicator_color2 ,"Wingdings");                       
         yIncL = yIncL + 20;
         setObject(TAG+"sem1l" ,"Lower Semafor " + DoubleToStr(lowerTL1[0], digits) + "["+lowerTLBars1[0]+"]" ,30,yIncLegend+yIncL,indicator_color2); 
         setObject(TAG+"sem1l1" ,CharToStr(Symbol_1_Kod),10,yIncLegend+yIncL,indicator_color2 ,"Wingdings");                       
    
   } // if(Show_Bars)



       
   if(Show_Diff)
   {
         yIncL = yIncL + 20;
         setObject(TAG+"s3ra","Sem3 Range    " +  DoubleToStr(Sema3Diff / point , 0) ,30,yIncLegend+yIncL,indicator_color5); 
         yIncL = yIncL + 20;
         setObject(TAG+"S3Rb","Sem3 Retrace  " +  DoubleToStr(Close3Diff / point , 0) ,30,yIncLegend+yIncL,indicator_color5); 
        
   } // if(Show_Diff)

      
}

//+------------------------------------------------------------------+  

void setObject(string labelName,string text,int x,int y,color theColor, string font = "Courier New",int size=10,int angle=0)
{
 
      
      if (ObjectFind(labelName) == -1)
          {
             ObjectCreate(labelName,OBJ_LABEL,0,0,0);
             ObjectSet(labelName,OBJPROP_CORNER,0);
             if (angle != 0)
                  ObjectSet(labelName,OBJPROP_ANGLE,angle);
          }               
       ObjectSet(labelName,OBJPROP_XDISTANCE,x);
       ObjectSet(labelName,OBJPROP_YDISTANCE,y);
       ObjectSetText(labelName,text,size,font,theColor);
}

//+------------------------------------------------------------------+
void TRO()
{   
   
   string tObjName03    = "TROTAG"  ;  
   ObjectCreate(tObjName03, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(tObjName03, CharToStr(78) , 12 ,  "Wingdings",  DimGray );
   ObjectSet(tObjName03, OBJPROP_CORNER, 3);
   ObjectSet(tObjName03, OBJPROP_XDISTANCE, 5 );
   ObjectSet(tObjName03, OBJPROP_YDISTANCE, 5 );  
}


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+