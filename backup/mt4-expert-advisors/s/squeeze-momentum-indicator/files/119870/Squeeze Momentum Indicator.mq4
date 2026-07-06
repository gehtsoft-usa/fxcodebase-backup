
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66250

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

#property indicator_width1 5
#property indicator_width2 5

extern int Length=20;
 

double Raw[];
double LRL[];

double UP[];
double DN[];

double local_ex_up[];
double local_ex_dn[];

double close_local_up[];
double close_local_dn[];
int init()
{
 IndicatorShortName("Squeeze Momentum Indicator");
 IndicatorBuffers(8);
 IndicatorDigits(Digits);
 
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Raw);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,LRL);
 
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,local_ex_up);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,local_ex_dn);
 
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,close_local_up);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,close_local_dn);
 

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 double x, y, xy, x2;
 double MA_Data;
 double Median_Data;
 int i;
 double Temp, m, yint;
 pos=limit;
 while(pos>=0)
 {
  MA_Data= iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  Median_Data=(High[pos]+Low[pos])/2;
  Raw[pos]=Close[pos]-( (Median_Data +MA_Data)/2);
  pos--;
 }
 
 
 
  
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Length;i++)
  {
   y=y+Raw[pos+i];
   xy=xy+Raw[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Length*x2-x*x;
  m=(Length*xy-x*y)/Temp;
  yint=(y+m*x)/Length;
  LRL[pos]=yint-m*Length;
  pos--;
 } 
 
 
 bool dn_sg = false;
 bool dn_sg_custom  = false;
 bool up_sg  = false;
 bool up_sg_custom = false;
 
 
  pos=limit;
 while(pos>=0)
 {
 
 
    if((LRL[pos]>0) && (LRL[pos]<LRL[pos+1]) && (LRL[pos+1]>LRL[pos+2]))
	{ 
	local_ex_up[pos]= LRL[pos];
	}
	else
	{
	local_ex_up[pos]=local_ex_up[pos+1];
    }	
	
	
     if ((LRL[pos]>0)  && (LRL[pos]<LRL[pos+1])  && (LRL[pos+1]>LRL[pos+2]))
	 {
	 close_local_up[pos]=Close[pos];
	 }
	 else
	 {
	 close_local_up[pos]=close_local_up[pos+1];
	 }
 
     if ( (LRL[pos]<0)  && (LRL[pos]>LRL[pos+1])  && (LRL[pos+1]<LRL[pos+2])  )
	 {
	 local_ex_dn[pos]=LRL[pos];
	 }
	 else
	 {
	 local_ex_dn[pos]=local_ex_dn[pos+1];
	 }
 
     if ((LRL[pos]<0)  && (LRL[pos]>LRL[pos+1])  && (LRL[pos+1]<LRL[pos+2]) ) 
	 {
	 close_local_dn[pos]=Close[pos];
	 }
	 else
	 {
	 close_local_dn[pos]=close_local_dn[pos+1]; 
	 }
	
	
	if ((close_local_up[pos]>close_local_up[pos+1])  && (local_ex_up[pos+1]>local_ex_up[pos]))  
	{
	dn_sg=true;
	}
	else
	{
	dn_sg=false;
	}
	
	
    if ((close_local_dn[pos]>close_local_dn[pos+1])  && (local_ex_dn[pos+1]>local_ex_dn[pos]) ) 
	{
	dn_sg_custom=true;
	}
	else
	{
	dn_sg_custom=false;
	}
	
     if ((close_local_dn[pos]<close_local_dn[pos+1])  && (local_ex_dn[pos+1]<local_ex_dn[pos]))  
	{
	up_sg=true;
     }
	 else
	 {
	 up_sg=false;
	}
     
	 if ((close_local_up[pos]<close_local_up[pos+1])  && (local_ex_up[pos+1]<local_ex_up[pos]))
	 {
	 up_sg_custom=true;
	 }
	 else
	 {
	 up_sg_custom=false;
	 }
   
   
   if (( dn_sg || dn_sg_custom || up_sg || up_sg_custom ) && (LRL[pos] > LRL[pos+1]))
   {
   UP[pos]=1;   
   }
   else
   {
   UP[pos]=0;  
   }
   
   
   if (( dn_sg || dn_sg_custom || up_sg || up_sg_custom ) && (LRL[pos] < LRL[pos+1]))
   {
   DN[pos]=1;   
   }
   else
   {
   DN[pos]=0;
   }
   
   
  pos--;
 } 
 
 
 


 return(0);
}

