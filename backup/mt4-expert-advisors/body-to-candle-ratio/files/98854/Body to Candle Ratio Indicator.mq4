//+------------------------------------------------------------------+
//|                               Body to Candle Ratio Indicator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red 
extern int Mode=0;  
extern int Length=14; 

double Ratio[];
double U[], D[]; 

int init()
  {
   IndicatorShortName("Body to Candle Ratio Indicator");
   IndicatorDigits(Digits);
     
    IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexBuffer(0,U);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexBuffer(1,D);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Ratio); 
 
 
   if(! (Mode >= 0 && Mode <= 1  )  ) 
   {
   Alert("Permitted Modes are 0 and 1");

   return(-1);
   }
 
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
 int pos=limit;
 while(pos>=0)
 { 
 
     
      Ratio[pos]=(Close[pos]-Low[pos])/(High[pos]-Low[pos]);
	  
	  
	  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 { 
 
    if (Mode == 0 )
	{
      if ( Ratio[pos] > 0.5)
	   {
		U[pos]=High[pos];
	   }
	    if ( Ratio[pos] < 0.5)
	   {
		D[pos]=Low[pos];
	   }
    }
	
	else
	
	{
	  double MA = iMAOnArray( Ratio, 0, Length, 0, MODE_SMA, pos);
	  
	  if (Ratio[pos] > MA )
	  {
	  U[pos]=High[pos];
	  }
	  else
	  {
	  D[pos]=Low[pos];
	  }
  	}

	
	  pos--;
 } 
 

 return(0);
}

