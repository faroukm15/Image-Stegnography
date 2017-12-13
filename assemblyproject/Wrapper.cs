using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace assemblyproject
{
    class Wrapper
    {
        [DllImport(@"Project.dll")]
        private static extern void MovMsgToEcx();

        [DllImport(@"Project.dll")]
        private static extern void MovDecMsgToEcx();

        [DllImport(@"Project.dll")]
        public static extern void EncryptMsg();
        
        [DllImport(@"Project.dll")]
        public static extern void outPutFileCreation();

        [DllImport(@"Project.dll")]
        public static extern void PrintDecMsg(ref byte arr);

        [DllImport(@"Project.dll")]
        public static extern void WriteHeaderToOutput();

        [DllImport(@"Project.dll")]
        private static extern void GetName(ref byte StringArr);

        [DllImport(@"Project.dll")]
        private static extern void OpenFile();

        [DllImport(@"Project.dll")]
        private static extern void ReadHeader();

        [DllImport(@"Project.dll")]
        private static extern void EscapeHeader();

        [DllImport(@"Project.dll")]
        private static extern void ReadWhole();

        [DllImport(@"Project.dll")]
        private static extern void CloseFilex();

        [DllImport(@"Project.dll")]
        private static extern void GetMsgKey(ref byte msg);

        [DllImport(@"Project.dll")]
        private static extern void EncBuffer();

        [DllImport(@"Project.dll")]
        private static extern void WriteFilex();

        [DllImport(@"Project.dll")]
        private static extern void DecBuffer();

        [DllImport(@"Project.dll")]
        public static extern void CloseOutPutFile();

        [DllImport(@"Project.dll")]
        public static extern void GetMsg(ref byte arr);
        [DllImport(@"Project.dll")]
        public static extern void getKey(ref byte arr);

        public static void SetFileName(string s)
        {
            List<byte> AsciiArr = Encoding.ASCII.GetBytes(s).ToList();
            AsciiArr.Add(0);
            byte[] Arr = AsciiArr.ToArray();
            GetName(ref Arr[0]);
        }

        public static void setMessage(string txt)
        {
            List<Byte> msgList = Encoding.ASCII.GetBytes(txt).ToList();
            msgList.Add(0);   
            byte[] msg = msgList.ToArray();
            GetMsg(ref msg[0]);
        }

        public static void setKey(char c)
        {
            byte key = Encoding.ASCII.GetBytes(new string(c, 1))[0];
            getKey(ref key);
        }

        public static bool OpenFileIn(bool Encrypted)
        {
            OpenFile();
            ReadHeader();
            WriteHeaderToOutput();

            if (Encrypted)
            {
                MovMsgToEcx();
                //EncryptMsg();
            }
                

            EncBuffer();
            WriteFilex();
            CloseFilex();
            return true;   
        }


        public static string OpenFileDec(bool Encrypted, char c)
        {
            OpenFile();
            ReadHeader();
            DecBuffer();

            if (Encrypted)
            {
                setKey(c);
                MovDecMsgToEcx();
                //EncryptMsg();
            }
            
            string result = "";
            byte[] arr = new byte[1002];
            
            PrintDecMsg(ref arr[0]);
            result = Encoding.ASCII.GetString(arr);

            CloseFilex();
            return result;
        }

        public static void Encrypt()
        {
            EncBuffer();
            WriteFilex();
        }
    }
}