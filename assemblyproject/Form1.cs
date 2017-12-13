using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Runtime.InteropServices;
using System.Reflection;

namespace assemblyproject
{
    public partial class Form1 : Form
    {
        
        Image img = null;
        Bitmap bi;
        string rbgFilePath;
        public Form1()
        {
            InitializeComponent();
            
        }
        string convertFromNumber(int num, int cnt)
        {
            string sNum = num.ToString();
            while (sNum.Length != cnt)
            {
                sNum = sNum.Insert(0, "0");
            }
            return sNum;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            OpenFileDialog choofdlog = new OpenFileDialog();
            choofdlog.Filter = "All Files (*.jpg)|*.jpg";
            choofdlog.FilterIndex = 1;
            choofdlog.Multiselect = false;
            string sFileName = "" ; 
            if (choofdlog.ShowDialog() == DialogResult.OK)
            {
                sFileName = choofdlog.FileName;
                img = Image.FromFile(sFileName); 
                pictureBox1.Image = img;
                bi = new Bitmap(pictureBox1.Image);
            }
        }
        public static byte[] ImageToByte(Image img)
        {
            ImageConverter converter = new ImageConverter();
            return (byte[])converter.ConvertTo(img, typeof(byte[]));
        }

        public static Image ByteToImage(byte[] bytes)
        {
            MemoryStream ms = new MemoryStream(bytes);
            return Image.FromStream(ms);
        }
        

        private void button3_Click(object sender, EventArgs e)
        {

            OpenFileDialog choofdlog = new OpenFileDialog();
            choofdlog.Filter = "All Files (*.txt)|*.txt";
            choofdlog.FilterIndex = 1;
            choofdlog.Multiselect = false;
            string sFileName = "";
            if (choofdlog.ShowDialog() == DialogResult.OK)
            {
                sFileName = choofdlog.FileName;
                rbgFilePath = sFileName;
                FileStream fs = new FileStream(sFileName, FileMode.OpenOrCreate);
                StreamReader sr = new StreamReader(fs);
                int height, width;
                if (sr.Peek() != -1)
                    height = int.Parse(sr.ReadLine());
                else return;
                if (sr.Peek() != -1)
                    width = int.Parse(sr.ReadLine());
                else return;

                bi = new Bitmap(width,height,PixelFormat.Format24bppRgb); 
                for (int i = 0; i < height; i++ )
                {
                    for ( int j = 0 ; j < width ; j++ )
                    {
                        int r = int.Parse(sr.ReadLine());
                        int g = int.Parse(sr.ReadLine());
                        int b = int.Parse(sr.ReadLine());
                        Color c = Color.FromArgb(r,g,b);
                        bi.SetPixel(j,i, c); 
                    }
                }
                sr.Close();
                fs.Close();

                img = bi;
                pictureBox1.Image = img;

            }

        }

     
        private void button4_Click(object sender, EventArgs e)
        {
            if (img == null) return;
            SaveFileDialog choofdlog = new SaveFileDialog(); 
            choofdlog.Filter = "All Files (*.jpg)|*.jpg";
            choofdlog.FilterIndex = 1;
            choofdlog.ShowDialog();

            if (choofdlog.FileName != "")
            {
                img.Save(choofdlog.FileName, ImageFormat.Bmp);
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (img == null) return; 
            SaveFileDialog choofdlog = new SaveFileDialog(); 
            choofdlog.Filter = "All Files (*.txt)|*.txt";
            choofdlog.FilterIndex = 1;
            string sFileName = "";
            choofdlog.ShowDialog();

            if (choofdlog.FileName != "")
            {
                sFileName = choofdlog.FileName;
                rbgFilePath = sFileName;
                bi = new Bitmap(img);
                
                FileStream fsRGB = new FileStream(sFileName, FileMode.Create);
                StreamWriter swRGB = new StreamWriter(fsRGB);

                swRGB.WriteLine(convertFromNumber(bi.Height, 4));
                swRGB.WriteLine(convertFromNumber(bi.Width, 4));

                for (int i = 0; i < bi.Height; i++)
                {
                    for (int j = 0; j < bi.Width; j++)
                    {
                        Color c = bi.GetPixel(j, i);
                        swRGB.WriteLine(convertFromNumber((int)c.R, 3));
                        swRGB.WriteLine(convertFromNumber((int)c.G, 3));
                        swRGB.WriteLine(convertFromNumber((int)c.B, 3));
                    }
                }
                swRGB.Close();
                fsRGB.Close();

            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (rbgFilePath == null || rbgFilePath == "")
            {
                MessageBox.Show("You Need To Load/save RBG file to Ecrypt or decrypt Image!");
                return;
            }
            Wrapper.outPutFileCreation();
            Wrapper.SetFileName(rbgFilePath);
            Wrapper.setMessage(textBox1.Text);

            if (checkBox1.Checked)
                Wrapper.setKey(textBox2.Text[0]);

            Wrapper.OpenFileIn(checkBox1.Checked);
            Wrapper.CloseOutPutFile();
            
        }

        private void button6_Click(object sender, EventArgs e)
        {
            if (rbgFilePath == null || rbgFilePath == "")
            {
                MessageBox.Show("You Need To Load/save RBG file to Ecrypt or decrypt Image!");
                return;
            }
            Wrapper.SetFileName(rbgFilePath);
            if (checkBox1.Checked)
                textBox3.Text = Wrapper.OpenFileDec(true, textBox2.Text[0]);
            else
                textBox3.Text = Wrapper.OpenFileDec(false, '\0');
        }
    }
}
