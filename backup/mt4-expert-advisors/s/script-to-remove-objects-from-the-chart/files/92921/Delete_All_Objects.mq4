//+------------------------------------------------------------------+
//|                                           Delete_All_Objects.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property show_inputs

extern bool Delete_From_All_Subwindows=false;

int start()
{
 if (Delete_From_All_Subwindows)
 {
  int i;
  for (i=0;i<WindowsTotal();i++)
  {
   ObjectsDeleteAll(i);
  }
 }
 else
 {
  ObjectsDeleteAll(0);
 }

 return(0);
}

