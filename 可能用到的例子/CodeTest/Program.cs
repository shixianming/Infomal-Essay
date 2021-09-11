#region 字符串处理测试
//int a = 1000;
//char c = 'a';
//1.字符串格式化拼接时装箱测试
//装箱2.0KB string.format 8.6KB
//string str1 = $"Hello{a}World";//10.5KB  0.90ms
//无装箱 int.tostring 3.3KB string.concact 5.3KB
//string str2 = $"Hello{a.ToString()}World";//8.6KB 0.60ms
//无装箱 int.tostring 3.3KB string.concact 5.3KB
//string str3 = "Hello" + a.ToString() + "World";//8.6KB 0.63ms

//2.字符拼接时是否会产生ToString测试
//装箱3.7KB string.format 11.5KB(int.tostring 3.3KB char.tostring 2.7KB)
//string str4 = $"Hello{a}{c}World";//15.2KB 0.98ms
//无装箱 int.tostring 3.3KB char.tostring 2.7KB string.concat 5.5KB
//string str5 = $"Hello{a.ToString()}{c.ToString()}World";//11.5KB 0.76ms
//无装箱 int.tostring 3.3KB char.tostring 2.7KB string.concat 5.5KB
//string str6 = "Hello" + a.ToString() + c + "World";//11.5KB 0.71ms

//3.字符串ToString写法测试
//装箱2.3KB string.format 52.2KB
//string str7 = $"{DateTime.Now}";//54.5KB 9.38ms
//装箱2.3KB string.format 37.7KB 
//string str8 = $"{DateTime.Now:00}";//40.0KB 6.14ms
//无装箱 datetime.tostring 10.0KB
//string str9 = DateTime.Now.ToString("00");//10.0KB 5.53ms

//4.字符串拼接和StringBuilder测试
//装箱 5.7KB string.format 15.6KB
//string str10 = $"Hello{a}{c}{a}World";//21.3KB 1.48ms
//gc 7.0KB int.tostring 6.6KB char.tostring 2.7KB string.concat 13.3KB(参数个数过多，调用的是string.concat(params String[] Values))会有字符串数组的gc分配
//string str11 = "Hello" + a.ToString() + c.ToString() + a.ToString() + "World";//29.7KB;
//StringBuilder builder = new StringBuilder(20);//可复用StringBuilder减少StringBuilder构造消耗
//var astr = a.ToString();
//builder.Append("Hello");
//builder.Append(astr);
//builder.Append(c);
//builder.Append(astr);
//builder.Append("World");
//builder.ToString();
#endregion