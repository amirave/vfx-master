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

float3x3 rotate(float3 radians)
{
	return mul(rotateX(radians.x), mul(rotateY(radians.y), rotateZ(radians.z)));
}