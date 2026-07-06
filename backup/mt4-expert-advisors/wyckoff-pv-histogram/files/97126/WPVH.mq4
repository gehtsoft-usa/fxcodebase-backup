//+------------------------------------------------------------------+
//|                                                         WPVH.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Short_Length=5;
extern int Long_Length=15;
extern bool Show_Histogram=false;

double Short[], Long[], Hist[];
double H[];

int init()
{
 IndicatorShortName("Wyckoff PV Histogram");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Short);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Long);
 if (Show_Histogram)
 {
  SetIndexStyle(2,DRAW_HISTOGRAM);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
 } 
 SetIndexBuffer(2,Hist);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,H);

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
 bool UDPC, UDNC, DDPC, DDNC, HVWS, HVNS, LVWS, LVNS;
 pos=limit;
 while(pos>=0)
 {
   if (Close[pos]>=((High[pos]-Low[pos])/2.+Low[pos]) && Close[pos]>Close[pos+1])
	{
	 UDPC= true;
	} 
	else
	{
	 UDPC= false;
	} 
	
	if (Close[pos]<((High[pos]-Low[pos])/2.+Low[pos]) && Close[pos]>Close[pos+1])
	{
	 UDNC= true;
	} 
	else
	{
	 UDNC= false;
	} 
	
	if (Close[pos]>=((High[pos]-Low[pos])/2.+Low[pos]) && Close[pos]<Close[pos+1])
	{
	 DDPC= true;
	} 
	else
	{
	 DDPC= false;
	} 
	
	if (Close[pos]<((High[pos]-Low[pos])/2.+Low[pos]) && Close[pos]<Close[pos+1])
	{
	 DDNC= true;
	} 
	else
	{
	 DDNC= false;
	} 
	
	if ((High[pos]-Low[pos])>=(High[pos+1]-Low[pos+1]) && Volume[pos]>Volume[pos+1])
	{
	 HVWS= true;
	} 
	else
	{
	 HVWS= false;
	} 
	
   if ((High[pos]-Low[pos])<(High[pos+1]-Low[pos+1]) && Volume[pos]>Volume[pos+1])
   {
	 HVNS= true;
	} 
	else
	{
	 HVNS= false;
	} 
	
	if ((High[pos]-Low[pos])>=(High[pos+1]-Low[pos+1]) && Volume[pos]<Volume[pos+1])
	{
	 LVWS= true;
	} 
	else
	{
	 LVWS= false;
	} 
	
	if ((High[pos]-Low[pos])<(High[pos+1]-Low[pos+1]) && Volume[pos]<Volume[pos+1])
	{
	 LVNS= true;
	} 
	else
	{
	 LVNS= false;
	} 
	
   if (UDPC && LVWS)
   {
    H[pos]=8.;
   }
   else
   {
	 if (UDPC && HVWS) 
	 {
	  H[pos]=7.; 
	 }
	 else
	 { 
	  if (UDPC && HVNS)
	  {
	   H[pos]=6.; 
	  }
	  else
	  { 
	   if (UDPC && LVNS)
	   {
	    H[pos]=5.; 
	   }
	   else
	   { 
	    if (UDNC && LVWS)
	    {
	     H[pos]=4.; 
	    }
	    else
	    { 
	     if (UDNC && HVWS)
	     {
	      H[pos]=3.; 
	     }
	     else
	     { 
	      if (UDNC && HVNS)
	      {
	       H[pos]=2.; 
	      }
	      else
	      { 
	       if (UDNC && LVNS)
	       {
	        H[pos]=1.; 
	       }
	       else
	       {
	        if (DDPC && LVNS)
	        {
	         H[pos]=-1.; 
	        }
	        else
	        { 
	         if (DDPC && HVNS)
	         {
	          H[pos]=-2.; 
	         }
	         else
	         { 
	          if (DDPC && HVWS)
	          {
	           H[pos]=-3.; 
	          }
	          else
	          { 
	           if (DDPC && LVWS)
	           {
	            H[pos]=-4.; 
	           }
	           else
	           { 
	            if (DDNC && LVNS)
	            {
	             H[pos]=-5.; 
	            }
	            else
	            { 
	             if (DDNC && HVNS)
	             {
	              H[pos]=-6.; 
	             }
	             else
	             { 
	              if (DDNC && HVWS)
	              {
	               H[pos]=-7.; 
	              }
	              else
	              { 
	               if (DDNC && LVWS)
	               {
	                H[pos]=-8.;
	               }
	               else
	               {
	                H[pos]=0.;
	               } 
	              }
	             }
	            }
	           }
	          }     
	         }
	        }
	       }
	      }
	     }
	    }
	   }
	  }
	 }
   }                

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Long[pos]=iMAOnArray(H, 0, Long_Length, 0, MODE_SMA, pos);
  Short[pos]=iMAOnArray(H, 0, Short_Length, 0, MODE_SMA, pos);
  Hist[pos]=H[pos]-H[pos+1];

  pos--;
 }
   
 return(0);
}

