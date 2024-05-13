Shader "Unlit/shader-03"//高光反射实现
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(8, 256)) = 20
    }

    //高光反射(Phone模型)：specular = lightColor * specularColor * max(0, dot(viewDir, reflectDir))^gloss
    //lightColor-光源颜色 specularColor-高光反射颜色 viewDir-视角方向 reflectDir-反射方向 gloss-光泽度，用于控制高光区域大小，值越大高光区域越小
    //在shader入门精要中光照方向指向光源
    //此时：reflectDir + incidence = 2 * dot(incidence, normal) * normal => reflectDir = 2 * dot(incidence, normal) * normal - incidence
    //在cg中光照方向指向入射点
    //此时：reflectDir - incidence = -2 * dot(incidence, normal) * normal => reflectDir = incidence - 2 * dot(incidence, normal) * normal
    //而unity中取得的光照方向是指向光源的，所以使用reflect函数时需要取反传入
    //高光反射(Blinn-Phone模型)：specular = lightColor * specularColor * max(0, dot(normalDir, halfDir))^gloss
    //lightColor-光源颜色 specularColor-高光反射颜色 halfDir-Blinn引入的新的矢量，是视角方向和光照方向相加后再归一化得到 gloss-光泽度
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        //URP
        // Tags { "LightMode"="UniversalForward" }

        //逐顶点光照的高光反射-Phone模型
        // Pass
        // {
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "UnityCG.cginc"
        //     #include "Lighting.cginc"

        //     struct a2v
        //     {
        //         float4 vertex : POSITION;
        //         float3 normal : NORMAL;
        //     };

        //     struct v2f
        //     {
        //         float4 pos   : SV_POSITION;
        //         fixed3 color : COLOR0;
        //     };

        //     CBUFFER_START(UnityPerMaterial)
        //     fixed4 _Diffuse;
        //     fixed4 _Specular;
        //     float _Gloss;
        //     CBUFFER_END

        //     v2f vert(a2v v)
        //     {
        //         v2f o;
        //         //顶点变换到裁剪空间
        //         o.pos = UnityObjectToClipPos(v.vertex);
        //         //法线变换到世界空间，并做归一化处理
        //         fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
        //         //入射光做归一化处理
        //         fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        //         //计算漫反射
        //         fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
        //         //环境光
        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
        //         //反射方向
        //         fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
        //         //视角方向 指向视角方向所以用相机位置减去模型位置
        //         fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
        //         //计算高光反射
        //         //pow(x, y)是以x为底的y次方运算，用在此处相当于对[0, 1]做_Gloss次方运算
        //         //0的多少次方都是0，1的多少次方都是1，其它值_Gloss越大，结果越小，用来控制高光部分的区域大小
        //         fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir, reflectDir)), _Gloss);
        //         o.color = diffuse + ambient + specular;
        //         return o;
        //     }

        //     fixed4 frag(v2f i) : SV_TARGET
        //     {
        //         return fixed4(i.color, 1.0);
        //     }
        //     ENDCG
        // }

        //逐像素光照的高光反射-Phone模型
        // Pass
        // {
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "UnityCG.cginc"
        //     #include "Lighting.cginc"

        //     struct a2v
        //     {
        //         float4 vertex : POSITION;
        //         float3 normal : NORMAL;
        //     };

        //     struct v2f
        //     {
        //         float4 pos         : SV_POSITION;
        //         float3 worldNormal : TEXCOORD0;
        //         float3 worldPos    : TEXCOORD1;
        //     };

        //     CBUFFER_START(UnityPerMaterial)
        //     fixed4 _Diffuse;
        //     fixed4 _Specular;
        //     float _Gloss;
        //     CBUFFER_END

        //     v2f vert(a2v v)
        //     {
        //         v2f o;
        //         o.pos = UnityObjectToClipPos(v.vertex);
        //         o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
        //         o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        //         return o;
        //     }

        //     fixed4 frag(v2f i) : SV_TARGET
        //     {
        //         //环境光
        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
        //         //法线归一化处理
        //         fixed3 worldNormal = normalize(i.worldNormal);
        //         //入射光做归一化处理
        //         fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        //         //计算漫反射
        //         fixed3 lambert = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
        //         //计算漫反射，采用半兰伯特
        //         // fixed3 halfLambert = _LightColor0.rgb * _Diffuse * (dot(i.worldNormal, worldLight) * 0.5 + 0.5);
        //         //反射方向
        //         fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
        //         //视角方向
        //         fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
        //         //高光反射
        //         fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir, reflectDir)), _Gloss);
        //         return fixed4(lambert + ambient + specular, 1.0);
        //     }
        //     ENDCG
        // }

        //逐像素光照的高光反射-Blinn-Phone模型
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos          : SV_POSITION;
                float3 worldNormal  : TEXCOORD0;
                float3 worldPos     : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                //使用unity内置函数替换
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                //法线归一化
                fixed3 worldNormal = normalize(i.worldNormal);
                //光源方向归一化
                // fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                //视角方向
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //half dir
                fixed3 halfDir = normalize(viewDir + worldLight);
                //高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}