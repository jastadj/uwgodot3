shader_type canvas_item;

uniform int tile_type;

void fragment() {

	// diagonal, open NE
	if(UV.x <= UV.y && tile_type == 0x04)
	{
		COLOR = vec4(0,0,0,0);
	}
	// diagonal, open SW
	else if(UV.x >= UV.y && tile_type == 0x03)
	{
		COLOR = vec4(0,0,0,0);
	}
	// diagonal, open SE
	else if(1.0 - UV.x >= UV.y && tile_type == 0x02)
	{
		COLOR = vec4(0,0,0,0);
	}
	// diagonal, open NW
	else if(1.0 - UV.x <= UV.y && tile_type == 0x05)
	{
		COLOR = vec4(0,0,0,0);
	}
	else if(tile_type == 0x00)
	{
		COLOR = vec4(0,0,0,0);
	}
}
