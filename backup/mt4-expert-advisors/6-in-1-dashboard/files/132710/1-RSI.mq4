// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69489
//+------------------------------------------------------------------+
//|RK-ml-RSI_EMA_mtf v1.2 jan 22, 2011      original-RSI_EMA_MTF.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Orange
#property indicator_color3 Lime
#property indicator_color4 Red

#property indicator_width1 2
#property indicator_width2 0 
#property indicator_width3 3
#property indicator_width4 3

extern string TimeFrame        = "H4";
extern int    RsiPeriod        = 5;
extern int    MaType           = MODE_EMA;
extern int    MaPeriod         = 3;
extern bool   Interpolate      = true;
input bool draw_arrows = true; // Draw arrows
extern string pus1 = "";
extern string arrowsIdentifier = "RsiEmaArrows";
extern color  arrowsUpColor    = Aqua;
extern color  arrowsDnColor    = Red;

//
//
//
//
//
extern string pus2 = "";
extern bool   alertsOn          = true;
extern bool   alertsOnCurrent   = false;

extern string pus3 = "";
extern bool   alertsSound       = true;
extern string up_sound = "news";
extern string down_sound = "ok";

extern string pus4 = "";
extern bool   alertsMessage     = true;
extern string arr_up = "up";
extern string arr_down = "down";

extern string pus5 = "";
extern bool   alertsEmail       = false;

//
//
//
//
//

double rsi[],ema[],trend[],trend_d[];

string indicatorFileName;
bool   calculating   = false;
bool   returningBars = false;
int    timeFrame;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
   IndicatorBuffers(4);      
   SetIndexBuffer(0,rsi);     SetIndexLabel(0,"rsi");
   SetIndexBuffer(1,ema);     SetIndexLabel(1,"ema");
   SetIndexBuffer(2,trend);   SetIndexLabel(2,"trend");
   SetIndexBuffer(3,trend_d); SetIndexLabel(3,"trend_d");
   
   if (TimeFrame=="calculate")
   {
      calculating=true;
      return(0);
   }
   if (TimeFrame=="returnBars")
   {
      returningBars=true;
      return(0);
   }
   timeFrame = stringToTimeFrame(TimeFrame);
      
   indicatorFileName = WindowExpertName();
   IndicatorShortName("RK-ml-RSI_EMA_mtf v1.2 "+tf());
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
      deleteArrows();
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returningBars)  { rsi[0] = limit+1; return(0); }
         if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));

   //
   //
   //
   //
   //

     if (calculating)
     {
         for(i=0; i<limit; i++) rsi[i] = iRSI(NULL,0,RsiPeriod,PRICE_CLOSE,i);
         for(i=0; i<limit; i++) ema[i] = iMAOnArray(rsi,0,MaPeriod,0,MaType,i);
         return(0);
     }         
     for(i=limit; i>=0; i--)
     {
         int y = iBarShift(NULL,timeFrame,Time[i]);
            rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculate",RsiPeriod,MaType,MaPeriod,0,y);
            ema[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculate",RsiPeriod,MaType,MaPeriod,1,y);
            
            //
            //
            //    must be done before interpolation
            //
            //
            
               trend[i] = trend[i+1];
               trend_d[i] = trend_d[i+1];
               
                  if (rsi[i]>ema[i]) {trend[i]= 1;trend_d[i]=EMPTY_VALUE;}
                  if (rsi[i]<ema[i]) {trend_d[i]=-1;trend[i]=EMPTY_VALUE;}
                  
                  deleteArrow(Time[i]);
                  
                  if (trend[i]!=trend[i+1])
                  {
                     if (trend[i] == 1) drawArrow(i,arrowsUpColor,233,false);
                     if (trend[i] ==-1) drawArrow(i,arrowsDnColor,234,true);
                  }

                  
                  
                  if (trend_d[i]!=trend_d[i+1])
                  {
                     if (trend_d[i] == 1) drawArrow(i,arrowsUpColor,233,false);
                     if (trend_d[i] ==-1) drawArrow(i,arrowsDnColor,234,true);
                  }
            
            //
            //
            //
            //
      
               if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
               if (!Interpolate) continue;

            //
            //
            //
            //
            //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               double factor = 1.0 / n;
               for(int k = 1; k < n; k++)
               {
                  rsi[i+k] = k*factor*rsi[i+n] + (1.0-k*factor)*rsi[i];
                  ema[i+k] = k*factor*ema[i+n] + (1.0-k*factor)*ema[i];
               }
               
           
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 0;
     ///////// 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(" "+arr_up,trend[whichBar]);         
      }    
     ///////// 
      if (trend_d[whichBar] != trend_d[whichBar+1])
      {
         if (trend_d[whichBar] ==-1) doAlert(" "+arr_down,trend_d[whichBar]);
      }         
      /////////   
   }
     
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   if (!draw_arrows)
   {
      return;
   }
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
   ObjectSet(name,OBJPROP_ARROWCODE,theCode);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   if (up)
      ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
   else  
      ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
//
//
//
//
//

void doAlert(string doWhat,int way)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",Period()," RSIs crosses ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Rsi5-3EMA"),message);
             if (alertsSound)
             {   
             if(way==1) PlaySound(up_sound+".wav");
             if(way==-1) PlaySound(down_sound+".wav");
             }
      }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   for(int l = StringLen(tfs)-1; l >= 0; l--)
   {
      int char1 = StringGetChar(tfs,l);
          if((char1 > 96 && char1 < 123) || (char1 > 223 && char1 < 256))
               tfs = StringSetChar(tfs, l, char1 - 32);
          else 
              if(char1 > -33 && char1 < 0)
                  tfs = StringSetChar(tfs, l, char1 + 224);
   }
   int tf=0;
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf==0 || tf<Period())      tf=Period();
   return(tf);
}


string tf()
{
   switch(timeFrame)
   {
      case PERIOD_M1:  return("M(1)");
      case PERIOD_M5:  return("M(5)");
      case PERIOD_M15: return("M(15)");
      case PERIOD_M30: return("M(30)");
      case PERIOD_H1:  return("H(1)");
      case PERIOD_H4:  return("H(4)");
      case PERIOD_D1:  return("D(1)");
      case PERIOD_W1:  return("W(1)");
      case PERIOD_MN1: return("MN(1)");
      default:         return("Unknown timeframe");
   }
}