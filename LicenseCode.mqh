//+------------------------------------------------------------------+
//|                                                  LicenseCode.mqh |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property strict

enum ENUM_LICENSE_CODE_TYPE
{
   LCT_1 = 1,
   LCT_2 = 2
};

//+------------------------------------------------------------------+
//| License Code                                                     |
//+------------------------------------------------------------------+
class CLicenseCode
{
   private:
      string                  m_LicenseCode;
      string                  m_SaltMd5;
      string                  m_SaltAes32Bit;
      //---
      ENUM_LICENSE_CODE_TYPE  m_LicenseType;
      int                     m_LicenseStatus;
      datetime                m_LicenseTime;
      //---
      int                     m_CheckDay;
      
      bool                    CheckLct1(const int accountLogin);
      bool                    CheckLct2(const int accountLogin);
   
   public:
                              CLicenseCode(void);
                             ~CLicenseCode(void);
      //---
      void                    Init(const string licenseCode, const string saltMd5);
      void                    Init(const string licenseCode, const string saltMd5, const string saltAes32Bit);
      bool                    CheckLicense();
      int                     GetLicenseStatus() { return m_LicenseStatus; };
      datetime                GetLicenseTime()   { return m_LicenseTime;   };
      //--- Generate
      string                  GenerateLicenseCode(const int accountLogin, const string saltMd5);
      string                  GenerateLicenseCode(const int accountLogin, const string saltMd5, const string saltAes32Bit, const datetime timeUntil);
      //--- CRYPT
      string                  Md5(const string str);
      string                  Aes256Decode(const string base64, const string key);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CLicenseCode::CLicenseCode(void): m_LicenseStatus(0)
{}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CLicenseCode::~CLicenseCode(void)
{}

//+------------------------------------------------------------------+
//| Initialize (for MD5 hash)                                        |
//+------------------------------------------------------------------+
void CLicenseCode::Init(const string licenseCode, const string saltMd5)
{
   m_LicenseType = LCT_1;
   Init(licenseCode, saltMd5, "");
}

//+------------------------------------------------------------------+
//| Initialize (for AES-256 crypt)                                   |
//+------------------------------------------------------------------+
void CLicenseCode::Init(const string licenseCode, const string saltMd5, const string saltAes32Bit)
{
   m_SaltMd5 = saltMd5;
   m_SaltAes32Bit = saltAes32Bit;
   m_LicenseCode = licenseCode;
   //---
   m_LicenseStatus = 0;
   m_CheckDay = Day();
   //---
   if (m_LicenseType != LCT_1)
      m_LicenseType = LCT_2;
}

//+------------------------------------------------------------------+
//| Check License code                                               |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLicense()
{
   if (m_LicenseStatus == 1)
   {
      if (m_CheckDay == Day())
         return true;
      else
         m_CheckDay = 0;
   }
   else if (m_LicenseStatus == -1)
      return false;
   
   if (StringLen(m_LicenseCode) < 8 || StringLen(m_SaltMd5) < 1)
   {
      m_LicenseStatus = -1;
      return false;
   }
   
   if (! TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   int accountLogin = (int)AccountInfoInteger(ACCOUNT_LOGIN);
   if (accountLogin < 1)
      return false;
   
   //--- check license
   m_LicenseStatus = -1;
   
   switch (m_LicenseType)
   {
      case LCT_1:
         if (! CheckLct1(accountLogin))
            return false;
         break;
      
      case LCT_2:
         if (! CheckLct2(accountLogin))
            return false;
         break;
      
      default: return false;
   }
   
   m_LicenseStatus = 1;
   return true;
}

//+------------------------------------------------------------------+
//| Check LicenseCode Type-1                                         |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLct1(const int accountLogin)
{
   string code = m_SaltMd5 + string(accountLogin);
   
   return (StringCompare(Md5(code), m_LicenseCode, true) == 0);
}

//+------------------------------------------------------------------+
//| Check LicenseCode Type-2                                         |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLct2(const int accountLogin)
{
   //--- Decode and parse license
   string licenseDecode = Aes256Decode(m_LicenseCode, m_SaltAes32Bit);
   
   if (StringLen(licenseDecode) != 42)
      return false;
   
   string md5Hash = StringSubstr(licenseDecode, 0, 32);
   string timeStr = StringSubstr(licenseDecode, 32);
   
   //--- Check time
   string checkCode = m_SaltMd5 + string(accountLogin) + timeStr;
   
   if (StringCompare(Md5(checkCode), md5Hash, true) != 0)
      return false;
   
   m_LicenseTime = (datetime)timeStr;
   
   return (m_LicenseTime > TimeCurrent());
}

//+------------------------------------------------------------------+
//| Generate License code (for MD5 hash)                             |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateLicenseCode(const int accountLogin, const string saltMd5)
{
   string code = saltMd5 + string(accountLogin);
   
   return Md5(code);
}

//+------------------------------------------------------------------+
//| Generate License code (for AES-256 crypt)                        |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateLicenseCode(const int accountLogin, const string saltMd5, const string saltAes32Bit, const datetime timeUntil)
{
   string timeStr = string(int(timeUntil));
   string code = saltMd5 + string(accountLogin) + timeStr;
   code = Md5(code) + string(timeUntil);
   
   uchar src[], keyAes[], dstAes[], dstBase64[];
   const uchar keyBase64[] = {};
   
   StringToCharArray(code, src, 0, StringLen(code));
   StringToCharArray(saltAes32Bit, keyAes, 0, StringLen(saltAes32Bit));
   
   if (CryptEncode(CRYPT_AES256, src, keyAes, dstAes) > 0 &&
       CryptEncode(CRYPT_BASE64, dstAes, keyBase64, dstBase64) > 0)
   {
      return CharArrayToString(dstBase64);
   }
   
   return "";
}

//+------------------------------------------------------------------+
//| MD5                                                              |
//+------------------------------------------------------------------+
string CLicenseCode::Md5(const string str)
{
   if (StringLen(str) == 0)
      return "D41D8CD98F00B204E9800998ECF8427E"; // empty md5
 
   string res = "";
   uchar src[], dst[];
   const uchar key[] = {};
   
   StringToCharArray(str, src, 0, StringLen(str));
   
   if (CryptEncode(CRYPT_HASH_MD5, src, key, dst) <= 0)
      return res;
   
   int cnt = ArraySize(dst);
   for (int i=0; i<cnt; i++)
      res += StringFormat("%.2X", dst[i]);

   return res;
}

//+------------------------------------------------------------------+
//| AES-256-ECB decode                                               |
//+------------------------------------------------------------------+
string CLicenseCode::Aes256Decode(const string base64, const string key)
{
   uchar src[], keyAes[], dstBase64[], dstAes[];
   const uchar keyEmpty[] = {};
   
   StringToCharArray(base64, src, 0, StringLen(base64));
   StringToCharArray(key, keyAes, 0, StringLen(key));
   
   if (CryptDecode(CRYPT_BASE64, src, keyEmpty, dstBase64) > 0 &&
       CryptDecode(CRYPT_AES256, dstBase64, keyAes, dstAes) > 0)
   {
      // check 16 bit
      int dstAesCnt = ArraySize(dstAes);
      uchar dstAesEnd = dstAes[dstAesCnt-1];
      
      if (dstAesEnd == 0)
      {
         int i;
         for (i=dstAesCnt-1; i>=0; i--)
         {
            if (dstAes[i] != 0)
               break;
         }
         if (i < (dstAesCnt-1) && ArrayResize(dstAes, i+1) <= 0)
            return "";
      }
      else if (dstAesEnd <= 16)
      {
         if (dstAesCnt <= dstAesEnd || (dstAes[dstAesCnt-dstAesEnd] == dstAesEnd && ArrayResize(dstAes, dstAesCnt-dstAesEnd) <= 0))
            return "";
      }
      
      //--- result
      return CharArrayToString(dstAes);
   }
   
   return "";
}

//+------------------------------------------------------------------+
