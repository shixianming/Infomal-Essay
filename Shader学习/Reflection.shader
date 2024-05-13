Shader "Unlit/Reflection"//环境反射效果
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1)//控制反射颜色
        _ReflectAmount ("Reflection Amount", Range(0, 1)) = 1//控制反射程度
        _Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}//模拟反射的环境映射纹理
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefl : TEXCOORD3;
                //定义阴影坐标，使用第4套纹理坐标
                SHADOW_COORDS(4)
            };

            fixed4 _Color;
            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                //顶点从模型空间变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线从模型空间变换到世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //顶点从模型空间变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //从世界空间中计算视角方向（指向摄像机）
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                //计算反射方向，由于视角方向的指向和cg中相反，所以需要反向再传入
                o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
                //计算阴影坐标，并传入像素着色器
                TRANSFER_SHADOW(O);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = i.worldNormal;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                //环境反射
                fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;
                //计算光照衰减和阴影相乘后的结果
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                //计算最终颜色
                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
