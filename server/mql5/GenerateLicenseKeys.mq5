//+------------------------------------------------------------------+
//|                                          GenerateLicenseCode.mq5 |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"

//--- includes
#include <DS\LicenseCode\LicenseCode.mqh>

//--- global variables
CLicenseCode LicenseCode;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   string strLifetime = "Key for Lifetime: "+LicenseCode.GenerateSalt();
   string strLimited = "Key for Limited: "+LicenseCode.GenerateSalt(true);
   
   CreateObjEdit("1", 100, 16, strLifetime);
   CreateObjEdit("2", 100, 58, strLimited);
   
   Print(strLifetime);
   Print(strLimited);
}

void CreateObjEdit(const string name, const int x, const int y, const string text)
{
   long chartID = ChartID();
   string objName = "LicenseKeys"+name;
   
   ObjectCreate(chartID, objName, OBJ_EDIT, 0, 0, 0);
   //---
   ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chartID, objName, OBJPROP_XSIZE, 400);
   ObjectSetInteger(chartID, objName, OBJPROP_YSIZE, 40);
   ObjectSetString(chartID, objName, OBJPROP_TEXT, text);
   // ObjectSetInteger(chartID, objName, OBJPROP_ALIGN, align);
}

//+------------------------------------------------------------------+
