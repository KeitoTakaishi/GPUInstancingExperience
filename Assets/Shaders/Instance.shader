Shader "Custom/Instance" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HDR]
		_Color("color", color) = (1.0, 1.0, 1.0, 1.0)
	}

    CGINCLUDE
        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "AutoLight.cginc"

        struct Params
        {
            float3 emitPos;
            float3 position;
            float lifeTime;
        };

        StructuredBuffer<Params> buf;
        sampler _MainTex;
        float4x4 modelMatrix;
        float timer;
        
        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;
            float3 ambient : TEXCOORD1;
            float3 diffuse : TEXCOORD2;
            float3 color : TEXCOORD3;
            SHADOW_COORDS(4)
        };


        v2f vert(appdata_full v, uint id : SV_InstanceID)
        {
            Params p = buf[id];
            p.lifeTime = 3.0;
            float3 localPosition = v.vertex.xyz / 50.0+ p.position;

            //float3 localPosition = v.vertex.xyz * (modf(timer, p.lifeTime))/100.0 + p.position;

            float3 worldPosition = mul(unity_ObjectToWorld, float4(localPosition, 1.0));
            
            v2f o;
            o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
            return o;
        }
        
        fixed4 _Color;
        fixed4 frag(v2f i) : SV_Target
        {
        
            fixed4 output = _Color;
            return output;
         
        }
    ENDCG
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
        Pass
        {
		CGPROGRAM
		#pragma vertex vert 
		#pragma fragment frag
		#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
		#pragma target 5.0
		ENDCG
		}
	}
}
