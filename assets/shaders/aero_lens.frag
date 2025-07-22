#include <flutter/runtime_effect.glsl>

// 输入纹理
uniform sampler2D uTexture;

// 尺寸和几何参数 (单位：逻辑像素)
uniform vec2 uSize;
uniform float uPadding;
uniform float uCornerRadius;
uniform float uSmoothness;

// 玻璃效果参数
uniform float uRefractiveIndex;
uniform float uChromaticAberration;
uniform float uDistortionStrength;
uniform float uDistortionSlope;

//玻璃色调和强度
uniform vec3 uGlassTint;
uniform float uGlassAlpha;

out vec4 fragColor;

// Inigo Quilez 的经典 2D 圆角矩形 Signed Distance Function (SDF)
float sdRoundedBox(in vec2 p, in vec2 b, in float r) {
    r = min(r, min(b.x, b.y));
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

void main() {
    // === 1. 坐标和 SDF 计算 (像素空间) ===
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = fragCoord / uSize;
    vec2 boxCenterPx = uSize / 2.0;
    vec2 boxHalfSizePx = boxCenterPx - uPadding;

    if (boxHalfSizePx.x < 0.0 || boxHalfSizePx.y < 0.0) {
        fragColor = texture(uTexture, uv);
        return;
    }

    vec2 p = fragCoord - boxCenterPx;
    float dist = sdRoundedBox(p, boxHalfSizePx, uCornerRadius);
    float alpha = 1.0 - smoothstep(-uSmoothness, uSmoothness, dist);

    if (alpha <= 0.0) {
        fragColor = texture(uTexture, uv);
        return;
    }

    // === 2. 玻璃效果计算 ===
    vec2 centerOffset = (uv - 0.5);
    float distortionFactor = clamp(dist / -max(boxHalfSizePx.x, boxHalfSizePx.y), 0.0, 1.0);
    float distortionGradient = pow(distortionFactor * uDistortionStrength, uDistortionSlope);
    vec2 distortedUv = (uv - 0.5) * (1.0 + (uRefractiveIndex - 1.0) * distortionGradient) + 0.5;

    vec2 caOffset = uChromaticAberration * centerOffset;
    vec3 col;
    col.r = texture(uTexture, distortedUv + caOffset).r;
    col.g = texture(uTexture, distortedUv).g;
    col.b = texture(uTexture, distortedUv - caOffset).b;

    // === 3. 光照效果 (修正版) ===

    vec3 highlightColor = vec3(0.7); // 使用白色作为高光颜色
    vec3 finalLight = vec3(0.0);

    // ## 第1层: 定向内部眩光 (复刻原版 'gradient') ##
    // 创建一个从中心向顶部/底部延伸的柔和辉光带
    // p.y 是当前片元距中心的垂直像素距离
    float glareBandHeight = boxHalfSizePx.y * 0.7; // 辉光带影响范围为半个高度
    
    // 顶部眩光: p.y 为负。从 0 到 -glareBandHeight 平滑过渡
    float topGlareFactor = smoothstep(0.0, -glareBandHeight*4, p.y);
    
    // 底部眩光: p.y 为正。从 0 到 glareBandHeight 平滑过渡
    float bottomGlareFactor = smoothstep(0.0, glareBandHeight*2, p.y);

    // 将顶部和底部眩光合并，并乘以一个基础强度
    float directionalGlare = (topGlareFactor + bottomGlareFactor) * 0.1;

    // ## 第2层: 边缘高光 (复刻原版 'rb2') ##
    // 使用 SDF 距离创建一个紧贴边缘的、更亮的反射效果
    // smoothstep 在距离边缘 -1px 到 -8px 的区域内创建一条高光带
    float rimBand = smoothstep(-0.0, -8.0, dist) - smoothstep(-5.0, -25.0, dist);
    float specularRim = rimBand * 0.04; // 设置高光强度

    // ## 组合光照 ##
    // 将两层光照效果叠加
    finalLight = highlightColor * (directionalGlare + specularRim);


    // === 4. 玻璃色调混合 ===
    
    col = mix(col, uGlassTint, uGlassAlpha);
    col += finalLight;

    // 将光照添加到折射后的颜色上
    

    // === 4. 最终混合 ===
    vec4 glassColor = vec4(col, 1.0);
    vec4 backgroundColor = texture(uTexture, uv);

    fragColor = clamp(mix(backgroundColor, glassColor, alpha), 0.0, 1.0);
}