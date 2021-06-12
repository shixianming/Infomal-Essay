/// <summary>
/// ��������
/// </summary>
private static void QuickSort(int[] arr, int left, int right)
{
    if (left < right)
    {
        int index = GetIndex(arr, left, right);
        QuickSort(arr, left, index - 1);
        QuickSort(arr, index + 1, right);
    }
}

/// <summary>
/// �õ���׼ֵ���±�
/// </summary>
/// <param name="arr"></param>
/// <param name="left"></param>
/// <param name="right"></param>
/// <returns></returns>
private static int GetIndex(int[] arr, int left, int right)
{
    int t = arr[left];//ȡ����±��Ӧ��ֵ��Ϊ��׼

    while (left < right)
    {
        while (arr[right] >= t && left < right)
        {
            right--;
        }
        arr[left] = arr[right];
        while (arr[left] <= t && left < right)
        {
            left++;
        }
        arr[right] = arr[left];
    }
    arr[left] = t;
    return left;
}

/// <summary>
/// ð������
/// </summary>
/// <param name="arr"></param>
private static void BubbleSort(int[] arr)
{
    for (int i = 0; i < arr.Length; i++)
    {
        for (int j = 0; j < arr.Length - 1; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

/// <summary>
/// ѡ������
/// </summary>
/// <param name="arr"></param>
private static void SelectSort(int[] arr)
{
    for (int i = 0; i < arr.Length - 1; i++)
    {
        for (int j = i + 1; j < arr.Length; j++)
        {
            if (arr[i] > arr[j])
            {
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
    }
}

/// <summary>
/// ��������
/// </summary>
private static void InsertSort(int[] arr)
{
    for (int i = 1; i < arr.Length; i++)
    {
        for (int j = i; j > 0; j--)
        {
            if (arr[j] < arr[j - 1])
            {
                int temp = arr[j];
                arr[j] = arr[j - 1];
                arr[j - 1] = temp;
            }
            else
            {
                break;
            }
        }
    }
}