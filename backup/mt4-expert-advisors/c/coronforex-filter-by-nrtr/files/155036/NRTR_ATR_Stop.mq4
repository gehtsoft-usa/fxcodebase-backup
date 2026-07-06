//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74784

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers  2


extern ENUM_TIMEFRAMES TimeFrame       = 0;
extern int             ATR             = 20;
extern double          Coeficient      = 2;
extern color           ColorUp         = clrDodgerBlue;
extern color           ColorDn         = clrMagenta;
extern int             LineWidth       = 3;
extern ENUM_LINE_STYLE LineStyle       = 2;
extern string          Separator       = "******** Alerts ********";
extern bool            alertsOn        = false;           // Turn alerts on?
extern bool            alertsOnCurrent = false;           // Alerts on still opened bar?
extern bool            alertsMessage   = false;            // Alerts should display message?
extern bool            alertsSound     = false;           // Alerts should play a sound?
extern bool            alertsNotify    = false;           // Alerts should send a notification?
extern bool            alertsEmail     = false;           // Alerts should send an email?
extern bool            Interpolate     = true;            // Interpolate in multi time frame mode?

//
//
//
//
//

double Up[], Dn[], mode[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
  {
   for (int i=0; i<indicator_buffers; i++) //SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(3);
   SetIndexBuffer(0, Up); SetIndexLabel (0, "Up"); SetIndexStyle(0,DRAW_LINE,LineStyle,LineWidth,ColorUp);
   SetIndexBuffer(1, Dn); SetIndexLabel (1, "Dn"); SetIndexStyle(1,DRAW_LINE,LineStyle,LineWidth,ColorDn);
   SetIndexBuffer(2, mode);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame == "returnBars";     if (returnBars)     return(0);
      calculateValue    = TimeFrame == "calculateValue"; if (calculateValue) return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit() 
{ 
   return(0); 
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { Up[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      for(int i = limit - 1; i >= 0; i--)
      {
       Dn[i]   = EMPTY_VALUE; 
       Up[i]   = EMPTY_VALUE;
       mode[i] = mode[i+1];
       double REZ = Coeficient*iATR(NULL, 0, ATR, i);

       if((mode[i] == -1 || mode[i]==EMPTY_VALUE) &&  Low[i+1] > Dn[i+1]) 
       { 
           Up[i+1] = Low[i+1] - REZ; 
           mode[i] = 1; 
       }
       if((mode[i]==1 || mode[i]==EMPTY_VALUE) && High[i+1] < Up[i+1]) 
       { 
           Dn[i+1] = High[i+1] + REZ; 
           mode[i] = -1; 
       }
       
       //
       //
       //
       //
       //
       
       if(mode[i]==1)
         {
           if(Low[i+1] > Up[i+1] + REZ) 
             { 
               Up[i] = Low[i+1] - REZ; 
               Dn[i] = EMPTY_VALUE; 
             }
		         else 
		           { 
		             Up[i] = Up[i+1]; 
                   Dn[i] = EMPTY_VALUE; 
		           }
		       }
       if(mode[i]==-1)
         {
     	     if(High[i+1] < Dn[i+1] - REZ) 
     	       { 
     	         Dn[i] = High[i+1] + REZ; 
     	         Up[i] = EMPTY_VALUE; 
     	       }
	          else 
	            { 
	              Dn[i] = Dn[i+1]; 
	              Up[i] = EMPTY_VALUE; 
	            }
	        }
      }
      //
   //
   //
   //
   //
      
   if (alertsOn)
   {
     int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
     if (mode[whichBar] != mode[whichBar+1])
     if (mode[whichBar] == 1)
           doAlert("up");
     else  doAlert("down");       
   }    
   return(0);
   
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
        int y = iBarShift(NULL,timeFrame,Time[i]);               
           Up[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ATR,Coeficient,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,0,y+y);
           Dn[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",ATR,Coeficient,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,1,y+y);
          
           //
           //
           //
           //
           //
                        
           if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

           //
           //
           //
           //
           //

           datetime time = iTime(NULL,timeFrame,y);
              for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
              for(int k = 1; k < n; k++)
              {
                 if (Up[i]!=EMPTY_VALUE && Up[i+n]!=EMPTY_VALUE) Up[i+k] = Up[i] + (Up[i+n]-Up[i])*k/n;
                 if (Dn[i]!=EMPTY_VALUE && Dn[i+n]!=EMPTY_VALUE) Dn[i+k] = Dn[i] + (Dn[i+n]-Dn[i])*k/n;
              }
   }
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
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

           message = stringToTimeFrame(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" nrtr atr stops state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," nrtr atr Stops "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
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