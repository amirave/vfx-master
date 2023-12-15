float3x3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(
        float3(1, 0, 0),
        float3(0, c, -s),
        float3(0, s, c)
    );
}

// Rotation matrix around the Y axis.
float3x3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(
        float3(c, 0, s),
        float3(0, 1, 0),
        float3(-s, 0, c)
    );
}

// Rotation matrix around the Z axis.
float3x3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return float3x3(
        float3(c, -s, 0),
        float3(s, c, 0),
        float3(0, 0, 1)
    );
}

float ScaleFactor(float x)
{
    return abs(sin(x)+0.4*cos(x*3.14)+0.15*sin(x*5.756));
}

float3 RandomRotation(float time)
{
    float xTheta = time * 0.3 + 3.1492653 * 5;
    float yTheta = time * 0.7 + 3.1492653 * 2.3;
    float zTheta = time * 0.5 + 3.1492653 * 1.7;

    return float3(xTheta, yTheta, zTheta);
}

float3 RandomScale(float time)
{
    float scale = 1 - abs(sin(time)+0.4*cos(time*3.14)+0.15*sin(time*5.756));
    return float3(scale, scale, scale);
}

float4 TransformVertex(float4 vertex, float3 rotation, float3 scale)
{
    float3 v = vertex * scale;
    v = mul(rotateX(rotation.x), mul(rotateY(rotation.y), mul(rotateZ(rotation.z), v)));
    return float4(v.xyz, vertex.w);
}