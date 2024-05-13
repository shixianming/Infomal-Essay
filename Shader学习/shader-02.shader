Shader "Unlit/shader-02"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
    }

    //Lambert：C(diffuse) = (Clight·mdiffuse)max(0, n·I)
    //         diffuse = lightcolor * diffusecolor * max(0, dot(normal, lightdit))
    //n--表面法线 I--光源的单位矢量 mdiffuse--材质的漫反射颜色 clight--光源颜色符号
    //half lambert: diffuse = lightcolor * diffusecolor * (dot(normal, lightdir) * 0.5 + 0.5)
    SubShader
    {
        Tags { "LightMode"="UniversalForward" }
        //逐顶点光照的漫反射
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
        //         fixed3 color : COLOR;
        //     };

        //     CBUFFER_START(UnityPerMaterial)
        //     fixed4 _Diffuse;
        //     CBUFFER_END

        //     v2f vert(a2v v)
        //     {
        //         v2f o;
        //         //transform vertex from object space to clip space
        //         o.pos = UnityObjectToClipPos(v.vertex);
        //         //transform normal from object space to world space
        //         //法线变化矩阵由normal*v = 0 => normal*M-1*M*v = 0求证
        //         //式一为法线*平面任意一点为0，插入M-1M单位矩阵上式同样满足
        //         //而M*v可见平面任意一点由模型空间变化到其它空间，同理要将法线也变化到其它空间需要右乘变化矩阵的逆矩阵
        //         //切由于向量平移无意义，只需要取矩阵的前三行三列即可
        //         fixed3 wolrdNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
        //         //得到环境光
        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        //         //入射光方向归一化
        //         fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        //         //公式diffuse = 入射光颜色 * 材质漫反射颜色 * (法线·入射光方向)
        //         //由于法线和入射光方向都做了归一化处理，此时点乘的结果就是cos夹角的值，为防止结果为负值使用saturate函数处理
        //         fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(wolrdNormal, worldLight));
        //         //最终结果加上环境光
        //         o.color = ambient + diffuse;
        //         return o;
        //     }

        //     fixed4 frag(v2f i) : SV_TARGET
        //     {
        //         return fixed4(i.color, 1.0);
        //     }
        //     ENDCG
        // }

        //逐像素光照
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
                float4 pos         : SV_POSITION;
                float3 worldNormal : TEXCOORD;
            };

            CBUFFER_START(UnityPerMaterial)
            fixed4 _Diffuse;
            CBUFFER_END

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, unity_WorldToObject);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                //normalize normal
                fixed3 worldNormal = normalize(i.worldNormal);
                //normalize light dir
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                //diffuse color
                // fixed3 c = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal, worldLight));
                //half lambert
                fixed3 c = _LightColor0.rgb * _Diffuse * (dot(worldNormal, worldLight) * 0.5 + 0.5);
                //add ambient color
                c += UNITY_LIGHTMODEL_AMBIENT.xyz;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
