shader_type canvas_item;

uniform int sides = 6;

// shader to draw polygon
// 2 # Combining powers
void fragment() {
	vec2 p = UV*2.0-1.0;
	
	float a = atan(p.x,p.y)+PI;
  	float r = TAU/float(sides);
	float d = cos(floor(0.5+a/r)*r-a)*length(p);
	
	COLOR = vec4(COLOR-smoothstep(.8,.8,d));
}
