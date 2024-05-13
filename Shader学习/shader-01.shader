Shader "Unlit/shader-01"
{
    // Properties
    // {
    //     _MainTex ("Texture", 2D) = "white" {}
    // }
    // SubShader
    // {
    //     Tags { "RenderType"="Opaque" }
    //     LOD 100

    //     Pass
    //     {
    //         CGPROGRAM
    //         #pragma vertex vert
    //         #pragma fragment frag
    //         // make fog work
    //         #pragma multi_compile_fog

    //         #include "UnityCG.cginc"

    //         struct appdata
    //         {
    //             float4 vertex : POSITION;
    //             float2 uv : TEXCOORD0;
    //         };

    //         struct v2f
    //         {
    //             float2 uv : TEXCOORD0;
    //             UNITY_FOG_COORDS(1)
    //             float4 vertex : SV_POSITION;
    //             float4 screenPos : TEXCOORD1;
    //         };

    //         sampler2D _MainTex;
    //         float4 _MainTex_ST;

    //         v2f vert (appdata v)
    //         {
    //             v2f o;
    //             o.vertex = UnityObjectToClipPos(v.vertex);
    //             o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    //             o.screenPos = ComputeScreenPos(o.vertex);
    //             UNITY_TRANSFER_FOG(o,o.vertex);
    //             return o;
    //         }

    //         fixed4 frag (v2f i) : SV_Target
    //         {
    //             // // sample the texture
    //             // fixed4 col = tex2D(_MainTex, i.uv);
    //             // // apply fog
    //             // UNITY_APPLY_FOG(i.fogCoord, col);
    //             // return col;

    //             float2 wcoord = (i.screenPos.xy / i.screenPos.w);
    //             return fixed4(wcoord, 0.0, 1.0);
    //         }
    //         ENDCG
    //     }
    // }

    //01-sample
    // Properties
    // {
    //     _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    // }

    // SubShader
    // {
    //     Pass
    //     {
    //         CGPROGRAM
    //         #pragma vertex vert
    //         #pragma fragment frag

    //         #include "UnityCG.cginc"

    //         fixed4 _Color;

    //         struct v2f {
    //             float4 pos : SV_POSITION;
    //             fixed3 color : COLOR0;
    //         };

    //         v2f vert(appdata_base v)
    //         {
    //             v2f o;
    //             o.pos = UnityObjectToClipPos(v.vertex);
    //             o.color = v.normal * 0.5 + 0.5;
    //             return o;
    //         }

    //         fixed4 frag(v2f i) : SV_TARGET
    //         {
    //             fixed3 c = i.color;
    //             c *= _Color.rgb;
    //             return fixed4(c, 1.0);
    //         }
    //         ENDCG
    //     }
    // }

    //02 false-color-image(debugger)
    // SubShader
    // {
    //     pass
    //     {
    //         CGPROGRAM
    //         #pragma vertex vert
    //         #pragma fragment frag

    //         #include "UnityCG.cginc" 

    //         struct v2f
    //         {
    //             float4 pos : SV_POSITION;
    //             fixed4 color : COLOR0;
    //         };

    //         v2f vert(appdata_full v)
    //         {
    //             v2f o;
    //             o.pos = UnityObjectToClipPos(v.vertex);
    //             //可视化法线方向
    //             o.color = fixed4(v.normal * 0.5 + 0.5, 1.0);
    //             //可视化切线方向
    //             o.color = fixed4(v.tangent * 0.5 + 0.5);
    //             //可视化第一组纹理坐标(左下角0,0 右上角1,1)
    //             o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
    //             //可视化第二组纹理坐标(左下角0,0 右上角1,1)
    //             o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);
    //             //可视化第三组纹理坐标(左下角0,0 右上角1,1)
    //             o.color = fixed4(v.texcoord2.xy, 0.0, 1.0);
    //             //可视化第四组纹理坐标(左下角0,0 右上角1,1)
    //             o.color = fixed4(v.texcoord3.xy, 0.0, 1.0);
    //             //可视化第一组纹理坐标小数部分
    //             o.color = frac(v.texcoord);//返回小数部分
    //             if (any(saturate(v.texcoord) - v.texcoord))
    //             {
    //                 o.color.b = 0.5;
    //             }
    //             o.color.a = 1.0;
    //             //可视化顶点颜色
    //             o.color = v.color;
    //             return o;
    //         }

    //         fixed4 frag(v2f i) : SV_TARGET
    //         {
    //             return i.color;
    //         }
    //         ENDCG
    //     }
    // }

    //03 chessboard
    Properties
    {
        [IntRange]_Scaling("Scaling", Range(1, 10)) = 10
        _Color("Color", Color) = (1, 1, 1, 1)
        _Color2("Color2", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex   : POSITION;
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 pos  : SV_POSITION;
                float2 uv   : TEXCOORD;
            };

            CBUFFER_START(UnityPerMaterial)
            float _Scaling; 
            fixed4 _Color;
            fixed4 _Color2;
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float2 repeatUV = i.uv * _Scaling;
                float2 c = floor(repeatUV) / 2;//小数部分只有0/0.5两种可能
                float checker = frac(c.x + c.y) * 2;//x+y小数部分只有0/0.5两种可能，x2映射到[0, 1]
                return lerp(_Color2, _Color, checker);
            }
            ENDCG
        }
    }
}
