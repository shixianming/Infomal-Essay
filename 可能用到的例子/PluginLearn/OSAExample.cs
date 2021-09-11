using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using Com.TheFallenGames.OSA.Core;
using Com.TheFallenGames.OSA.DataHelpers;
using Com.TheFallenGames.OSA.CustomParams;
using frame8.Logic.Misc.Other.Extensions;

public class OSAExample : OSA<CustomParamsWithPrefab, CustomItemViewsHolder>
{
    /// <summary>
    /// 存储所有的单元数据（增，删，改）
    /// </summary>
    public SimpleDataHelper<CustomItemViewsHolderData> Data { get; private set; }

    protected override void Start()
    {
        Data = new SimpleDataHelper<CustomItemViewsHolderData>(this);
        base.Start();
    }

    /// <summary>
    /// 创建单元
    /// </summary>
    /// <param name="itemIndex"></param>
    /// <returns></returns>
    protected override CustomItemViewsHolder CreateViewsHolder(int itemIndex)
    {
        var instance = new CustomItemViewsHolder();
        instance.Init(_Params.ItemPrefab, _Params.Content, itemIndex);

        return instance;
    }

    /// <summary>
    /// 更新数据到单元
    /// </summary>
    /// <param name="newOrRecycled"></param>
    protected override void UpdateViewsHolder(CustomItemViewsHolder newOrRecycled)
    {
        var data = Data[newOrRecycled.ItemIndex];
        newOrRecycled.UpdateFromModle(data);
    }

    /// <summary>
    /// 返回单元要变化的尺寸（base.ForceRebuildViewsHolder由LayoutRebuilder.ForceRebuildLayoutImmediate强制刷新布局获得正确尺寸）
    /// 返回的尺寸 => 记录到OSA.ItemDesciptor.sizeInfo => CorrectPositions取得sizeInfo.size => 
    /// SetInsetAndSizeFromParentEdgeWithCurrentAnchors => RectTransform.SetInsetAndSizeFromParentEdge改变尺寸
    /// 记录一个距父边距的值，每改变一个单元的尺寸该值加上该单元的尺寸加spacing由此每个单元的尺寸和位置设置完毕
    /// ComputeVisibilityTwinPass函数会遍历所有的单元获得单元的尺寸（水平返回宽，垂直返回高）
    /// </summary>
    /// <param name="viewsHolder"></param>
    /// <returns></returns>
    protected override float ForceRebuildViewsHolder(CustomItemViewsHolder viewsHolder)
    {
        return base.ForceRebuildViewsHolder(viewsHolder);
        //不使用LayoutRebuild重建，自定义单元尺寸
    }

    /// <summary>
    /// 在UpdateItemSizeOnTwinPass后调用，此时单元尺寸并没有更新
    /// </summary>
    /// <param name="viewsHolder"></param>
    protected override void OnItemHeightChangedPreTwinPass(CustomItemViewsHolder viewsHolder)
    {
        base.OnItemHeightChangedPreTwinPass(viewsHolder);
    }

    /// <summary>
    /// 在UpdateItemSizeOnTwinPass后调用，此时单元尺寸并没有更新
    /// </summary>
    /// <param name="viewsHolder"></param>
    protected override void OnItemWidthChangedPreTwinPass(CustomItemViewsHolder viewsHolder)
    {
        base.OnItemWidthChangedPreTwinPass(viewsHolder);
    }

    /// <summary>
    /// 设置数据集合
    /// </summary>
    /// <param name="datas"></param>
    public void SetItems(IList<CustomItemViewsHolderData> datas)
    {
        Data.ResetItems(datas);
    }

    /// <summary>
    /// 插入一个数据集合到当前集合
    /// </summary>
    /// <param name="datas"></param>
    public void AddItemsAtStart(IList<CustomItemViewsHolderData> datas)
    {
        Data.InsertItemsAtStart(datas);
    }

    /// <summary>
    /// 追加一个数据集合到当前数据集合
    /// </summary>
    /// <param name="datas"></param>
    public void AddItemsAtEnd(IList<CustomItemViewsHolderData> datas)
    {
        Data.InsertItemsAtEnd(datas);
    }

    /// <summary>
    /// 插入一个数据到当前数据集合
    /// </summary>
    /// <param name="data"></param>
    public void AddItemAtStart(CustomItemViewsHolderData data)
    {
        Data.InsertOneAtStart(data);
    }
    
    /// <summary>
    /// 追加一个数据到当前数据集合
    /// </summary>
    /// <param name="data"></param>
    public void AddItemAtEnd(CustomItemViewsHolderData data)
    {
        Data.InsertOneAtEnd(data);
    }
}

/// <summary>
/// 滑动列表参数
/// </summary>
public class CustomParamsWithPrefab : BaseParamsWithPrefab
{

}

/// <summary>
/// 滑动列表单元
/// 不继承MonoBehaviour所以组件需要用GetComponent等API去获取
/// </summary>
public class CustomItemViewsHolder : BaseItemViewsHolder
{
    /// <summary>
    /// 标题
    /// </summary>
    private Text m_MessageText;

    /// <summary>
    /// 背景
    /// </summary>
    private Image m_BackgroundImage;

    /// <summary>
    /// 单元尺寸
    /// </summary>
    public float ItemSize { get; private set; }

    /// <summary>
    /// 创建单元时调用，初始化UI组件的引用，该函数的调用控制在Init函数中
    /// </summary>
    public override void CollectViews()
    {
        base.CollectViews();
        root.GetComponentAtPath("Text", out m_MessageText);
        root.GetComponentAtPath("Image", out m_BackgroundImage);
    }

    public override void MarkForRebuild()
    {
        base.MarkForRebuild();
        //TODO 启动Layout布局
    }

    public override void UnmarkForRebuild()
    {
        //TODO 关闭Layout布局
        base.UnmarkForRebuild();
    }

    /// <summary>
    /// 单元更新--可重载函数增加其它数据（如在CustomParamsWithPrefab添加其它参数传递至该单元）
    /// 每次更新都会遍历所有单元，所以用某个标识来判断该单元的数据是否需要更新
    /// </summary>
    /// <param name="data">数据</param>
    public void UpdateFromModle(CustomItemViewsHolderData data)
    {
        if (m_MessageText.text != data.message)
        {
            m_MessageText.text = $"#{ItemIndex.ToString()}--{data.message}";
            m_BackgroundImage.color = data.color;
            //确定数据更新后该单元的尺寸
            //若不想计算可添加Layout组件并调用base.ForceRebuildViewsHolder强制刷新布局获得单元的尺寸
            //并在MarkForRebuild和UnmarkForRebuild两个函数中控制Layout布局的启用和禁用以减小消耗
            ItemSize = Random.Range(40f, 100f);
        }
    }
}

/// <summary>
/// 滑动列表单元的数据（是滑动列表更新单元的数据载体）
/// </summary>
public class CustomItemViewsHolderData
{
    public string message;

    public Color color;
}
