//透明度混合
Shader "Unlit/shader-08"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProject"="True" "RenderType"="Transparent" }

        // Pass
        // {
        //     Tags { "LightMode"="ForwardBase" }
        //     ZWrite Off
        //     Blend SrcAlpha OneMinusSrcAlpha
        //     //OutColor = srcAlpha * srcColor + (1 - srcAlpha) * dstColorOld
        //     //OutAlpha = srcAlpha * srcColora + (1 - srcAlpha) * dstColora

        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "UnityCG.cginc"
        //     #include "Lighting.cginc"

        //     struct a2v
        //     {
        //         float4 vertex   : POSITION;
        //         float3 normal   : NORMAL;
        //         float2 texcoord : TEXCOORD0;
        //     };

        //     struct v2f
        //     {
        //         float4 pos         : SV_POSITION;
        //         float3 worldNormal : TEXCOORD0;
        //         float3 worldPos    : TEXCOORD1;
        //         float2 uv          : TEXCOORD2;
        //     };

        //     fixed4 _Color;
        //     sampler2D _MainTex;
        //     float4 _MainTex_ST;
        //     fixed _AlphaScale;

        //     v2f vert (a2v v)
        //     {
        //         v2f o;
        //         o.pos = UnityObjectToClipPos(v.vertex);
        //         o.worldNormal = UnityObjectToWorldNormal(v.normal);
        //         o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        //         o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         fixed3 worldNormal = i.worldNormal;
        //         fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        //         fixed4 texColor = tex2D(_MainTex, i.uv);
        //         //使用漫反射贴图采样结果和颜色属性_Color的乘积作为材质的反射率
        //         fixed3 albedo = texColor.rgb * _Color.rgb;
        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
        //         fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
        //         return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
        //     }
        //     ENDCG
        // }

        //透明度混合+双面渲染
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
            //OutColor = srcAlpha * srcColor + (1 - srcAlpha) * dstColorOld
            //OutAlpha = srcAlpha * srcColora + (1 - srcAlpha) * dstColora

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos         : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos    : TEXCOORD1;
                float2 uv          : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = i.worldNormal;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //使用漫反射贴图采样结果和颜色属性_Color的乘积作为材质的反射率
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            //OutColor = srcAlpha * srcColor + (1 - srcAlpha) * dstColorOld
            //OutAlpha = srcAlpha * srcColora + (1 - srcAlpha) * dstColora

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos         : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos    : TEXCOORD1;
                float2 uv          : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = i.worldNormal;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //使用漫反射贴图采样结果和颜色属性_Color的乘积作为材质的反射率
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}
