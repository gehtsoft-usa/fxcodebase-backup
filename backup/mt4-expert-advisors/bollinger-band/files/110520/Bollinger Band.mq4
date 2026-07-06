//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 26
#property indicator_color1 clrRed
#property indicator_color2 clrGreen


extern int Length1=20;
extern double Deviation1=1.;
extern int Method1=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price1=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
					   
					   
extern bool ShowLines= 1;

extern color UpUpBarColor = Green;
extern color DownUpBarColor = DarkGreen;
extern color UpNeutralBarColor = Gray;
extern color DownNeutralBarColor = DimGray;
extern color UpDownBarColor = Red;
extern color DownDownBarColor = Maroon;



double  U1[], L1[];


double High_0[], Low_0[], Open_0[], Close_0[];
double High_1[], Low_1[], Open_1[], Close_1[];
double High_2[], Low_2[], Open_2[], Close_2[];
double High_3[], Low_3[], Open_3[], Close_3[];
double High_4[], Low_4[], Open_4[], Close_4[];
double High_5[], Low_5[], Open_5[], Close_5[];


//int Initialization=0;

int init()
{
 IndicatorShortName("Bollinger Bands");
 IndicatorDigits(Digits);
 IndicatorBuffers(26);
 
  
 SetIndexBuffer(0,U1);
 SetIndexBuffer(1,L1);

 
  if (ShowLines == 1)
  {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
  }
  else
  {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
  }
 


 
   SetIndexBuffer(2,High_0);
   SetIndexBuffer(3,Low_0);
   SetIndexBuffer(4,Open_0);
   SetIndexBuffer(5,Close_0);
   
   SetIndexBuffer(6,High_1);
   SetIndexBuffer(7,Low_1);
   SetIndexBuffer(8,Open_1);
   SetIndexBuffer(9,Close_1);
   
   SetIndexBuffer(10,High_2);
   SetIndexBuffer(11,Low_2);
   SetIndexBuffer(12,Open_2);
   SetIndexBuffer(13,Close_2);
   
   SetIndexBuffer(14,High_3);
   SetIndexBuffer(15,Low_3);
   SetIndexBuffer(16,Open_3);
   SetIndexBuffer(17,Close_3);
   
   SetIndexBuffer(18,High_4);
   SetIndexBuffer(19,Low_4);
   SetIndexBuffer(20,Open_4);
   SetIndexBuffer(21,Close_4);
   
   SetIndexBuffer(22,High_5);
   SetIndexBuffer(23,Low_5);
   SetIndexBuffer(24,Open_5);
   SetIndexBuffer(25,Close_5);
   
    SetIndexStyle( 2, DRAW_HISTOGRAM, DRAW_LINE, 1, UpUpBarColor );
	SetIndexStyle( 3, DRAW_HISTOGRAM, DRAW_LINE, 1, UpUpBarColor );
	SetIndexStyle( 4, DRAW_HISTOGRAM, DRAW_LINE, 4, UpUpBarColor );
	SetIndexStyle( 5, DRAW_HISTOGRAM, DRAW_LINE, 4, UpUpBarColor );
	
	SetIndexStyle( 6, DRAW_HISTOGRAM, DRAW_LINE, 1, DownUpBarColor );
	SetIndexStyle( 7, DRAW_HISTOGRAM, DRAW_LINE, 1, DownUpBarColor );
	SetIndexStyle( 8, DRAW_HISTOGRAM, DRAW_LINE, 4, DownUpBarColor );
	SetIndexStyle( 9, DRAW_HISTOGRAM, DRAW_LINE, 4, DownUpBarColor );
	
	SetIndexStyle( 10, DRAW_HISTOGRAM, DRAW_LINE, 1, UpNeutralBarColor );
	SetIndexStyle( 11, DRAW_HISTOGRAM, DRAW_LINE, 1, UpNeutralBarColor );
	SetIndexStyle( 12, DRAW_HISTOGRAM, DRAW_LINE, 4, UpNeutralBarColor );
	SetIndexStyle( 13, DRAW_HISTOGRAM, DRAW_LINE, 4, UpNeutralBarColor );
	
	SetIndexStyle( 14, DRAW_HISTOGRAM, DRAW_LINE, 1, DownNeutralBarColor );
	SetIndexStyle( 15, DRAW_HISTOGRAM, DRAW_LINE, 1, DownNeutralBarColor );
	SetIndexStyle( 16, DRAW_HISTOGRAM, DRAW_LINE, 4, DownNeutralBarColor );
	SetIndexStyle( 17, DRAW_HISTOGRAM, DRAW_LINE, 4, DownNeutralBarColor );
   
 
   SetIndexStyle( 18, DRAW_HISTOGRAM, DRAW_LINE, 1, UpDownBarColor );
	SetIndexStyle( 19, DRAW_HISTOGRAM, DRAW_LINE, 1, UpDownBarColor );
	SetIndexStyle( 20, DRAW_HISTOGRAM, DRAW_LINE, 4, UpDownBarColor );
	SetIndexStyle( 21, DRAW_HISTOGRAM, DRAW_LINE, 4, UpDownBarColor );
	
	SetIndexStyle( 22, DRAW_HISTOGRAM, DRAW_LINE, 1, DownDownBarColor );
	SetIndexStyle( 23, DRAW_HISTOGRAM, DRAW_LINE, 1, DownDownBarColor );
	SetIndexStyle( 24, DRAW_HISTOGRAM, DRAW_LINE, 4, DownDownBarColor );
	SetIndexStyle( 25, DRAW_HISTOGRAM, DRAW_LINE, 4, DownDownBarColor );
 
 return(0);
}



int deinit()
{

 return(0);
}

int start()
{


 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 { 

  U1[pos]=iBands(NULL,0,Length1,Deviation1,0,Price1,1,pos); // 1 
  L1[pos]=iBands(NULL,0,Length1,Deviation1,0,Price1,2,pos); // 2  
 
 
   if  ( Close[pos]> U1[pos]  )
   {
   
      if (Close[pos]> Open[pos])
	  {
      High_0[pos]  = iHigh(NULL,0,pos);
      Low_0[pos]   = iLow(NULL,0,pos);
      Open_0[pos]  = iOpen(NULL,0,pos);
      Close_0[pos] = iClose(NULL,0,pos);
	  }
	  else
	  {
	  High_1[pos]  = iHigh(NULL,0,pos);
      Low_1[pos]   = iLow(NULL,0,pos);
      Open_1[pos]  = iOpen(NULL,0,pos);
      Close_1[pos] = iClose(NULL,0,pos);
	  }
     
	 }
	 
	  else if (Close[pos]< L1[pos] )
	  { 
		   if (Close[pos]> Open[pos])
		  {
		  High_4[pos]  = iHigh(NULL,0,pos);
		  Low_4[pos]   = iLow(NULL,0,pos);
		  Open_4[pos]  = iOpen(NULL,0,pos);
		  Close_4[pos] = iClose(NULL,0,pos);
		  }
		  else
		  {
		  High_5[pos]  = iHigh(NULL,0,pos);
		  Low_5[pos]   = iLow(NULL,0,pos);
		  Open_5[pos]  = iOpen(NULL,0,pos);
		  Close_5[pos] = iClose(NULL,0,pos);
		  }
      }
	  
	  else
	  
	  {
	          if (Close[pos]> Open[pos])
		  {
		  High_2[pos]  = iHigh(NULL,0,pos);
		  Low_2[pos]   = iLow(NULL,0,pos);
		  Open_2[pos]  = iOpen(NULL,0,pos);
		  Close_2[pos] = iClose(NULL,0,pos);
		  }
		  else
		  {
		  High_3[pos]  = iHigh(NULL,0,pos);
		  Low_3[pos]   = iLow(NULL,0,pos);
		  Open_3[pos]  = iOpen(NULL,0,pos);
		  Close_3[pos] = iClose(NULL,0,pos);
		  }
		  
		  
	  
	  }
	  
	  
    
   pos--;
 } 
 
 
     
 
	 
 
 return(0);
}

