Shader "Unlit/shader-05"//法线贴图
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        
        /*注解
        [_BumpMap]：对于法线纹理_BumpMap，使用"bump"作为其默认值，"bump"是Unity内置的法线纹理
        当没有提供任何法线纹理时，"bump"就对应了模型自带的法线信息。
        [_BumpScale]：_BumpScale则是用于控制凹凸程度的，当它为0时，意味着该法线纹理不会对光照产生任何影响
        */
    }

    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        //URP
        // Tags { "LightMode"="UniversalForward" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float4 tangent  : TANGENT;
                float4 texcoord : TEXCOORD0;
                /*注解
                [tangent]：tagent的类型是float4，因为我们需要使用tangent.w的分量来决定
                切线空间中的第三个坐标轴--副切线的方向性
                */
            };

            struct v2f
            {
                float4 pos      : SV_POSITION;
                float4 uv       : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir  : TEXCORRD2;
                /*注解
                [lightDir]和[viewDir]：我们需要在顶点着色器中计算切线空间下的光照和视角方向
                因此我们在v2f结构体中添加两个变量来存储变换后的光照和视角方向
                */
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算uv
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                //计算副切线
                //float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                //得到由模型空间到切线空间的变换矩阵
                //float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                //或者使用Unity内置宏
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //对法线贴图进行采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                //tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //使用漫反射贴图采样结果和颜色属性_Color的乘积作为反射率
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                //计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                //计算高光反射
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                //返回最终颜色：环境光+漫反射+高光反射
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}