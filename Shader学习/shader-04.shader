Shader "Unlit/shader-04"//漫反射贴图
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos          : SV_POSITION;
                float3 worldNormal  : TEXCOORD0;
                float3 worldPos     : TEXCOORD1;
                float2 uv           : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            //得到纹理的缩放和偏移值，xy存储缩放值，zw存储偏移值
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(a2v v)
            {
                v2f o;
                //顶点变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线从模型空间变换到世界空间，已做归一化处理
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //顶点变换到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // o.uv = v.texcoord.xy * _MainTex.ST.XY + _MainTex_ST.zw;
                //使用unity内置宏计算uv
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                //计算世界空间中光源方向
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //使用漫反射贴图采样结果和颜色属性_Color的乘积作为材质的反射率
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(i.worldNormal, worldLightDir));
                //视角方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //计算光照方向和视角方向相加后再归一化的方向
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                //计算高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);
                //返回最终颜色：环境光 + 漫反射 + 高光反射
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}