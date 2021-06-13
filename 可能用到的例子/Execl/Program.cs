using NPOI.HSSF.UserModel;
using System.IO;

namespace Test1
{
    class Program
    {
        static void Main(string[] args)
        {
            WriteFileToExecl();
        }

        static void WriteFileToExecl()
        {
            var targetExeclPath = "D:\\Test.xlsx";//要写入的Execl的路径
            var workbook = new HSSFWorkbook();//用Execl文件创建一个Execl对象
            var sheet = workbook.CreateSheet("FirstSheet");//获取第一个工作簿
            
            for (int i = 0; i < 5; i++)
            {
                var row = sheet.CreateRow(i);//创建行
                for (int j = 0; j < 5; j++)
                {
                    row.CreateCell(j).SetCellValue(j.ToString());//创建单元格并写入数据
                }
            }

            if (File.Exists(targetExeclPath)) File.Delete(targetExeclPath);
            using var fs = File.Open(targetExeclPath, FileMode.CreateNew, FileAccess.ReadWrite);//将Execl以文件流的形式写入
            workbook.Write(fs);
            workbook.Close();
            //导出以后的文件虽然后缀名是Execl格式的，但是并不是一个Execl，打开时会报错，解决办法是修改其后缀
        }
    }
}
