/*
── Project ─────────────────────────────────────────────────────────────────────

Name:         
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75032&p=161099#p161099
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
 

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrCoral
#property indicator_color3 clrGreen
#property indicator_color4 clrFireBrick

#property indicator_color5 clrLimeGreen
#property indicator_color6 clrCoral


enum ENUM_PRICE
{
   close,               // Close
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   heikenAshiClose,     // Heiken Ashi Close
   heikenAshiMedian,    // Heiken Ashi Median
   heikenAshiTypical,   // Heiken Ashi Typical
   heikenAshiWeighted   // Heiken Ashi Weighted Close   
};

//---- indicator parameters
input string      UniqueName           = "DonchianBrk";
input ENUM_PRICE  Price                = heikenAshiClose;
input int         ChannelPeriod        =        5;
input int         MaxChannelPeriod     =       30;
input double      Margin               =        0;
input double      MinChannelWidth      =       10;  
input color       UpTrendColor         = clrDodgerBlue;   
input color       DnTrendColor         = clrLightCoral;
input bool        ShowFilledBoxes      =     false;
input bool        ShowChannel          =     true;
 
input string      AnalysisSets         = "=== Trade Analysis ===";
input bool        ShowAnalysis         =     false;
input bool        ShowStatsComment     =     false;
input bool        ShowArrows           =     true;
input bool        ShowProfit           =     false;
input bool        ShowExits            =     false;
input color       WinColor             = clrLimeGreen;   
input color       LossColor            = clrTomato;

input string      alerts               = "==== Alerts & Emails: ====";
input bool        AlertOn              =    false;       //
input int         AlertShift           =        1;       // Alert Shift:0-current bar,1-previous bar
input int         SoundsNumber         =        5;       // Number of sounds after Signal
input int         SoundsPause          =        5;       // Pause in sec between sounds 
input string      UpTrendSound         = "alert.wav";
input string      DnTrendSound         = "alert2.wav";
input bool        EmailOn              =    false;       // 
input int         EmailsNumber         =        1;       //
input bool        PushNotificationOn   =    false;


//---- indicator buffers
double UpSignal[];
double DnSignal[];
double UpBand[];
double LoBand[];
double buyexit[];
double sellexit[];
double trend[];
double buycnt[];
double sellcnt[];
double pf[];


int      timeframe, buylosscnt[2], selllosscnt[2];
bool     buystop[2], sellstop[2];
double   _point, buyopen[], buyclose[], sellopen[], sellclose[], lobound, upbound, totbuyprofit[2], totsellprofit[2], totbuyloss[2], totsellloss[2];
datetime buyopentime[], buyclosetime[], sellopentime[], sellclosetime[], prevtime;
string   short_name, TF, IndicatorName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   timeframe = Period(); 
   TF = tf(timeframe);
  
   if(ShowChannel) int drawmode = DRAW_LINE; else drawmode = DRAW_NONE;
   IndicatorDigits(Digits);  

//---- drawing settings
   IndicatorBuffers(10);
   SetIndexBuffer(0,UpSignal); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,233);
   SetIndexBuffer(1,DnSignal); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,234);
   SetIndexBuffer(2,  UpBand); SetIndexStyle(2,drawmode  );
   SetIndexBuffer(3,  LoBand); SetIndexStyle(3,drawmode  );
   SetIndexBuffer(4, buyexit); SetIndexStyle(4,DRAW_ARROW); 
   SetIndexBuffer(5,sellexit); SetIndexStyle(5,DRAW_ARROW);
   SetIndexBuffer(6,   trend);
   SetIndexBuffer(7,  buycnt);
   SetIndexBuffer(8, sellcnt);
   SetIndexBuffer(9,      pf);
   
   int draw_begin = ChannelPeriod;
//---- 
   IndicatorName = WindowExpertName(); 
   short_name    = IndicatorName+"["+TF+"]("+ChannelPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend Signal");
   SetIndexLabel(1,"DnTrend Signal");
   SetIndexLabel(2,"Upper Band");
   SetIndexLabel(3,"Lower Band");
   
   
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   
   
   SetIndexEmptyValue(4,0);
   SetIndexEmptyValue(5,0);
   SetIndexEmptyValue(7,0);
   SetIndexEmptyValue(8,0);
   
   _point = Point*MathPow(10,Digits%2);
//---- initialization done
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
   Comment("");
   ObjectsDeleteAll(0,UniqueName);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| DonchianBreakoutSystem_v1.1.2 600+                                 |
//+------------------------------------------------------------------+
int start()
{
   int   shift, limit, counted_bars = IndicatorCounted();
   double buyprofit, sellprofit;

//---- 
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
    //   limit = Bars - 1;   
      limit = 200;   
      for(int i=limit;i>=0;i--) 
      {
      UpBand[i]   = EMPTY_VALUE; 
      LoBand[i]   = EMPTY_VALUE;
      UpSignal[i] = EMPTY_VALUE;
      DnSignal[i] = EMPTY_VALUE;
      buyexit[i]  = 0;
      sellexit[i] = 0;
      } 
   }   
     
   
   
   for(shift=limit; shift>=0; shift--)
   {
      if(Time[shift] != prevtime)
      {
      buystop[1]  = buystop[0];
      sellstop[1] = sellstop[0];
      prevtime    = Time[shift];    
      }
   
   
   int maxperiod = MaxChannelPeriod;
   int hhbar     = iHighest(NULL,0,MODE_HIGH,ChannelPeriod,shift);
   int llbar     = iLowest (NULL,0,MODE_LOW ,ChannelPeriod,shift);   
   double hh     = High[hhbar];
   double ll     = Low [llbar];
   double width  = (hh - ll)*(1 - 2*Margin);
  
   if(shift > Bars - maxperiod) continue;
      
      if(width < MinChannelWidth*_point)
      { 
         for(i=ChannelPeriod+1;i<=maxperiod;i++)  
         {
         hhbar = iHighest(NULL,0,MODE_HIGH,i,shift); 
         llbar = iLowest (NULL,0,MODE_LOW ,i,shift);
      
         hh = High[hhbar];
         ll = Low [llbar];
      
         width = (hh - ll)*(1 - 2*Margin);
         
            if(width >= MinChannelWidth*_point) break; 
            else
            { 
               if(i >= maxperiod && shift + i < Bars - 2) maxperiod = maxperiod + 1;
               else
               continue;
            }
         }
      }
           
   UpBand[shift] = hh - width*Margin;
   LoBand[shift] = ll + width*Margin;
   
   trend[shift] = trend[shift+1];
   
      if(priceWrapper(Price,shift) > UpBand[shift+1]) trend[shift] = 1;
      if(priceWrapper(Price,shift) < LoBand[shift+1]) trend[shift] =-1;
  
      
      
      if(trend[shift+1] != trend[shift+2])
      {
      if(trend[shift+1] > 0) {totsellprofit[1] = totsellprofit[0]; totsellloss[1] = totsellloss[0]; selllosscnt[1] = selllosscnt[0];}
      if(trend[shift+1] < 0) {totbuyprofit[1]  =  totbuyprofit[0]; totbuyloss[1]  =  totbuyloss[0]; buylosscnt[1]  = buylosscnt[0];}
      }
   
   
   UpSignal[shift]  = EMPTY_VALUE;
   DnSignal[shift]  = EMPTY_VALUE;
   buycnt[shift]    = buycnt[shift+1];
   sellcnt[shift]   = sellcnt[shift+1];
   buyexit[shift]   = 0;
   sellexit[shift]  = 0;
   buystop[0]       = buystop[1];
   sellstop[0]      = sellstop[1];   
   
   
      if(trend[shift] > 0)
      {
         if(trend[shift+1] <= 0) 
         {
         lobound  = MathMin(LoBand[llbar],LoBand[MathMax(llbar,shift+ChannelPeriod)]);
            
            if(UpBand[shift+1] > 0 && UpBand[shift+1] != EMPTY_VALUE && lobound > 0 && lobound != EMPTY_VALUE)
            {
               SetBox(UniqueName+" UpBox "+TimeToString(Time[shift]),0,Time[shift],UpBand[shift+1],Time[MathMax(llbar,shift+ChannelPeriod)],lobound,ShowFilledBoxes,clrNONE,1,UpTrendColor,1); 
                UpSignal[shift] = lobound;
               
               if(ShowAnalysis)
               {
               buycnt[shift] = buycnt[shift+1] + 1;
                
               ArrayResize(buyopen ,buycnt[shift]);
               ArrayResize(buyclose,buycnt[shift]);
               ArrayResize(buyopentime ,buycnt[shift]);
               ArrayResize(buyclosetime,buycnt[shift]);
               
               buyopen[(int)buycnt[shift]-1]     = Close[shift];
               buyopentime[(int)buycnt[shift]-1] = Time[shift];
               buyclose[(int)buycnt[shift]-1]    = buyopen[(int)buycnt[shift]-1];
               buystop[0] = false;
                 
                  if(ShowArrows) 
                  {
                  ObjectDelete(UniqueName+" BuyOpen "+DoubleToStr(buycnt[shift],0)); 
                  plotArrow(UniqueName+" BuyOpen "+DoubleToStr(buycnt[shift],0),buyopentime[(int)buycnt[shift]-1],buyopen[(int)buycnt[shift]-1],1,UpTrendColor);
                  }
               }
            }
         
            if(High[shift] >= upbound && !sellstop[0] && sellclose[(int)sellcnt[shift]-1] == sellopen[(int)sellcnt[shift]-1]) 
            {
            sellclose[(int)sellcnt[shift]-1]     = upbound; 
            sellclosetime[(int)sellcnt[shift]-1] = Time[shift];
            sellstop[0]     = true;
            
               if(sellopentime[(int)sellcnt[shift]-1] > 0 && sellclosetime[(int)sellcnt[shift]-1] > 0)
               {   
               if(sellclose[(int)sellcnt[shift]-1] <= sellopen[(int)sellcnt[shift]-1]) color sellcolor = WinColor; else sellcolor = LossColor;
               plotTrend(UniqueName+" SellTrend "+DoubleToStr(sellcnt[shift],0),sellopentime[(int)sellcnt[shift]-1],sellopen[(int)sellcnt[shift]-1],sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],2,0,sellcolor);   
               if(ShowArrows && trend[shift+1] < 0) plotArrow(UniqueName+" SellClose "+DoubleToStr(sellcnt[shift],0),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],3,DnTrendColor);
               if(ShowExits) sellexit[shift] = sellclose[(int)sellcnt[shift]-1];
               }
                  
         
               if(ShowProfit)
               { 
               sellprofit = (sellopen[(int)sellcnt[shift]-1] - sellclose[(int)sellcnt[shift]-1])/_point;
                  if(sellprofit >= 0) totsellprofit[0] = totsellprofit[1] + sellprofit; 
                  else 
                  {
                  totsellloss[0] = totsellloss[1] - sellprofit; 
                  selllosscnt[0] = selllosscnt[1] + 1;
                  }
               
               ObjectDelete(0,UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0));
                  
                  if(sellprofit >= 0) plotText(UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0),0,"+"+DoubleToStr(sellprofit,1),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],ANCHOR_RIGHT_UPPER,WinColor,"Arial",8);
                  else plotText(UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0),0,DoubleToStr(sellprofit,1),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],ANCHOR_RIGHT_LOWER,LossColor,"Arial",8);
               }   
            }  
         }
      
      ObjectDelete(0,UniqueName+" DnBox "+TimeToString(Time[shift]));
      
         if(ShowAnalysis) 
         {
            if(trend[shift+1] > 0)
            {
               if(High[shift] > buyclose[(int)buycnt[shift]-1] && !buystop[0]) 
               {
               buyclose[(int)buycnt[shift]-1]     = High[shift]; 
               buyclosetime[(int)buycnt[shift]-1] = Time[shift];
               }
               
               if(Low[shift] <= lobound && !buystop[0] && buyclose[(int)buycnt[shift]-1] == buyopen[(int)buycnt[shift]-1]) 
               {
               buyclose[(int)buycnt[shift]-1]     = lobound;
               buyclosetime[(int)buycnt[shift]-1] = Time[shift];
               buystop[0] = true;
               }
            }
            
            
        ObjectDelete(0,UniqueName+" BuyTrend "+DoubleToStr(buycnt[shift],0)); 
        if(ShowArrows) ObjectDelete(0,UniqueName+" BuyClose "+DoubleToStr(buycnt[shift],0));
         
            if(buyopentime[(int)buycnt[shift]-1] > 0 && buyclosetime[(int)buycnt[shift]-1] > 0)
            {   
            if(buyclose[(int)buycnt[shift]-1] >= buyopen[(int)buycnt[shift]-1]) color buycolor = WinColor; else buycolor = LossColor;
            plotTrend(UniqueName+" BuyTrend "+DoubleToStr(buycnt[shift],0),buyopentime[(int)buycnt[shift]-1],buyopen[(int)buycnt[shift]-1],buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],2,0,buycolor);   
            if(ShowArrows && trend[shift+1] > 0) plotArrow(UniqueName+" BuyClose "+DoubleToStr(buycnt[shift],0),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],3,UpTrendColor);
            if(ShowExits) buyexit[shift] = buyclose[(int)buycnt[shift]-1];
            }
         
         
            
            if(ShowProfit)
            { 
            buyprofit = (buyclose[(int)buycnt[shift]-1] - buyopen[(int)buycnt[shift]-1])/_point;
               if(buyprofit >= 0) totbuyprofit[0] = totbuyprofit[1] + buyprofit; 
               else 
               {
               totbuyloss[0] = totbuyloss[1] - buyprofit;
               buylosscnt[0] = buylosscnt[1] + 1;
               }
                  
            ObjectDelete(0,UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0));
               
               if(buyprofit >= 0) plotText(UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0),0,"+"+DoubleToStr(buyprofit,1),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],ANCHOR_RIGHT_LOWER,WinColor,"Arial",8);
               else plotText(UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0),0,DoubleToStr(buyprofit,1),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],ANCHOR_RIGHT_UPPER,LossColor,"Arial",8);
            }
         
         if(ShowArrows) 
            if(ObjectGetInteger(0,UniqueName+" SellOpen "+DoubleToStr(sellcnt[shift]+1,0),OBJPROP_TIME) == Time[shift]) ObjectDelete(0,UniqueName+" SellOpen "+DoubleToStr(sellcnt[shift]+1,0));
         }
      }
      
      if(trend[shift] < 0)
      {
         if(trend[shift+1] >= 0) 
         {
         upbound = MathMax(UpBand[hhbar],UpBand[MathMax(hhbar,shift+ChannelPeriod)]); //High[iHighest(NULL,0,MODE_HIGH,MathMax(hhbar - shift,ChannelPeriod),shift+1)]; 
         
            if(LoBand[shift+1] > 0 && LoBand[shift+1] != EMPTY_VALUE && upbound > 0 && upbound != EMPTY_VALUE)
            {
            SetBox(UniqueName+" DnBox "+TimeToString(Time[shift]),0,Time[shift],LoBand[shift+1],Time[MathMax(hhbar,shift+ChannelPeriod)],upbound,ShowFilledBoxes,clrNONE,1,DnTrendColor,1); 
            DnSignal[shift] = upbound;
               
               if(ShowAnalysis)
               {
               sellcnt[shift] = sellcnt[shift+1] + 1;
               
               ArrayResize(sellopen ,sellcnt[shift]);
               ArrayResize(sellclose,sellcnt[shift]);
               ArrayResize(sellopentime ,sellcnt[shift]);
               ArrayResize(sellclosetime,sellcnt[shift]);
               
               //sellopen[(int)sellcnt[shift]-1]     = HeikenAshi(0,0,shift);
               sellopen[(int)sellcnt[shift]-1]     = Close[shift];
               sellopentime[(int)sellcnt[shift]-1] = Time[shift];
               sellclose[(int)sellcnt[shift]-1]    = sellopen[(int)sellcnt[shift]-1];
               sellstop[0] = false;
                   
                  if(ShowArrows) 
                  {
                  ObjectDelete(UniqueName+" SellOpen "+DoubleToStr(sellcnt[shift],0));
                  plotArrow(UniqueName+" SellOpen "+DoubleToStr(sellcnt[shift],0),sellopentime[(int)sellcnt[shift]-1],sellopen[(int)sellcnt[shift]-1],2,DnTrendColor);
                  }
               }
            }
            
            if(Low[shift] <= lobound && !buystop[0] && buyclose[(int)buycnt[shift]-1] == buyopen[(int)buycnt[shift]-1]) 
            {
            buyclose[(int)buycnt[shift]-1]     = lobound;
            buyclosetime[(int)buycnt[shift]-1] = Time[shift];
            buystop[0] = true;
            
               if(buyopentime[(int)buycnt[shift]-1] > 0 && buyclosetime[(int)buycnt[shift]-1] > 0)
               {   
               if(buyclose[(int)buycnt[shift]-1] >= buyopen[(int)buycnt[shift]-1]) buycolor = WinColor; else buycolor = LossColor;
               plotTrend(UniqueName+" BuyTrend "+DoubleToStr(buycnt[shift],0),buyopentime[(int)buycnt[shift]-1],buyopen[(int)buycnt[shift]-1],buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],2,0,buycolor);   
               if(ShowArrows && trend[shift+1] > 0) plotArrow(UniqueName+" BuyClose "+DoubleToStr(buycnt[shift],0),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],3,UpTrendColor);
               if(ShowExits) buyexit[shift] = buyclose[(int)buycnt[shift]-1];
               }
            
               if(ShowProfit)
               { 
               buyprofit = (buyclose[(int)buycnt[shift]-1] - buyopen[(int)buycnt[shift]-1])/_point;
                  if(buyprofit >= 0) totbuyprofit[0] = totbuyprofit[1] + buyprofit; 
                  else 
                  {
                  totbuyloss[0] = totbuyloss[1] - buyprofit;
                  buylosscnt[0] = buylosscnt[1] + 1;
                  }
                  
               ObjectDelete(0,UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0));
                  
                  if(buyprofit >= 0) plotText(UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0),0,"+"+DoubleToStr(buyprofit,1),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],ANCHOR_RIGHT_LOWER,WinColor,"Arial",8);
                  else plotText(UniqueName+" BuyProfit "+DoubleToStr(buycnt[shift],0),0,DoubleToStr(buyprofit,1),buyclosetime[(int)buycnt[shift]-1],buyclose[(int)buycnt[shift]-1],ANCHOR_RIGHT_UPPER,LossColor,"Arial",8);
               }
            }
         }
      
      ObjectDelete(0,UniqueName+" UpBox "+TimeToString(Time[shift]));
      
         if(ShowAnalysis) 
         {
            if(trend[shift+1] < 0)
            {
               if(Low[shift] < sellclose[(int)sellcnt[shift]-1] && !sellstop[0]) 
               {
               sellclose[(int)sellcnt[shift]-1]     = Low[shift]; 
               sellclosetime[(int)sellcnt[shift]-1] = Time[shift];
               }
               
               if(High[shift] >= upbound && !sellstop[0] && sellclose[(int)sellcnt[shift]-1] == sellopen[(int)sellcnt[shift]-1]) 
               {
               sellclose[(int)sellcnt[shift]-1]     = upbound; 
               sellclosetime[(int)sellcnt[shift]-1] = Time[shift];
               sellstop[0] = true;
               }  
            }   
        
        ObjectDelete(0,UniqueName+" SellTrend "+DoubleToStr(sellcnt[shift],0));
        if(ShowArrows) ObjectDelete(0,UniqueName+" SellClose "+DoubleToStr(sellcnt[shift],0));
         
            if(sellopentime[(int)sellcnt[shift]-1] > 0 && sellclosetime[(int)sellcnt[shift]-1] > 0)
            {   
            if(sellclose[(int)sellcnt[shift]-1] <= sellopen[(int)sellcnt[shift]-1]) sellcolor = WinColor; else sellcolor = LossColor;
            plotTrend(UniqueName+" SellTrend "+DoubleToStr(sellcnt[shift],0),sellopentime[(int)sellcnt[shift]-1],sellopen[(int)sellcnt[shift]-1],sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],2,0,sellcolor);   
            if(ShowArrows && trend[shift+1] < 0) plotArrow(UniqueName+" SellClose "+DoubleToStr(sellcnt[shift],0),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],3,DnTrendColor);
            if(ShowExits) sellexit[shift] = sellclose[(int)sellcnt[shift]-1];
            }
                  
         
            if(ShowProfit)
            { 
            sellprofit = (sellopen[(int)sellcnt[shift]-1] - sellclose[(int)sellcnt[shift]-1])/_point;
               if(sellprofit >= 0) totsellprofit[0] = totsellprofit[1] + sellprofit; 
               else 
               {
               totsellloss[0] = totsellloss[1] - sellprofit; 
               selllosscnt[0] = selllosscnt[1] + 1;
               }
                         
            ObjectDelete(0,UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0));
               
               if(sellprofit >= 0) plotText(UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0),0,"+"+DoubleToStr(sellprofit,1),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],ANCHOR_RIGHT_UPPER,WinColor,"Arial",8);
               else plotText(UniqueName+" SellProfit "+DoubleToStr(sellcnt[shift],0),0,DoubleToStr(sellprofit,1),sellclosetime[(int)sellcnt[shift]-1],sellclose[(int)sellcnt[shift]-1],ANCHOR_RIGHT_LOWER,LossColor,"Arial",8);
            }
                
         if(ObjectGetInteger(0,UniqueName+" BuyOpen "+DoubleToStr(buycnt[shift]+1,0),OBJPROP_TIME) == Time[shift])  ObjectDelete(0,UniqueName+" BuyOpen "+DoubleToStr(buycnt[shift]+1,0));
         }
      }   
   
   if((totbuyloss[0] + totsellloss[0]) > 0) pf[shift] = (totbuyprofit[0] + totsellprofit[0])/(totbuyloss[0] + totsellloss[0]); else pf[shift] = 0; 
   } 
   
   
   
   
   
   if(ShowStatsComment)
   {
   if(pf[0] > 0) string pftext = DoubleToStr(pf[0],1); else pftext = "n/a";
   
   if(sellcnt[0]==0 || buycnt[0]==0){
      Comment("\n","DONCHIAN BREAKOUT SYSTEM(Breakout on "+price_type(Price)+")\n============================\nToo few trades");
   }else
      Comment( "\n","DONCHIAN BREAKOUT SYSTEM(Breakout on "+price_type(Price)+")","\n",
               "============================","\n", 
               "Long positions (% won): ",buycnt[0]," (",DoubleToStr(100*(buycnt[0] - buylosscnt[0])/buycnt[0],1),"%)","\n",
               "Short positions(% won): ",sellcnt[0]," (",DoubleToStr(100*(sellcnt[0] - selllosscnt[0])/sellcnt[0],1),"%)","\n",
               "Profit factor: ",pftext,"\n");  
      }

   
   
   if(AlertOn || EmailOn || PushNotificationOn)
   {
   bool uptrend = trend[AlertShift] > 0 && trend[AlertShift+1] <= 0;                  
   bool dntrend = trend[AlertShift] < 0 && trend[AlertShift+1] >= 0;
         
      if(uptrend || dntrend)
      {
         if(isNewBar(timeframe))
         {
            if(AlertOn)
            {
            BoxAlert(uptrend," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            BoxAlert(dntrend," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
            }
                   
            if(EmailOn)
            {
            EmailAlert(uptrend,"BUY" ," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            EmailAlert(dntrend,"SELL"," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            }
         
            if(PushNotificationOn)
            {
            PushAlert(uptrend," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            PushAlert(dntrend," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
            }
         }
         else
         {
            if(AlertOn)
            {
            WarningSound(uptrend,SoundsNumber,SoundsPause,UpTrendSound,Time[AlertShift]);
            WarningSound(dntrend,SoundsNumber,SoundsPause,DnTrendSound,Time[AlertShift]);
            }
         }   
      }
   }   
//----
   return(0);
}
//+------------------------------------------------------------------+


datetime prevnbtime;

bool isNewBar(int tf)
{
   bool res = false;
   
   if(tf >= 0)
   {
      if(iTime(NULL,tf,0) != prevnbtime)
      {
      res   = true;
      prevnbtime = iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

string prevmess;
 
bool BoxAlert(bool cond,string text)   
{      
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

datetime pausetime;

bool Pause(int sec)
{
   if(TimeCurrent() >= pausetime + sec) {pausetime = TimeCurrent(); return(true);}
   
   return(false);
}

datetime warningtime;

void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
{
   static int i;
   
   if(cond)
   {
   if(curtime != warningtime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); warningtime = curtime; i++;}       	
   }
}

string prevemail;

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = "New " + text1 +" Signal from " + IndicatorName + "!!!";    
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}

string prevpush;
 
bool PushAlert(bool cond,string text)   
{      
   string push = IndicatorName + "("+Symbol() + "," + TF + ")" + text;
   
   if(cond && push != prevpush)
	{
	SendNotification(push);
	
	prevpush = push; 
	return(true);
	} 
  
   return(false);  
}



string tf(int itimeframe)
{
   string result = "";
   
   switch(itimeframe)
   {
   case PERIOD_M1:   result = "M1" ;
   case PERIOD_M5:   result = "M5" ;
   case PERIOD_M15:  result = "M15";
   case PERIOD_M30:  result = "M30";
   case PERIOD_H1:   result = "H1" ;
   case PERIOD_H4:   result = "H4" ;
   case PERIOD_D1:   result = "D1" ;
   case PERIOD_W1:   result = "W1" ;
   case PERIOD_MN1:  result = "MN1";
   default:          result = "N/A";
   }
   
   if(result == "N/A")
   {
   if(itimeframe <  PERIOD_H1 ) result = "M"  + itimeframe;
   if(itimeframe >= PERIOD_H1 ) result = "H"  + itimeframe/PERIOD_H1;
   if(itimeframe >= PERIOD_D1 ) result = "D"  + itimeframe/PERIOD_D1;
   if(itimeframe >= PERIOD_W1 ) result = "W"  + itimeframe/PERIOD_W1;
   if(itimeframe >= PERIOD_MN1) result = "MN" + itimeframe/PERIOD_MN1;
   }
   
   return(result); 
}



//+------------------------------------------------------------------+
//| Draw a Box with given color for a symbol                       |
//+------------------------------------------------------------------+

void SetBox(string name,int win,datetime time1,double price1,datetime time2,double price2,bool fill,color bg_color,int border_type,color border_clr,int border_width)
{
   ObjectDelete(0,name);
   
   if(ObjectCreate(0,name,OBJ_RECTANGLE,win,0,0,0,0))
   {
   ObjectSetInteger(0,name,OBJPROP_TIME1      ,        time1);
   ObjectSetDouble (0,name,OBJPROP_PRICE1     ,       price1);
   ObjectSetInteger(0,name,OBJPROP_TIME2      ,        time2);
   ObjectSetDouble (0,name,OBJPROP_PRICE2     ,       price2);
   ObjectSetInteger(0,name,OBJPROP_COLOR      ,  border_clr);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE, border_type);
   ObjectSetInteger(0,name,OBJPROP_WIDTH      ,border_width);
   ObjectSetInteger(0,name,OBJPROP_STYLE      , STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK       ,        fill);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE ,           1);
   ObjectSetInteger(0,name,OBJPROP_SELECTED   ,           0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN     ,       false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER     ,           0);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR    ,    bg_color);
   }
}



void plotArrow(string name,datetime time,double price,int arrow,color clr)
{
   if(ObjectFind(0,name) < 0)
   {
   ObjectCreate(0,name,OBJ_ARROW,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE ,arrow); 
   ObjectSetInteger(0,name,OBJPROP_COLOR     ,  clr);
   }   
   else ObjectSetInteger(0,name,OBJPROP_COLOR,  clr);
}


void plotTrend(string name,datetime time1,double price1,datetime time2,double price2,int style,int width,color clr)
{
   if(ObjectFind(0,name) < 0)
   {
   ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style); 
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_RAY  ,false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,  clr); 
   }
}     
    
void plotText(string name,int win,string text,datetime time,double price,int anchor,color clr,string font,int fontsize)
{
   ObjectDelete(0,name);
   
   if(ObjectCreate(0,name,OBJ_TEXT,win,0,0))
   {
   ObjectSetInteger(0,name,OBJPROP_TIME     ,    time);
   ObjectSetDouble (0,name,OBJPROP_PRICE    ,   price);
   ObjectSetInteger(0,name,OBJPROP_COLOR    ,     clr);
   ObjectSetString (0,name,OBJPROP_FONT     ,    font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE ,fontsize);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR   ,  anchor);
   ObjectSetString (0,name,OBJPROP_TEXT     ,    text);
   }
}

double priceWrapper(int price, int bar){
   if(price>=4)
      return(HeikenAshi(0,Price-4,bar));
   if(price>0)
      price+=3;
   return(iMA(Symbol(),0,1,0,0,price,bar));
}

// HeikenAshi Price
double   haClose[1][2], haOpen[1][2], haHigh[1][2], haLow[1][2];
datetime prevhatime[1];

double HeikenAshi(int index,int price,int bar)
{ 

   if(prevhatime[index] != Time[bar])
   {
   haClose[index][1] = haClose[index][0];
   haOpen [index][1] = haOpen [index][0];
   haHigh [index][1] = haHigh [index][0];
   haLow  [index][1] = haLow  [index][0];
   prevhatime[index] = Time[bar];
   }
   
   if(bar == Bars - 1) 
   {
   haClose[index][0] = Close[bar];
   haOpen [index][0] = Open [bar];
   haHigh [index][0] = High [bar];
   haLow  [index][0] = Low  [bar];
   }
   else
   {
   haClose[index][0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [index][0] = (haOpen[index][1] + haClose[index][1])/2;
   haHigh [index][0] = MathMax(High[bar],MathMax(haOpen[index][0],haClose[index][0]));
   haLow  [index][0] = MathMin(Low [bar],MathMin(haOpen[index][0],haClose[index][0]));
   }
   
   switch(price)
   {
   case  0: return(haClose[index][0]); break;
   case  1: return((haHigh[index][0] + haLow[index][0])/2); break;
   case  2: return((haHigh[index][0] + haLow[index][0] +   haClose[index][0])/3); break;
   case  3: return((haHigh[index][0] + haLow[index][0] + 2*haClose[index][0])/4); break;
   default: return(haClose[index][0]); break;
   }
}     

string price_type(int price)
{
   switch(price)
   {
   case 0:   return("Close");
   case 1:   return("Median");
   case 2:   return("Typical");
   case 3:   return("Weighted Close");
   case 4:   return("Heiken Ashi Close");
   case 5:   return("Heiken Ashi Median");
   case 6:   return("Heiken Ashi Typical");
   case 7:   return("Heiken Ashi Weighted Close");
   default:  return("Unknown price");
   }
}
/*
── Project ─────────────────────────────────────────────────────────────────────

Name:         
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75032&p=161099#p161099
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/