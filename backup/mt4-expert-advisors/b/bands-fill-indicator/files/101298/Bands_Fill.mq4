//+------------------------------------------------------------------+
//|                                                  Bands_Fill.mq4  |
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
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Black
#property indicator_color3 Green
#property indicator_color4 Black
#property indicator_color5 Yellow
#property indicator_color6 Yellow

#property indicator_width1 64
#property indicator_width2 64
#property indicator_width3 64
#property indicator_width4 64
#property indicator_width5 2
#property indicator_width6 2

extern int       per=20;
extern int       dev=2;
 

double buffer1[];
double buffer2[];

double buffer3[];
double buffer4[];

double buffer5[];
double buffer6[]; 
double Trigger[];
 

int init()
{
   
   IndicatorBuffers(7);
    
   SetIndexBuffer(0,buffer1);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   
   SetIndexBuffer(1,buffer2);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   
    SetIndexBuffer(2,buffer3); 
   SetIndexStyle(2,DRAW_HISTOGRAM);
   
   SetIndexBuffer(3,buffer4); 
   SetIndexStyle(3,DRAW_HISTOGRAM);
 
   SetIndexBuffer(4,buffer5);
   SetIndexStyle(4,DRAW_LINE);
   
   SetIndexBuffer(5,buffer6);
   SetIndexStyle(5,DRAW_LINE);
   
   SetIndexBuffer(6,Trigger);
   SetIndexStyle(6,DRAW_NONE);
   
   
   return(0);
}
int deinit()
{
   return(0);
}

  

int start()
{
   int counted_bars=IndicatorCounted();
   int limit,i;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=Bars-counted_bars;

 

   for(i=limit; i>=0; i--)
   {
    
	 Trigger[i]=Trigger[i+1];
	 
    if (Trigger[i]==1  && Close[i]<  iBands(NULL,0,per,dev,0,PRICE_CLOSE,0,i))
    {
	Trigger[i]=0;
	}
  
	 if (Trigger[i]==-1 && Close[i]>  iBands(NULL,0,per,dev,0,PRICE_CLOSE,0,i))
	 {
     Trigger[i]=0;
      }	 
  
	
    if (Close[i]>=iBands(NULL,0,per,dev,0,PRICE_CLOSE,1,i) )  
    {	
	Trigger[i]=1;
	}
 
		 if (Close[i]<=iBands(NULL,0,per,dev,0,PRICE_CLOSE,2,i))
		 {
		 Trigger[i]=-1;
		 }	 
    
		  
		
         if (Trigger[i]==1 ) 
		  {
		  buffer1[i] =  iBands(NULL,0,per,dev,0,PRICE_CLOSE,1,i); 
		  buffer2[i] = iBands(NULL,0,per,dev,0,PRICE_CLOSE,2,i);
		   }
		  
		  if (Trigger[i]==-1) 
		  {
		  buffer3[i] =  iBands(NULL,0,per,dev,0,PRICE_CLOSE,1,i); 
		  buffer4[i] = iBands(NULL,0,per,dev,0,PRICE_CLOSE,2,i);
		  }
		  
		  
	      buffer5[i] = iBands(NULL,0,per,dev,0,PRICE_CLOSE,1,i);
		  buffer6[i] = iBands(NULL,0,per,dev,0,PRICE_CLOSE,2,i);
		  
   }
	   
	   
 
	 
   return(0);
}

