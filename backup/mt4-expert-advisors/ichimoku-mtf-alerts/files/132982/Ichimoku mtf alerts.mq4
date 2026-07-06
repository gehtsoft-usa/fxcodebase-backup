// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69580

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
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  clrNONE
#property indicator_color2  clrNONE
#property indicator_color3  clrSandyBrown
#property indicator_color4  clrThistle
#property indicator_color5  clrNONE
#property indicator_color6  clrSaddleBrown
#property indicator_color7  clrThistle
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT

extern ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT; // Timeframe to use
extern int    Tenkan                     = 5;              // Tenkan Period
extern int    Kijun                      = 15;             // Kijun Period
extern int    Senkou                     = 52;             // Senkou Period
extern bool   alertsOn                   = false;           // Alerts On?
extern bool   alertsOnKumoCloudCross     = false;          // Alerts on leaving Kumo cloud?
extern bool   alertsOnTenkanKijunCross   = true;           // Alerts on tenkan and kijun cross?
extern bool   alertsOnPriceKijunCross    = false;          // Alerts on price crossing kijun?
extern bool   alertsOnChinkouTenkanCross = false;          // Alerts on Chinkou and Tenkan cross?
extern bool   alertsOnSpanASpanBCross    = true;           // Alerts on SpanA and SpanB cross?
extern bool   alertsOnCurrent            = false;          // Alerts on current open bar?
extern bool   alertsMessage              = true;           // Alerts message?
extern bool   alertsSound                = true;           // Alerts sound?
extern bool   alertsNotify               = false;          // Alerts Send Notification?
extern bool   alertsEmail                = false;          // Alerts send email?
extern int    Shift                      = 26;             // Shift values should = Kijun 
extern bool   Interpolate                = true;           // Interpolate values if multi timeframe is used

extern bool   Draw_Tenkan                = true;           // Draw Tenkan option
extern bool   Draw_Kijun                 = true;           // Draw Kijun option
extern bool   Draw_Kumo                  = true;           // Draw Kumo cloud option
extern bool   Draw_Chikou                = true;           // Draw Chinkou option
input color ichimoku_button_color = clrDarkRed; // Ichimoku button color
input color tenkan_button_color = Red; // Tenkan button color
input color kijun_button_color = Blue; // Kijun button color
input color chikou_button_color = Green; // Chikou button color
input color kumo_button_color = SandyBrown; // Kumo button color
input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.1
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y, color clr = clrDarkRed)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clr, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, y);
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

double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];
double trend1[];
double trend2[];
double trend3[];
double trend4[];
double trend5[];
double count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Tenkan,Kijun,Senkou,alertsOn,alertsOnKumoCloudCross,alertsOnTenkanKijunCross,alertsOnPriceKijunCross,alertsOnChinkouTenkanCross,alertsOnSpanASpanBCross,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,0,_buff,_ind)

VisibilityCotroller ich;
VisibilityCotroller kijun;
VisibilityCotroller tenkan;
VisibilityCotroller chikou;
VisibilityCotroller kumo;

double Tenkan_Buffer2[], Kijun_Buffer2[], SpanA_Buffer2[], SpanB_Buffer2[], Chinkou_Buffer2[], SpanA2_Buffer2[], SpanB2_Buffer2[];

int init()
{
   ich.Init("show_hide_ich", "ich1", "Ichimoku", button_x, button_y, ichimoku_button_color);
   kijun.Init("show_hide_kijun", "ich2", "Kijun", button_x, button_y + 70, kijun_button_color);
   tenkan.Init("show_hide_tenkan", "ich3", "Tenkan", button_x, button_y + 70 * 2, tenkan_button_color);
   chikou.Init("show_hide_chikou", "ich4", "Chikou", button_x, button_y + 70 * 4, chikou_button_color);
   kumo.Init("show_hide_kumo", "ich5", "Kumo", button_x, button_y + 70 * 3, kumo_button_color);
   IndicatorBuffers(20);
   SetIndexBuffer(0, Tenkan_Buffer);                                  SetIndexLabel(0,"Tenkan Sen");
   SetIndexBuffer(1, Kijun_Buffer);                                   SetIndexLabel(1,"Kijun Sen");
   SetIndexBuffer(2, SpanA_Buffer);  SetIndexStyle(2,DRAW_HISTOGRAM);  
   SetIndexBuffer(3, SpanB_Buffer);  SetIndexStyle(3,DRAW_HISTOGRAM);  
   SetIndexBuffer(4, Chinkou_Buffer);                                 SetIndexLabel(4,"Chinkou Span");
   SetIndexBuffer(5, SpanA2_Buffer);                                  SetIndexLabel(5,"Senkou Span A");
   SetIndexBuffer(6, SpanB2_Buffer);                                  SetIndexLabel(6,"Senkou Span B");
   SetIndexBuffer(7, trend1); 
   SetIndexBuffer(8, trend2); 
   SetIndexBuffer(9, trend3); 
   SetIndexBuffer(10,trend4); 
   SetIndexBuffer(11,trend5); 
   SetIndexBuffer(12,count);

   SetIndexBuffer(13, Tenkan_Buffer2);
   SetIndexBuffer(14, Kijun_Buffer2);
   SetIndexBuffer(15, SpanA_Buffer2);
   SetIndexBuffer(16, SpanB_Buffer2);
   SetIndexBuffer(17, Chinkou_Buffer2);
   SetIndexBuffer(18, SpanA2_Buffer2);
   SetIndexBuffer(19, SpanB2_Buffer2);
   if (!Draw_Tenkan) SetIndexStyle(0, DRAW_NONE);
   if (!Draw_Kijun)  SetIndexStyle(1, DRAW_NONE);
   if (!Draw_Chikou) SetIndexStyle(4, DRAW_NONE);
   if (!Draw_Kumo) 
   {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
      SetIndexStyle(6, DRAW_NONE);
   }
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   SetIndexShift(2,Shift  * TimeFrame/_Period); 
   SetIndexShift(3,Shift  * TimeFrame/_Period);
   SetIndexShift(4,-Shift * TimeFrame/_Period);
   SetIndexShift(5,Shift  * TimeFrame/_Period);
   SetIndexShift(6,Shift  * TimeFrame/_Period);    
     
   IndicatorShortName(timeFrameToString(TimeFrame)+" Ichimoku"); 
   return(0);
}
int deinit()
{
   ich.DeInit();
   chikou.DeInit();
   tenkan.DeInit();
   kijun.DeInit();
   kumo.DeInit();
   return(0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (ich.HandleButtonClicks() || tenkan.HandleButtonClicks() || kijun.HandleButtonClicks() || chikou.HandleButtonClicks() || kumo.HandleButtonClicks())
   {
      start();
   }
}

int start()
{
   ich.HandleButtonClicks();
   tenkan.HandleButtonClicks();
   kijun.HandleButtonClicks();
   chikou.HandleButtonClicks();
   kumo.HandleButtonClicks();

   int i,k,counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   if (ich.IsRecalcNeeded() || tenkan.IsRecalcNeeded() || kijun.IsRecalcNeeded() || chikou.IsRecalcNeeded() || kumo.IsRecalcNeeded())
   {
      counted_bars = 0;
   }
   int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
   ich.ResetRecalc();
   tenkan.ResetRecalc();
   kijun.ResetRecalc();
   chikou.ResetRecalc();
   kumo.ResetRecalc();
   if (TimeFrame!=_Period)
   {
      limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(12,0)*TimeFrame/_Period));
      for (i=limit;i>=0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL,TimeFrame,Time[i]);
         Tenkan_Buffer2[i]  = _mtfCall(0,y);
         if (tenkan.IsVisible() && ich.IsVisible())
         { 
            Tenkan_Buffer[i] = Tenkan_Buffer2[i];
         }
         else
         {
            Tenkan_Buffer[i] = EMPTY_VALUE;
         }
         Kijun_Buffer2[i] = _mtfCall(1,y);
         if (kijun.IsVisible() && ich.IsVisible())
         {
            Kijun_Buffer[i] = Kijun_Buffer2[i];
         }
         else
         {
            Kijun_Buffer[i] = EMPTY_VALUE;
         }
         Chinkou_Buffer2[i] = _mtfCall(4,y);
         SpanA_Buffer2[i]   = _mtfCall(2,y);
         SpanB_Buffer2[i]   = _mtfCall(3,y);
         SpanA2_Buffer2[i]  = _mtfCall(5,y);
         SpanB2_Buffer2[i]  = _mtfCall(6,y);
         if (kumo.IsVisible() && ich.IsVisible())
         {
            Chinkou_Buffer[i] = Chinkou_Buffer2[i];
            SpanA_Buffer[i]   = SpanA_Buffer2[i];
            SpanB_Buffer[i]   = SpanB_Buffer2[i];
            SpanA2_Buffer[i]  = SpanA2_Buffer2[i];
            SpanB2_Buffer[i]  = SpanB2_Buffer2[i];
         }
         else
         {
            Chinkou_Buffer[i] = EMPTY_VALUE;
            SpanA_Buffer[i]   = EMPTY_VALUE;
            SpanB_Buffer[i]   = EMPTY_VALUE;
            SpanA2_Buffer[i]  = EMPTY_VALUE;
            SpanB2_Buffer[i]  = EMPTY_VALUE;
         }
            
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) 
            continue;
         #define _interpolate(buff) buff[i+j] = buff[i]+(buff[i+n]-buff[i])*j/n
         int n,j; datetime time = iTime(NULL,TimeFrame,y);
         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) 
            continue;	
         for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++) 
         {
            _interpolate(Tenkan_Buffer);
            _interpolate(Kijun_Buffer);
            _interpolate(SpanA_Buffer);
            _interpolate(SpanB_Buffer);
            _interpolate(Chinkou_Buffer);
            _interpolate(SpanA2_Buffer);
            _interpolate(SpanB2_Buffer);
         }
      }
      return(0);
   }
      
   for(i=limit; i>=0; i--)
   {
      double thi    = High[i];
      double tlo    = Low[i];
      double tprice = 0;
      if (i >= Bars - Tenkan) continue;
      for(k = 0; k < Tenkan; k++)
      {
         tprice = High[i+k]; if(thi<tprice) thi = tprice;
         tprice =  Low[i+k]; if(tlo>tprice) tlo = tprice;
      }
      
      Tenkan_Buffer2[i] = (thi+tlo) > 0.0 ? (thi + tlo)*0.5 : 0;
      if (tenkan.IsVisible() && ich.IsVisible())
      {
         Tenkan_Buffer[i] = Tenkan_Buffer2[i];
      }
      else
      {
         Tenkan_Buffer[i] = EMPTY_VALUE;
      }
      
      double khi    = High[i];
      double klo    = Low[i];
      double kprice = 0;
      if (i >= Bars - Kijun) 
         continue;
      for (k = 0; k < Kijun; k++)
      {
         kprice = High[i+k]; if(khi<kprice) khi = kprice;
         kprice =  Low[i+k]; if(klo>kprice) klo = kprice;
      }
      
      Kijun_Buffer2[i] = (khi+klo) > 0.0 ? (khi + klo)*0.5 : 0;
      if (kijun.IsVisible() && ich.IsVisible())
      {
         Kijun_Buffer[i] = Kijun_Buffer2[i];
      }
      else
      {
         Kijun_Buffer[i] = EMPTY_VALUE;
      }
      
      double shi = High[i];
      double slo = Low[i];
      double sprice = 0;
      if (i >= Bars - Senkou) 
         continue;
      for (k = 0; k < Senkou; k++)
      {
         sprice = High[i+k]; if(shi<sprice) shi  = sprice;
         sprice =  Low[i+k]; if(slo>sprice) slo  = sprice;
      }
      
      SpanA_Buffer2[i]   = (Kijun_Buffer2[i] + Tenkan_Buffer2[i])*0.5;
      SpanA2_Buffer2[i]  = (Kijun_Buffer2[i] + Tenkan_Buffer2[i])*0.5;
      SpanB_Buffer2[i]   = (shi + slo)*0.5; 
      SpanB2_Buffer2[i]  = (shi + slo)*0.5; 
      if (kumo.IsVisible() && ich.IsVisible())
      {
         SpanA_Buffer[i]   = SpanA_Buffer2[i];
         SpanA2_Buffer[i]  = SpanA2_Buffer2[i];
         SpanB_Buffer[i]   = SpanB_Buffer2[i];
         SpanB2_Buffer[i]  = SpanB2_Buffer2[i];
      }
      else
      {
         SpanA_Buffer[i] = EMPTY_VALUE;
         SpanA2_Buffer[i] = EMPTY_VALUE;
         SpanB_Buffer[i] = EMPTY_VALUE;
         SpanB2_Buffer[i] = EMPTY_VALUE;
      }
      Chinkou_Buffer2[i] = Close[i];
      if (chikou.IsVisible() && ich.IsVisible())
      {
         Chinkou_Buffer[i] = Chinkou_Buffer2[i];
      }
      else
      {
         Chinkou_Buffer[i] = EMPTY_VALUE;
      }
      if (i<Bars-1)
      {
         trend1[i] = trend1[i+1];
         trend2[i] = trend2[i+1];
         trend3[i] = trend3[i+1];
         trend4[i] = trend4[i+1];
         trend5[i] = trend5[i+1];
         if (Close[i] > MathMax(SpanA_Buffer2[i+Kijun],SpanB_Buffer2[i+Kijun])) trend1[i] = 1;
         if (Close[i] < MathMin(SpanA_Buffer2[i+Kijun],SpanB_Buffer2[i+Kijun])) trend1[i] =-1;
         if (Tenkan_Buffer2[i]>Kijun_Buffer2[i])                                trend2[i] = 1;
         if (Tenkan_Buffer2[i]<Kijun_Buffer2[i])                                trend2[i] =-1;
         if (Close[i]>Kijun_Buffer2[i])                                        trend3[i] = 1;
         if (Close[i]<Kijun_Buffer2[i])                                        trend3[i] =-1;
         if (Chinkou_Buffer2[i]<Tenkan_Buffer2[i])                              trend4[i] = 1;
         if (Chinkou_Buffer2[i]>Tenkan_Buffer2[i])                              trend4[i] =-1;
         if (SpanA2_Buffer2[i]>SpanB2_Buffer2[i])                               trend5[i] = 1;
         if (SpanA2_Buffer2[i]<SpanB2_Buffer2[i])                               trend5[i] =-1;
      }
   }
   manageAlerts();
   return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

void manageAlerts()
{
    int whichBar = 1; if (alertsOnCurrent) whichBar = 0;          
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnKumoCloudCross && trend1[whichBar] != trend1[whichBar+1])
      {
         if (trend1[whichBar] ==  1) doAlert(time1,mess1,whichBar,"Price crossing Kumo up");
         if (trend1[whichBar] == -1) doAlert(time1,mess1,whichBar,"Price crossing Kumo down");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnTenkanKijunCross && trend2[whichBar] != trend2[whichBar+1])
      {
         if (trend2[whichBar] ==  1) doAlert(time2,mess2,whichBar,"Tenkan crossing Kijun up");
         if (trend2[whichBar] == -1) doAlert(time2,mess2,whichBar,"Tenkan crossing Kijun down");
      }
      static datetime time3 = 0;
      static string   mess3 = "";
      if (alertsOnPriceKijunCross && trend3[whichBar] != trend3[whichBar+1])
      {
         if (trend3[whichBar] ==  1) doAlert(time3,mess3,whichBar,"Price crossing Kijun up");
         if (trend3[whichBar] == -1) doAlert(time3,mess3,whichBar,"Price crossing Kijun down");
      }
      static datetime time4 = 0;
      static string   mess4 = "";
      if (alertsOnChinkouTenkanCross && trend4[whichBar] != trend4[whichBar+1])
      {
         if (trend4[whichBar] ==  1) doAlert(time4,mess4,whichBar,"Tenkan crossing Chinkou up");
         if (trend4[whichBar] == -1) doAlert(time4,mess4,whichBar,"Tenkan crossing Chinkou down");
      }
      static datetime time5 = 0;
      static string   mess5 = "";
      if (alertsOnSpanASpanBCross && trend5[whichBar] != trend5[whichBar+1])
      {
         if (trend5[whichBar] ==  1) doAlert(time5,mess5,whichBar,"SpanA crossing SpanB up");
         if (trend5[whichBar] == -1) doAlert(time5,mess5,whichBar,"SpanA crossing SpanB down");
      }
   }

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Ichimoku ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Ichimoku "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

