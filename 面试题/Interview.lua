print("----------测试type的含义----------")
print(type(type))
print(type(true))
print(type(nil))
print("10" + 1)

print("----------测试ipairs和pairs的区别----------")
local a = {"Hello", "World", a = 1, b = 2, x = 10, y = 20, "Good"}
function Test1()
    for i, v in ipairs(a) do
        print(i, v)
    end
    
    print("")

    for i, v in pairs(a) do
        print(i, v)
    end
end
Test1()

print("----------测试lua可变参数函数----------")
function Test2(...)
    --用迭代器遍历可变参数
    -- local args = {...}
    -- print(string.format("可变参数个数：%s", #args))
    -- for i, v in ipairs(args) do
    --     print(v)
    -- end

    --用select获取参数
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        print("arg：" , arg)
    end
end
Test2(1, 2, 3)
