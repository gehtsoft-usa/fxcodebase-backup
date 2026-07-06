// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76250

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrOrange
#property indicator_width3 2
#property indicator_width4 2

#property strict

extern int bars = 10000;
           
extern int             length      = 22;             
extern double          multiplier  = 3.0;            
extern bool            useClose = true;           


extern string s16 = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";//_
extern string s17 = "           Arrows Parameters";//_
extern string s18 = "////////////////////////////////";//_
extern bool arrows = true;//Main Chart Arrows
extern int arrowBuyCode = 233;
extern int arrowSellCode = 234;
extern int arrowBuySize = 2;
extern int arrowSellSize = 2;
extern color arrowColorBuy = clrGreen;
extern color arrowColorSell = clrRed;
extern double ArrowDistanceBuy = 2;
extern double ArrowDistanceSell = 2;
extern int ArrowRef = 1234;
  
extern string s6 = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";//_
extern string s7 = "           Alerts Parameters";//_
extern string s8 = "////////////////////////////////";//_
extern bool AlertOnClose = true;//Alert On Close Only ?
extern bool AudioAlert = true;
extern string sound = "alert2.wav";
extern bool AlertAlert = true;//Alert
extern bool EmailAlert = false;
extern bool PushAlert = false;

string indicatorFileName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
double longStop_[],longStop[];
double shortStop_[],shortStop[];
int OnInit()
{

  
      
      
      SetIndexBuffer(2, longStop);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2); 
      SetIndexBuffer(3, shortStop);
      SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2); 
       
      SetIndexBuffer(4, longStop_);
      SetIndexStyle(4,DRAW_NONE); 
      SetIndexBuffer(5, shortStop_);
      SetIndexStyle(5,DRAW_NONE); 
      
      
      SetIndexBuffer(0,up_arr);
      SetIndexStyle(0,DRAW_ARROW,EMPTY,arrowBuySize,arrowColorBuy);
      SetIndexArrow(0,arrowBuyCode);
      SetIndexLabel(0,"UP arrow");
      
      SetIndexBuffer(1,dn_arr);
      SetIndexStyle(1,DRAW_ARROW,EMPTY,arrowSellSize,arrowColorSell);
      SetIndexArrow(1,arrowSellCode);
      SetIndexLabel(1,"DOWN arrow");
      
   
      
      
      indicatorFileName = WindowExpertName();
   return(0);
}
 double up_arr[];//!
 double dn_arr[];//!


void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
bool nb = false;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int limit;
   int CountedBars=IndicatorCounted();
   if(CountedBars>Bars-1) CountedBars=Bars-1;
   if(CountedBars<0) return(-1);
   if(CountedBars>0) CountedBars--;
   if(CountedBars<10) CountedBars = 10;
   limit=Bars-1-CountedBars;
   
   if (limit > bars)
   {
      limit = bars;
   }
   for(int i=limit; i>=AlertOnClose; i--) 
   {
         if (tim != iTime(NULL,0,1))
        {
            tim = iTime(NULL,0,1);
            nb = true;
            
            up_arr[i] = EMPTY_VALUE;
            dn_arr[i] = EMPTY_VALUE;
        }
               /*
         length = 1
         mult = 1.4
         showLabels = true
         useClose =false
         highlightState = true
         
         atr = mult * atr(length)*/
         double atr = multiplier * iATR(NULL,0,length,i);
         
         /*
         
         longStop = (useClose ? highest(close, length) : highest(length)) - atr
         longStopPrev = nz(longStop[1], longStop) 
         longStop := close[1] > longStopPrev ? max(longStop, longStopPrev) : longStop
         */
         
            int hh;
            if (useClose)
               hh = iHighest(NULL,0,MODE_CLOSE,length,i);
            else hh = iHighest(NULL,0,MODE_HIGH,length,i);
            
            if (useClose)
            {
               longStop_[i] = iClose(NULL,0,hh) - atr;
            }
            else longStop_[i] = iHigh(NULL,0,hh) - atr;
            
            longStop_[i] = iClose(NULL,0,i+1) > longStop_[i+1] ? MathMax(longStop_[i], longStop_[i+1]) : longStop_[i];
            
            
         
         /*
         shortStop = (useClose ? lowest(close, length) : lowest(length)) + atr
         shortStopPrev = nz(shortStop[1], shortStop)
         shortStop := close[1] < shortStopPrev ? min(shortStop, shortStopPrev) : shortStop
         */
            int ll;
            if (useClose)
               ll = iLowest(NULL,0,MODE_CLOSE,length,i);
            else ll = iLowest(NULL,0,MODE_LOW,length,i);
            
            if (useClose)
            {
               shortStop_[i] = iClose(NULL,0,ll) + atr;
            }
            else shortStop_[i] = iLow(NULL,0,ll) + atr;
         
            shortStop_[i] = iClose(NULL,0,i+1) < shortStop_[i+1] ? MathMin(shortStop_[i], shortStop_[i+1]) : shortStop_[i];
        
         
         
         static int prevdir ;
         
         /*
         var int dir = 1
         dir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : dir
         */
         static int dir = 1;
         dir = (iClose(NULL,0,i) > shortStop_[i+1]) ? 1 : (iClose(NULL,0,i) < longStop_[i+1] ? -1 : dir);
                     
            
         if (dir == 1)
         {
            longStop[i] = longStop_[i];
            shortStop[i] = EMPTY_VALUE;
            if (prevdir == -1)
            {
               longStop[i+1] = shortStop[i+1];
               up_arr[i] = iLow(NULL,0,i) - iATR(NULL,0,20,i)*ArrowDistanceBuy;         
            }
               
         }
         else if (dir == -1)
         {
            shortStop[i] = shortStop_[i];
            longStop[i] = EMPTY_VALUE;
            if (prevdir == 1)
            {
               shortStop[i+1] = longStop[i+1];
               dn_arr[i] = iHigh(NULL,0,i) + iATR(NULL,0,20,i)*(ArrowDistanceSell+1);           
            } 
         }   
         
         if (i == AlertOnClose && up_arr[i+AlertOnClose] > 0 && up_arr[i+AlertOnClose] < EMPTY_VALUE)
             AlertBuy();
         if (i == AlertOnClose && dn_arr[i+AlertOnClose] > 0 && dn_arr[i+AlertOnClose] < EMPTY_VALUE)
             AlertSell();         
            
               
         prevdir = dir;
         /*
         var color longColor = color.green
         var color shortColor = color.red
         
         longStopPlot = plot(dir == 1 ? longStop : na, title="Long Stop", style=plot.style_linebr, linewidth=2, color=longColor)
         buySignal = dir == 1 and dir[1] == -1
         plotshape(buySignal ? longStop : na, title="Long Stop Start", location=location.absolute, style=shape.circle, size=size.tiny, color=longColor, transp=0)
         plotshape(buySignal and showLabels ? longStop : na, title="Buy Label", text="Buy", location=location.absolute, style=shape.labelup, size=size.tiny, color=longColor, textcolor=color.white, transp=0)
         */
            }
   return(rates_total);
   }               
       
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//


void AlertBuy()
{
   if (nb)
   {  
      string text = "";
      
      text = "Chandelier Exit : Open BUY order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";
          
      SetAlert(text);
      nb = false;
   }
}  
void AlertSell()
{
   if (nb)
   {  
      string text = "";
      
      text = "Chandelier Exit : Open SELL order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";
          
      SetAlert(text);
      nb = false;

   }
} 

void SetAlert(string s)
{     
   if (AudioAlert)
   {
      PlaySound(sound);
   }
   if (AlertAlert)
   {
      Alert(s);
   }
   if (EmailAlert)
   {
       SendMail(s, "Alert from indicator : ");
   }
   if (PushAlert)
   {
       SendNotification(s);
   }
   
}     
datetime tim;

int TFNumber(int tf)
{
   switch (tf)
   {
      case PERIOD_M1 : return 0; break;
      case PERIOD_M5 : return 1; break;
      case PERIOD_M15 : return 2; break;
      case PERIOD_M30 : return 3; break;
      case PERIOD_H1 : return 4; break;
      case PERIOD_H4 : return 5; break;
      case PERIOD_D1 : return 6; break;
      case PERIOD_W1 : return 7; break;
      case PERIOD_MN1 : return 8; break;
   }
   return -1;
}
string GetNameTF(int ctTF)
{
   switch (ctTF)
   {
      case 0 : return "M1"; break;
      case 1 : return "M5"; break;
      case 2 : return "M15"; break;
      case 3 : return "M30"; break;
      case 4 : return "H1"; break;
      case 5 : return "H4"; break;
      case 6 : return "D1"; break;
      case 7 : return "W1"; break;
      case 8 : return "MN1"; break;
   }
   
   return "";
}  
  
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76250

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+