//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75943

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrWhite 
#property indicator_color2  clrRed 
#property indicator_color3  clrRed
#property indicator_color4  clrNONE  
#property indicator_width1  2
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  2
#property indicator_levelstyle STYLE_DASH
#property indicator_level1 0

#property indicator_label5 "Arrow Up"
#property  indicator_type5  DRAW_ARROW
#property indicator_color5 clrBlue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Arrow Down"
#property  indicator_type6  DRAW_ARROW
#property indicator_color6 clrRed
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

extern string TimeFrame   = "Current time frame";
extern int    HalfLength1 = 180;
extern int    HalfLength2 = 360;
extern int    Price       = PRICE_CLOSE;
extern bool   Invert      = true;
extern bool   Interpolate = true;

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double slope[];

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//

int init()
{
   IndicatorDigits(6);
   IndicatorBuffers(7);
   SetIndexBuffer(0,buffer4);SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1); //   biaco sporco 
   SetIndexBuffer(1,buffer1);
   SetIndexBuffer(2,buffer2);
   SetIndexBuffer(3,buffer3);
   SetIndexBuffer(4,slope); 
   SetIndexStyle(4, DRAW_NONE);
   
  SetIndexBuffer(5, ArrowUp, INDICATOR_DATA);
  SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, Blue);
   SetIndexArrow(5, 233);
  SetIndexBuffer(6, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, Red);
   SetIndexArrow(6, 234);

      if ((HalfLength1%2)==0) HalfLength1++;
      if ((HalfLength2%2)==0) HalfLength2++;
        indicatorFileName = WindowExpertName();
        calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
        returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
        timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}
int deinit() { return(0); }




//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][10];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
      int limit=MathMin(Bars-counted_bars+MathMax(HalfLength1,HalfLength2)*5,Bars-1);
      if (returnBars) { buffer4[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      if (slope[limit]==-1) CleanPoint(limit,buffer2,buffer3);
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)  work[r][0] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         work[r][1] = iCTma(0,HalfLength1,i);
         work[r][2] = iCTma(0,HalfLength2,i);
         if (Invert)
               work[r][3] = 100.0*(work[r][2]-work[r][1]);
         else  work[r][3] = 100.0*(work[r][1]-work[r][2]);
      }  
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         work[r][4] = iCTma(3,HalfLength2,i);
         work[r][5] = 100.0*(work[r][4]-work[r-1][4]);
      }
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         work[r][6] = iCTma(5,HalfLength2,i);
         work[r][7] = 100.0*(work[r][6]-work[r-1][6]);
      }
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         work[r][8] = iCTma(7,HalfLength2,i);
         work[r][9] = work[r][8]-work[r-1][8];
            buffer1[i] = work[r][8];
            buffer2[i] = EMPTY_VALUE;
            buffer3[i] = EMPTY_VALUE;
            buffer4[i] = work[r][9]*50;
            slope[i]   = slope[i+1];
               if (buffer1[i]>buffer1[i+1]) slope[i]= 1;
               if (buffer1[i]<buffer1[i+1]) slope[i]=-1;
               if (slope[i]==-1) PlotPoint(i,buffer2,buffer3,buffer1);
      }





      for (i=limit;i>=0;i--) {      
         if(buffer4[i] > buffer1[i] && buffer4[i+1] <= buffer1[i+1]) { ArrowUp[i] = buffer4[i]; } else { ArrowUp[i] = EMPTY_VALUE; }
         if(buffer4[i] < buffer1[i] && buffer4[i+1] >= buffer1[i+1]) { ArrowDn[i] = buffer4[i]; } else { ArrowDn[i] = EMPTY_VALUE; }
      }



      return(0);
   }      

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (slope[limit]==-1) CleanPoint(limit,buffer2,buffer3);
   
   for (i=limit;i>=0; i--)
   {
       int y = iBarShift(NULL,timeFrame,Time[i]);
            buffer4[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HalfLength1,HalfLength2,Price,Invert,0,y);
            buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HalfLength1,HalfLength2,Price,Invert,1,y);
            slope[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HalfLength1,HalfLength2,Price,Invert,4,y);
            buffer2[i] = EMPTY_VALUE;
            buffer3[i] = EMPTY_VALUE;
      
            ArrowUp[i] = EMPTY_VALUE;
            ArrowDn[i] = EMPTY_VALUE;
            
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
                  buffer4[i+k] = buffer4[i] + (buffer4[i+n]-buffer4[i])*k/n;
                  buffer1[i+k] = buffer1[i] + (buffer1[i+n]-buffer1[i])*k/n;
               }
   }

   for (i=limit;i>=0;i--) 
   {
      if (slope[i]==-1) PlotPoint(i,buffer2,buffer3,buffer1);  
   }
   
   // for (i=limit;i>=0;i--) {      
   //    if(buffer4[i] > buffer1[i] && buffer4[i+1] <= buffer1[i+1]) {ArrowUp[i] = 0.01;} else {ArrowUp[i] = EMPTY_VALUE;}
   //    if(buffer4[i] < buffer1[i] && buffer4[i+1] >= buffer1[i+1]) {ArrowDn[i] = -0.01;} else {ArrowDn[i] = EMPTY_VALUE;}
   // }

   

   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double iCTma(int useValue, int halfLength, int i)
{
   i = Bars-i-1;
   
   //
   //
   //
   //
   //
      
   double sum  = (halfLength+1)*work[i][useValue];
   double sumw = (halfLength+1);
 
      //
      //
      //
      //
      //
 
      int j,k = halfLength; 
      for(j=1; j<=halfLength; j++,k--)
      {
         sum  += k*work[i-j][useValue];
         sumw += k;
            int l = MathMin(j+i,Bars-1);
               sum  += k*work[l][useValue];
               sumw += k;
      }
   return(sum/sumw);      
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H2","150m","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,120,150,240,1440,10080,43200};

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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75943

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 