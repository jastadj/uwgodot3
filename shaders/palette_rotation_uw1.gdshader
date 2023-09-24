shader_type canvas_item;

// 4 color palette rotator
uniform float speed_ms;
// water effect (4 sets of 4 colors, rotating down)
uniform vec4 color0;
uniform vec4 color1;
uniform vec4 color2;
uniform vec4 color3;
uniform vec4 color4;
uniform vec4 color5;
uniform vec4 color6;
uniform vec4 color7;
uniform vec4 color8;
uniform vec4 color9;
uniform vec4 color10;
uniform vec4 color11;
uniform vec4 color12;
uniform vec4 color13;
uniform vec4 color14;
uniform vec4 color15;
// fire effect group 1 (5 colors, rotating up)
uniform vec4 color16;
uniform vec4 color17;
uniform vec4 color18;
uniform vec4 color19;
uniform vec4 color20;
// fire effect group 2 (3 colors, rotating up)
uniform vec4 color21;
uniform vec4 color22;
uniform vec4 color23;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV); // get pixel color
	int cycle1 = int(TIME/(speed_ms*0.001))%4;
	int cycle2 = int(TIME/(speed_ms*0.001))%5;
	int cycle3 = int(TIME/(speed_ms*0.001))%3;
	
	const float precision = 0.01;
	
	// water effect
	if (cycle1 == 0)
	{
		// colors 0-3
		if (distance(current_color, color0) <= precision) current_color = color1;
		else if (distance(current_color, color1) <= precision) current_color = color2;
		else if (distance(current_color, color2) <= precision) current_color = color3;
		else if (distance(current_color, color3) <= precision) current_color = color4;
		
		// color 4-7
		else if (distance(current_color, color4) <= precision) current_color = color5;
		else if (distance(current_color, color5) <= precision) current_color = color6;
		else if (distance(current_color, color6) <= precision) current_color = color7;
		else if (distance(current_color, color7) <= precision) current_color = color4;
		
		// color 8-11
		else if (distance(current_color, color8) <= precision) current_color = color9;
		else if (distance(current_color, color9) <= precision) current_color = color10;
		else if (distance(current_color, color10) <= precision) current_color = color11;
		else if (distance(current_color, color11) <= precision) current_color = color8;
		
		// color 12-15
		else if (distance(current_color, color12) <= precision) current_color = color13;
		else if (distance(current_color, color13) <= precision) current_color = color14;
		else if (distance(current_color, color14) <= precision) current_color = color15;
		else if (distance(current_color, color15) <= precision) current_color = color12;
	}
	else if (cycle1 == 1)
	{
		// colors 0-3
		if (distance(current_color, color0) <= precision) current_color = color2;
		else if (distance(current_color, color1) <= precision) current_color = color3;
		else if (distance(current_color, color2) <= precision) current_color = color0;
		else if (distance(current_color, color3) <= precision) current_color = color1;
		
		// color 4-7
		else if (distance(current_color, color4) <= precision) current_color = color6;
		else if (distance(current_color, color5) <= precision) current_color = color7;
		else if (distance(current_color, color6) <= precision) current_color = color4;
		else if (distance(current_color, color7) <= precision) current_color = color5;
		
		// color 8-11
		else if (distance(current_color, color8) <= precision) current_color = color10;
		else if (distance(current_color, color9) <= precision) current_color = color11;
		else if (distance(current_color, color10) <= precision) current_color = color8;
		else if (distance(current_color, color11) <= precision) current_color = color9;
		
		// color 12-15
		else if (distance(current_color, color12) <= precision) current_color = color14;
		else if (distance(current_color, color13) <= precision) current_color = color15;
		else if (distance(current_color, color14) <= precision) current_color = color12;
		else if (distance(current_color, color15) <= precision) current_color = color13;
	}
	else if (cycle1 == 2)
	{
		// colors 0-3
		if (distance(current_color, color0) <= precision) current_color = color3;
		else if (distance(current_color, color1) <= precision) current_color = color0;
		else if (distance(current_color, color2) <= precision) current_color = color1;
		else if (distance(current_color, color3) <= precision) current_color = color2;
		
		// color 4-7
		else if (distance(current_color, color4) <= precision) current_color = color7;
		else if (distance(current_color, color5) <= precision) current_color = color4;
		else if (distance(current_color, color6) <= precision) current_color = color5;
		else if (distance(current_color, color7) <= precision) current_color = color6;
		
		// color 8-11
		else if (distance(current_color, color8) <= precision) current_color = color11;
		else if (distance(current_color, color9) <= precision) current_color = color8;
		else if (distance(current_color, color10) <= precision) current_color = color9;
		else if (distance(current_color, color11) <= precision) current_color = color10;
		
		// color 12-15
		else if (distance(current_color, color12) <= precision) current_color = color15;
		else if (distance(current_color, color13) <= precision) current_color = color12;
		else if (distance(current_color, color14) <= precision) current_color = color13;
		else if (distance(current_color, color15) <= precision) current_color = color14;
	}
	
	// fire effect group 1
	if (cycle2 == 0)
	{
		// colors 16-20
		if (distance(current_color, color16) <= precision) current_color = color20;
		else if (distance(current_color, color17) <= precision) current_color = color16;
		else if (distance(current_color, color18) <= precision) current_color = color17;
		else if (distance(current_color, color19) <= precision) current_color = color18;
		else if (distance(current_color, color20) <= precision) current_color = color19;
	}
	else if (cycle2 == 1)
	{
		// colors 16-20
		if (distance(current_color, color16) <= precision) current_color = color19;
		else if (distance(current_color, color17) <= precision) current_color = color20;
		else if (distance(current_color, color18) <= precision) current_color = color16;
		else if (distance(current_color, color19) <= precision) current_color = color17;
		else if (distance(current_color, color20) <= precision) current_color = color18;
	}
	else if (cycle2 == 2)
	{
		// colors 16-20
		if (distance(current_color, color16) <= precision) current_color = color18;
		else if (distance(current_color, color17) <= precision) current_color = color19;
		else if (distance(current_color, color18) <= precision) current_color = color20;
		else if (distance(current_color, color19) <= precision) current_color = color16;
		else if (distance(current_color, color20) <= precision) current_color = color17;
	}
	else if (cycle2 == 3)
	{
		// colors 16-20
		if (distance(current_color, color16) <= precision) current_color = color17;
		else if (distance(current_color, color17) <= precision) current_color = color18;
		else if (distance(current_color, color18) <= precision) current_color = color19;
		else if (distance(current_color, color19) <= precision) current_color = color20;
		else if (distance(current_color, color20) <= precision) current_color = color16;
	}
	
	// fire effect group 2
	// fire effect group 1
	if (cycle3 == 0)
	{
		// colors 21-23
		if (distance(current_color, color21) <= precision) current_color = color23;
		else if (distance(current_color, color22) <= precision) current_color = color21;
		else if (distance(current_color, color23) <= precision) current_color = color22;
	}
	if (cycle3 == 1)
	{
		// colors 21-23
		if (distance(current_color, color21) <= precision) current_color = color22;
		else if (distance(current_color, color22) <= precision) current_color = color23;
		else if (distance(current_color, color23) <= precision) current_color = color21;
	}
	
	COLOR = current_color;
}
